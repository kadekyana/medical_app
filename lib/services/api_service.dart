import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:medical_app/models/reports_model.dart';

// IMPORT MODELS
import '../models/user_model.dart'; // Berisi class Users
import '../models/patient_model.dart'; // Berisi class Patients
import '../models/dashboard_model.dart'; // Berisi class Dashboard
import '../models/medical_record_model.dart'; // Berisi class MedicalReports (CRUD)

class ApiService {
  // Ganti dengan IP Address jika di Emulator/HP Fisik
  // Emulator Android: 10.0.2.2
  // iOS/Web: localhost atau 127.0.0.1
  static const String baseUrl =
      "https://shavira.undiksha.ac.id/medical-api/api";

  // ===========================================================================
  // 1. AUTHENTICATION
  // ===========================================================================
  Future<Users?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return Users.fromJson(jsonDecode(response.body));
      } else {
        debugPrint("Login Failed: ${response.body}");
      }
    } catch (e) {
      debugPrint("Login Error: $e");
    }
    return null;
  }

  // ===========================================================================
  // 2. DASHBOARD
  // ===========================================================================
  Future<Dashboard?> getDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard'));
      if (response.statusCode == 200) {
        return dashboardFromJson(response.body);
      }
    } catch (e) {
      debugPrint("Dashboard Error: $e");
    }
    return null;
  }

  // ===========================================================================
  // 3. PATIENTS (CRUD LENGKAP)
  // ===========================================================================

  // GET (Search Support)
  Future<List<Patients>> getPatients({String? query}) async {
    String url = '$baseUrl/patients';
    if (query != null && query.isNotEmpty) {
      url += '?query=$query';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return patientsFromJson(response.body);
      }
    } catch (e) {
      debugPrint("Get Patients Error: $e");
    }
    return [];
  }

  // CREATE
  Future<bool> createPatient(Patients patient) async {
    try {
      debugPrint("Create Patient Payload: ${jsonEncode(patient.toJson())}");

      final response = await http.post(
        Uri.parse('$baseUrl/patients'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(patient.toJson()),
      );

      debugPrint("Response Create (${response.statusCode}): ${response.body}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Create Patient Error: $e");
      return false;
    }
  }

  // UPDATE
  Future<bool> updatePatient(int id, Patients patient) async {
    try {
      debugPrint("Update Patient Payload: ${jsonEncode(patient.toJson())}");

      final response = await http.put(
        Uri.parse('$baseUrl/patients/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(patient.toJson()),
      );

      debugPrint("Response Update (${response.statusCode}): ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update Patient Error: $e");
      return false;
    }
  }

  // DELETE (Baru)
  Future<bool> deletePatient(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/patients/$id'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Delete Patient Error: $e");
      return false;
    }
  }

  // ===========================================================================
  // 4. MEDICAL RECORDS (CRUD)
  // ===========================================================================

  // GET BY PATIENT ID
  Future<List<MedicalReports>> getRecords(int patientId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/records/$patientId'));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        // Pastikan menggunakan MedicalReports.fromJson
        return data.map((e) => MedicalReports.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Get Records Error: $e");
    }
    return [];
  }

  // CREATE
  Future<bool> createRecord(MedicalReports record) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/records'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(record.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Create Record Error: $e");
      return false;
    }
  }

  // UPDATE
  Future<bool> updateRecord(int id, MedicalReports record) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/records/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(record.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update Record Error: $e");
      return false;
    }
  }

  // DELETE
  Future<bool> deleteRecord(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/records/$id'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Delete Record Error: $e");
      return false;
    }
  }

  // ===========================================================================
  // 5. USERS (CRUD)
  // ===========================================================================

  // GET
  Future<List<Users>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        return usersFromJson(response.body);
      }
    } catch (e) {
      debugPrint("Get Users Error: $e");
    }
    return [];
  }

  // CREATE
  Future<bool> createUser(Users user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Create User Error: $e");
      return false;
    }
  }

  // UPDATE (Baru)
  Future<bool> updateUser(int id, Users user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update User Error: $e");
      return false;
    }
  }

  // DELETE
  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Delete User Error: $e");
      return false;
    }
  }

  // ===========================================================================
  // 6. REPORTS (VIEW ONLY)
  // ===========================================================================
  Future<List<Reports>> getReports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reports'));
      if (response.statusCode == 200) {
        debugPrint("Reports Data: ${response.body}"); // Debugging
        return reportsFromJson(response.body);
      }
    } catch (e) {
      debugPrint("Get Reports Error: $e");
    }
    return [];
  }
}
