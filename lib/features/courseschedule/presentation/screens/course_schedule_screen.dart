import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/api_service.dart';

class MergedCourseSchedule extends CourseSchedule {
  final int periodCount;
  final List<CourseSchedule> originalCourses;

  MergedCourseSchedule({
    required super.day,
    required super.courseCode,
    required super.courseName,
    required super.startTime,
    required super.endTime,
    required super.classroom,
    required this.periodCount,
    required this.originalCourses,
  });
}

class CourseScheduleScreen extends StatefulWidget {
  const CourseScheduleScreen({super.key});

  @override
  State<CourseScheduleScreen> createState() => _CourseScheduleScreenState();
}

class _CourseScheduleScreenState extends State<CourseScheduleScreen> {
  final AuthService _authService = AuthService();
  List<CourseSchedule> _courses = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _weekDays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  @override
  void initState() {
    super.initState();
    _loadCourseSchedule();
  }

  Future<void> _loadCourseSchedule() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = _authService.currentUser;
      if (user?.studentNumber == null) {
        throw Exception('Öğrenci numarası bulunamadı');
      }

      final apiService = ApiService.instance;
      final response = await apiService.getCourseSchedule(user!.studentNumber!);

      if (response.success && response.data != null) {
        setState(() {
          _courses = response.data!;
          _courses.sort((a, b) {
            final dayComparison = a.dayIndex.compareTo(b.dayIndex);
            if (dayComparison != 0) return dayComparison;
            return a.startTime.compareTo(b.startTime);
          });

          // Ardışık dersleri birleştir
          _courses = _mergeContinuousCourses(_courses);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Ders programı yüklenemedi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  List<CourseSchedule> _mergeContinuousCourses(List<CourseSchedule> courses) {
    List<CourseSchedule> mergedCourses = [];

    for (int i = 0; i < courses.length; i++) {
      CourseSchedule currentCourse = courses[i];
      List<CourseSchedule> consecutiveCourses = [currentCourse];

      // Aynı ders kodu ve derslik için ardışık saatleri kontrol et
      while (i + 1 < courses.length) {
        CourseSchedule nextCourse = courses[i + 1];

        // Aynı gün, aynı ders, aynı derslik ve ardışık saatler mi?
        if (currentCourse.day == nextCourse.day &&
            currentCourse.courseCode == nextCourse.courseCode &&
            currentCourse.classroom == nextCourse.classroom &&
            _areTimesConsecutive(currentCourse.endTime, nextCourse.startTime)) {
          consecutiveCourses.add(nextCourse);
          currentCourse = nextCourse; // Bir sonraki döngü için güncelle
          i++; // İndeksi artır
        } else {
          break;
        }
      }

      // Eğer birden fazla ardışık ders varsa birleştir
      if (consecutiveCourses.length > 1) {
        mergedCourses.add(
          MergedCourseSchedule(
            day: consecutiveCourses.first.day,
            courseCode: consecutiveCourses.first.courseCode,
            courseName: consecutiveCourses.first.courseName,
            startTime: consecutiveCourses.first.startTime,
            endTime: consecutiveCourses.last.endTime,
            classroom: consecutiveCourses.first.classroom,
            periodCount: consecutiveCourses.length,
            originalCourses: consecutiveCourses,
          ),
        );
      } else {
        mergedCourses.add(currentCourse);
      }
    }

    return mergedCourses;
  }

  bool _areTimesConsecutive(String endTime, String startTime) {
    try {
      // Saatleri dakikaya çevir
      List<String> endParts = endTime.split(':');
      List<String> startParts = startTime.split(':');

      int endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      int startMinutes =
          int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

      // 15 dakika veya daha az ara varsa ardışık kabul et
      return (startMinutes - endMinutes) <= 15 &&
          (startMinutes - endMinutes) >= 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Ders Programı',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadCourseSchedule,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Ders programı yükleniyor...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCourseSchedule,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_courses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Henüz ders programınız bulunmuyor',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCourseSchedule,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _weekDays.map((day) => _buildDaySection(day)).toList(),
        ),
      ),
    );
  }

  Widget _buildDaySection(String day) {
    final dayCourses = _courses.where((course) => course.day == day).toList();

    if (dayCourses.isEmpty) {
      return const SizedBox.shrink();
    }

    final isToday = _isToday(day);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: AppColors.primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primaryColor : Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getDayIcon(day),
                  color: isToday ? Colors.white : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : Colors.grey.shade700,
                  ),
                ),
                if (isToday) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'BUGÜN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Courses for this day
          ...dayCourses.map((course) => _buildCourseCard(course, isToday)),
        ],
      ),
    );
  }

  Widget _buildCourseCard(CourseSchedule course, bool isToday) {
    final isCurrentTime =
        isToday && _isCurrentTime(course.startTime, course.endTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentTime ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: isCurrentTime
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCurrentTime ? Colors.green : AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${course.startTime} - ${course.endTime}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isCurrentTime) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ŞİMDİ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Course info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseCode,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.courseName,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Period count for merged courses
              if (course is MergedCourseSchedule && course.periodCount > 1) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${course.periodCount} Ders',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                course.classroom,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Duration
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getCourseDuration(course.startTime, course.endTime),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(String day) {
    final today = DateTime.now().weekday;
    final dayIndex = _weekDays.indexOf(day) + 1;
    return today == dayIndex;
  }

  bool _isCurrentTime(String startTime, String endTime) {
    try {
      final now = TimeOfDay.now();
      final start = TimeOfDay(
        hour: int.parse(startTime.split(':')[0]),
        minute: int.parse(startTime.split(':')[1]),
      );
      final end = TimeOfDay(
        hour: int.parse(endTime.split(':')[0]),
        minute: int.parse(endTime.split(':')[1]),
      );

      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;

      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } catch (e) {
      return false;
    }
  }

  IconData _getDayIcon(String day) {
    switch (day) {
      case 'Pazartesi':
        return Icons.work;
      case 'Salı':
        return Icons.book;
      case 'Çarşamba':
        return Icons.school;
      case 'Perşembe':
        return Icons.edit;
      case 'Cuma':
        return Icons.grade;
      case 'Cumartesi':
        return Icons.weekend;
      case 'Pazar':
        return Icons.home;
      default:
        return Icons.calendar_today;
    }
  }

  String _getCourseDuration(String startTime, String endTime) {
    try {
      final start = TimeOfDay(
        hour: int.parse(startTime.split(':')[0]),
        minute: int.parse(startTime.split(':')[1]),
      );
      final end = TimeOfDay(
        hour: int.parse(endTime.split(':')[0]),
        minute: int.parse(endTime.split(':')[1]),
      );

      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      final durationMinutes = endMinutes - startMinutes;

      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;

      if (hours > 0) {
        return '$hours saat ${minutes > 0 ? '$minutes dakika' : ''}';
      } else {
        return '$minutes dakika';
      }
    } catch (e) {
      return 'Süre hesaplanamadı';
    }
  }
}
