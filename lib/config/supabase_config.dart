import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const supabaseUrl = 'https://zbkslbnugzwlljwhioxf.supabase.co';
  static const supabaseAnonKey = 'sb_publishable_B_oP9un8JJgNcbqYwZphqA_XPLf--qT';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
}