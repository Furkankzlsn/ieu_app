import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/api_service.dart';

class ExamScheduleScreen extends StatefulWidget {
  const ExamScheduleScreen({super.key});

  @override
  State<ExamScheduleScreen> createState() => _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends State<ExamScheduleScreen> {
  final AuthService _authService = AuthService();
  List<ExamSchedule> _exams = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExamSchedule();
  }

  Future<void> _loadExamSchedule() async {
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
      final response = await apiService.getExamSchedule(user!.studentNumber!);

      if (response.success && response.data != null) {
        setState(() {
          _exams = response.data!;
          _exams.sort((a, b) => a.examDateTime.compareTo(b.examDateTime));
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Sınav programı yüklenemedi';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Sınav Programı',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadExamSchedule,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
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
            Text('Sınav programı yükleniyor...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExamSchedule,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_exams.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Henüz sınav programınız bulunmuyor',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExamSchedule,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _exams.length,
        itemBuilder: (context, index) {
          final exam = _exams[index];
          return _buildExamCard(exam);
        },
      ),
    );
  }

  Widget _buildExamCard(ExamSchedule exam) {
    final isUpcoming = exam.examDateTime.isAfter(DateTime.now());
    final isPast = exam.examDateTime.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    
    Color cardColor = Colors.white;
    Color borderColor = AppColors.primaryColor;
    
    if (exam.isCancelled) {
      cardColor = Colors.red.shade50;
      borderColor = Colors.red;
    } else if (isPast) {
      cardColor = Colors.grey.shade50;
      borderColor = Colors.grey;
    } else if (isUpcoming) {
      cardColor = Colors.green.shade50;
      borderColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    exam.examDateName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (exam.isCancelled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'İPTAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Course info
            Text(
              exam.courseCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              exam.courseName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Exam details
            _buildDetailRow(Icons.access_time, 'Saat', '${exam.startTime} - ${exam.endTime}'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.location_on, 'Yer', exam.examLocation),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.person, 'Öğretim Üyesi', exam.instructorName),
            
            // Duration indicator
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getExamDuration(exam.startTime, exam.endTime),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getExamDuration(String startTime, String endTime) {
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
