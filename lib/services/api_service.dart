import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://analytics.ieu.edu.tr/ieuapp666888/API';
  static const String secretKey = 'IEU_APP_SECRET_KEY_2024';
  
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._internal();
  
  ApiService._internal();

  /// Token oluşturma metodu
  Map<String, String> _generateTokenAndTimestamp() {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final dataToHash = '$timestamp:$secretKey';
    final bytes = utf8.encode(dataToHash);
    final digest = sha256.convert(bytes);
    final token = digest.toString();
    
    return {
      'token': token,
      'timestamp': timestamp,
    };
  }

  /// HTTP isteği için headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Öğrenci giriş kontrolü
  Future<ApiResponse<StudentLoginResponse>> loginControl(String studentNumber) async {
    try {
      final tokenData = _generateTokenAndTimestamp();
      
      final body = {
        'ogr_no': studentNumber,
        'token': tokenData['token'],
        'timestamp': tokenData['timestamp'],
      };

      print('🔗 API Login Control çağrılıyor: $studentNumber');
      
      final response = await http.post(
        Uri.parse('$baseUrl/LoginControl'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final loginResponse = StudentLoginResponse.fromJson(jsonResponse);
          return ApiResponse.success(loginResponse);
        } else {
          return ApiResponse.error(jsonResponse['message'] ?? 'Bilinmeyen hata');
        }
      } else {
        return ApiResponse.error('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on SocketException {
      return ApiResponse.error('İnternet bağlantısı bulunamadı');
    } on http.ClientException {
      return ApiResponse.error('Sunucuya bağlanılamadı');
    } catch (e) {
      print('❌ API Login Control hatası: $e');
      return ApiResponse.error('Bir hata oluştu: $e');
    }
  }

  /// Sınav programını çekme
  Future<ApiResponse<List<ExamSchedule>>> getExamSchedule(String studentNumber) async {
    try {
      final tokenData = _generateTokenAndTimestamp();
      
      final body = {
        'ogr_no': studentNumber,
        'token': tokenData['token'],
        'timestamp': tokenData['timestamp'],
      };

      print('🔗 API Get Exam Schedule çağrılıyor: $studentNumber');
      
      final response = await http.post(
        Uri.parse('$baseUrl/GetSinav'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print('📡 API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> examData = jsonResponse['data'] ?? [];
          final exams = examData.map((exam) => ExamSchedule.fromJson(exam)).toList();
          return ApiResponse.success(exams);
        } else {
          return ApiResponse.error(jsonResponse['message'] ?? 'Sınav programı alınamadı');
        }
      } else {
        return ApiResponse.error('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on SocketException {
      return ApiResponse.error('İnternet bağlantısı bulunamadı');
    } on http.ClientException {
      return ApiResponse.error('Sunucuya bağlanılamadı');
    } catch (e) {
      print('❌ API Get Exam Schedule hatası: $e');
      return ApiResponse.error('Bir hata oluştu: $e');
    }
  }

  /// Ders programını çekme
  Future<ApiResponse<List<CourseSchedule>>> getCourseSchedule(String studentNumber) async {
    try {
      final tokenData = _generateTokenAndTimestamp();
      
      final body = {
        'ogr_no': studentNumber,
        'token': tokenData['token'],
        'timestamp': tokenData['timestamp'],
      };

      print('🔗 API Get Course Schedule çağrılıyor: $studentNumber');
      
      final response = await http.post(
        Uri.parse('$baseUrl/GetDers'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print('📡 API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> courseData = jsonResponse['data'] ?? [];
          final courses = courseData.map((course) => CourseSchedule.fromJson(course)).toList();
          return ApiResponse.success(courses);
        } else {
          return ApiResponse.error(jsonResponse['message'] ?? 'Ders programı alınamadı');
        }
      } else {
        return ApiResponse.error('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on SocketException {
      return ApiResponse.error('İnternet bağlantısı bulunamadı');
    } on http.ClientException {
      return ApiResponse.error('Sunucuya bağlanılamadı');
    } catch (e) {
      print('❌ API Get Course Schedule hatası: $e');
      return ApiResponse.error('Bir hata oluştu: $e');
    }
  }
}

/// API yanıt wrapper sınıfı
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse.success(this.data) : success = true, error = null;
  ApiResponse.error(this.error) : success = false, data = null;
}

/// Öğrenci giriş yanıt modeli
class StudentLoginResponse {
  final bool success;
  final bool isActive;
  final String message;
  final StudentData? data;

  StudentLoginResponse({
    required this.success,
    required this.isActive,
    required this.message,
    this.data,
  });

  factory StudentLoginResponse.fromJson(Map<String, dynamic> json) {
    return StudentLoginResponse(
      success: json['success'] ?? false,
      isActive: json['isActive'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? StudentData.fromJson(json['data']) : null,
    );
  }
}

/// Öğrenci veri modeli
class StudentData {
  final String studentNumber;
  final String tck;

  StudentData({
    required this.studentNumber,
    required this.tck,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      studentNumber: json['ogr_no'] ?? '',
      tck: json['tck'] ?? '',
    );
  }
}

/// Sınav programı modeli
class ExamSchedule {
  final String examDate;
  final String examDateName;
  final String startTime;
  final String endTime;
  final String courseCode;
  final String courseName;
  final String instructorName;
  final String examLocation;
  final bool isCancelled;

  ExamSchedule({
    required this.examDate,
    required this.examDateName,
    required this.startTime,
    required this.endTime,
    required this.courseCode,
    required this.courseName,
    required this.instructorName,
    required this.examLocation,
    required this.isCancelled,
  });

  factory ExamSchedule.fromJson(Map<String, dynamic> json) {
    return ExamSchedule(
      examDate: json['sinav_tarihi'] ?? '',
      examDateName: json['sinav_tarih_adi'] ?? '',
      startTime: json['baslangic_saati'] ?? '',
      endTime: json['bitis_saati'] ?? '',
      courseCode: json['ders_kodu'] ?? '',
      courseName: json['ders_adi'] ?? '',
      instructorName: json['oe_adsoyad'] ?? '',
      examLocation: json['sinav_yeri'] ?? '',
      isCancelled: json['kontrol2'] ?? false,
    );
  }

  DateTime get examDateTime {
    try {
      // "03-06-2025" formatını parse et
      final dateParts = examDate.split('-');
      if (dateParts.length == 3) {
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Tarih parse hatası: $e');
    }
    return DateTime.now();
  }
}

/// Ders programı modeli
class CourseSchedule {
  final String day;
  final String courseCode;
  final String courseName;
  final String startTime;
  final String endTime;
  final String classroom;

  CourseSchedule({
    required this.day,
    required this.courseCode,
    required this.courseName,
    required this.startTime,
    required this.endTime,
    required this.classroom,
  });

  factory CourseSchedule.fromJson(Map<String, dynamic> json) {
    return CourseSchedule(
      day: json['gun'] ?? '',
      courseCode: json['ders_kodu'] ?? '',
      courseName: json['ders_adi'] ?? '',
      startTime: json['bas_saat'] ?? '',
      endTime: json['bit_saat'] ?? '',
      classroom: json['derslik'] ?? '',
    );
  }

  /// Günleri sıralamak için index
  int get dayIndex {
    const days = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 
      'Cuma', 'Cumartesi', 'Pazar'
    ];
    return days.indexOf(day);
  }
}
