import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation_sos/config/supabase_config.dart';
import 'package:blood_donation_sos/controllers/auth_controller.dart';
import 'package:blood_donation_sos/screens/splash_screen.dart';
import 'package:blood_donation_sos/screens/login_screen.dart';
import 'package:blood_donation_sos/screens/signup_screen.dart';
import 'package:blood_donation_sos/screens/home_screen.dart';
import 'package:blood_donation_sos/screens/donor_home_screen.dart';
import 'package:blood_donation_sos/screens/profile_screen.dart';
import 'package:blood_donation_sos/screens/find_donors_screen.dart';
import 'package:blood_donation_sos/screens/sos_request_screen.dart';
import 'package:blood_donation_sos/screens/donation_camps_screen.dart';
import 'package:blood_donation_sos/screens/forgot_password_screen.dart';
import 'package:blood_donation_sos/screens/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SupabaseConfig.initialize();
  
  Get.put(AuthController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Blood Donation SOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFD32F2F),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          accentColor: Colors.redAccent,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD32F2F),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD32F2F),
          ),
          titleMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      initialRoute: '/',
      getPages: [
        // Core Navigation
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/forgot-password', page: () => const ForgotPasswordScreen()),
        
        // Home Screens (Based on User Type)
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/donor-home', page: () => DonorHomeScreen()),
        
        // Profile
        GetPage(name: '/profile', page: () => ProfileScreen()),
        
        // SOS Features
        GetPage(name: '/sos-request', page: () => SosRequestScreen()),
        
        // Donor Features
        GetPage(name: '/find-donors', page: () => FindDonorsScreen()),
        
        // Donation Camps
        GetPage(name: '/donation-camps', page: () => DonationCampsScreen()),
        
        // Admin Dashboard
        GetPage(name: '/admin-dashboard', page: () => AdminDashboardScreen()),
      ],
      home: const SplashScreen(),
    );
  }
}