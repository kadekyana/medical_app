import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/models/patient_model.dart';
import 'package:medical_app/models/user_model.dart'; // Import User Model
import 'package:medical_app/services/api_service.dart';
import '../models/medical_record_model.dart';

class MedicalRecordScreen extends StatefulWidget {
  final Patients patient;
  final Users user; // TERIMA DATA USER YANG LOGIN

  const MedicalRecordScreen({
    super.key,
    required this.patient,
    required this.user,
  });

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  List<MedicalReports> _records = [];
  bool _isLoading = true;

  final Color _primaryColor = const Color(0xFF1E88E5);

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final data = await ApiService().getRecords(widget.patient.id);
    if (mounted) {
      setState(() {
        _records = data;
        _isLoading = false;
      });
    }
  }

  void _showAddRecordModal() {
    final anamnesaController = TextEditingController();
    final terapiController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note_add_rounded, color: _primaryColor),
                        const SizedBox(width: 10),
                        const Text(
                          "Tambah Rekam Medis",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    TextFormField(
                      controller: anamnesaController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Anamnesa & Diagnosa",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: terapiController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "Terapi / Tindakan",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  setModalState(() => isSaving = true);

                                  MedicalReports newRecord = MedicalReports(
                                    id: 0,
                                    patientId: widget.patient.id,
                                    // GUNAKAN ID DOKTER YANG SEDANG LOGIN
                                    doctorId: widget.user.id,
                                    tanggalPeriksa: DateTime.now(),
                                    anamnesaDiagnosa: anamnesaController.text,
                                    terapiTindakan: terapiController.text,
                                  );

                                  bool success = await ApiService()
                                      .createRecord(newRecord);

                                  if (mounted) {
                                    Navigator.pop(context);
                                    if (success) {
                                      _loadRecords();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Tersimpan"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Gagal menyimpan"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "SIMPAN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Riwayat Pemeriksaan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // LOGIKA UTAMA: Cek apakah user adalah dokter?
      // Jika Dokter -> Tampilkan tombol. Jika Bukan -> Null (Hilang).
      floatingActionButton: widget.user.isDokter
          ? FloatingActionButton.extended(
              onPressed: _showAddRecordModal,
              backgroundColor: _primaryColor,
              icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
              label: const Text(
                "Diagnosa Baru",
                style: TextStyle(color: Colors.white),
              ),
            )
          : null, // Tombol hilang untuk user/staff
      body: Column(
        children: [
          _buildPatientInfoCard(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadRecords,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 80),
                      itemCount: _records.length,
                      itemBuilder: (context, index) =>
                          _buildRecordCard(_records[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ... (Widget _buildPatientInfoCard, _buildRecordCard, _buildEmptyState SAMA SEPERTI SEBELUMNYA) ...
  // Silakan copy paste bagian widget UI bawahnya dari kode sebelumnya agar tidak kepanjangan
  // Bagian pentingnya ada di Class Definition & FloatingActionButton di atas.

  Widget _buildPatientInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              widget.patient.nama[0].toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patient.nama,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "RM: ${widget.patient.noRm}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(MedicalReports record) {
    DateTime date =
        DateTime.tryParse(record.tanggalPeriksa.toString()) ?? DateTime.now();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('dd').format(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              Text(
                DateFormat('MMM').format(date),
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
        title: Text(
          record.anamnesaDiagnosa ?? '-',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.terapiTindakan ?? '-',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "Dr. ${record.doctor?.fullName ?? '-'}",
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() => const Center(child: Text("Belum ada riwayat"));
}
