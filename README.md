# 🏥 Medical App - Sistem Rekam Medis

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

Aplikasi manajemen rekam medis sederhana yang dibangun menggunakan **Flutter** (Frontend) dan **Golang** (Backend). Aplikasi ini mendukung Multi-Platform (Android & Windows) dengan sistem Role-Based Access Control (RBAC).

---

## 📥 Download Aplikasi

Anda dapat mengunduh versi terbaru aplikasi melalui link di bawah ini:

| Platform | Link Download |
| :--- | :--- |
| **🤖 Android (APK)** | [**Download APK Terbaru**](https://github.com/[USERNAME]/[REPO_NAME]/releases/latest) |
| **💻 Windows (.exe)** | [**Download Windows ZIP**](https://github.com/[USERNAME]/[REPO_NAME]/releases/latest) |

> *Catatan: Klik link di atas, lalu pada bagian "Assets", pilih file `.apk` untuk Android atau `.zip` untuk Windows.*

---

## 🚀 Panduan Instalasi (User Guide)

### 🤖 Untuk Pengguna Android
1. Download file `.apk` dari link di atas.
2. Buka file tersebut di HP Anda.
3. Jika muncul peringatan keamanan, izinkan instalasi dari **Unknown Source** (Sumber Tidak Dikenal).
4. Klik **Install** dan aplikasi siap digunakan.

### 💻 Untuk Pengguna Windows
1. Download file `.zip` dari link di atas.
2. **Ekstrak (Unzip)** file tersebut ke folder yang aman (misal: `D:\MedicalApp`).
3. Buka folder hasil ekstrak.
4. Cari file bernama `medical_app.exe` dan klik dua kali untuk menjalankan.
   > *Tidak perlu instalasi, aplikasi bersifat Portable.*

---

## 🔑 Akun Demo (Default)

Jika Anda baru pertama kali menjalankan aplikasi dan belum memiliki user, gunakan akun Administrator default (jika sudah diset di database) atau minta admin untuk membuatkan akun.

| Role | Fitur Akses |
| :--- | :--- |
| **Admin** | Mengelola User, Melihat Laporan, Melihat Data Pasien. |
| **Dokter** | Menambah Rekam Medis, Melihat Riwayat Pasien. |
| **Staff/User** | Mendaftarkan Pasien Baru, Melihat Data Pasien (Read Only). |

---

## ✨ Fitur Utama

* **Multi-Role Login**: Admin, Dokter, dan Staff memiliki tampilan menu yang berbeda.
* **Manajemen Pasien**: Tambah, Edit, Hapus, dan Cari data pasien dengan cepat.
* **Rekam Medis Elektronik**:
    * Dokter dapat menginput diagnosa dan terapi.
    * Riwayat medis tersusun rapi berdasarkan tanggal.
* **Dashboard Statistik**: Grafik kunjungan dan total pasien real-time.
* **Laporan**: Rekapitulasi kunjungan untuk keperluan administrasi.

---

## 🛠️ Tech Stack (Untuk Developer)

Jika Anda ingin mengembangkan ulang kode ini:

* **Frontend**: Flutter (Dart)
* **Backend**: Golang (Gin Framework + GORM)
* **Database**: MySQL
* **Architecture**: MVVM (Model-View-ViewModel)