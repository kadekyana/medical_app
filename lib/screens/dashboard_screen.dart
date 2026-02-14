import 'package:flutter/material.dart';
import 'package:medical_app/models/dashboard_model.dart';
import 'package:medical_app/models/user_model.dart';
import 'package:medical_app/screens/patient_list_screnn.dart';
import 'package:medical_app/services/api_service.dart';
import 'package:medical_app/screens/login_screen.dart';
import 'package:medical_app/screens/user_management_screen.dart';
import 'package:medical_app/screens/report_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Users user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Dashboard? _dashboardData;
  bool _isLoading = true;

  final Color _primaryColor = const Color(0xFF1E88E5);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService().getDashboardStats();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading dashboard: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          "Medika Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HEADER USER
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // 2. KARTU STATISTIK
                    Row(
                      children: [
                        _buildStatCard(
                          title: "Total Pasien",
                          value: "${_dashboardData?.totalPatients ?? 0}",
                          color1: Colors.blue.shade400,
                          color2: Colors.blue.shade700,
                          icon: Icons.people_alt_rounded,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          title: "Kunjungan Hari Ini",
                          value: "${_dashboardData?.visitsToday ?? 0}",
                          color1: Colors.orange.shade300,
                          color2: Colors.orange.shade700,
                          icon: Icons.access_time_filled_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 3. MENU UTAMA (ROLE BASED)
                    Text(
                      "Menu Utama",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActionsGrid(context),

                    const SizedBox(height: 32),

                    // 4. PASIEN TERBARU
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pasien Terbaru",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PatientListScreen(user: widget.user),
                              ),
                            );
                          },
                          child: const Text("Lihat Semua"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    (_dashboardData?.recentPatients.isEmpty ?? true)
                        ? _buildEmptyState()
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _dashboardData!.recentPatients.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final p = _dashboardData!.recentPatients[index];
                              return _buildPatientCard(p);
                            },
                          ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade50,
            child: Text(
              widget.user.fullName.isNotEmpty
                  ? widget.user.fullName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, ${widget.user.fullName}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade900,
              ),
            ),
            const SizedBox(height: 4),
            // ROLE BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: widget.user.isAdmin
                    ? Colors.orange.shade100
                    : widget.user.isDokter
                    ? Colors.green.shade100
                    : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.user.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: widget.user.isAdmin
                      ? Colors.orange.shade800
                      : widget.user.isDokter
                      ? Colors.green.shade800
                      : Colors.blue.shade800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color1,
    required Color color2,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color2.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              top: -15,
              child: Icon(
                icon,
                size: 90,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIC ROLE DISINI ---
  Widget _buildQuickActionsGrid(BuildContext context) {
    // List Menu Dinamis
    List<Widget> menuItems = [
      // 1. DATA PASIEN (Semua Role bisa akses)
      _buildMenuButton(
        context,
        "Data Pasien",
        Icons.people_outline_rounded,
        Colors.blue,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            // KIRIM USER DARI DASHBOARD KE LIST PASIEN
            builder: (_) => PatientListScreen(user: widget.user),
          ),
        ),
      ),

      // 2. LAPORAN (Semua Role bisa akses - atau bisa dibatasi)
      _buildMenuButton(
        context,
        "Laporan",
        Icons.analytics_outlined,
        Colors.purple,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportScreen()),
        ),
      ),
    ];

    // 3. KELOLA USER (Hanya Admin)
    if (widget.user.isAdmin) {
      menuItems.add(
        _buildMenuButton(
          context,
          "Kelola User",
          Icons.manage_accounts_outlined,
          Colors.teal,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserManagementScreen()),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: menuItems,
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32), // Ukuran Proporsional
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(RecentPatient p) {
    // Format Tanggal Manual (atau pakai intl jika formatnya string)
    String dateStr = p.createdAt.toIso8601String().split('T')[0];

    return Container(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _primaryColor.withOpacity(0.1),
          child: Text(
            p.nama.isNotEmpty ? p.nama[0].toUpperCase() : '?',
            style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          p.nama,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "RM: ${p.noRm}",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey.shade300,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientListScreen(user: widget.user),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Text(
              "Belum ada data pasien",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
