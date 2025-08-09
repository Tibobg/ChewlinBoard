const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
const { Storage } = require('@google-cloud/storage');
const sharp = require('sharp');
const path = require('path');
const os = require('os');
const fs = require('fs');
const stripe = require('stripe')(functions.config().stripe.secret);

admin.initializeApp();
const storage = new Storage();

exports.onNewSkateboardUpload = functions
  .region('europe-west1')
  .storage
  .object()
  .onFinalize(async (object) => {
    const filePath = object.name;
    if (!filePath.startsWith('skateboards_fini/')) return;

        if (filePath.includes('thumbs/')) {
      console.log('🛑 Miniature détectée, on ignore.');
      return;
    }

    const fileName = path.basename(filePath);
    const bucket = storage.bucket(object.bucket);
    const tempFilePath = path.join(os.tmpdir(), fileName);
    const thumbPath = `skateboards_fini/thumbs/${fileName}`;
    const metadata = {
      contentType: object.contentType,
    };

    // Télécharger le fichier temporairement
    await bucket.file(filePath).download({ destination: tempFilePath });

    // Créer une version compressée (500px largeur max)
    await sharp(tempFilePath)
      .rotate()
      .resize({ width: 500 })
      .toFile(path.join(os.tmpdir(), 'thumb_' + fileName));

    // Upload miniature vers Firebase Storage
    await bucket.upload(path.join(os.tmpdir(), 'thumb_' + fileName), {
      destination: thumbPath,
      metadata: metadata,
    });

    // Générer URLs image
    const imageUrl = `https://firebasestorage.googleapis.com/v0/b/chewlinboard-7a16f.firebasestorage.app/o/${encodeURIComponent(filePath)}?alt=media`;
    const thumbUrl = `https://firebasestorage.googleapis.com/v0/b/chewlinboard-7a16f.firebasestorage.app/o/${encodeURIComponent(thumbPath)}?alt=media`;

    const fileNameNoExt = fileName.split('.').slice(0, -1).join('.');
    const priceMatch = fileNameNoExt.match(/_(\d+)/);
    const price = priceMatch ? `${priceMatch[1]}€` : 'À définir';

    await admin.firestore().collection('skateboards').add({
      imageUrl,
      thumbUrl,
      title: fileNameNoExt,
      price,
      isSold: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    fs.unlinkSync(tempFilePath);
    fs.unlinkSync(path.join(os.tmpdir(), 'thumb_' + fileName));
  });

exports.createStripeSession = functions
  .region('europe-west1')
  .https
  .onRequest(async (req, res) => {
    try {
      const {
        skateboardId,
        imageUrl,
        price,
        buyerName,
        email,
        phone,
        address,
      } = req.body;    
      console.log('➡️ Requête reçue :', req.body);

      const numericPrice = parseFloat(price.toString().replace('€', '').trim());

      if (isNaN(numericPrice)) {
        throw new Error('Le prix reçu n’est pas un nombre valide');
      }

      if (!skateboardId || !price || !email || !buyerName) {
        return res.status(400).json({ error: 'Données manquantes' });
      }

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        customer_email: email,
        line_items: [
          {
            price_data: {
              currency: 'eur',
              product_data: {
                name: 'Planche ChewLinBoard',
                description: `Custom par ${buyerName}`,
                images: [imageUrl],
              },
              unit_amount: Math.round(numericPrice * 100),
            },
            quantity: 1,
          },
        ],
        mode: 'payment',
        success_url: 'https://chewlinboard.com/success',
        cancel_url: 'https://chewlinboard.com/cancel',
        metadata: {
          skateboardId,
          buyerName,
          phone,
          address,
        },
      });

      res.status(200).json({ checkoutUrl: session.url });
    } catch (err) {
      console.error('🔥 Erreur Stripe :', err);
      res.status(500).json({ error: 'Erreur interne Stripe' });
    }
  });
exports.markSkateboardAsSold = functions.region('europe-west1').https.onRequest(async (req, res) => {
  try {
    const { skateboardId } = req.body;

    if (!skateboardId) {
      return res.status(400).json({ error: 'ID manquant' });
    }

    const docRef = admin.firestore().collection('skateboards').doc(skateboardId);

    await docRef.update({
      isSold: true,
      soldAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).json({ message: 'Statut mis à jour' });
  } catch (err) {
    console.error('🔥 Erreur Firestore:', err);
    res.status(500).json({ error: 'Erreur lors de la mise à jour du statut' });
  }
});

const { google } = require('googleapis');

const config = functions.config();

if (!config.google || !config.google.client_id || !config.google.client_secret || !config.google.refresh_token) {
  console.error("❌ Configuration Google OAuth manquante.");
  throw new Error("Google OAuth configuration manquante");
}

const oauth2Client = new google.auth.OAuth2(
  config.google.client_id,
  config.google.client_secret,
  'https://developers.google.com/oauthplayground'
);

oauth2Client.setCredentials({
  refresh_token: functions.config().google.refresh_token,
});

const express = require('express');
const cors = require('cors');
const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

exports.addAgendaEvent = functions
  .region('europe-west1')
  .https
  .onRequest(async (req, res) => {
    try {
      const { startDate, username } = req.body;
      if (!startDate || !username) {
        return res.status(400).json({ error: 'startDate et username sont requis' });
      }

      const delivery = new Date(startDate);

      const start = new Date(delivery);
      start.setDate(start.getDate() - 21);

      // ⚠️ Google Calendar: end.date est EXCLUSIVE.
      // Pour bloquer jusqu’au jour de livraison inclus, on met end = delivery + 1 jour.
      const end = new Date(delivery);
      end.setDate(end.getDate() + 1);

      // helper pour n’avoir que la partie YYYY-MM-DD
      const ymd = d => d.toISOString().split('T')[0];

      const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

      await calendar.events.insert({
        calendarId: 'chewlincorp@gmail.com',
        requestBody: {
          summary: `skateboard ${username}`,
          start: { date: ymd(start), timeZone: 'Europe/Paris' },
          end:   { date: ymd(end),   timeZone: 'Europe/Paris' },
        },
      });

      return res.status(200).json({ success: true });
    } catch (error) {
      console.error('❌ Erreur Agenda Google:', error);
      return res.status(500).json({ error: 'Erreur interne Google Agenda' });
    }
  });


