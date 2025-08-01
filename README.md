# NotedTeam - Mobile Apps (Flutter)

![NotedTeam Logo](assets/images/logo.png)

Ini adalah repositori untuk aplikasi mobile **NotedTeam**, sebuah to-do list kolaboratif yang dibangun menggunakan **Flutter**. Aplikasi ini berfungsi sebagai antarmuka (frontend) untuk [NotedTeam Go Backend]([Link ke Repositori Backend Anda Di Sini]).

Aplikasi ini dirancang untuk memberikan pengalaman pengguna yang mulus, responsif, dan real-time di platform Android.

[**Kunjungi Landing Page »**]([Link ke Landing Page Anda Di Sini])

---

## 📱 Fitur Aplikasi

-   **Antarmuka Bersih & Modern**: UI yang dirancang dengan baik, lengkap dengan mode Terang & Gelap.
-   **Alur Otentikasi Lengkap**:
    -   Registrasi Pengguna dengan Verifikasi Email.
    -   Login Aman dengan JWT.
    -   Fungsionalitas Lupa & Reset Password.
    -   Sesi persisten (Auto-Login).
-   **Manajemen Tim Kolaboratif**:
    -   Membuat, mengubah nama, dan menghapus tim (hanya oleh pemilik).
    -   Mengundang anggota baru melalui email.
    -   Menerima atau menolak undangan tim.
    -   Melihat daftar anggota dalam sebuah tim.
-   **Manajemen Tugas Interaktif**:
    -   CRUD (Create, Read, Update, Delete) penuh untuk to-do list.
    -   Geser-untuk-hapus (Swipe-to-delete).
    -   Pengaturan Status, Urgensi, dan Tanggal Jatuh Tempo (Timeline).
-   **Sinkronisasi Real-time**: Didukung oleh **WebSocket**, semua perubahan pada to-do list langsung diperbarui di semua perangkat anggota tim yang online.
-   **Internasionalisasi (i18n)**: Dukungan untuk dua bahasa: Inggris dan Indonesia.
-   **Pengaturan Persisten**: Pengguna dapat menyimpan preferensi tema dan bahasa mereka di perangkat.

## 🛠️ Teknologi & Arsitektur

-   **Framework**: **Flutter 3.x**
-   **Bahasa**: **Dart**
-   **Manajemen State**: **Provider** - Pola yang diadopsi secara luas untuk manajemen state yang reaktif dan sederhana. Arsitektur menggunakan `ChangeNotifierProvider` dan `ChangeNotifierProxyProvider` untuk dependensi antar state.
-   **Networking**:
    -   `http`: Untuk komunikasi dengan RESTful API backend.
    -   `web_socket_channel`: Untuk koneksi real-time dengan server WebSocket.
-   **Penyimpanan Lokal**: `shared_preferences` untuk menyimpan token otentikasi JWT dan pengaturan pengguna.
-   **Navigasi**: Menggunakan `Navigator` bawaan Flutter dengan `MaterialPageRoute` dan `pushAndRemoveUntil` untuk alur otentikasi yang solid.
-   **Lokalisasi**: `flutter_localizations` dan `intl` dengan file `.arb` untuk manajemen terjemahan.
-   **Ketergantungan UI Tambahan**:
    -   `google_fonts`: Untuk tipografi yang konsisten dan menarik.
    -   `flutter_staggered_animations`: Untuk memberikan animasi daftar yang halus.

## 📂 Struktur Proyek

Proyek ini disusun dengan arsitektur berlapis untuk keterbacaan dan skalabilitas:

```
lib/
├── api/          # Lapisan komunikasi dengan backend (Services)
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── websocket_service.dart
├── l10n/         # File terjemahan (internasionalisasi)
│   ├── app_en.arb
│   └── app_id.arb
├── models/       # Kelas model data (merepresentasikan data dari JSON)
│   ├── invitation.dart
│   ├── team.dart
│   ├── todo.dart
│   └── user.dart
├── providers/    # Lapisan logika bisnis dan state management
│   ├── auth_provider.dart
│   ├── settings_provider.dart
│   └── team_provider.dart
├── screens/      # Widget untuk setiap halaman/layar
│   ├── home_screen.dart
│   ├── invitations_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── settings_screen.dart
│   └── todo_screen.dart
└── main.dart     # Titik masuk utama aplikasi, mengatur provider dan tema
```

## 🚀 Memulai (Getting Started)

### Prasyarat

-   Pastikan Anda telah menginstal **Flutter SDK** (versi 3.0 atau lebih baru).
-   **Backend NotedTeam harus berjalan**. Lihat [dokumentasi backend]([Link ke Repositori Backend Anda Di Sini]) untuk instruksi menjalankannya.

### Instalasi & Menjalankan

1.  **Clone repositori ini:**
    ```bash
    git clone [Link ke Repositori Frontend Anda Di Sini]
    cd notedteam_app
    ```

2.  **Instal semua dependensi:**
    ```bash
    flutter pub get
    ```

3.  **Konfigurasi URL Backend:**
    - Buka file `lib/api/api_service.dart`.
    - Temukan variabel `_baseUrl`.
    - Ubah nilainya agar sesuai dengan alamat server backend Anda:
        - Untuk emulator Android: `'http://10.0.2.2:8080'`
        - Untuk emulator iOS: `'http://localhost:8080'`
        - Untuk perangkat fisik (di jaringan yang sama): `'http://[IP_LOKAL_KOMPUTER_ANDA]:8080'`
    - Lakukan hal yang sama untuk URL WebSocket di `lib/api/websocket_service.dart`.

4.  **Jalankan aplikasi (Mode Debug):**
    ```bash
    flutter run
    ```

## 📦 Membangun untuk Rilis (Build)

Aplikasi ini sudah dikonfigurasi untuk membuat **Android App Bundle (AAB)** untuk rilis ke Google Play Store.

1.  **Siapkan Keystore Penandatanganan**: Ikuti panduan resmi Flutter untuk [membuat upload keystore](https://docs.flutter.dev/deployment/android#create-an-upload-keystore).
2.  **Konfigurasi `key.properties`**: Buat file `android/key.properties` dan isi dengan kredensial keystore Anda. Pastikan file ini ada di `.gitignore`.
3.  **Perbarui Versi**: Tingkatkan `versionCode` dan `versionName` di `android/app/build.gradle`.
4.  **Jalankan Perintah Build**:
    ```bash
    flutter build appbundle
    ```
    File rilis akan dibuat di `build/app/outputs/bundle/release/app-release.aab`.

---

Dibuat dengan ❤️ menggunakan Flutter dan Go.
