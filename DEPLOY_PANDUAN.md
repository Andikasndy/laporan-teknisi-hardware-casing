# 📦 Panduan Deploy Laporan Service Web

## Persyaratan Server
- **Node.js** v16+ (https://nodejs.org)
- **MySQL** 5.7+ atau MariaDB 10.3+ (atau XAMPP)
- **npm** (sudah termasuk dengan Node.js)

---

## 1. Setup Database MySQL (Terpisah: Hardware & Casing)

Aplikasi ini menggunakan 2 database terpisah untuk Teknisi Hardware dan Teknisi Casing:
- `laporan_service_hardware`: Menyimpan data khusus perbaikan Hardware
- `laporan_service_casing`: Menyimpan data khusus perbaikan Casing

### Otomatis
Database dan tabel akan dibuat secara otomatis oleh server Node.js saat pertama kali dijalankan.

### Manual (Opsional via MySQL CLI / phpMyAdmin)
Jalankan file `database.sql`:
```bash
mysql -u root < database.sql
```

---

## 2. Konfigurasi Koneksi Database

Edit file `config.json`:
```json
{
  "host": "localhost",
  "user": "root",
  "password": "",
  "port": 3306,
  "databases": {
    "hardware": "laporan_service_hardware",
    "casing": "laporan_service_casing"
  }
}
```

**Atau gunakan environment variables** (untuk VPS/PM2/cloud):
```bash
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=password_anda
DB_PORT=3306
DB_NAME_HARDWARE=laporan_service_hardware
DB_NAME_CASING=laporan_service_casing
PORT=3000
```

---

## 3. Instalasi & Menjalankan

```bash
# Install dependencies
npm install

# Jalankan server
node server.js

# Atau gunakan PM2 (agar berjalan terus di background)
npm install -g pm2
pm2 start server.js --name laporan-service
pm2 save
pm2 startup
```

---

## 4. Akses Aplikasi

- **Lokal**: http://localhost:3000
- **Jaringan LAN**: http://[IP-SERVER]:3000
- **Online (VPS)**: http://[IP-VPS]:3000

---

## 5. Login Default
- **Akun 1 (Hardware)**:
  - **Username**: `hardware`
  - **Password**: `hardware123`
  - **Jabatan / Role**: Teknisi Hardware
- **Akun 2 (Casing)**:
  - **Username**: `casing`
  - **Password**: `casing123`
  - **Jabatan / Role**: Teknisi Casing

---

## 6. Fitur Utama
- ✅ Database MySQL (data tidak hilang, bisa akses multi-device)
- ✅ Fallback otomatis ke JSON jika MySQL tidak tersedia
- ✅ Import/Export Data Laporan (Excel .xlsx)
- ✅ Import/Export Kategori Lokasi (Excel)
- ✅ Indikator status database di topbar

---

## 7. Struktur File
```
LaporanService-Web/
├── server.js          # Server utama (Node.js + Express)
├── db.js              # Koneksi dan operasi MySQL
├── config.json        # Konfigurasi database
├── database.sql       # Schema tabel MySQL
├── package.json       # Dependencies npm
├── web/               # File frontend (HTML, CSS, JS)
│   ├── index.html
│   ├── app.js
│   ├── style.css
│   └── exceljs.min.js
└── data/              # Backup JSON (otomatis)
    └── laporan-service.json
```
