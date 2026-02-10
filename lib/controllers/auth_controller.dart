import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:blood_donation_sos/config/supabase_config.dart';
import 'package:blood_donation_sos/models/user_model.dart';

class AuthController extends GetxController {
  final SupabaseClient _supabase = SupabaseConfig.client;

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  UserModel? get currentUser => _currentUser.value;   

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isLoggedIn = false.obs;
  bool get isLoggedIn => _isLoggedIn.value;

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    _supabase.auth.onAuthStateChange.listen((AuthState data) {
      final session = data.session;
      if (session != null) {
        _isLoggedIn.value = true;
        fetchUserProfile(session.user.id);
      } else {
        _isLoggedIn.value = false;
        _currentUser.value = null;
      }
    });
    
    await checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        _isLoggedIn.value = true;
        await fetchUserProfile(session.user.id);
      } else {
        _isLoggedIn.value = false;
      }
    } catch (e) {
      print('Error checking current user: $e');
      _isLoggedIn.value = false;
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String bloodGroup,
    required String address,
    bool isDonor = true,
  }) async {
    try {
      _isLoading.value = true;
      print('Starting signup for: $email');

      // First check if user already exists by email
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('User already registered. Please login instead.');
      }

      // Create auth user
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'blood_group': bloodGroup,
        },
      );

      print('Auth response received: ${res.user?.id}');

      if (res.user == null) {
        throw Exception('User creation failed');
      }

      // Wait a bit to ensure auth is complete
      await Future.delayed(Duration(milliseconds: 500));

      // Check if user profile already exists
      final existingProfile = await _supabase
          .from('users')
          .select()
          .eq('id', res.user!.id)
          .maybeSingle();

      if (existingProfile != null) {
        // Profile already exists, use it
        _currentUser.value = UserModel.fromJson(existingProfile);
        _isLoggedIn.value = true;
        
        print('Using existing profile for: ${_currentUser.value?.name}');
        
        Fluttertoast.showToast(
          msg: 'Welcome back! Logged in successfully.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        
        Get.offAllNamed('/home');
        return;
      }

      // Create new profile
      final userData = {
        'id': res.user!.id,
        'name': name,
        'email': email,
        'phone': phone,
        'blood_group': bloodGroup,
        'address': address,
        'is_donor': isDonor,
        'is_available': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Inserting user data: $userData');
      
      // Use insert with onConflict to handle duplicates
      final insertResponse = await _supabase
          .from('users')
          .insert(userData)
          .select()
          .single();

      _currentUser.value = UserModel.fromJson(insertResponse);
      _isLoggedIn.value = true;

      print('Signup successful for: ${_currentUser.value?.name}');
      
      Fluttertoast.showToast(
        msg: 'Account created successfully!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      
      Get.offAllNamed('/home');
      
    } on PostgrestException catch (e) {
      print('Signup PostgrestException: ${e.message}, Code: ${e.code}');
      
      String errorMessage = 'Signup failed. Please try again.';
      
      if (e.code == '23505' || e.message?.contains('duplicate key') == true) {
        // Duplicate key error - user already exists
        errorMessage = 'Account already exists. Attempting to login...';
        
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
        
        // Try to login automatically
        try {
          await login(email: email, password: password);
          return;
        } catch (loginError) {
          errorMessage = 'Account exists but login failed. Please try logging in manually.';
        }
      }
      
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      
      rethrow;
    } on AuthException catch (e) {
      print('Signup AuthException: ${e.message}, Code: ${e.code}');
      
      String errorMessage = 'Signup failed. Please try again.';
      
      if (e.message?.contains('already registered') == true || 
          e.message?.contains('User already registered') == true ||
          e.code == 'user_already_exists') {
        errorMessage = 'This email is already registered. Please login instead.';
      } else if (e.message?.contains('Email not confirmed') == true) {
        errorMessage = 'Email verification required. Please check your email.';
      } else if (e.message?.contains('Invalid email') == true) {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.message?.contains('Password should be at least') == true) {
        errorMessage = 'Password must be at least 6 characters.';
      }
      
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      
      rethrow;
    } catch (e) {
      print('Signup general error: $e');
      
      String errorMessage = 'Signup failed. Please try again.';
      
      if (e.toString().contains('already registered') || 
          e.toString().contains('duplicate')) {
        errorMessage = 'Account already exists. Please login instead.';
      }
      
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading.value = true;
      print('Attempting login for: $email');

      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('Login successful, user ID: ${res.user?.id}');
      
      await fetchUserProfile(res.user!.id);
      
      if (_currentUser.value == null) {
        await Future.delayed(Duration(seconds: 1));
        await fetchUserProfile(res.user!.id);
      }

      if (_currentUser.value == null) {
        throw Exception('User profile not found');
      }

      _isLoggedIn.value = true;

      Fluttertoast.showToast(
        msg: 'Login successful!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      
      Get.offAllNamed('/home');
      
    } on AuthException catch (e) {
      print('Auth error: ${e.message}');
      Fluttertoast.showToast(
        msg: 'Login failed: ${e.message}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      rethrow;
    } catch (e) {
      print('Login error: $e');
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single()
          .timeout(Duration(seconds: 10));

      _currentUser.value = UserModel.fromJson(response);
      print('User profile fetched: ${_currentUser.value?.name}');
      
    } on PostgrestException catch (e) {
      print('Postgrest error fetching user: $e');
      await _createUserProfileFromAuth(userId);
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> _createUserProfileFromAuth(String userId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final userData = {
          'id': user.id,
          'name': user.userMetadata?['name'] ?? 'User',
          'email': user.email ?? '',
          'phone': user.userMetadata?['phone'] ?? '',
          'blood_group': user.userMetadata?['blood_group'] ?? 'O+',
          'address': '',
          'is_donor': true,
          'is_available': true,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('users').insert(userData);
        _currentUser.value = UserModel.fromJson(userData);
      }
    } catch (e) {
      print('Error creating user profile from auth: $e');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? bloodGroup,
    String? address,
    bool? isAvailable,
  }) async {
    try {
      _isLoading.value = true;
      
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (bloodGroup != null) updates['blood_group'] = bloodGroup;
      if (address != null) updates['address'] = address;
      if (isAvailable != null) updates['is_available'] = isAvailable;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', _currentUser.value!.id!);

      await fetchUserProfile(_currentUser.value!.id!);

      Fluttertoast.showToast(
        msg: 'Profile updated successfully!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      print('Profile update error: $e');
      Fluttertoast.showToast(
        msg: 'Error updating profile: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _currentUser.value = null;
      _isLoggedIn.value = false;
      
      Fluttertoast.showToast(
        msg: 'Logged out successfully',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
      );
      
      Get.offAllNamed('/login');
    } catch (e) {
      print('Logout error: $e');
      Fluttertoast.showToast(
        msg: 'Error logging out: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading.value = true;
      await _supabase.auth.resetPasswordForEmail(email);
      
      Fluttertoast.showToast(
        msg: 'Password reset email sent!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      print('Password reset error: $e');
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }
}