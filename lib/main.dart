import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'core/constants/app_theme.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'services/badge_service.dart';
import 'shared/widgets/splash_screen.dart';
import 'features/home/presentation/screens/new_home_screen.dart';
import 'features/announcements/presentation/screens/announcements_screen.dart';
import 'features/announcements/presentation/screens/all_announcements_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/slider/presentation/screens/slider_detail_screen.dart';
import 'features/news/presentation/screens/news_detail_screen.dart';
import 'features/menu/presentation/screens/menu_category_screen.dart';
import 'features/menu/presentation/screens/menu_detail_screen.dart';
import 'features/student/presentation/screens/student_dashboard_screen.dart';
import 'features/examschedule/presentation/screens/exam_schedule_screen.dart';
import 'features/courseschedule/presentation/screens/course_schedule_screen.dart';

// Top-level function for background message handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Background message received: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only if not already initialized
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('Firebase already initialized');
    } else {
      print('Firebase initialization error: $e');
    }
  }
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize shared preferences
  await SharedPreferences.getInstance();
  
  runApp(const IEUApp());
}

class IEUApp extends StatelessWidget {
  const IEUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İEU Öğrenci',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainApp(),
      routes: {
        '/home': (context) => const NewHomeScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/announcements': (context) => const AnnouncementsScreen(),
        '/all-announcements': (context) => const AllAnnouncementsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/dashboard': (context) => const NewHomeScreen(),
        '/student-dashboard': (context) => const StudentDashboardScreen(),
        '/exam-schedule': (context) => const ExamScheduleScreen(),
        '/course-schedule': (context) => const CourseScheduleScreen(),
      },
      onGenerateRoute: (settings) {
        // Slider detay sayfası
        if (settings.name?.startsWith('/slider-detail/') == true) {
          final sliderId = settings.name!.replaceFirst('/slider-detail/', '');
          return MaterialPageRoute(
            builder: (context) => SliderDetailScreen(sliderId: sliderId),
          );
        }
        
        // Haber detay sayfası
        if (settings.name?.startsWith('/news-detail/') == true) {
          final newsId = settings.name!.replaceFirst('/news-detail/', '');
          return MaterialPageRoute(
            builder: (context) => NewsDetailScreen(newsId: newsId),
          );
        }
        
        // Menü kategorisi sayfası
        if (settings.name == '/menu-category') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => const MenuCategoryScreen(),
            settings: RouteSettings(
              name: '/menu-category',
              arguments: args,
            ),
          );
        }
        
        // Menü detay sayfası
        if (settings.name == '/menu-detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => MenuDetailScreen(
              category: args['category'] ?? '',
              menuId: args['menuId'] ?? '',
            ),
            settings: RouteSettings(
              name: '/menu-detail',
              arguments: args,
            ),
          );
        }
        
        return null;
      },
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize notification service
      await NotificationService.initialize();
      
      // Initialize auth service and user
      await AuthService().initializeUser();
      
      // Initialize badge service
      await BadgeService().initialize();
      
      // UYGULAMA BAŞLATILDIĞINDA UNREAD COUNT GÜNCELLEMESİ
      await NotificationService.refreshUserNotifications();
      
      // Get FCM token for debugging
      final token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Uygulama başlatılırken hata oluştu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Hata!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isInitialized = false;
                  });
                  _initializeApp();
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const SplashScreen(
        child: NewHomeScreen(),
      );
    }

    return const NewHomeScreen();
  }
}