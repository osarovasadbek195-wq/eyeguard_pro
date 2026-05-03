# EyeGuard Pro

Ko'z himoyasi va mashqlari premium ilovasi - Flutter (Dart) yordamida yaratilgan oflayn ilova.

## Xususiyatlar

- **To'liq oflayn:** Internetga ulanish talab qilmaydi
- **Pirpiratish eslatmasi:** Oddiy va kama AI bilan ilg'or rejim
- **20-20-20 qoidasi:** Har 20 daqiqada tanaffus taymeri
- **Masofa nazorati:** AI yordamida ekranga bo'lgan masofani kuzatish
- **Ko'k nur filtri:** Ekran rangini iliqlashtiruvchi filtr
- **Ko'z mashqlari:** Gamified mashqlar kamera bilan kuzatish
- **Statistika:** fl_chart bilan grafiklar
- **Ko'p profil:** Oilaviy foydalanish uchun
- **Bolalar rejimi:** Qattiqroq nazorat va vaqt cheklovi

## Platformalar

- Android (API 24+)
- Windows (Windows 10+)

## Texnologiyalar

- **Flutter:** 3.24+
- **State Management:** Riverpod
- **Local Storage:** Hive (sozlamalar), Isar (statistika)
- **AI:** Google ML Kit Face Detection
- **UI:** Glassmorphism, Inter font, HyperOS 3 uslubi
- **Background Services:** flutter_background_service
- **Notifications:** flutter_local_notifications

## O'rnatish

### Android

1. Flutter SDK o'rnatilgan bo'lishi kerak
2. Android Studio o'rnatilgan bo'lishi kerak
3. Proyektni ochish:
```bash
cd eyeguard_pro
flutter pub get
```

4. Android uchun build:
```bash
flutter build apk
```

### Windows

1. Flutter SDK o'rnatilgan bo'lishi kerak
2. Visual Studio o'rnatilgan bo'lishi kerak
3. Proyektni ochish:
```bash
cd eyeguard_pro
flutter pub get
```

4. Windows uchun build:
```bash
flutter build windows
```

## Ruxsatlar

### Android
- CAMERA - Kamera uchun
- RECEIVE_BOOT_COMPLETED - Avtomatik ishga tushish
- SYSTEM_ALERT_WINDOW - Overlay uchun
- FOREGROUND_SERVICE - Fon xizmati
- POST_NOTIFICATIONS - Bildirishnomalar

### Windows
- Webcam ruxsati (kamera uchun)

## Loyiha strukturasi

```
lib/
├── main.dart
├── core/
│   ├── theme/ - HyperOS 3 mavzu
│   ├── constants/ - Matnlar
│   ├── utils/ - Hive helper
│   └── services/ - Fon, bildirishnomalar, kamera, masofa
├── features/
│   ├── onboarding/ - Birinchi ishga tushirish
│   ├── dashboard/ - Boshqaruv paneli
│   ├── blink_reminder/ - Pirpiratish eslatmasi
│   ├── break_reminder/ - Tanaffus taymeri
│   ├── distance_monitor/ - Masofa nazorati
│   ├── blue_filter/ - Ko'k nur filtri
│   ├── eye_exercises/ - Ko'z mashqlari
│   ├── statistics/ - Statistika
│   └── profiles/ - Profillar
└── models/ - Ma'lumot modellari
```

## Ishga tushirish

```bash
flutter run
```

## Qo'shimcha ma'lumot

- Ilova internet ishlatmaydi
- Barcha ma'lumotlar qurilmada saqlanadi
- Kamera tasviri hech qayerga uzatilmaydi
- Batareya optimizatsiyasi qilingan

## Litsenziya

Proprietary - Barcha huquqlar saqlangan.
