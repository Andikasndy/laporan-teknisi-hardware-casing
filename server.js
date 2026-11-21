const http = require('http');
const fs = require('fs');
const path = require('path');
const os = require('os');
const url = require('url');
const db = require('./db');

const DEFAULT_PORT = process.env.PORT || 3000;

// Otomatis cari folder web/ atau public/ atau root
function getWebDir() {
  if (fs.existsSync(path.join(__dirname, 'web'))) {
    return path.join(__dirname, 'web');
  }
  if (fs.existsSync(path.join(__dirname, 'public'))) {
    return path.join(__dirname, 'public');
  }
  return __dirname;
}

const WEB_DIR = getWebDir();

// Tentukan path penyimpanan data JSON lokal berdasarkan database key
function getDataFilePath(targetDb = 'hardware') {
  const localDataDir = path.join(__dirname, 'data');
  if (!fs.existsSync(localDataDir)) {
    fs.mkdirSync(localDataDir, { recursive: true });
  }

  const key = String(targetDb || '').toLowerCase() === 'casing' ? 'casing' : 'hardware';
  const targetFile = path.join(localDataDir, `laporan-service-${key}.json`);

  // Jika file per-bagian belum ada tapi file legacy ada, jadikan legacy sebagai acuan awal
  if (!fs.existsSync(targetFile)) {
    const legacyFile = path.join(localDataDir, 'laporan-service.json');
    if (fs.existsSync(legacyFile)) {
      try {
        const legacyData = JSON.parse(fs.readFileSync(legacyFile, 'utf8'));
        fs.writeFileSync(targetFile, JSON.stringify({
          users: legacyData.users || DEFAULT_USERS,
          jenisAlat: legacyData.jenisAlat || INITIAL_DATA.jenisAlat,
          kategoriLokasi: legacyData.kategoriLokasi || INITIAL_DATA.kategoriLokasi,
          laporan: []
        }, null, 2), 'utf8');
      } catch (e) {}
    }
  }

  return targetFile;
}

// Data default jika file/db belum ada
const DEFAULT_USERS = [
  {
    id: 1,
    username: 'hardware',
    password: 'hardware123',
    nama: 'Teknisi Hardware',
    role: 'Teknisi Hardware'
  },
  {
    id: 2,
    username: 'casing',
    password: 'casing123',
    nama: 'Teknisi Casing',
    role: 'Teknisi Casing'
  }
];

const DEFAULT_ADMIN = DEFAULT_USERS[0];

const INITIAL_DATA = {
  users: DEFAULT_USERS,
  jenisAlat: [
    { id: 1, nama: 'INF HOT 11 PLAY' },
    { id: 2, nama: 'INF HOT 50I' },
    { id: 3, nama: 'INF HOT 60I' },
    { id: 4, nama: 'INF SMART 10' },
    { id: 5, nama: 'INF SMART 20' },
    { id: 6, nama: 'INF SMART 6+' },
    { id: 7, nama: 'PC' },
    { id: 8, nama: 'SAMSUNG' }
  ],
  kategoriLokasi: [
    { id: 1, nama: 'Teknisi Limin' },
    { id: 2, nama: 'Rutan Bangil' },
    { id: 3, nama: 'Ponpes Salafiyah Sukorejo' },
    { id: 4, nama: 'Hardware Andika' }
  ],
  laporan: []
};

// Baca data JSON lokal berdasarkan bagian ('hardware' atau 'casing')
function readJsonData(targetDb = 'hardware') {
  const filePath = getDataFilePath(targetDb);
  try {
    if (fs.existsSync(filePath)) {
      const content = fs.readFileSync(filePath, 'utf-8');
      const parsed = JSON.parse(content);
      return {
        users: Array.isArray(parsed.users) && parsed.users.length > 0 ? parsed.users : DEFAULT_USERS,
        jenisAlat: Array.isArray(parsed.jenisAlat) ? parsed.jenisAlat : INITIAL_DATA.jenisAlat,
        kategoriLokasi: Array.isArray(parsed.kategoriLokasi) ? parsed.kategoriLokasi : INITIAL_DATA.kategoriLokasi,
        laporan: Array.isArray(parsed.laporan) ? parsed.laporan : []
      };
    }
  } catch (err) {
    console.error(`Gagal membaca file data JSON [${targetDb}]:`, err.message);
  }
  return INITIAL_DATA;
}

// Simpan data JSON lokal berdasarkan bagian ('hardware' atau 'casing')
function writeJsonData(newData, targetDb = 'hardware') {
  const filePath = getDataFilePath(targetDb);
  try {
    const dir = path.dirname(filePath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(filePath, JSON.stringify(newData, null, 2), 'utf-8');
    return true;
  } catch (err) {
    console.error(`Gagal menyimpan file data JSON [${targetDb}]:`, err.message);
    return false;
  }
}

// Ambil IP Lokal untuk akses jaringan LAN / Wi-Fi
function getLocalIPAddresses() {
  const interfaces = os.networkInterfaces();
  const ips = [];
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        ips.push({ name, ip: iface.address });
      }
    }
  }
  return ips;
}

// Content-Type map
const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
};

const server = http.createServer(async (req, res) => {
  try {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-Database');

    if (req.method === 'OPTIONS') {
      res.writeHead(204);
      res.end();
      return;
    }

    const parsedUrl = url.parse(req.url, true);
    const pathname = parsedUrl.pathname;

    // Normalisasi database tujuan dari query param ?db=casing / ?db=hardware atau header
    const requestedDb = (parsedUrl.query.db || req.headers['x-database'] || 'hardware').toLowerCase() === 'casing' ? 'casing' : 'hardware';

    // --- API: GET DATA ---
    if (pathname === '/api/data' && req.method === 'GET') {
      let result = null;
      const dbStatus = db.getDatabaseStatus(requestedDb);

      if (dbStatus.connected) {
        result = await db.getDataFromDb(requestedDb);
      }

      if (!result) {
        result = readJsonData(requestedDb);
      }

      result.activeDatabase = requestedDb;
      result.databaseName = dbStatus.database || path.basename(getDataFilePath(requestedDb));

      res.writeHead(200, {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Database-Engine': dbStatus.engine,
        'X-Database-Target': requestedDb,
        'X-Database-Name': result.databaseName
      });
      res.end(JSON.stringify(result));
      return;
    }

    // --- API: SAVE DATA ---
    if (pathname === '/api/save-data' && req.method === 'POST') {
      let body = '';
      req.on('data', chunk => {
        body += chunk;
        if (body.length > 50 * 1024 * 1024) { // 50MB limit
          req.destroy();
        }
      });
      req.on('end', async () => {
        try {
          const parsed = JSON.parse(body);
          const targetDb = (parsedUrl.query.db || parsed.db || req.headers['x-database'] || 'hardware').toLowerCase() === 'casing' ? 'casing' : 'hardware';
          
          // 1. Simpan ke file JSON cadangan khusus bagian tersebut
          writeJsonData(parsed, targetDb);

          // 2. Simpan ke database MySQL jika terhubung
          const dbStatus = db.getDatabaseStatus(targetDb);
          let dbSuccess = true;
          if (dbStatus.connected) {
            dbSuccess = await db.saveDataToDb(parsed, targetDb);
          }

          res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
          res.end(JSON.stringify({
            success: true,
            database: targetDb,
            databaseName: dbStatus.database,
            engine: dbStatus.engine,
            dbSaved: dbSuccess
          }));
        } catch (e) {
          res.writeHead(400, { 'Content-Type': 'application/json; charset=utf-8' });
          res.end(JSON.stringify({ success: false, error: 'Format data tidak valid: ' + e.message }));
        }
      });
      return;
    }

    // --- API: INFO SERVER ---
    if (pathname === '/api/info' && req.method === 'GET') {
      const dbOverall = db.getDatabaseStatus();
      res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
      res.end(JSON.stringify({
        status: 'online',
        databases: {
          hardware: db.getDatabaseStatus('hardware'),
          casing: db.getDatabaseStatus('casing')
        },
        backupFiles: {
          hardware: getDataFilePath('hardware'),
          casing: getDataFilePath('casing')
        },
        localIps: getLocalIPAddresses()
      }));
      return;
    }

    // --- STATIC FILE SERVING ---
    let safePath = path.normalize(pathname).replace(/^(\.\.[\/\\])+/, '');
    if (safePath === '/' || safePath === '\\' || safePath === '') {
      safePath = '/index.html';
    }

    let filePath = path.join(WEB_DIR, safePath);

    if (!fs.existsSync(filePath)) {
      filePath = path.join(WEB_DIR, 'index.html');
    } else {
      try {
        if (fs.statSync(filePath).isDirectory()) {
          filePath = path.join(filePath, 'index.html');
        }
      } catch (e) {
        filePath = path.join(WEB_DIR, 'index.html');
      }
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    fs.readFile(filePath, (err, content) => {
      if (err) {
        res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end('File tidak ditemukan: ' + safePath);
        return;
      }
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content);
    });
  } catch (err) {
    console.error('Unhandled request error:', err);
    try {
      res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('Internal Server Error: ' + err.message);
    } catch (e) {}
  }
});

server.on('error', (err) => {
  console.error('Server error:', err);
});

process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
});

async function startServer() {
  // Inisialisasi data awal untuk Hardware dan Casing
  const initialHw = readJsonData('hardware');
  const initialCs = readJsonData('casing');

  await db.initDatabase({
    hardware: initialHw,
    casing: initialCs,
    default: initialHw
  });

  server.listen(DEFAULT_PORT, '0.0.0.0', () => {
    const ips = getLocalIPAddresses();
    const statusHw = db.getDatabaseStatus('hardware');
    const statusCs = db.getDatabaseStatus('casing');

    console.log('\n=============================================================');
    console.log('  🌐 Laporan Service Web Server Berhasil Dijalankan!');
    console.log('=============================================================');
    console.log(`  ▶ Akses dari komputer ini : http://localhost:${DEFAULT_PORT}`);
    ips.forEach(item => {
      console.log(`  ▶ Akses dari HP/PC lain (${item.name}): http://${item.ip}:${DEFAULT_PORT}`);
    });
    console.log('-------------------------------------------------------------');
    console.log(`  🗄️ Database Hardware      : ${statusHw.connected ? `MySQL [${statusHw.database}]` : 'File JSON (Hardware)'}`);
    console.log(`  🗄️ Database Casing        : ${statusCs.connected ? `MySQL [${statusCs.database}]` : 'File JSON (Casing)'}`);
    console.log(`  📁 File Backup Hardware   : ${getDataFilePath('hardware')}`);
    console.log(`  📁 File Backup Casing     : ${getDataFilePath('casing')}`);
    console.log('=============================================================\n');
  });
}

startServer();
