import 'package:flutter/material.dart';
import 'package:medical_app/services/api_service.dart';
import '../models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Users> _users = [];
  bool _isLoading = true;

  // Warna Tema
  final Color _primaryColor = const Color(0xFF1E88E5);

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    setState(() => _isLoading = true);
    final data = await ApiService().getUsers();
    if (mounted) {
      setState(() {
        _users = data;
        _isLoading = false;
      });
    }
  }

  // --- LOGIC HAPUS USER ---
  void _confirmDelete(Users user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Pengguna"),
        content: Text(
          "Apakah anda yakin ingin menghapus user '${user.username}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              bool success = await ApiService().deleteUser(user.id);
              if (mounted) {
                if (success) {
                  _loadUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("User berhasil dihapus"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gagal menghapus user"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- LOGIC TAMBAH / EDIT USER (MODAL) ---
  void _showUserForm({Users? user}) {
    // Jika user != null berarti Mode Edit
    final bool isEdit = user != null;

    final fullNameController = TextEditingController(
      text: isEdit ? user.fullName : '',
    );
    final usernameController = TextEditingController(
      text: isEdit ? user.username : '',
    );
    final passwordController =
        TextEditingController(); // Password kosong default
    String selectedRole = isEdit ? user.role : 'user';

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header dengan Ikon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isEdit ? Icons.edit_note : Icons.person_add,
                          color: _primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isEdit ? "Edit Pengguna" : "Tambah Pengguna Baru",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Input Nama Lengkap
                    TextFormField(
                      controller: fullNameController,
                      decoration: _inputDecoration(
                        "Nama Lengkap",
                        Icons.badge_outlined,
                      ),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Input Username
                    TextFormField(
                      controller: usernameController,
                      decoration: _inputDecoration(
                        "Username",
                        Icons.person_outline,
                      ),
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Input Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration:
                          _inputDecoration(
                            isEdit ? "Password Baru (Opsional)" : "Password",
                            Icons.lock_outline,
                          ).copyWith(
                            helperText: isEdit
                                ? "Kosongkan jika tidak ingin mengganti password"
                                : null,
                          ),
                      validator: (val) {
                        // Wajib diisi jika Mode Tambah. Opsional jika Mode Edit.
                        if (!isEdit && (val == null || val.length < 4)) {
                          return "Minimal 4 karakter";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Role
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: _inputDecoration(
                        "Role Akses",
                        Icons.security,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text("Administrator"),
                        ),
                        DropdownMenuItem(
                          value: 'dokter',
                          child: Text("Dokter"),
                        ),
                        DropdownMenuItem(
                          value: 'user',
                          child: Text("Staff / User"),
                        ),
                      ],
                      onChanged: (val) =>
                          setModalState(() => selectedRole = val!),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Simpan
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  setModalState(() => isSaving = true);

                                  // Siapkan Data
                                  Users userData = Users(
                                    id: isEdit ? user.id : 0,
                                    username: usernameController.text,
                                    fullName: fullNameController.text,
                                    role: selectedRole,
                                    // Kirim password jika diisi, jika kosong kirim null/string kosong
                                    password: passwordController.text.isNotEmpty
                                        ? passwordController.text
                                        : null,
                                  );

                                  bool success;
                                  if (isEdit) {
                                    success = await ApiService().updateUser(
                                      user.id,
                                      userData,
                                    );
                                  } else {
                                    success = await ApiService().createUser(
                                      userData,
                                    );
                                  }

                                  if (mounted) {
                                    Navigator.pop(context);
                                    if (success) {
                                      _loadUsers();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isEdit
                                                ? "User berhasil diupdate"
                                                : "User berhasil dibuat",
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Gagal menyimpan data"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isEdit ? "UPDATE DATA" : "SIMPAN USER",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Kelola Pengguna",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _primaryColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryColor,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("Tambah User", style: TextStyle(color: Colors.white)),
        onPressed: () => _showUserForm(), // Mode Tambah
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return _buildUserCard(user);
              },
            ),
    );
  }

  Widget _buildUserCard(Users user) {
    bool isAdmin = user.role.toLowerCase() == 'admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isAdmin
              ? Colors.orange.shade100
              : Colors.blue.shade100,
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : "U",
            style: TextStyle(
              color: isAdmin ? Colors.orange.shade800 : Colors.blue.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "@${user.username}",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAdmin
                      ? Colors.orange.shade200
                      : Colors.green.shade200,
                ),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isAdmin
                      ? Colors.orange.shade800
                      : Colors.green.shade800,
                ),
              ),
            ),
          ],
        ),
        // Action Button: Popup Menu (Edit & Delete)
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit') {
              _showUserForm(user: user); // Mode Edit
            } else if (value == 'delete') {
              _confirmDelete(user);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('Edit User'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Hapus User'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
