import 'package:flutter/material.dart';
import 'package:hyper_local_employee/services/user_session.dart';
import '../services/api_service.dart';
import '../models/job_post_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class JobPostController extends ChangeNotifier {
  final ApiService _service = ApiService();

  bool isLoading = false;
  String? errorMessage;
  int? lastCreatedJobPostId;
  List<JobPostModel> myJobPosts = [];

  // ─────────────────────────────────────────────
  // CREATE — Model object pathavaycha
  // ─────────────────────────────────────────────
  Future<int?> createJobPostFromModel(JobPostModel model) async {
    return createJobPost(model.toFullJson());
  }

  // Single-shot full create (router.post('/', authMiddleware, jobPostController.createFullJobPost))
  Future<int?> createFullJobPost(JobPostModel model) async {
    return createJobPost(model.toFullJson());
  }

  // ─────────────────────────────────────────────
  // CREATE — screen madhun banवलेला pura payload pathavायचa
  // ─────────────────────────────────────────────
  Future<int?> createJobPost(Map<String, dynamic> payload) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      var token = UserSession.token;
      if (token == null || token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('auth_token');
      }

      if (token == null || token.isEmpty) {
        errorMessage = 'Not logged in. Please login again.';
        return null;
      }

      final jobPostId = await _service.createJobPostFromMap(payload, token);
      lastCreatedJobPostId = jobPostId;
      return jobPostId;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // FETCH ONE — preview / edit screen sathi
  // ─────────────────────────────────────────────
  Future<JobPostModel?> getJobPostById(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = UserSession.token;
      if (token == null || token.isEmpty) {
        errorMessage = 'Not logged in. Please login again.';
        return null;
      }

      final jobPost = await _service.getJobPostById(id, token);
      return jobPost;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE — job post update karayla
  // ─────────────────────────────────────────────
  Future<bool> updateJobPost(int id, Map<String, dynamic> payload) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      var token = UserSession.token;
      if (token == null || token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('auth_token');
      }

      if (token == null || token.isEmpty) {
        errorMessage = 'Not logged in. Please login again.';
        return false;
      }

      await _service.updateJobPost(id, payload, token);
      await fetchMyJobPosts(); // Refresh list after update
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // LIST — employer cha "My Jobs" screen sathi
  // ─────────────────────────────────────────────
  Future<void> fetchMyJobPosts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      var token = UserSession.token;
      if (token == null || token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('auth_token');
      }

      if (token == null || token.isEmpty) {
        errorMessage = 'Not logged in. Please login again.';
        return;
      }

      myJobPosts = await _service.getMyJobPosts(token);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // PUBLISH — draft status change karayला
  // ─────────────────────────────────────────────
  Future<bool> publishJobPost(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      var token = UserSession.token;
      if (token == null || token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('auth_token');
      }

      if (token == null || token.isEmpty) {
        errorMessage = 'Not logged in. Please login again.';
        return false;
      }

      await _service.publishJobPost(id, token);
      await fetchMyJobPosts(); // Refresh status in list
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────
  Future<bool> deleteJobPost(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      var token = UserSession.token;
      if (token == null || token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('auth_token');
      }

      if (token == null || token.isEmpty) {
        errorMessage = 'Not logged in. Please login again.';
        return false;
      }

      await _service.deleteJobPost(id, token);
      myJobPosts.removeWhere((job) => job.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}