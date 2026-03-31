# Mousetrap — Setup-Checkliste

## 1. Flutter-Projekt initialisieren
```bash
# Im mousetrap/ Verzeichnis:
flutter create . --platforms=android --org com.yourname
# Danach diese Dateien NICHT überschreiben lassen:
# lib/main.dart, pubspec.yaml, android/app/build.gradle
```

## 2. Dependencies holen
```bash
flutter pub get
```

## 3. Snap-Sound ersetzen
- `assets/sounds/snap.mp3` durch echten Mausefallen-Sound ersetzen
- Freie Quellen: freesound.org → Suche "mousetrap snap"
- Format: MP3, mono, ~0.3 Sekunden, so laut wie möglich

## 4. AdMob IDs ersetzen
Vor dem Release in diesen Dateien die Test-IDs durch echte ersetzen:
- `lib/core/constants.dart` → `AdConfig.bannerAdUnitId`
- `android/app/src/main/AndroidManifest.xml` → `APPLICATION_ID` meta-data

## 5. App-ID anpassen
Ersetze überall `com.yourname.mousetrap` mit deiner echten App-ID:
- `android/app/build.gradle` → `applicationId`
- `android/app/src/main/AndroidManifest.xml` → `namespace`
- `android/app/src/main/kotlin/com/yourname/mousetrap/` → Ordner umbenennen

## 6. Build & Test
```bash
flutter run --release           # auf echtem Gerät testen
flutter build apk --release     # APK für Play Store
```

## 7. Play Store Checkliste
- [ ] Keystore erstellen + in build.gradle eintragen
- [ ] Screenshots: 2 Phone-Screenshots mindestens
- [ ] Feature Graphic: 1024x500px
- [ ] Content Rating: "Everyone" auswählen
- [ ] AdMob-Konto verknüpfen (Google UMP SDK für EU-Consent bereits vorbereitet)

## Hinweis: EU Consent (DSGVO)
Das `google_mobile_ads` Package enthält den UMP SDK.
Vor dem EU-Release: In `main.dart` den ConsentInformation-Flow aktivieren.
Docs: https://developers.google.com/admob/flutter/eu-consent
