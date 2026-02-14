// To parse this JSON data, do
//
//     final reports = reportsFromJson(jsonString);

import 'dart:convert';

List<Reports> reportsFromJson(String str) =>
    List<Reports>.from(json.decode(str).map((x) => Reports.fromJson(x)));

String reportsToJson(List<Reports> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Reports {
  DateTime tanggalPeriksa;
  String pasien;
  String dokter;
  String anamnesaDiagnosa;

  Reports({
    required this.tanggalPeriksa,
    required this.pasien,
    required this.dokter,
    required this.anamnesaDiagnosa,
  });

  factory Reports.fromJson(Map<String, dynamic> json) => Reports(
    tanggalPeriksa: DateTime.parse(json["tanggal_periksa"]),
    pasien: json["pasien"],
    dokter: json["dokter"],
    anamnesaDiagnosa: json["anamnesa_diagnosa"],
  );

  Map<String, dynamic> toJson() => {
    "tanggal_periksa":
        "${tanggalPeriksa.year.toString().padLeft(4, '0')}-${tanggalPeriksa.month.toString().padLeft(2, '0')}-${tanggalPeriksa.day.toString().padLeft(2, '0')}",
    "pasien": pasien,
    "dokter": dokter,
    "anamnesa_diagnosa": anamnesaDiagnosa,
  };
}
