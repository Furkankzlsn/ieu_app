import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart';
import '../../../../models/user_model.dart';
import '../../../../core/constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> 
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isStudent = _authService.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Info Card
            _buildUserInfoCard(user, isStudent),
            
            const SizedBox(height: 20),
            
            // Login/Logout Section
            if (!isStudent) ...[
              _buildLoginSection(),
            ] else ...[
              _buildStudentInfoSection(user!),
              const SizedBox(height: 20),
              _buildLogoutSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(UserModel? user, bool isStudent) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryColor,
              child: const Text(
                'MK',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'Bilinmeyen Kullanıcı',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isStudent ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user?.userTypeString ?? 'Bilinmiyor',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Öğrenci Girişi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'İEU öğrenci numaranız ve şifrenizle giriş yaparak kişisel özelliklerinizi kullanabilirsiniz.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _showLoginDialog,
              icon: const Icon(Icons.login),
              label: const Text('Öğrenci Girişi Yap'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoSection(UserModel user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Öğrenci Bilgileri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Öğrenci Numarası:', user.studentNumber ?? 'Bilinmiyor'),
            _buildInfoRow('Bölüm:', user.department ?? 'Bilinmiyor'),
            _buildInfoRow('Fakülte:', user.faculty ?? 'Bilinmiyor'),
            _buildInfoRow('Sınıf:', user.gradeString),
            _buildInfoRow('Kayıt Yılı:', user.enrollmentYear?.toString() ?? 'Bilinmiyor'),
            _buildInfoRow('Yaş:', user.age?.toString() ?? 'Bilinmiyor'),
            _buildInfoRow('E-posta:', user.email),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Hesap İşlemleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginDialog() {
    final studentNumberController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Öğrenci Girişi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Öğrenci Numarası',
                  hintText: '20xxxxxx',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Test amaçlı: Öğrenci numarası 2 ile başlamalı ve en az 6 karakter, şifre en az 6 karakter olmalıdır.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      final success = await _loginAsStudent(
                        studentNumberController.text.trim(),
                        passwordController.text.trim(),
                      );
                      setState(() => isLoading = false);
                      if (mounted && success) {
                        Navigator.of(context).pop();
                        // Student Dashboard'a yönlendir
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/student-dashboard', 
                          (route) => false,
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _loginAsStudent(String studentNumber, String password) async {
    if (studentNumber.isEmpty || password.isEmpty) {
      _showErrorDialog('Lütfen tüm alanları doldurunuz.');
      return false;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authService.loginAsStudent(
        studentNumber: studentNumber,
        password: password,
      );

      if (success) {
        if (mounted) {
          // Profile screen'i güncelle
          setState(() {});
        }
        return true;
      } else {
        _showErrorDialog('Giriş başarısız. Lütfen bilgilerinizi kontrol ediniz.');
        return false;
      }
    } catch (e) {
      _showErrorDialog('Giriş sırasında bir hata oluştu: $e');
      return false;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    return false;
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        await _authService.logout();
        if (mounted) {
          setState(() {});
          // Dashboard'a dön ve güncelle
          Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
        }
      } catch (e) {
        _showErrorDialog('Çıkış sırasında bir hata oluştu: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Başarılı'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
