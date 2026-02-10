import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _users = [];

  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  String _selectedRole = 'perawat';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    final data = await DatabaseHelper().getUsers();
    setState(() {
      _users = data.map((e) => User.fromMap(e)).toList();
    });
  }

  void _addUser() async {
    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) return;

    User newUser = User(
      username: _usernameCtrl.text,
      password: _passwordCtrl.text,
      role: _selectedRole,
      fullName: _nameCtrl.text,
    );

    await DatabaseHelper().insertUser(newUser.toMap());

    _usernameCtrl.clear();
    _passwordCtrl.clear();
    _nameCtrl.clear();
    _loadUsers();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("User Berhasil Ditambah")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen Pengguna (Admin)")),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PANEL KIRI: FORM TAMBAH ---
          Container(
            width: 350, // Fixed width biar rapi
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tambah Staff Baru",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Isi form di bawah untuk mendaftarkan dokter atau perawat baru.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Divider(height: 30),

                const Text(
                  "Informasi Akun",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Biodata",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nama Lengkap",
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: "Role / Jabatan",
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'dokter', child: Text("Dokter")),
                    DropdownMenuItem(value: 'perawat', child: Text("Perawat")),
                    DropdownMenuItem(
                      value: 'user',
                      child: Text("Staf Pendaftaran"),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _addUser,
                    child: const Text("SIMPAN USER BARU"),
                  ),
                ),
              ],
            ),
          ),

          // --- PANEL KANAN: LIST USER ---
          Expanded(
            child: Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daftar Pengguna Aktif (${_users.length})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _users.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        // Warna avatar beda-beda sesuai role
                        Color roleColor = user.role == 'dokter'
                            ? Colors.teal
                            : (user.role == 'perawat'
                                  ? Colors.blue
                                  : Colors.orange);

                        return Card(
                          margin: EdgeInsets.zero,
                          elevation: 1,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: roleColor.withOpacity(0.1),
                              child: Text(
                                user.fullName.isNotEmpty
                                    ? user.fullName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: roleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              user.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  size: 14,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "@${user.username}  •  ${user.role.toUpperCase()}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              tooltip: "Hapus User",
                              onPressed: () async {
                                // Idealnya ada konfirmasi dialog di sini
                                await DatabaseHelper().deleteUser(user.id!);
                                _loadUsers();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
