import 'package:flutter/material.dart';
import 'package:medical_app/screens/patient_list_screnn.dart';
import '../db/database_helper.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'report_screen.dart';
import 'user_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Variabel untuk statistik
  int _totalPatients = 0;
  int _visitsToday = 0;
  List<Map<String, dynamic>> _recentPatients = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Ambil data ringkasan dari Database agar dashboard hidup
  void _loadDashboardData() async {
    final db = await DatabaseHelper().database;

    // 1. Hitung Total Pasien
    final countPatient = await db.rawQuery(
      'SELECT COUNT(*) as count FROM patients',
    );

    // 2. Hitung Kunjungan Hari Ini
    String today = DateTime.now().toString().split(' ')[0];
    final countVisits = await db.rawQuery(
      'SELECT COUNT(*) as count FROM medical_records WHERE tanggal_periksa LIKE ?',
      ['$today%'],
    );

    // 3. Ambil 5 Pasien Terakhir
    final recents = await db.query(
      'patients',
      orderBy: 'created_at DESC',
      limit: 5,
    );

    if (mounted) {
      setState(() {
        _totalPatients = countPatient.first['count'] as int;
        _visitsToday = countVisits.first['count'] as int;
        _recentPatients = recents;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.local_hospital, color: Color(0xFF00796B)),
            const SizedBox(width: 10),
            const Text(
              "Medika App",
              style: TextStyle(
                color: Color(0xFF00796B),
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: 1,
              height: 24,
              color: Colors.grey[300],
            ),
            Text(
              "Dashboard ${widget.user.role.toUpperCase()}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: TextButton.icon(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => const LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. WELCOME SECTION ---
            Text(
              "Halo, ${widget.user.fullName} 👋",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Text(
              "Berikut adalah ringkasan aktivitas klinik hari ini.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // --- 2. STATS CARDS (Data Realtime) ---
            Row(
              children: [
                _buildStatCard(
                  "Total Pasien",
                  _totalPatients.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  "Kunjungan Hari Ini",
                  _visitsToday.toString(),
                  Icons.access_time_filled,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  "Role Akun",
                  widget.user.role.toUpperCase(),
                  Icons.security,
                  Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- 3. MAIN CONTENT (Split View) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PANEL KIRI: Menu Cepat (Quick Actions)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Menu Utama",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grid Menu
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2, // 2 Kolom
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio:
                            1.5, // Agar kartu melebar (tidak kotak)
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildActionCard(
                            context,
                            "Data Pasien",
                            "Registrasi & Rekam Medis",
                            Icons.people_outline,
                            Colors.blue,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) =>
                                    PatientListScreen(currentUser: widget.user),
                              ),
                            ).then((_) => _loadDashboardData()),
                          ),

                          if (widget.user.role == 'dokter' ||
                              widget.user.role == 'perawat')
                            _buildActionCard(
                              context,
                              "Laporan Medis",
                              "Lihat Riwayat Kunjungan",
                              Icons.assignment_outlined,
                              Colors.orange,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => const ReportScreen(),
                                ),
                              ),
                            ),

                          if (widget.user.role == 'dokter')
                            _buildActionCard(
                              context,
                              "Kelola User",
                              "Tambah/Hapus Akun",
                              Icons.manage_accounts_outlined,
                              Colors.red,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => const UserManagementScreen(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 32),

                // PANEL KANAN: Aktivitas Terkini (Pasien Terbaru)
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Pasien Terbaru Ditambahkan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => PatientListScreen(
                                    currentUser: widget.user,
                                  ),
                                ),
                              ).then((_) => _loadDashboardData());
                            },
                            child: const Text("Lihat Semua"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recentPatients.length,
                          separatorBuilder: (c, i) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final p = _recentPatients[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal.shade50,
                                child: Text(
                                  p['nama'][0],
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                p['nama'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("No RM: ${p['no_rm']}"),
                              trailing: Text(
                                p['created_at'].toString().substring(0, 10),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_recentPatients.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Belum ada data pasien.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget Kartu Statistik Kecil di Atas
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget Kartu Menu Utama
  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
