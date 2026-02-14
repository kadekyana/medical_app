import 'dart:convert';

List<Users> usersFromJson(String str) =>
    List<Users>.from(json.decode(str).map((x) => Users.fromJson(x)));

String usersToJson(List<Users> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Users {
  int id;
  String username;
  String? password;
  String role; // 'admin', 'dokter', 'user'
  String fullName;
  DateTime? createdAt;

  Users({
    required this.id,
    required this.username,
    this.password,
    required this.role,
    required this.fullName,
    this.createdAt,
  });

  // --- HELPER UNTUK CEK ROLE ---
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isDokter => role.toLowerCase() == 'dokter';
  bool get isUser => role.toLowerCase() == 'user';
  // -----------------------------

  factory Users.fromJson(Map<String, dynamic> json) => Users(
    id: json["id"] ?? 0,
    username: json["username"] ?? "",
    password: json["password"],
    role: json["role"] ?? "user",
    fullName: json["full_name"] ?? "",
    createdAt: json["created_at"] != null
        ? DateTime.tryParse(json["created_at"])
        : null,
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "username": username,
      "role": role,
      "full_name": fullName,
    };
    if (id != 0) data["id"] = id;
    if (password != null && password!.isNotEmpty) {
      data["password"] = password;
    }
    return data;
  }
}
