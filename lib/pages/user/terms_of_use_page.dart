import 'package:flutter/material.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions Générales d’Utilisation')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(child: TermsContent()),
      ),
    );
  }
}

class TermsContent extends StatelessWidget {
  const TermsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SectionTitle('1. Introduction'),
        SectionText(
          'Bienvenue sur ChewLinBoard. En utilisant cette application, vous acceptez les présentes Conditions Générales d’Utilisation (CGU).',
        ),
        SizedBox(height: 16),

        SectionTitle('2. Utilisation de l’application'),
        SectionText(
          'L’application permet la création et la commande de planches personnalisées. Toute utilisation abusive est interdite.',
        ),
        SizedBox(height: 16),

        SectionTitle('3. Propriété intellectuelle'),
        SectionText(
          'Tous les contenus générés ou fournis par ChewLinBoard, y compris les designs de planches, sont protégés par le droit d’auteur.',
        ),
        SizedBox(height: 16),

        SectionTitle('4. Données personnelles'),
        SectionText(
          'Les données utilisateurs sont utilisées uniquement dans le cadre du fonctionnement de l’application. Aucune donnée n’est partagée à des tiers sans consentement.',
        ),
        SizedBox(height: 16),

        SectionTitle('5. Commandes et paiements'),
        SectionText(
          'Toute commande validée est considérée comme ferme. Les paiements sont sécurisés via notre prestataire Stripe.',
        ),
        SizedBox(height: 16),

        SectionTitle('6. Messagerie'),
        SectionText(
          'La messagerie intégrée est destinée aux échanges entre le client et l’administrateur. Aucun abus ne sera toléré.',
        ),
        SizedBox(height: 16),

        SectionTitle('7. Modification des CGU'),
        SectionText(
          'ChewLinBoard se réserve le droit de modifier les CGU à tout moment. Les utilisateurs seront notifiés via l’application.',
        ),
        SizedBox(height: 16),

        SectionTitle('8. Contact'),
        SectionText(
          'Pour toute question, contactez-nous à chewlinboard@gmail.com.',
        ),
        SizedBox(height: 32),
        Text(
          'Dernière mise à jour : 31 mai 2025',
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class SectionText extends StatelessWidget {
  final String text;
  const SectionText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16));
  }
}
