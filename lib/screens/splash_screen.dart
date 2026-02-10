import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation_sos/controllers/auth_controller.dart';
import 'package:blood_donation_sos/screens/login_screen.dart';
import 'package:blood_donation_sos/screens/home_screen.dart';
import 'package:blood_donation_sos/screens/donor_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = Get.find();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(Duration(seconds: 2));
    
    if (_authController.isLoggedIn) {
      // Check if user is donor or recipient
      final user = _authController.currentUser;
      if (user?.isDonor == true) {
        Get.offAll(() => DonorHomeScreen()); // Donor
      } else {
        Get.offAll(() => HomeScreen()); // Recipient
      }
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD32F2F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              color: Colors.white,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Blood Donation SOS',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Save Lives, Donate Blood',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}