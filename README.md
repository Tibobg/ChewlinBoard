# ChewlinBoard

Application mobile Flutter pour la création et la vente de skateboards décoratifs personnalisés, avec un back-office admin complet pour gérer commandes et stock.

## Fonctionnalités

**Côté client**
- Compte utilisateur (Firebase Auth), catalogue de planches
- Personnalisation d'une planche (deck, motifs) avec **aperçu 3D** du modèle personnalisé
- Sélection d'une date de livraison (calendrier) et paiement (Stripe)
- Messagerie directe avec moi pour suivre ou ajuster une commande
- Export de ses propres données (bouton dédié, dans l'esprit RGPD)

**Côté admin** (back-office séparé dans l'app)
- Gestion des commandes, du stock, du catalogue
- Chat avec les clients
- Statistiques de vente

## Stack

- **Client** : Flutter
- **Backend** : Firebase (Auth, Firestore, Storage, App Check) + Cloud Functions (voir `functions/`)
- **Paiement** : Stripe
- **3D** : `model_viewer_plus` pour la prévisualisation de la planche personnalisée

## Architecture

```
lib/
├─ pages/            # parcours client : catalogue, personnalisation, commande, livraison, compte
├─ pagesAdmin/        # back-office : commandes, stock, stats, chat admin
├─ services/          # auth_service, order_service
├─ repositories/       # user_repository, project_repository
├─ core/              # firebase_refs.dart (accès centralisé Firestore/Storage)
└─ widgets/           # calendrier de disponibilité, galerie, header
functions/            # Cloud Functions (Node.js)
```

## Lancer le projet

```bash
flutter pub get
flutter run
```

Nécessite un projet Firebase configuré (`google-services.json` fourni pour Android — c'est une config client publique, pas un secret ; voir la [doc Firebase](https://firebase.google.com/docs/projects/api-keys)) et des clés Stripe côté Cloud Functions pour le paiement.

## Ce que j'ai appris

- Structurer une seule app Flutter avec deux parcours complètement séparés (client / admin) plutôt que deux projets.
- Intégrer un aperçu 3D en temps réel de la personnalisation avant achat.
- Mettre en place un vrai tunnel de paiement (Stripe) avec suivi de commande et messagerie, pas juste un catalogue statique.
