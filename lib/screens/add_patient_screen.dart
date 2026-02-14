import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Wajib: flutter pub add intl
import '../models/patient_model.dart';
import '../services/api_service.dart';

class AddPatientScreen extends StatefulWidget {
  final Patients? patient; // Jika null = Tambah Baru, Jika ada = Edit Mode
  const AddPatientScreen({super.key, this.patient});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _noRmController = TextEditingController();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tglLahirController = TextEditingController();
  final _alergiController = TextEditingController(text: "-"); // Default "-"

  String _jenisKelamin = 'L';
  bool _isLoading = false;
  bool _isEditMode = false;

  // Warna Tema Konsisten
  final Color _primaryColor = const Color(0xFF1E88E5);

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _isEditMode = true;
      _noRmController.text = widget.patient!.noRm ?? "";
      _namaController.text = widget.patient!.nama;
      _alamatController.text = widget.patient!.alamat;

      // Format Tanggal dari DateTime ke String untuk Controller
      _tglLahirController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.patient!.tanggalLahir);

      _jenisKelamin = widget.patient!.jenisKelamin;
      _alergiController.text = widget.patient!.alergiObat;
    }
  }

  // Fungsi Simpan Data ke API
  void _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Parsing Tanggal Aman
      DateTime parsedTglLahir = DateTime.parse(_tglLahirController.text);

      // Siapkan Objek Patient
      Patients patientData = Patients(
        id: widget.patient?.id ?? 0,
        noRm: _noRmController.text.isEmpty
            ? ""
            : _noRmController.text, // Kirim string kosong jika auto
        nama: _namaController.text,
        alamat: _alamatController.text,
        jenisKelamin: _jenisKelamin,
        tanggalLahir: parsedTglLahir,
        alergiObat: _alergiController.text,
        // Gunakan createdAt lama jika edit, null jika baru (server yg handle/atau DateTime.now)
        createdAt: _isEditMode ? widget.patient?.createdAt : DateTime.now(),
      );

      bool success;
      final api = ApiService();

      if (_isEditMode) {
        success = await api.updatePatient(widget.patient!.id, patientData);
      } else {
        success = await api.createPatient(patientData);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(context); // Kembali ke list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? "Data Berhasil Diupdate"
                  : "Pasien Berhasil Ditambahkan",
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Gagal menyimpan data. Cek koneksi atau No RM duplikat.",
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper untuk DatePicker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format ke YYYY-MM-DD (Standar MySQL/API)
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        _tglLahirController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 Background
      appBar: AppBar(
        title: Text(
          _isEditMode ? "Edit Pasien" : "Tambah Pasien Baru",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // CARD FORMULIR
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // INFO HEADER
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              color: _primaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Informasi Pasien",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Lengkapi data diri pasien dengan benar",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 30, thickness: 1),

                      // FIELD 1: NO RM
                      _buildTextField(
                        controller: _noRmController,
                        label: "No. Rekam Medis (Opsional)",
                        icon: Icons.badge_outlined,
                        hint: "Kosongkan untuk Auto-Generate",
                        validator: (val) => null, // Boleh kosong
                      ),
                      const SizedBox(height: 16),

                      // FIELD 2: NAMA LENGKAP
                      _buildTextField(
                        controller: _namaController,
                        label: "Nama Lengkap",
                        icon: Icons.person_outline_rounded,
                        hint: "Masukkan nama pasien",
                        validator: (val) =>
                            val!.isEmpty ? "Nama wajib diisi" : null,
                      ),
                      const SizedBox(height: 16),

                      // FIELD 3 & 4: GENDER & TGL LAHIR (ROW)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // GENDER DROPDOWN
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _jenisKelamin,
                              decoration: _inputDecoration(
                                "Gender",
                                Icons.wc_rounded,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'L',
                                  child: Text("Laki-laki"),
                                ),
                                DropdownMenuItem(
                                  value: 'P',
                                  child: Text("Perempuan"),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => _jenisKelamin = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // DATE PICKER
                          Expanded(
                            child: TextFormField(
                              controller: _tglLahirController,
                              readOnly: true,
                              decoration: _inputDecoration(
                                "Tgl Lahir",
                                Icons.calendar_today_rounded,
                              ),
                              onTap: () => _selectDate(context),
                              validator: (val) =>
                                  val!.isEmpty ? "Wajib diisi" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // FIELD 5: ALAMAT
                      _buildTextField(
                        controller: _alamatController,
                        label: "Alamat Lengkap",
                        icon: Icons.home_outlined,
                        maxLines: 3,
                        validator: (val) =>
                            val!.isEmpty ? "Alamat wajib diisi" : null,
                      ),
                      const SizedBox(height: 16),

                      // FIELD 6: ALERGI (Opsional/Warning)
                      _buildTextField(
                        controller: _alergiController,
                        label: "Riwayat Alergi Obat",
                        icon: Icons.warning_amber_rounded,
                        iconColor: Colors.orange,
                        hint: "Isi '-' jika tidak ada",
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // TOMBOL SIMPAN
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    shadowColor: _primaryColor.withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.save_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              "SIMPAN DATA",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET HELPER: TEXT FIELD CUSTOM
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    Color iconColor = Colors.grey,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(
        label,
        icon,
        hint: hint,
        iconColor: iconColor,
      ),
      validator: validator,
    );
  }

  // STYLE DECORATION INPUT (Konsisten)
  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
    Color iconColor = Colors.grey,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: iconColor == Colors.grey ? _primaryColor : iconColor,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: Colors.blueGrey.shade600),
    );
  }
}
