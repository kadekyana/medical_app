import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/models/reports_model.dart';
import 'package:medical_app/services/api_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // Data List menggunakan Model Reports
  List<Reports> _allReports = [];
  List<Reports> _filteredReports = [];

  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // Warna Tema
  final Color _primaryColor = const Color(0xFF1E88E5);
  // final Color _accentColor = const Color(0xFFE3F2FD);
  final Color _headerTextColor = const Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() async {
    setState(() => _isLoading = true);

    // ApiService mengembalikan List<Reports>
    final data = await ApiService().getReports();

    if (mounted) {
      setState(() {
        _allReports = data;
        _filteredReports = data;
        _isLoading = false;
      });
    }
  }

  void _filterReports(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredReports = _allReports.where((item) {
        // Karena Backend Go menggunakan Custom Query (Flat JSON),
        // Kita akses properti String langsung dari model Reports.
        final pasien = item.pasien.toLowerCase();
        final dokter = item.dokter.toLowerCase();
        final diagnosa = item.anamnesaDiagnosa.toLowerCase();

        return pasien.contains(lowerQuery) ||
            dokter.contains(lowerQuery) ||
            diagnosa.contains(lowerQuery);
      }).toList();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    try {
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      appBar: AppBar(
        title: const Text(
          "Laporan Kunjungan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. BAGIAN ATAS (SEARCH & SUMMARY)
          _buildTopBar(),

          // 2. HEADER TABEL (Sticky)
          _buildTableHeader(),

          // 3. ISI TABEL (Scrollable)
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: _primaryColor))
                : _filteredReports.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async => _loadReports(),
                    color: _primaryColor,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: _filteredReports.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildReportRow(_filteredReports[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Top Bar (Search & Card Total)
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Card Total Data
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.assignment_turned_in_rounded,
                    color: _primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Laporan",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blueGrey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${_filteredReports.length}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Search Bar Expanded
          Expanded(
            child: Container(
              height: 55, // Tinggi disamakan agar rapi
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), // Slate 50
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari Pasien / Dokter...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _filterReports('');
                          },
                        )
                      : null,
                ),
                onChanged: _filterReports,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _buildColumnHeader("TANGGAL", flex: 3),
          _buildColumnHeader("PASIEN", flex: 3),
          _buildColumnHeader("DOKTER", flex: 3),
          _buildColumnHeader("DIAGNOSA", flex: 4),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(String title, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: TextStyle(
          color: _headerTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // WIDGET: Row Data (Item List)
  Widget _buildReportRow(Reports report) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. TANGGAL (Flex 3)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDate(report.tanggalPeriksa),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. PASIEN (Flex 3)
          Expanded(
            flex: 3,
            child: Text(
              report.pasien, // Menggunakan String langsung (Flat Model)
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 3. DOKTER (Flex 3)
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                // color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                report.dokter, // Menggunakan String langsung (Flat Model)
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // 4. DIAGNOSA (Flex 4)
          Expanded(
            flex: 4,
            child: Text(
              report.anamnesaDiagnosa, // Menggunakan String langsung
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 50,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Data tidak ditemukan",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Coba kata kunci lain atau tarik untuk refresh",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
