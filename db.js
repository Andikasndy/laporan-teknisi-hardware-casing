// ==============================================================
// MYSQL DATABASE CONNECTOR & ORM (MULTI-DATABASE: HARDWARE & CASING)
// Mendukung 5 Database Terpisah:
// 1. hardware_hp     : Service HP, PC & Tab
// 2. hardware_alat   : Service Alat Lain
// 3. hardware_rusak  : Data Barang Rusak
// 4. casing_admin    : Dari Admin Stock
// 5. casing_paket    : Dari Paket
// Otomatis membuat database, migrate table, auto-seed data, & auto-fallback
// ==============================================================

const fs = require('fs');
const path = require('path');

let mysql = null;
try {
  mysql = require('mysql2/promise');
} catch (e) {
  console.warn('⚠️ Modul mysql2 belum tersedia. Pastikan menjalankan "npm install mysql2".');
}

const DB_KEYS = ['hardware_hp', 'hardware_alat', 'hardware_rusak', 'casing_admin', 'casing_paket'];

// Normalisasi target database key
function normalizeDbKey(key) {
  const k = String(key || '').toLowerCase().trim();
  if (k === 'hardware') return 'hardware_hp';
  if (k === 'casing') return 'casing_admin';
  if (DB_KEYS.includes(k)) return k;
  return 'hardware_hp';
}

// Baca konfigurasi dari config.json atau Environment Variables
function getDbConfig() {
  const configPath = path.join(__dirname, 'config.json');
  let fileConfig = {};
  if (fs.existsSync(configPath)) {
    try {
      fileConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    } catch (e) {
      console.error('Gagal membaca config.json:', e.message);
    }
  }

  const baseConfig = {
    host: process.env.DB_HOST || fileConfig.host || 'localhost',
    user: process.env.DB_USER || fileConfig.user || 'root',
    password: process.env.DB_PASSWORD !== undefined ? process.env.DB_PASSWORD : (fileConfig.password !== undefined ? fileConfig.password : ''),
    port: parseInt(process.env.DB_PORT || fileConfig.port || 3306, 10),
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    charset: 'utf8mb4'
  };

  const fileDbs = fileConfig.databases || {};
  const databases = {
    hardware_hp: process.env.DB_HARDWARE_HP || fileDbs.hardware_hp || 'laporan_hardware_hp',
    hardware_alat: process.env.DB_HARDWARE_ALAT || fileDbs.hardware_alat || 'laporan_hardware_alat',
    hardware_rusak: process.env.DB_HARDWARE_RUSAK || fileDbs.hardware_rusak || 'laporan_hardware_rusak',
    casing_admin: process.env.DB_CASING_ADMIN || fileDbs.casing_admin || 'laporan_casing_admin',
    casing_paket: process.env.DB_CASING_PAKET || fileDbs.casing_paket || 'laporan_casing_paket'
  };

  return {
    ...baseConfig,
    databases
  };
}

const pools = {};
const connectionStatus = {};
DB_KEYS.forEach(k => { connectionStatus[k] = false; });

// Inisialisasi pool dan database untuk seluruh landing page
async function initDatabase(initialDataMap = {}) {
  if (!mysql) return false;

  const config = getDbConfig();

  // 1. Coba koneksi ke server MySQL tanpa memilih database terlebih dahulu
  let tempConn = null;
  try {
    tempConn = await mysql.createConnection({
      host: config.host,
      user: config.user,
      password: config.password,
      port: config.port
    });

    // Buat seluruh 5 database jika belum ada
    for (const key of DB_KEYS) {
      const dbName = config.databases[key];
      await tempConn.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
    }
    await tempConn.end();
    tempConn = null;
  } catch (err) {
    console.warn(`⚠️ MySQL tidak aktif (${err.message}). Sistem menggunakan penyimpanan file JSON otomatis.`);
    if (tempConn) {
      try { await tempConn.end(); } catch (e) {}
    }
    DB_KEYS.forEach(k => { connectionStatus[k] = false; });
    return false;
  }

  // 2. Inisialisasi pool & tabel untuk setiap database
  for (const key of DB_KEYS) {
    const dbName = config.databases[key];
    try {
      const pool = mysql.createPool({
        host: config.host,
        user: config.user,
        password: config.password,
        port: config.port,
        database: dbName,
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0,
        charset: 'utf8mb4'
      });

      // Buat tabel users
      await pool.query(`
        CREATE TABLE IF NOT EXISTS \`users\` (
          \`id\` BIGINT NOT NULL,
          \`username\` VARCHAR(100) NOT NULL UNIQUE,
          \`password\` VARCHAR(255) NOT NULL,
          \`nama\` VARCHAR(255) NOT NULL,
          \`role\` VARCHAR(100) NOT NULL DEFAULT 'Admin',
          \`avatar\` LONGTEXT NULL,
          \`createdAt\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          \`updatedAt\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          PRIMARY KEY (\`id\`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `);

      // Buat tabel jenis_alat
      await pool.query(`
        CREATE TABLE IF NOT EXISTS \`jenis_alat\` (
          \`id\` BIGINT NOT NULL,
          \`nama\` VARCHAR(255) NOT NULL,
          \`createdAt\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (\`id\`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `);

      // Buat tabel kategori_lokasi
      await pool.query(`
        CREATE TABLE IF NOT EXISTS \`kategori_lokasi\` (
          \`id\` BIGINT NOT NULL,
          \`nama\` VARCHAR(255) NOT NULL,
          \`createdAt\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (\`id\`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `);

      // Buat tabel laporan
      await pool.query(`
        CREATE TABLE IF NOT EXISTS \`laporan\` (
          \`id\` BIGINT NOT NULL,
          \`no\` VARCHAR(50) DEFAULT '',
          \`tanggalMasuk\` VARCHAR(50) DEFAULT '',
          \`tanggalKeluar\` VARCHAR(50) DEFAULT '',
          \`jumlahAlat\` INT DEFAULT 1,
          \`keteranganPerbaikan\` TEXT,
          \`jenisAlatId\` BIGINT DEFAULT NULL,
          \`jenisAlatNama\` VARCHAR(255) DEFAULT '',
          \`lokasiDari\` VARCHAR(255) DEFAULT '',
          \`kondisi\` VARCHAR(50) DEFAULT 'Lama',
          \`lamaHari\` INT DEFAULT 0,
          \`createdAt\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          \`updatedAt\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          PRIMARY KEY (\`id\`),
          INDEX \`idx_tgl_masuk\` (\`tanggalMasuk\`),
          INDEX \`idx_lokasi\` (\`lokasiDari\`),
          INDEX \`idx_jenis\` (\`jenisAlatNama\`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `);

      pools[key] = pool;
      connectionStatus[key] = true;

      // 3. Cek apakah tabel users kosong, jika ya migrasikan data awal
      const [userRows] = await pool.query('SELECT COUNT(*) as cnt FROM users');
      const targetInitial = initialDataMap[key] || initialDataMap['default'];
      if (userRows[0].cnt === 0 && targetInitial) {
        console.log(`📦 Memigrasikan data awal ke database MySQL [${dbName}]...`);
        await saveDataToDb(targetInitial, key);
        console.log(`✓ Inisialisasi awal ke database [${dbName}] berhasil!`);
      }

      console.log(`✓ Terhubung ke database MySQL: [${dbName}] (${key})`);
    } catch (err) {
      console.warn(`⚠️ Gagal menginisialisasi database [${dbName}]: ${err.message}`);
      connectionStatus[key] = false;
      pools[key] = null;
    }
  }

  return Object.values(connectionStatus).some(Boolean);
}

// Ambil seluruh data dari MySQL berdasarkan target database
async function getDataFromDb(targetDb = 'hardware_hp') {
  const key = normalizeDbKey(targetDb);
  const pool = pools[key];
  if (!connectionStatus[key] || !pool) return null;

  try {
    const [users] = await pool.query('SELECT id, username, password, nama, role, avatar FROM users ORDER BY id ASC');
    const [jenisAlat] = await pool.query('SELECT id, nama FROM jenis_alat ORDER BY nama ASC');
    const [kategoriLokasi] = await pool.query('SELECT id, nama FROM kategori_lokasi ORDER BY nama ASC');
    const [laporan] = await pool.query('SELECT id, no, tanggalMasuk, tanggalKeluar, jumlahAlat, keteranganPerbaikan, jenisAlatId, jenisAlatNama, lokasiDari, kondisi, lamaHari FROM laporan ORDER BY id ASC');

    return {
      users: users || [],
      jenisAlat: jenisAlat || [],
      kategoriLokasi: kategoriLokasi || [],
      laporan: laporan || []
    };
  } catch (err) {
    console.error(`Error saat mengambil data dari MySQL [${key}]:`, err.message);
    return null;
  }
}

// Simpan data ke MySQL menggunakan transaksi berdasarkan target database
async function saveDataToDb(data, targetDb = 'hardware_hp') {
  const key = normalizeDbKey(targetDb);
  const pool = pools[key];
  if (!connectionStatus[key] || !pool) return false;

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    // 1. Simpan Users
    if (Array.isArray(data.users) && data.users.length > 0) {
      await conn.query('DELETE FROM users');
      for (const u of data.users) {
        await conn.query(
          'INSERT INTO users (id, username, password, nama, role, avatar) VALUES (?, ?, ?, ?, ?, ?)',
          [u.id || 1, u.username || 'hardware', u.password || '', u.nama || '', u.role || 'Teknisi', u.avatar || null]
        );
      }
    }

    // 2. Simpan Jenis Alat / Kategori
    if (Array.isArray(data.jenisAlat)) {
      await conn.query('DELETE FROM jenis_alat');
      const seenIds = new Set();
      let nextId = Date.now();
      for (const j of data.jenisAlat) {
        let jid = parseInt(j.id, 10);
        if (!jid || seenIds.has(jid)) {
          jid = ++nextId;
        }
        seenIds.add(jid);
        j.id = jid;
        await conn.query('INSERT INTO jenis_alat (id, nama) VALUES (?, ?)', [jid, j.nama || '']);
      }
    }

    // 3. Simpan Kategori Lokasi
    if (Array.isArray(data.kategoriLokasi)) {
      await conn.query('DELETE FROM kategori_lokasi');
      const seenIds = new Set();
      let nextId = Date.now();
      for (const k of data.kategoriLokasi) {
        let kid = parseInt(k.id, 10);
        if (!kid || seenIds.has(kid)) {
          kid = ++nextId;
        }
        seenIds.add(kid);
        k.id = kid;
        await conn.query('INSERT INTO kategori_lokasi (id, nama) VALUES (?, ?)', [kid, k.nama || '']);
      }
    }

    // 4. Simpan Laporan
    if (Array.isArray(data.laporan)) {
      await conn.query('DELETE FROM laporan');
      const seenIds = new Set();
      let nextId = Date.now();
      for (const l of data.laporan) {
        let lid = parseInt(l.id, 10);
        if (!lid || seenIds.has(lid)) {
          lid = ++nextId;
        }
        seenIds.add(lid);
        l.id = lid;
        await conn.query(
          `INSERT INTO laporan 
          (id, no, tanggalMasuk, tanggalKeluar, jumlahAlat, keteranganPerbaikan, jenisAlatId, jenisAlatNama, lokasiDari, kondisi, lamaHari)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            lid,
            l.no || '',
            l.tanggalMasuk || '',
            l.tanggalKeluar || '',
            parseInt(l.jumlahAlat, 10) || 1,
            l.keteranganPerbaikan || '',
            l.jenisAlatId || null,
            l.jenisAlatNama || '',
            l.lokasiDari || '',
            l.kondisi || 'Lama',
            parseInt(l.lamaHari, 10) || 0
          ]
        );
      }
    }

    await conn.commit();
    return true;
  } catch (err) {
    await conn.rollback();
    console.error(`Error saat menyimpan ke MySQL [${key}]:`, err.message);
    return false;
  } finally {
    conn.release();
  }
}

function getDatabaseStatus(targetDb = null) {
  const config = getDbConfig();
  if (targetDb) {
    const key = normalizeDbKey(targetDb);
    return {
      target: key,
      engine: connectionStatus[key] ? 'mysql' : 'json',
      connected: !!connectionStatus[key],
      host: config.host,
      port: config.port,
      database: config.databases[key]
    };
  }

  const anyConnected = Object.values(connectionStatus).some(Boolean);
  const statusMap = {};
  DB_KEYS.forEach(k => {
    statusMap[k] = {
      connected: !!connectionStatus[k],
      database: config.databases[k]
    };
  });

  return {
    engine: anyConnected ? 'mysql' : 'json',
    connected: anyConnected,
    host: config.host,
    port: config.port,
    databases: statusMap
  };
}

module.exports = {
  DB_KEYS,
  normalizeDbKey,
  initDatabase,
  getDataFromDb,
  saveDataToDb,
  getDatabaseStatus,
  getDbConfig
};
