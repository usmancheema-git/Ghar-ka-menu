import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static Future<SupabaseClient?> initialize() async {
    if (!isConfigured) return null;

    await Supabase.initialize(url: url, publishableKey: anonKey);
    return Supabase.instance.client;
  }
}
