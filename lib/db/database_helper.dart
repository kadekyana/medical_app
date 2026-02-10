import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Getter database: memastikan hanya ada 1 koneksi
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Inisialisasi database factory untuk Desktop (Windows/Mac/Linux)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Menentukan lokasi penyimpanan file .db di komputer user
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'medical_app.db');

    // Print lokasi file agar kamu bisa cek saat development
    print('Lokasi Database: $path');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Membuat tabel saat pertama kali aplikasi dijalankan
  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabel Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL,
        full_name TEXT
      )
    ''');

    // 2. Tabel Pasien (Sesuai Header Form)
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        no_rm TEXT UNIQUE,
        nama TEXT NOT NULL,
        alamat TEXT,
        tanggal_lahir TEXT,
        jenis_kelamin TEXT,
        alergi_obat TEXT,
        created_at TEXT
      )
    ''');

    // 3. Tabel Rekam Medis (Sesuai Kolom Tabel Form)
    await db.execute('''
      CREATE TABLE medical_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER,
        doctor_id INTEGER,
        tanggal_periksa TEXT,
        anamnesa_diagnosa TEXT,
        terapi_tindakan TEXT,
        FOREIGN KEY(patient_id) REFERENCES patients(id),
        FOREIGN KEY(doctor_id) REFERENCES users(id)
      )
    ''');

    // Seed Data Awal (Opsional: Admin Default)
    await db.execute('''
      INSERT INTO users (username, password_hash, role, full_name)
      VALUES ('admin', 'admin123', 'dokter', 'Dr. Administrator')
    ''');
  }

  // --- AUTH METHODS ---

  // Fungsi Login
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await database;

    // Query cari user berdasarkan username dan password
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, password],
    );

    if (results.isNotEmpty) {
      return results.first; // Return user jika ketemu
    } else {
      return null; // Return null jika salah
    }
  }

  // Fungsi Tambah User Baru (Untuk nanti test bikin akun Perawat/User)
  Future<int> registerUser(Map<String, dynamic> userRow) async {
    final db = await database;
    return await db.insert('users', userRow);
  }

  // --- PATIENT METHODS ---

  // 1. Tambah Pasien Baru
  Future<int> insertPatient(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('patients', row);
  }

  // 2. Ambil Semua Data Pasien (Untuk List)
  Future<List<Map<String, dynamic>>> getPatients() async {
    final db = await database;
    return await db.query(
      'patients',
      orderBy: 'created_at DESC',
    ); // Yang terbaru paling atas
  }

  // 3. Generate No RM Otomatis (Opsional, biar keren kayak sequence di SQL)
  // Format: RM-20240209-001
  Future<String> generateNoRM() async {
    final db = await database;
    // Hitung jumlah pasien hari ini untuk running number
    // Sederhana dulu: ambil ID terakhir + 1
    final result = await db.rawQuery('SELECT MAX(id) as max_id FROM patients');
    int nextId = (result.first['max_id'] as int? ?? 0) + 1;

    // Format sederhana: RM-001, RM-002, dst.
    return 'RM-${nextId.toString().padLeft(4, '0')}';
  }

  // --- MEDICAL RECORD METHODS ---

  // 1. Tambah Rekam Medis
  Future<int> insertMedicalRecord(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('medical_records', row);
  }

  // 2. Ambil Riwayat Berdasarkan ID Pasien
  Future<List<Map<String, dynamic>>> getMedicalRecordsByPatient(
    int patientId,
  ) async {
    final db = await database;
    return await db.query(
      'medical_records',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'id DESC', // Yang terbaru paling atas
    );
  }

  // --- UPDATE & DELETE METHODS ---

  // 1. Update Data Pasien
  Future<int> updatePatient(Map<String, dynamic> row) async {
    final db = await database;
    int id = row['id'];
    return await db.update('patients', row, where: 'id = ?', whereArgs: [id]);
  }

  // 2. Update Rekam Medis (Jika dokter salah ketik)
  Future<int> updateMedicalRecord(Map<String, dynamic> row) async {
    final db = await database;
    int id = row['id'];
    return await db.update(
      'medical_records',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 3. Hapus Rekam Medis
  Future<int> deleteMedicalRecord(int id) async {
    final db = await database;
    return await db.delete('medical_records', where: 'id = ?', whereArgs: [id]);
  }

  // --- USER MANAGEMENT METHODS ---

  // 4. Ambil Semua User (Untuk Admin)
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // 5. Tambah User Baru
  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('users', row);
  }

  // 6. Hapus User
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
