// To parse this JSON data, do
//
//     final dashboard = dashboardFromJson(jsonString);

import 'dart:convert';

Dashboard dashboardFromJson(String str) => Dashboard.fromJson(json.decode(str));

String dashboardToJson(Dashboard data) => json.encode(data.toJson());

class Dashboard {
  List<RecentPatient> recentPatients;
  int totalPatients;
  int visitsToday;

  Dashboard({
    required this.recentPatients,
    required this.totalPatients,
    required this.visitsToday,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) => Dashboard(
    recentPatients: List<RecentPatient>.from(
      json["recent_patients"].map((x) => RecentPatient.fromJson(x)),
    ),
    totalPatients: json["total_patients"],
    visitsToday: json["visits_today"],
  );

  Map<String, dynamic> toJson() => {
    "recent_patients": List<dynamic>.from(
      recentPatients.map((x) => x.toJson()),
    ),
    "total_patients": totalPatients,
    "visits_today": visitsToday,
  };
}

class RecentPatient {
  int id;
  String noRm;
  String nama;
  String alamat;
  DateTime tanggalLahir;
  String jenisKelamin;
  String alergiObat;
  DateTime createdAt;
  DateTime updatedAt;

  RecentPatient({
    required this.id,
    required this.noRm,
    required this.nama,
    required this.alamat,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.alergiObat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecentPatient.fromJson(Map<String, dynamic> json) => RecentPatient(
    id: json["id"],
    noRm: json["no_rm"],
    nama: json["nama"],
    alamat: json["alamat"],
    tanggalLahir: DateTime.parse(json["tanggal_lahir"]),
    jenisKelamin: json["jenis_kelamin"],
    alergiObat: json["alergi_obat"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "no_rm": noRm,
    "nama": nama,
    "alamat": alamat,
    "tanggal_lahir":
        "${tanggalLahir.year.toString().padLeft(4, '0')}-${tanggalLahir.month.toString().padLeft(2, '0')}-${tanggalLahir.day.toString().padLeft(2, '0')}",
    "jenis_kelamin": jenisKelamin,
    "alergi_obat": alergiObat,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
