class User {
  final int? id;
  final String username;
  final String password;
  final String role;
  final String fullName;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.fullName,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password_hash'],
      role: map['role'],
      fullName: map['full_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': password,
      'role': role,
      'full_name': fullName,
    };
  }
}
