import 'package:flutter/material.dart';
import 'package:medical_app/models/user_model.dart';
import 'package:medical_app/screens/medical_record_screen.dart';
import '../db/database_helper.dart';
import '../models/patient_model.dart';
import 'add_patient_screen.dart';

class PatientListScreen extends StatefulWidget {
  final User currentUser;
  const PatientListScreen({super.key, required this.currentUser});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Patient> _allPatients = []; // Data asli
  List<Patient> _filteredPatients = []; // Data hasil search
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshPatientList();
  }

  void _refreshPatientList() async {
    final data = await DatabaseHelper().getPatients();
    setState(() {
      _allPatients = data.map((e) => Patient.fromMap(e)).toList();
      _filteredPatients = _allPatients; // Awalnya tampilkan semua
      _isLoading = false;
    });
  }

  // Logika Pencarian
  void _filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients = _allPatients.where((patient) {
          return patient.nama.toLowerCase().contains(query.toLowerCase()) ||
              patient.noRm.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Pasien"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Pasien Baru"),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const AddPatientScreen()),
                );
                _refreshPatientList();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- 1. HEADER PENCARIAN (BARU) ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _filterPatients,
              decoration: InputDecoration(
                hintText: "Cari nama pasien atau No. RM...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterPatients('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // --- 2. TABEL DATA ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Data tidak ditemukan",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        // Bungkus tabel dengan Card biar rapi
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.teal.shade50,
                          ),
                          columnSpacing: 20,
                          dataRowHeight: 60,
                          columns: const [
                            DataColumn(
                              label: Text(
                                "No. RM",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Nama Pasien",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "L/P",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Umur/Tgl Lahir",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Status",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Aksi",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: _filteredPatients.map((patient) {
                            bool hasAllergy =
                                patient.alergiObat.isNotEmpty &&
                                patient.alergiObat != '-';
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    patient.noRm,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    patient.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: patient.jenisKelamin == 'L'
                                          ? Colors.blue.shade50
                                          : Colors.pink.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      patient.jenisKelamin,
                                      style: TextStyle(
                                        color: patient.jenisKelamin == 'L'
                                            ? Colors.blue
                                            : Colors.pink,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(patient.tanggalLahir)),
                                DataCell(
                                  hasAllergy
                                      ? Chip(
                                          label: Text(
                                            "Alergi: ${patient.alergiObat}",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          padding: EdgeInsets.zero,
                                        )
                                      : const Chip(
                                          label: Text(
                                            "Normal",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          backgroundColor: Colors.greenAccent,
                                        ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.orange,
                                        ),
                                        tooltip: "Edit Data",
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (c) => AddPatientScreen(
                                                patient: patient,
                                              ),
                                            ),
                                          );
                                          _refreshPatientList();
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.medical_services_outlined,
                                          size: 16,
                                        ),
                                        label: const Text("Periksa"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (c) =>
                                                  MedicalRecordScreen(
                                                    patient: patient,
                                                    doctor: widget.currentUser,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
