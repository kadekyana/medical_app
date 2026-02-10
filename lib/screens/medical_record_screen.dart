import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/patient_model.dart';
import '../models/user_model.dart';
import '../models/medical_record_model.dart';

class MedicalRecordScreen extends StatefulWidget {
  final Patient patient;
  final User doctor; // User yang sedang login

  const MedicalRecordScreen({
    super.key,
    required this.patient,
    required this.doctor,
  });

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  final _anamnesaController = TextEditingController();
  final _terapiController = TextEditingController();
  List<MedicalRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final data = await DatabaseHelper().getMedicalRecordsByPatient(
      widget.patient.id!,
    );
    setState(() {
      _records = data.map((e) => MedicalRecord.fromMap(e)).toList();
    });
  }

  void _saveRecord() async {
    if (_anamnesaController.text.isEmpty) return;

    String today = DateTime.now().toString().split(' ')[0];

    MedicalRecord newRecord = MedicalRecord(
      patientId: widget.patient.id!,
      doctorId: widget.doctor.id!,
      tanggalPeriksa: today,
      anamnesa: _anamnesaController.text,
      terapi: _terapiController.text,
    );

    await DatabaseHelper().insertMedicalRecord(newRecord.toMap());

    _anamnesaController.clear();
    _terapiController.clear();
    _loadHistory();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Rekam Medis Tersimpan")));
  }

  void _deleteRecord(int id) async {
    await DatabaseHelper().deleteMedicalRecord(id);
    _loadHistory();
  }

  void _showEditDialog(MedicalRecord record) {
    final anamnesaEditCtrl = TextEditingController(text: record.anamnesa);
    final terapiEditCtrl = TextEditingController(text: record.terapi);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Rekam Medis"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: anamnesaEditCtrl,
              decoration: const InputDecoration(labelText: "Anamnesa"),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: terapiEditCtrl,
              decoration: const InputDecoration(labelText: "Terapi"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Map<String, dynamic> updatedRow = {
                'id': record.id,
                'patient_id': record.patientId,
                'doctor_id': record.doctorId,
                'tanggal_periksa': record.tanggalPeriksa,
                'anamnesa_diagnosa': anamnesaEditCtrl.text,
                'terapi_tindakan': terapiEditCtrl.text,
              };
              await DatabaseHelper().updateMedicalRecord(updatedRow);
              Navigator.pop(context);
              _loadHistory();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasAllergy =
        widget.patient.alergiObat.isNotEmpty &&
        widget.patient.alergiObat != '-';
    // LOGIC UTAMA: Cek apakah user adalah dokter
    bool isDoctor = widget.doctor.role == 'dokter';

    return Scaffold(
      appBar: AppBar(title: Text("Rekam Medis: ${widget.patient.nama}")),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PANEL KIRI (INPUT FORM) ---
          // HANYA MUNCUL JIKA DOKTER
          if (isDoctor)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientInfoCard(hasAllergy),
                    const SizedBox(height: 32),

                    const Text(
                      "Pemeriksaan Hari Ini",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _anamnesaController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Anamnesa / Diagnosa / Lab",
                        hintText: "Keluhan pasien...",
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _terapiController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Terapi / Tindakan / Obat",
                        hintText: "Resep obat...",
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("SIMPAN REKAM MEDIS"),
                        onPressed: _saveRecord,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // --- PANEL KANAN (TIMELINE RIWAYAT) ---
          // Jika User biasa, panel ini akan mengambil Full Width (Expanded flex-nya menyesuaikan)
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: const Color(0xFFF5F7FA), // Background abu muda
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Jika User biasa, Info Pasien muncul di atas sini karena panel kiri hilang
                  if (!isDoctor) ...[
                    _buildPatientInfoCard(hasAllergy),
                    const SizedBox(height: 24),
                  ],

                  const Text(
                    "Riwayat Pemeriksaan (Kartu Status)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: _records.isEmpty
                        ? Center(
                            child: Text(
                              "Belum ada riwayat medis.",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _records.length,
                            itemBuilder: (context, index) {
                              final record = _records[index];
                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: const BoxDecoration(
                                            color: Colors.teal,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            width: 2,
                                            color: Colors.teal.shade100,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 24.0,
                                        ),
                                        child: Card(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            side: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.calendar_today,
                                                          size: 14,
                                                          color: Colors.teal,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          record.tanggalPeriksa,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.teal,
                                                                fontSize: 16,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Tombol Edit/Delete HANYA UNTUK DOKTER
                                                    if (isDoctor)
                                                      Row(
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.edit,
                                                              size: 18,
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                            onPressed: () =>
                                                                _showEditDialog(
                                                                  record,
                                                                ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              size: 18,
                                                              color: Colors.red,
                                                            ),
                                                            onPressed: () =>
                                                                _deleteRecord(
                                                                  record.id!,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                                const Divider(height: 24),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "KELUHAN & DIAGNOSA",
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .grey[600],
                                                              letterSpacing: 1,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            record.anamnesa,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 15,
                                                                  height: 1.4,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "TERAPI & OBAT",
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .teal[700],
                                                              letterSpacing: 1,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            record.terapi,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  height: 1.4,
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Info Pasien dipisah agar bisa dipakai ulang
  Widget _buildPatientInfoCard(bool hasAllergy) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasAllergy ? Colors.red.shade50 : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasAllergy ? Colors.red.shade100 : Colors.teal.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("No RM", widget.patient.noRm),
          _buildInfoRow("Nama", widget.patient.nama),
          _buildInfoRow("Usia / Tgl Lahir", widget.patient.tanggalLahir),
          const Divider(),
          Row(
            children: [
              const Text(
                "ALERGI OBAT: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                widget.patient.alergiObat,
                style: TextStyle(
                  color: hasAllergy ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text("$label", style: const TextStyle(color: Colors.grey)),
          ),
          Text(":  ", style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
