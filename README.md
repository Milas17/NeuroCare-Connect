# NeuroCare Connect — Flutter App

Monorepo **template** d’application Flutter pour la plateforme NeuroCare Connect (téléneurologie, VSL/transport médicalisé, EEG/ENMG, Academy/webinaires, suivi à domicile, boutique).  
Architecture modulaire, **Riverpod** pour l’état & **GoRouter** pour la navigation.

> **Important :** Ce dépôt contient le code **Flutter** (lib/, pubspec.yaml, assets) + CI GitHub.  
> Pour générer les dossiers plateformes (android/ ios/ web/ macos/ windows/ linux/), lancez `flutter create .` **une seule fois** à la racine.

---

## Installation

1. Installez Flutter (>=3.19 recommandé).
2. Clonez ce repo ou dézippez-le.
3. À la racine du projet :
   ```bash
   flutter create .   # génère android/ ios/ web/ etc. (ne supprime pas lib/ ni pubspec.yaml)
   flutter pub get
   flutter run -d windows|macos|linux|chrome|android|ios
   ```

## Build APK local
```bash
flutter build apk --release
```

## CI GitHub (APK)
- Un workflow `.github/workflows/flutter-ci.yml` construit l’APK de release à chaque push sur `main` (Android).
- L’artefact se trouve dans l’onglet “Actions” de GitHub.

## Modules inclus (démos stubs)
- **Auth** : sélection de rôle (Patient / Médecin / Régulateur / Conducteur)
- **Dashboard** (selon rôle)
- **Telemed** : liste des médecins, prise de rendez-vous, mes rendez-vous (données mockées)
- **HomeCare** : demande de soins à domicile / suivi post‑hospitalisation (mock)
- **Transport (VSL)** : demande & suivi de transport (mock)
- **EEG/ENMG** : téléversement de fichiers EDF/PDF/ZIP (mock) et liste d’examens
- **Academy** : webinaires/événements (mock)
- **Shop** : produits (ex : huiles, équipements), panier (mock)
- **Settings** : langue (FR/EN), thème, profil (mock)

> Tout est **offline-first** (mémoire). Connectez vos API plus tard via `core/repositories/*_repository.dart`.

## Personnalisation & backends
- Points d’intégration : `core/repositories/*.dart` & `core/services/*.dart`.
- Exemple : remplacez les `InMemory*Repository` par des implémentations **REST (Dio)**, **Supabase**, **Firebase**, etc.

## Internationalisation
- FR & EN simples via une classe utilitaire `AppStrings`.
- Pour i18n avancée : Flutter gen-l10n.

## Sécurité & RGPD (à faire)
- Auth réelle (JWT/OAuth), chiffrement, protection données patients.
- Consentements, mentions légales, journalisations conformes.

## Structure
```
lib/
  main.dart
  app.dart
  router.dart
  theme.dart
  strings.dart
  core/
    app_state.dart
    models/...
    repositories/...
    services/...
  features/
    auth/...
    dashboard/...
    telemed/...
    homecare/...
    transport/...
    eeg_enmg/...
    academy/...
    shop/...
    settings/...
assets/
  images/
  data/
.github/workflows/flutter-ci.yml
pubspec.yaml
```

---

## Feuille de route (suggestion)
- [ ] Connexion API rendez‑vous (WordPress/KiviCare ou backend dédié)
- [ ] Paiements (Mobile Money/Moov/MTN, Stripe)
- [ ] Carto temps réel (Google Maps) & dispatch VSL
- [ ] Stockage fichiers EEG/ENMG (S3/Wasabi) + visionneuse
- [ ] Notifications push (FCM)
- [ ] Auth multi‑rôle réelle
- [ ] RGPD, logs médicaux, audit
- [ ] Tests unitaires & widget
- [ ] Publication stores

---

© 2025 NeuroCare Connect
