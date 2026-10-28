import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee_model.dart';

class UserSession {
  static const String _keyEmployee = 'current_employee';
  static const String _keyToken = 'auth_token';
  static const String _keyBusinessName = 'saved_business_name';

  // ValueNotifier so UI can reactively rebuild when user session changes
  static final ValueNotifier<Employee?> userNotifier = ValueNotifier<Employee?>(null);

  static Employee? _currentEmployee;
  static String? _token;
  static String? _savedBusinessName;

  static Employee? get currentEmployee => _currentEmployee;
  static String? get token => _token;

  static bool get isLoggedIn => _currentEmployee != null;

  static String get userName {
    if (_currentEmployee != null && _currentEmployee!.fullName.trim().isNotEmpty) {
      return _currentEmployee!.fullName.trim();
    }
    return '';
  }

  static String get userEmail {
    if (_currentEmployee != null && _currentEmployee!.email.trim().isNotEmpty) {
      return _currentEmployee!.email.trim();
    }
    return '';
  }

  static String get userPhone {
    if (_currentEmployee != null && _currentEmployee!.phone.trim().isNotEmpty) {
      return _currentEmployee!.phone.trim();
    }
    return '';
  }

  static String get displayName {
    final name = userName;
    if (name.isEmpty) return 'User';
    final parts = name.split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : name;
  }

  /// Strictly returns Company / Business Name added during signup/profile.
  /// Does NOT fallback to person's full name.
  static String get companyName {
    if (_currentEmployee != null &&
        _currentEmployee!.businessName != null &&
        _currentEmployee!.businessName!.trim().isNotEmpty) {
      return _currentEmployee!.businessName!.trim();
    }
    if (_savedBusinessName != null && _savedBusinessName!.trim().isNotEmpty) {
      return _savedBusinessName!.trim();
    }
    return '';
  }

  static String get userInitials {
    return getInitials(userName);
  }

  static String get companyInitials {
    return getInitials(companyName);
  }

  static String getInitials(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return 'U';
    final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.length == 1 && parts[0].isNotEmpty) {
      return parts[0].substring(0, min(2, parts[0].length)).toUpperCase();
    }
    return 'U';
  }

  /// Retrieves current logged in employer/employee ID from session or local storage
  static Future<int> getEmployerId() async {
    if (_currentEmployee != null && _currentEmployee!.id > 0) {
      return _currentEmployee!.id;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      int? empId = prefs.getInt('employer_id');
      if (empId == null) {
        final raw = prefs.get('employer_id');
        if (raw != null) empId = int.tryParse(raw.toString());
      }
      empId ??= prefs.getInt('employee_id');
      if (empId == null) {
        final raw = prefs.get('employee_id');
        if (raw != null) empId = int.tryParse(raw.toString());
      }
      empId ??= _currentEmployee?.companyId;
      if (empId != null && empId > 0) return empId;
    } catch (_) {}
    return _currentEmployee?.id ?? 3;
  }

  /// Initialize session from local storage on app startup
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final empJsonStr = prefs.getString(_keyEmployee);
      _token = prefs.getString(_keyToken);
      _savedBusinessName = prefs.getString(_keyBusinessName);

      if (empJsonStr != null && empJsonStr.isNotEmpty) {
        final Map<String, dynamic> jsonMap = jsonDecode(empJsonStr);
        var emp = Employee.fromJson(jsonMap);
        if ((emp.businessName == null || emp.businessName!.trim().isEmpty) &&
            _savedBusinessName != null &&
            _savedBusinessName!.trim().isNotEmpty) {
          emp = Employee(
            id: emp.id,
            fullName: emp.fullName,
            email: emp.email,
            phone: emp.phone,
            companyId: emp.companyId,
            industry: emp.industry,
            businessName: _savedBusinessName,
            establishmentYear: emp.establishmentYear,
          );
        }
        _currentEmployee = emp;
        userNotifier.value = _currentEmployee;
      }
    } catch (e) {
      debugPrint('Error loading UserSession: $e');
    }
  }

  /// Save employee data and token after login or signup
  static Future<void> saveSession({
    required Employee? employee,
    String? token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_savedBusinessName == null || _savedBusinessName!.isEmpty) {
        _savedBusinessName = prefs.getString(_keyBusinessName);
      }

      var empToSave = employee;
      if (empToSave != null) {
        if (empToSave.businessName != null && empToSave.businessName!.trim().isNotEmpty) {
          _savedBusinessName = empToSave.businessName!.trim();
          await prefs.setString(_keyBusinessName, _savedBusinessName!);
        } else if (_savedBusinessName != null && _savedBusinessName!.trim().isNotEmpty) {
          empToSave = Employee(
            id: empToSave.id,
            fullName: empToSave.fullName,
            email: empToSave.email,
            phone: empToSave.phone,
            companyId: empToSave.companyId,
            industry: empToSave.industry,
            businessName: _savedBusinessName,
            establishmentYear: empToSave.establishmentYear,
          );
        }
      }

      _currentEmployee = empToSave;
      if (token != null && token.isNotEmpty) {
        _token = token;
      }
      userNotifier.value = _currentEmployee;

      if (_currentEmployee != null) {
        await prefs.setString(_keyEmployee, jsonEncode(_currentEmployee!.toJson()));
      }
      if (_token != null) {
        await prefs.setString(_keyToken, _token!);
      }
    } catch (e) {
      debugPrint('Error saving UserSession: $e');
    }
  }

  /// Clear session on logout
  static Future<void> clearSession() async {
    _currentEmployee = null;
    _token = null;
    _savedBusinessName = null;
    userNotifier.value = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyEmployee);
      await prefs.remove(_keyToken);
      await prefs.remove(_keyBusinessName);
      await prefs.remove('employer_id');
      await prefs.remove('employee_id');
    } catch (e) {
      debugPrint('Error clearing UserSession: $e');
    }
  }
}
