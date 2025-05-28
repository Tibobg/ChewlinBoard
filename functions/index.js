const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
const { Storage } = require('@google-cloud/storage');
const sharp = require('sharp');
const path = require('path');
const os = require('os');
const fs = require('fs');

admin.initializeApp();
const storage = new Storage();

exports.onNewSkateboardUpload = functions
  .region('europe-west1')
  .storage
  .object()
  .onFinalize(async (object) => {
    const filePath = object.name; // ex: skateboards_fini/planche_90.jpg
    if (!filePath.startsWith('skateboards_fini/')) return;

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
      .resize({ width: 500 })
      .toFile(path.join(os.tmpdir(), 'thumb_' + fileName));

    // Upload miniature vers Firebase Storage
    await bucket.upload(path.join(os.tmpdir(), 'thumb_' + fileName), {
      destination: thumbPath,
      metadata: metadata,
    });

    // Générer URLs signées
    const [imageUrl] = await bucket.file(filePath).getSignedUrl({
      action: 'read',
      expires: Date.now() + 365 * 24 * 60 * 60 * 1000,
    });

    const [thumbUrl] = await bucket.file(thumbPath).getSignedUrl({
      action: 'read',
      expires: Date.now() + 365 * 24 * 60 * 60 * 1000,
    });

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

    console.log(`✅ Document Firestore créé pour ${fileName}`);
    fs.unlinkSync(tempFilePath);
    fs.unlinkSync(path.join(os.tmpdir(), 'thumb_' + fileName));
  });