import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_post_model.dart';
import '../models/candidate_card_model.dart';
import 'user_session.dart';

/// Single Central API Service
/// 
/// Base URL ani saglya APIs (Employee, Job Post, etc.) ithech ekach file madhe ahet.
class ApiService {
  // =========================================================================
  // 1. COMMON BASE URL & ENDPOINTS
  // =========================================================================
  /// Single Common Base URL (Change this to switch between Local and Live)
  static const String baseUrl = 'http://localhost:5000/api';
  // static const String baseUrl = 'https://api.hihr.app/api';

  /// Employee module endpoint -> http://localhost:5000/api/employee

  /// Job Post module endpoint -> http://localhost:5000/api/jobpost

  static const Duration _timeout = Duration(seconds: 15);

  // Response parser helper
  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': 'Unexpected response format from server',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Server error (${response.statusCode}): ${response.reasonPhrase ?? "Unknown"}',
      };
    }
  }

  // Error message cleaner helper
  static String _cleanErrorMessage(http.Response response) {
    String body = response.body.trim();
    if (body.contains('<!DOCTYPE html>') || body.contains('<html') || body.contains('<pre>')) {
      final regExp = RegExp(r'<pre>(.*?)</pre>', dotAll: true);
      final match = regExp.firstMatch(body);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
      return 'Server error (${response.statusCode})';
    }
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        return data['message'] ?? data['error'] ?? body;
      }
    } catch (_) {}
    return body.isNotEmpty ? body : 'Server error (${response.statusCode})';
  }

  // =========================================================================
  // 2. EMPLOYEE AUTH APIS
  // =========================================================================

  // ---- SIGNUP ----
  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String phone,
    required String industry,
    required String businessName,
    required String establishmentYear,
    int companyId = 1,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/employee/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'full_name': fullName.trim(),
              'email': email.trim().toLowerCase(),
              'phone': phone.trim(),
              'company_id': companyId,
              'industry': industry.trim(),
              'business_name': businessName.trim(),
              'establishment_year': establishmentYear.trim(),
            }),
          )
          .timeout(_timeout);

      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Server connect hot nahi. (${e.toString()})',
      };
    }
  }

  // ---- VERIFY SIGNUP OTP ----
  static Future<Map<String, dynamic>> verifySignupOtp({
    required int employeeId,
    required String otp,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/employee/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'employee_id': employeeId,
              'otp': otp.trim(),
            }),
          )
          .timeout(_timeout);

      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Server connect hot nahi. (${e.toString()})',
      };
    }
  }

  // ---- LOGIN REQUEST OTP ----
  static Future<Map<String, dynamic>> loginRequestOtp({
    required String phone,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/employee/login/request-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone': phone.trim()}),
          )
          .timeout(_timeout);

      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Server connect hot nahi. (${e.toString()})',
      };
    }
  }

  // ---- LOGIN VERIFY OTP ----
  static Future<Map<String, dynamic>> loginVerifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/employee/login/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone': phone.trim(),
              'otp': otp.trim(),
            }),
          )
          .timeout(_timeout);

      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Server connect hot nahi. (${e.toString()})',
      };
    }
  }

  // =========================================================================
  // 3. JOB POST APIS
  // =========================================================================

  // ---- CREATE JOB POST (From Map) ----
  Future<int?> createJobPostFromMap(Map<String, dynamic> payload, String token) async {
    String endpoint = '$baseUrl/jobpost/add';
    debugPrint('[ApiService] Posting to: $endpoint');
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(_timeout);

      debugPrint('[ApiService] Response status from $endpoint: ${response.statusCode}');

      // Fallback if /add is 404
      if (response.statusCode == 404) {
        endpoint = '$baseUrl/jobpost';
        debugPrint('[ApiService] Fallback posting to: $endpoint');
        response = await http.post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        ).timeout(_timeout);
        debugPrint('[ApiService] Fallback response status from $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Could not connect to backend server ($endpoint): $e');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data['jobPostId'] ?? data['id'] ?? data['data']?['id'] ?? data['job_post_id'] ?? 1;
      }
      return 1;
    }

    final cleanMsg = _cleanErrorMessage(response);
    throw Exception('Failed to create job post (${response.statusCode}): $cleanMsg');
  }

  // ---- CREATE JOB POST (From Model) ----
  Future<int?> createJobPost(JobPostModel jobPost, String token) async {
    return createJobPostFromMap(jobPost.toFullJson(), token);
  }

  // ---- GET JOB POST BY ID ----
  Future<JobPostModel> getJobPostById(int id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/jobpost/GetById/$id'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return JobPostModel.fromJson(data['jobPost'] ?? data['data'] ?? data);
    } else {
      throw Exception('Failed to fetch job post: ${_cleanErrorMessage(response)}');
    }
  }

  // ---- GET MY JOB POSTS ----
  static Future<List<JobPostModel>> fetchMyJobPosts([String? token]) async {
    token ??= UserSession.token;
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token') ?? '';
    }
    return ApiService().getMyJobPosts(token);
  }

  Future<List<JobPostModel>> getMyJobPosts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/jobpost'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List jobPosts = (data is List)
          ? data
          : (data['jobPosts'] ?? data['data'] ?? []);
      return jobPosts.map((json) => JobPostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch job posts: ${_cleanErrorMessage(response)}');
    }
  }

  // ---- PUBLISH JOB POST ----
  Future<void> publishJobPost(int id, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/jobpost/$id/publish'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to publish job post: ${_cleanErrorMessage(response)}');
    }
  }

  // ---- UPDATE JOB POST ----
  Future<bool> updateJobPost(int id, Map<String, dynamic> payload, String token) async {
    final endpoint = '$baseUrl/jobpost/updated/$id';
    debugPrint('[ApiService] Updating at: $endpoint');
    final response = await http.put(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    ).timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to update job post: ${_cleanErrorMessage(response)}');
    }
  }

  // ---- DELETE JOB POST ----
  Future<void> deleteJobPost(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/jobpost/Delete/$id'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete job post: ${_cleanErrorMessage(response)}');
    }
  }

  // =========================================================================
  // 4. LOCATION APIS
  // =========================================================================
  static Future<List<Map<String, dynamic>>> getStates() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/location/states')).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? data['states'] ?? (data is List ? data : []);
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('[ApiService] Error fetching states: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getCities({int? stateId}) async {
    try {
      final url = stateId != null
          ? '$baseUrl/location/cities/$stateId'
          : '$baseUrl/location/cities';
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? data['cities'] ?? (data is List ? data : []);
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('[ApiService] Error fetching cities: $e');
    }
    return [];
  }

  // =========================================================================
  // 5. CATEGORY APIS
  // =========================================================================
  static Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories')).timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final List list = data['categories'] ?? data['data'] ?? (data is List ? data : []);
        List<String> titles = [];
        for (var item in list) {
          if (item is Map && item['title'] != null) {
            final t = item['title'].toString().trim();
            if (t.isNotEmpty && !titles.contains(t)) {
              titles.add(t);
            }
          } else if (item is String && item.trim().isNotEmpty) {
            if (!titles.contains(item.trim())) {
              titles.add(item.trim());
            }
          }
        }
        return titles;
      }
    } catch (e) {
      debugPrint('[ApiService] Error fetching categories: $e');
    }
    return [];
  }

  // =========================================================================
  // 6. NEARBY CANDIDATES API
  // =========================================================================
  static Future<Map<String, dynamic>> fetchNearbyCandidates({
    required int employerId,
    required double radius,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/jobpost/nearby-users?employer_id=$employerId&radius=$radius');
      debugPrint('[ApiService] Fetching nearby candidates from: $uri');
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final List rawUsers = data['users'] ?? data['data'] ?? data['candidates'] ?? [];
          final users = rawUsers
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          return {
            'success': data['success'] ?? true,
            'count': data['count'] ?? users.length,
            'users': users,
            'employer_id': data['employer_id'] ?? employerId,
            'radius_km': data['radius_km'] ?? radius,
            'message': '',
          };
        }
      }
      final err = _cleanErrorMessage(response);
      return {
        'success': false,
        'count': 0,
        'users': <Map<String, dynamic>>[],
        'message': err.isNotEmpty ? err : 'Server returned status ${response.statusCode}',
      };
    } catch (e) {
      debugPrint('[ApiService] Error fetching nearby candidates: $e');
      return {
        'success': false,
        'count': 0,
        'users': <Map<String, dynamic>>[],
        'message': e.toString(),
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getNearbyCandidates({int employerId = 1, double radius = 50.0}) async {
    final result = await fetchNearbyCandidates(employerId: employerId, radius: radius);
    final users = result['users'];
    if (users is List) {
      return users.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // =========================================================================
  // 7. INDUSTRY APIS
  // =========================================================================
  static Future<List<String>> fetchIndustries() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/industries')).timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final List list = data['industries'] ?? data['data'] ?? (data is List ? data : []);
        List<String> names = [];
        for (var item in list) {
          if (item is Map && item['name'] != null) {
            final name = item['name'].toString().trim();
            if (name.isNotEmpty && !names.contains(name)) {
              names.add(name);
            }
          } else if (item is String && item.trim().isNotEmpty) {
            final trimmed = item.trim();
            if (!names.contains(trimmed)) {
              names.add(trimmed);
            }
          }
        }
        return names;
      }
    } catch (e) {
      debugPrint('[ApiService] Error fetching industries: $e');
    }
    return [];
  }

  // =========================================================================
  // 8. JOB APPLICATIONS & CANDIDATES
  // =========================================================================

  /// GET {baseUrl}/job-applications/employer/:employerId/candidates
  static Future<List<CandidateCardModel>> getCandidateCards(int employerId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/job-applications/employer/$employerId/candidates'))
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          if (data['success'] == false) {
            throw Exception(data['message'] ?? 'Failed to fetch candidate cards');
          }
          final List list = data['candidates'] ?? data['data'] ?? [];
          return list.map((json) => CandidateCardModel.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is List) {
          return data.map((json) => CandidateCardModel.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
      final cleanMsg = _cleanErrorMessage(response);
      throw Exception('Failed to fetch candidate cards ($cleanMsg)');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error while fetching candidate cards: $e');
    }
  }

  /// PUT / PATCH {baseUrl}/job-applications/:applicationId/status
  static Future<bool> updateApplicationStatus(int applicationId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? UserSession.token;

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Try PUT first as per API specification
      var response = await http
          .put(
            Uri.parse('$baseUrl/job-applications/$applicationId/status'),
            headers: headers,
            body: jsonEncode({'status': status}),
          )
          .timeout(_timeout);

      // Fallback to PATCH if PUT is not allowed or 404
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await http
            .patch(
              Uri.parse('$baseUrl/job-applications/$applicationId/status'),
              headers: headers,
              body: jsonEncode({'status': status}),
            )
            .timeout(_timeout);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['success'] == false) {
          throw Exception(data['message'] ?? 'Failed to update application status');
        }
        return true;
      }
      final cleanMsg = _cleanErrorMessage(response);
      throw Exception('Failed to update application status ($cleanMsg)');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error while updating application status: $e');
    }
  }

  /// GET {baseUrl}/job-applications/:applicationId/candidate
  static Future<Map<String, dynamic>> getCandidateDetails(int applicationId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/job-applications/$applicationId/candidate'))
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          if (data['success'] == false) {
            throw Exception(data['message'] ?? 'Failed to fetch candidate details');
          }
          final cand = data['candidate'] ?? data['data'] ?? data;
          if (cand is Map<String, dynamic>) {
            return cand;
          }
        }
      }
      final cleanMsg = _cleanErrorMessage(response);
      throw Exception('Failed to fetch candidate details ($cleanMsg)');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error while fetching candidate details: $e');
    }
  }

  /// GET {baseUrl}/job-applications/employer/:employerId
  static Future<List<Map<String, dynamic>>> getEmployerApplications(int employerId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/job-applications/employer/$employerId'))
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          if (data['success'] == false) {
            throw Exception(data['message'] ?? 'Failed to fetch applications');
          }
          final List list = data['applications'] ?? data['data'] ?? [];
          return list.cast<Map<String, dynamic>>();
        } else if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }
      final cleanMsg = _cleanErrorMessage(response);
      throw Exception('Failed to fetch applications ($cleanMsg)');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error while fetching applications: $e');
    }
  }


  /// POST {baseUrl}/job-interviews/:applicationId/schedule
  static Future<Map<String, dynamic>> scheduleInterview(
      int applicationId, Map<String, dynamic> body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? UserSession.token;

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/job-interviews/$applicationId/schedule'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final data = _parseResponse(response);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data['success'] == true) {
          return data;
        }
        throw Exception(data['message'] ?? 'Failed to schedule interview');
      }

      final errorMsg = _cleanErrorMessage(response);
      throw Exception(errorMsg);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error while scheduling interview: $e');
    }
  }

  /// PATCH {baseUrl}/job-interviews/:interviewId/reschedule
  static Future<Map<String, dynamic>> rescheduleInterview(
      int interviewId, Map<String, dynamic> body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? UserSession.token;

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .patch(
            Uri.parse('$baseUrl/job-interviews/$interviewId/reschedule'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final data = _parseResponse(response);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data['success'] == true) {
          return data;
        }
        throw Exception(data['message'] ?? 'Failed to reschedule interview');
      }

      final errorMsg = _cleanErrorMessage(response);
      throw Exception(errorMsg);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error while rescheduling interview: $e');
    }
  }

  /// GET {baseUrl}/job-interviews/application/:applicationId
  static Future<Map<String, dynamic>?> getInterviewByApplication(
      int applicationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? UserSession.token;

      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/job-interviews/application/$applicationId'),
            headers: headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = _parseResponse(response);
        if (data['success'] == true && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching interview by application: $e');
      return null;
    }
  }

  /// GET {baseUrl}/job-interviews/upcoming
  static Future<List<Map<String, dynamic>>> getUpcomingInterviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? UserSession.token;

      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/job-interviews/upcoming'),
            headers: headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = _parseResponse(response);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching upcoming interviews: $e');
      return [];
    }
  }

  /// POST {baseUrl}/candidate-invitations
  static Future<Map<String, dynamic>> sendCandidateInvitation(
      Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/candidate-invitations'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final data = _parseResponse(response);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data['success'] == true) {
          return data;
        }
        throw Exception(data['message'] ?? 'Failed to send invitation');
      }

      final errorMsg = _cleanErrorMessage(response);
      throw Exception(errorMsg);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error while sending invitation: $e');
    }
  }

  /// GET {baseUrl}/candidate-invitations/employer/:employerId
  static Future<List<Map<String, dynamic>>> getEmployerInvitations(int employerId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/candidate-invitations/employer/$employerId'))
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          if (data['success'] == true && data['data'] is List) {
            return (data['data'] as List).cast<Map<String, dynamic>>();
          }
          if (data['invitations'] is List) {
            return (data['invitations'] as List).cast<Map<String, dynamic>>();
          }
        } else if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching employer invitations: $e');
      return [];
    }
  }


  // =========================================================================
  // 9. COMPANY PROFILE APIS
  // =========================================================================

  /// Server root URL for assets (e.g. http://localhost:5000)
  static String get serverBaseUrl => baseUrl.replaceAll('/api', '');

  /// Resolves partial uploaded image path to full URL
  static String resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final server = serverBaseUrl;
    if (!trimmed.startsWith('/')) {
      return '$server/$trimmed';
    }
    return '$server$trimmed';
  }

  /// Helper to get current auth token
  static Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? UserSession.token;
      return token;
    } catch (_) {
      return UserSession.token;
    }
  }

  /// GET {baseUrl}/company-profiles/my
  static Future<Map<String, dynamic>> getMyCompanyProfile() async {
    try {
      final token = await _getAuthToken();
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/company-profiles/my'),
            headers: headers,
          )
          .timeout(_timeout);

      final data = _parseResponse(response);
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Server connect hot nahi. (${e.toString()})',
      };
    }
  }

  /// PATCH {baseUrl}/company-profiles/my
  static Future<Map<String, dynamic>> updateMyCompanyProfile(
      Map<String, dynamic> updateData) async {
    try {
      final token = await _getAuthToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Security: Strictly exclude employee_id, id, status, created_at, updated_at
      final safePayload = Map<String, dynamic>.from(updateData);
      safePayload.remove('id');
      safePayload.remove('employee_id');
      safePayload.remove('status');
      safePayload.remove('created_at');
      safePayload.remove('updated_at');

      final response = await http
          .patch(
            Uri.parse('$baseUrl/company-profiles/my'),
            headers: headers,
            body: jsonEncode(safePayload),
          )
          .timeout(_timeout);

      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Failed to update profile. (${e.toString()})',
      };
    }
  }

  /// PATCH {baseUrl}/company-profiles/my/documents
  /// Uploads company_logo and company_registration_certificate using multipart/form-data
  static Future<Map<String, dynamic>> uploadCompanyDocuments({
    String? logoPath,
    Uint8List? logoBytes,
    String? logoFileName,
    String? certPath,
    Uint8List? certBytes,
    String? certFileName,
  }) async {
    try {
      final token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/company-profiles/my/documents');
      final request = http.MultipartRequest('PATCH', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Logo
      if (logoBytes != null && logoBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'company_logo',
            logoBytes,
            filename: logoFileName ?? 'company_logo.png',
          ),
        );
      } else if (logoPath != null && logoPath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'company_logo',
            logoPath,
            filename: logoFileName,
          ),
        );
      }

      // Registration certificate
      if (certBytes != null && certBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'company_registration_certificate',
            certBytes,
            filename: certFileName ?? 'company_registration_certificate.pdf',
          ),
        );
      } else if (certPath != null && certPath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'company_registration_certificate',
            certPath,
            filename: certFileName,
          ),
        );
      }

      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      return _parseResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload documents: (${e.toString()})',
      };
    }
  }

  /// GET {baseUrl}/offer-letters
  static Future<List<Map<String, dynamic>>> getOfferLetters() async {
    try {
      final token = await _getAuthToken();
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(Uri.parse('$baseUrl/offer-letters'), headers: headers)
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = _parseResponse(response);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching offer letters: $e');
      return [];
    }
  }
}