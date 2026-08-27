
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> createHousehold(String householdName, String userName);
  Future<void> joinHousehold(String joinCode, String userName);
  bool get isSignedIn;
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  bool get isSignedIn => _supabase.auth.currentUser != null;

  @override
  Future<void> signInWithGoogle() async {
    // Note: In a real production app, you'd use google_sign_in package
    // alongside Supabase for native Google Sign-In on iOS/Android.
    // For this prototype/v1, we use the web-based OAuth or a mocked delay if not configured.
    
    // For now, simulating the network delay so the Bloc can show loading states.
    // Replace this with actual Supabase Auth when credentials are set up.
    await Future.delayed(const Duration(seconds: 1)); 
    // await _supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  @override
  Future<void> createHousehold(String householdName, String userName) async {
    // Generate a 6 digit code
    // final joinCode = (100000 + Random().nextInt(900000)).toString();
    
    // Simulating database interactions since Supabase isn't fully initialized with keys yet
    await Future.delayed(const Duration(seconds: 1));

    /* Actual implementation:
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final householdResponse = await _supabase.from('households').insert({
      'name': householdName,
      'join_code': joinCode,
    }).select().single();

    await _supabase.from('members').insert({
      'id': user.id,
      'household_id': householdResponse['id'],
      'name': userName,
      'role': 'planner',
    });
    */
  }

  @override
  Future<void> joinHousehold(String joinCode, String userName) async {
    await Future.delayed(const Duration(seconds: 1));

    /* Actual implementation:
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final household = await _supabase
        .from('households')
        .select()
        .eq('join_code', joinCode)
        .maybeSingle();

    if (household == null) {
      throw Exception('Invalid join code');
    }

    await _supabase.from('members').insert({
      'id': user.id,
      'household_id': household['id'],
      'name': userName,
      'role': 'member',
    });
    */
  }
}
