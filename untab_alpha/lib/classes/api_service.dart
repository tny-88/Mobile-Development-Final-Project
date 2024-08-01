import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://untab-backend.nw.r.appspot.com';
  static final storage = FlutterSecureStorage();

  static Future<String?> getJwtToken() async {
    return await storage.read(key: 'jwt_token');
  }

  static Future<Map<String, dynamic>?> fetchUserData() async {
    final jwtToken = await getJwtToken();
    if (jwtToken == null) {
      print('JWT token not found');
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_user_details'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load user data: ${response.statusCode} - ${response.reasonPhrase}');
      return null;
    }
  }

  static Future<List<dynamic>?> fetchMedications() async {
    final jwtToken = await getJwtToken();
    if (jwtToken == null) {
      print('JWT token not found');
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_medications'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load medications: ${response.statusCode} - ${response.reasonPhrase}');
      return null;
    }
  }

  static Future<List<dynamic>?> fetchEmergencyContacts() async {
    final jwtToken = await getJwtToken();
    if (jwtToken == null) {
      print('JWT token not found');
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/get_emergency_contacts'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load emergency contacts: ${response.statusCode} - ${response.reasonPhrase}');
      return null;
    }
  }

  static Future<bool> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    String? notes,
    String? schedule,
  }) async {
    final jwtToken = await getJwtToken();
    if (jwtToken == null) {
      print('JWT token not found');
      return false;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/add_medication'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'notes': notes,
        'schedule': schedule,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to add medication: ${response.statusCode} - ${response.reasonPhrase}');
      return false;
    }
  }

  static Future<bool> addEmergencyContact({
    required String fname,
    required String lname,
    required String phoneNumber,
    required String relationship,
  }) async {
    final jwtToken = await getJwtToken();
    if (jwtToken == null) {
      print('JWT token not found');
      return false;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/add_emergency_contact'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'fname': fname,
        'lname': lname,
        'phoneNumber': phoneNumber,
        'relationship': relationship,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to add contact: ${response.statusCode} - ${response.reasonPhrase}');
      return false;
    }
  }
}
