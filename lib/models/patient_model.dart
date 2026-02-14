import 'dart:convert';
import 'package:intl/intl.dart';

List<Patients> patientsFromJson(String str) =>
    List<Patients>.from(json.decode(str).map((x) => Patients.fromJson(x)));

String patientsToJson(List<Patients> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Patients {
  int id;
  String? noRm; // Boleh null
  String nama;
  String alamat;
  DateTime tanggalLahir;
  String jenisKelamin;
  String alergiObat;
  DateTime? createdAt; // Boleh null (dihandle server)
  DateTime? updatedAt;

  Patients({
    required this.id,
    this.noRm,
    required this.nama,
    required this.alamat,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.alergiObat,
    this.createdAt,
    this.updatedAt,
  });

  factory Patients.fromJson(Map<String, dynamic> json) => Patients(
    id: json["id"] ?? 0,
    noRm: json["no_rm"] ?? "",
    nama: json["nama"] ?? "",
    alamat: json["alamat"] ?? "",
    // Handle parsing tanggal dengan aman
    tanggalLahir: json["tanggal_lahir"] != null
        ? DateTime.tryParse(json["tanggal_lahir"]) ?? DateTime.now()
        : DateTime.now(),
    jenisKelamin: json["jenis_kelamin"] ?? "L",
    alergiObat: json["alergi_obat"] ?? "-",
    createdAt: json["created_at"] != null
        ? DateTime.tryParse(json["created_at"])
        : null,
    updatedAt: json["updated_at"] != null
        ? DateTime.tryParse(json["updated_at"])
        : null,
  );

  Map<String, dynamic> toJson() {
    // Format tanggal ke YYYY-MM-DD string untuk API Golang
    String tglLahirString = DateFormat('yyyy-MM-dd').format(tanggalLahir);

    return {
      // Jangan kirim ID jika 0 (create), tapi kirim jika update
      if (id != 0) "id": id,
      "no_rm": noRm ?? "",
      "nama": nama,
      "alamat": alamat,
      "tanggal_lahir": tglLahirString, // Kirim String, bukan DateTime obj
      "jenis_kelamin": jenisKelamin,
      "alergi_obat": alergiObat,
      // Jangan kirim created_at/updated_at dari client, biarkan server handle
    };
  }
}
