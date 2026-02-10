import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Map<String, dynamic>> _reportData = [];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() async {
    final db = await DatabaseHelper().database;
    final data = await db.rawQuery('''
      SELECT 
        patients.nama as pasien, 
        users.full_name as dokter, 
        medical_records.tanggal_periksa,
        medical_records.anamnesa_diagnosa
      FROM medical_records
      JOIN patients ON medical_records.patient_id = patients.id
      JOIN users ON medical_records.doctor_id = users.id
      ORDER BY medical_records.tanggal_periksa DESC
    ''');

    setState(() {
      _reportData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Laporan Kunjungan Klinik")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.teal.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Kunjungan: ${_reportData.length}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {}, // Nanti bisa fitur export PDF
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text("Cetak Laporan"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tabel Data
            Expanded(
              child: Card(
                elevation: 2,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        const Color(0xFF00796B),
                      ), // Header Teal
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      dataRowColor: MaterialStateProperty.resolveWith<Color?>((
                        Set<MaterialState> states,
                      ) {
                        return null; // Default putih
                      }),
                      columns: const [
                        DataColumn(label: Text("Tanggal")),
                        DataColumn(label: Text("Pasien")),
                        DataColumn(label: Text("Dokter Pemeriksa")),
                        DataColumn(label: Text("Diagnosa Utama")),
                      ],
                      rows: _reportData.asMap().entries.map((entry) {
                        int idx = entry.key;
                        Map<String, dynamic> row = entry.value;
                        // Efek Zebra Striping (Baris ganjil genap beda warna)
                        return DataRow(
                          color: MaterialStateProperty.all(
                            idx % 2 == 0 ? Colors.white : Colors.grey[50],
                          ),
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(row['tanggal_periksa']),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                row['pasien'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(Text(row['dokter'])),
                            DataCell(
                              Text(
                                row['anamnesa_diagnosa'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
