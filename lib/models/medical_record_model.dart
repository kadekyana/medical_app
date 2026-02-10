class MedicalRecord {
  final int? id;
  final int patientId;
  final int doctorId;
  final String tanggalPeriksa;
  final String anamnesa; // Keluhan & Diagnosa
  final String terapi; // Obat & Tindakan

  MedicalRecord({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.tanggalPeriksa,
    required this.anamnesa,
    required this.terapi,
  });

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id'],
      patientId: map['patient_id'],
      doctorId: map['doctor_id'],
      tanggalPeriksa: map['tanggal_periksa'],
      anamnesa: map['anamnesa_diagnosa'], // Sesuai nama kolom di DB
      terapi: map['terapi_tindakan'], // Sesuai nama kolom di DB
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'tanggal_periksa': tanggalPeriksa,
      'anamnesa_diagnosa': anamnesa,
      'terapi_tindakan': terapi,
    };
  }
}
