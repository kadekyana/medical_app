class User {
  final int id;
  final String username;
  final String fullName;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'] ?? '', // Sesuai JSON tag di Go
      role: json['role'] ?? 'user',
    );
  }
}

class Patient {
  final int id;
  final String noRM;
  final String nama;
  final String alamat;
  final String jenisKelamin;

  Patient({
    required this.id,
    required this.noRM,
    required this.nama,
    required this.alamat,
    required this.jenisKelamin,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      noRM: json['no_rm'] ?? '-',
      nama: json['nama'] ?? '',
      alamat: json['alamat'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
    );
  }

  // Untuk mengirim data ke server (POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'no_rm': noRM,
      'nama': nama,
      'alamat': alamat,
      'jenis_kelamin': jenisKelamin,
    };
  }
}
