// To parse this JSON data, do
//
//     final medicalReports = medicalReportsFromJson(jsonString);

import 'dart:convert';

List<MedicalReports> medicalReportsFromJson(String str) =>
    List<MedicalReports>.from(
      json.decode(str).map((x) => MedicalReports.fromJson(x)),
    );

String medicalReportsToJson(List<MedicalReports> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MedicalReports {
  int? id;
  int? patientId;
  int? doctorId;
  DateTime? tanggalPeriksa;
  String? anamnesaDiagnosa;
  String? terapiTindakan;
  DateTime? createdAt;
  Patient? patient;
  Doctor? doctor;

  MedicalReports({
    this.id,
    this.patientId,
    this.doctorId,
    this.tanggalPeriksa,
    this.anamnesaDiagnosa,
    this.terapiTindakan,
    this.createdAt,
    this.patient,
    this.doctor,
  });

  factory MedicalReports.fromJson(Map<String, dynamic> json) => MedicalReports(
    id: json["id"],
    patientId: json["patient_id"],
    doctorId: json["doctor_id"],
    tanggalPeriksa: json["tanggal_periksa"] == null
        ? null
        : DateTime.parse(json["tanggal_periksa"]),
    anamnesaDiagnosa: json["anamnesa_diagnosa"],
    terapiTindakan: json["terapi_tindakan"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
    doctor: json["doctor"] == null ? null : Doctor.fromJson(json["doctor"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patient_id": patientId,
    "doctor_id": doctorId,
    "tanggal_periksa":
        "${tanggalPeriksa!.year.toString().padLeft(4, '0')}-${tanggalPeriksa!.month.toString().padLeft(2, '0')}-${tanggalPeriksa!.day.toString().padLeft(2, '0')}",
    "anamnesa_diagnosa": anamnesaDiagnosa,
    "terapi_tindakan": terapiTindakan,
    "created_at": createdAt?.toIso8601String(),
    "patient": patient?.toJson(),
    "doctor": doctor?.toJson(),
  };
}

class Doctor {
  int? id;
  String? username;
  String? password;
  String? role;
  String? fullName;
  DateTime? createdAt;

  Doctor({
    this.id,
    this.username,
    this.password,
    this.role,
    this.fullName,
    this.createdAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json["id"],
    username: json["username"],
    password: json["password"],
    role: json["role"],
    fullName: json["full_name"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "password": password,
    "role": role,
    "full_name": fullName,
    "created_at": createdAt?.toIso8601String(),
  };
}

class Patient {
  int? id;
  String? noRm;
  String? nama;
  String? alamat;
  String? tanggalLahir;
  String? jenisKelamin;
  String? alergiObat;
  DateTime? createdAt;
  DateTime? updatedAt;

  Patient({
    this.id,
    this.noRm,
    this.nama,
    this.alamat,
    this.tanggalLahir,
    this.jenisKelamin,
    this.alergiObat,
    this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json["id"],
    noRm: json["no_rm"],
    nama: json["nama"],
    alamat: json["alamat"],
    tanggalLahir: json["tanggal_lahir"],
    jenisKelamin: json["jenis_kelamin"],
    alergiObat: json["alergi_obat"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "no_rm": noRm,
    "nama": nama,
    "alamat": alamat,
    "tanggal_lahir": tanggalLahir,
    "jenis_kelamin": jenisKelamin,
    "alergi_obat": alergiObat,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
