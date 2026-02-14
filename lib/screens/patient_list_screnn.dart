import 'package:flutter/material.dart';
import 'package:medical_app/models/user_model.dart';
import 'package:medical_app/screens/medical_record_screen.dart';
import 'package:medical_app/services/api_service.dart';
import '../models/patient_model.dart';
import 'add_patient_screen.dart';

class PatientListScreen extends StatefulWidget {
  final Users user; // Tambahkan ini
  const PatientListScreen({super.key, required this.user});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Patients> _patients = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  // Warna Utama (Biru Medis)
  final Color _primaryColor = const Color(0xFF1E88E5);

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  void _fetchPatients({String? query}) async {
    setState(() => _isLoading = true);
    final data = await ApiService().getPatients(query: query);

    if (mounted) {
      setState(() {
        _patients = data;
        _isLoading = false;
      });
    }
  }

  // LOGIC HAPUS PASIEN
  void _confirmDelete(Patients patient) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Pasien"),
        content: Text(
          "Apakah anda yakin ingin menghapus data '${patient.nama}'?\n\nPERINGATAN: Semua rekam medis pasien ini juga akan terhapus!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog

              // Tampilkan Loading Indicator sementara
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Menghapus data...")),
              );

              bool success = await ApiService().deletePatient(patient.id);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Pasien berhasil dihapus"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _fetchPatients(); // Refresh list
                } else {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gagal menghapus pasien"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Logic Navigasi ke Edit
  void _navigateToEdit(Patients patient) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPatientScreen(patient: patient), // Kirim data lama
      ),
    );
    _fetchPatients(); // Refresh setelah kembali dari edit
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return Colors.grey;
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      appBar: AppBar(
        title: const Text(
          "Data Pasien",
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPatientScreen()),
          );
          _fetchPatients();
        },
        backgroundColor: _primaryColor,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text("Pasien Baru", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // 1. HEADER PENCARIAN
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: "Cari Nama atau No RM...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.search, color: _primaryColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _fetchPatients();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (val) => _fetchPatients(query: val),
                    onChanged: (val) {
                      if (val.isEmpty) _fetchPatients();
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 2. LIST PASIEN
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _patients.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async => _fetchPatients(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _patients.length,
                      itemBuilder: (context, index) {
                        final patient = _patients[index];
                        return _buildPatientCard(patient);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Patients patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Default Tap: Ke Rekam Medis
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MedicalRecordScreen(patient: patient, user: widget.user),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // AVATAR
              CircleAvatar(
                radius: 28,
                backgroundColor: _getAvatarColor(patient.nama).withOpacity(0.1),
                child: Text(
                  patient.nama.isNotEmpty ? patient.nama[0].toUpperCase() : "?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getAvatarColor(patient.nama),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // INFO TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "RM: ${patient.noRm}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          patient.jenisKelamin == 'L'
                              ? Icons.male
                              : Icons.female,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patient.alamat,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // MENU ACTIONS (Edit & Delete)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEdit(patient);
                  } else if (value == 'delete') {
                    _confirmDelete(patient);
                  } else if (value == 'record') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicalRecordScreen(
                          patient: patient,
                          user: widget.user,
                        ),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'record',
                    child: ListTile(
                      leading: Icon(
                        Icons.assignment_ind_outlined,
                        color: Colors.green,
                      ),
                      title: Text('Rekam Medis'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined, color: Colors.blue),
                      title: Text('Edit Data'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Hapus Pasien'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_off_rounded,
              size: 60,
              color: Colors.blue.shade200,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Pasien tidak ditemukan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Coba kata kunci lain",
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
