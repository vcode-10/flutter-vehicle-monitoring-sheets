# Aplikasi Laporan BBM Sederhana v1.0

> **Catatan:** Ini adalah dokumentasi untuk versi awal aplikasi. Untuk versi terbaru, silakan lihat bagian di atas.

## ✨ Fitur Utama (v1.0)

- **Form Input Data**: Mencatat informasi penting seperti ID Kendaraan, Nama Sopir, Odometer, Jenis BBM, Jumlah Liter, dan Biaya.
- **Upload Foto Bukti**: Pengguna dapat mengunggah foto bukti (struk) langsung dari kamera atau galeri.
- **Tampilan Laporan Harian**: Menampilkan daftar semua log BBM yang telah diinput pada hari ini.

## 🛠️ Panduan Instalasi (v1.0)

### Backend (Google)

1.  **Google Sheet**: Buat satu sheet (tab) bernama **`Logs`** dengan kolom berikut:
    | timestamp | id_kendaraan | nama_driver | odometer | jenis_bbm | jumlah_liter | biaya | foto_url |
    | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
2.  **Google Drive**: Buat folder untuk foto dan salin **ID Folder**-nya.
3.  **Apps Script**: Gunakan script `doGet` dan `doPost` versi awal, masukkan ID Folder, lalu **Deploy** sebagai Web app. Salin URL-nya.

### Frontend (Flutter)

1. Gunakan struktur kode Flutter versi 1.0.
2. Buka file `lib/providers/report_provider.dart` dan ganti nilai `_baseUrl` dengan URL Web app Anda.
3. Jalankan aplikasi.