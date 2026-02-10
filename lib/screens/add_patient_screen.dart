import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/patient_model.dart';

class AddPatientScreen extends StatefulWidget {
  final Patient? patient;
  const AddPatientScreen({super.key, this.patient});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tglLahirController = TextEditingController();
  final _alergiController = TextEditingController(text: "-"); // Default -

  String _jenisKelamin = 'L';
  String _noRM = 'Loading...';

  bool _isEditMode = false; // Penanda mode edit

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _isEditMode = true;
      _noRM = widget.patient!.noRm;
      _namaController.text = widget.patient!.nama;
      _alamatController.text = widget.patient!.alamat;
      _tglLahirController.text = widget.patient!.tanggalLahir;
      _jenisKelamin = widget.patient!.jenisKelamin;
      _alergiController.text = widget.patient!.alergiObat;
    } else {
      _generateRM();
    }
  }

  void _savePatient() async {
    if (_formKey.currentState!.validate()) {
      Patient patientData = Patient(
        id: widget.patient?.id,
        noRm: _noRM,
        nama: _namaController.text,
        alamat: _alamatController.text,
        tanggalLahir: _tglLahirController.text,
        jenisKelamin: _jenisKelamin,
        alergiObat: _alergiController.text,
        createdAt: widget.patient?.createdAt ?? DateTime.now().toString(),
      );

      if (_isEditMode) {
        await DatabaseHelper().updatePatient(patientData.toMap());
      } else {
        await DatabaseHelper().insertPatient(patientData.toMap());
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? "Data Diupdate" : "Data Disimpan"),
        ),
      );
    }
  }

  void _generateRM() async {
    String rm = await DatabaseHelper().generateNoRM();
    setState(() {
      _noRM = rm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Pasien Baru")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Header Info RM (Read Only)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.teal.shade50,
                child: Text(
                  "Nomor Rekam Medis: $_noRM",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _jenisKelamin,
                      decoration: const InputDecoration(
                        labelText: "Jenis Kelamin",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'L', child: Text("Laki-laki")),
                        DropdownMenuItem(value: 'P', child: Text("Perempuan")),
                      ],
                      onChanged: (val) => setState(() => _jenisKelamin = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _tglLahirController,
                      decoration: const InputDecoration(
                        labelText: "Tanggal Lahir (YYYY-MM-DD)",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        // Date Picker sederhana
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _tglLahirController.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _alamatController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Alamat",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _alergiController,
                decoration: const InputDecoration(
                  labelText: "Riwayat Alergi Obat",
                  border: OutlineInputBorder(),
                  helperText: "Isi '-' jika tidak ada alergi.",
                  prefixIcon: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _savePatient,
                  child: const Text("SIMPAN DATA PASIEN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
