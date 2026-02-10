class Patient {
  final int? id;
  final String noRm; // Nomor Rekam Medis
  final String nama;
  final String alamat;
  final String tanggalLahir;
  final String jenisKelamin; // 'L' atau 'P'
  final String alergiObat; // Penting!
  final String createdAt;

  Patient({
    this.id,
    required this.noRm,
    required this.nama,
    required this.alamat,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.alergiObat,
    required this.createdAt,
  });

  // Dari Database ke Dart
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      noRm: map['no_rm'],
      nama: map['nama'],
      alamat: map['alamat'],
      tanggalLahir: map['tanggal_lahir'],
      jenisKelamin: map['jenis_kelamin'],
      alergiObat: map['alergi_obat'],
      createdAt: map['created_at'],
    );
  }

  // Dari Dart ke Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'no_rm': noRm,
      'nama': nama,
      'alamat': alamat,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'alergi_obat': alergiObat,
      'created_at': createdAt,
    };
  }
}
