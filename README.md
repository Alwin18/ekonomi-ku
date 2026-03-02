# Ekonomi-Ku 💰

Aplikasi mobile untuk tracking keuangan pribadi — pemasukan, pengeluaran, dan pinjaman. Dibangun dengan **Flutter** + **Supabase**.

## Tech Stack

- **Flutter** 3.32+ (Dart ^3.8.1)
- **Supabase** — Auth & PostgreSQL database
- **flutter_bloc** — State management (BLoC pattern)
- **fl_chart** — Grafik dashboard

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.32
- Akun [Supabase](https://supabase.com/) dengan project yang sudah dibuat
- Android Studio / Xcode (untuk emulator) atau device fisik

## Setup & Running Locally

### 1. Clone & Install Dependencies

```bash
git clone <repository-url>
cd ekonomi-ku
flutter pub get
```

### 2. Konfigurasi Environment

Salin file `.env.example` menjadi `.env` dan isi dengan kredensial Supabase:

```bash
cp .env.example .env
```

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

> Dapatkan URL dan Anon Key dari **Supabase Dashboard → Settings → API**.

### 3. Setup Database

Jalankan SQL berikut di **Supabase Dashboard → SQL Editor**:

```sql
-- Buat enum untuk status pinjaman (jika belum ada)
create type loan_status as enum ('active', 'paid');

-- Jalankan file schema
-- Lihat file supabase_schema.sql untuk detail lengkap
```

### 4. Run di Development

```bash
# Cek device yang tersedia
flutter devices

# Run di device/emulator yang terhubung
flutter run

# Run di device spesifik
flutter run -d <device-id>

# Run di Chrome (web)
flutter run -d chrome
```

## Build Production

### Android (APK)

```bash
# APK untuk semua arsitektur (ukuran lebih besar)
flutter build apk --release

# APK per arsitektur (recommended, ukuran lebih kecil)
flutter build apk --split-per-abi --release
```

Output: `build/app/outputs/flutter-apk/`

### Android (App Bundle — untuk Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
# Pastikan sudah setup signing di Xcode
flutter build ipa --release
```

Output: `build/ios/ipa/`

### Web

```bash
flutter build web --release
```

Output: `build/web/`

### Linux

```bash
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/`

## Struktur Project

```
lib/
├── main.dart              # Entry point + Supabase init
├── app.dart               # Auth gate + bottom navigation
├── core/
│   ├── constants/         # Theme, warna, spacing
│   ├── error/             # Error handling
│   └── utils/             # Currency & date formatter
└── features/
    ├── auth/              # Login & Register (Supabase Auth)
    │   ├── bloc/
    │   ├── repository/
    │   └── view/
    ├── dashboard/         # Ringkasan keuangan + grafik
    ├── income/            # CRUD pemasukan
    ├── expense/           # CRUD pengeluaran
    └── loan/              # CRUD pinjaman + tandai lunas
```

## Fitur

- 🔐 **Autentikasi** — Login & register dengan email/password
- 📊 **Dashboard** — Ringkasan saldo, pemasukan, pengeluaran, pinjaman + grafik 6 bulan
- 💵 **Pemasukan** — Tambah, edit, hapus pemasukan per bulan
- 💸 **Pengeluaran** — Tambah, edit, hapus pengeluaran per bulan
- 🤝 **Pinjaman** — Kelola pinjaman dengan status aktif/lunas, jatuh tempo
