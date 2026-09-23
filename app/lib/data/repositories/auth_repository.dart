import 'package:supabase_flutter/supabase_flutter.dart';

import '../mock/mock_household_store.dart';

abstract class AuthRepository {
  Future<void> authenticateWithEmail(
    String email,
    String password, {
    required bool createAccount,
  });
  Future<void> createHousehold(String householdName, String userName);
  Future<void> joinHousehold(String joinCode, String userName);
  Future<bool> restoreSession();
  Future<void> signOut();
  bool get isSignedIn;
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient? _supabase;
  final bool live;

  SupabaseAuthRepository(this._supabase, {this.live = false});

  SupabaseClient? get _liveClient {
    return live ? _supabase : null;
  }

  @override
  bool get isSignedIn => _liveClient?.auth.currentUser != null;

  @override
  Future<void> signOut() async {
    final liveClient = _liveClient;
    if (liveClient != null) {
      await liveClient.auth.signOut();
    }
    MockHouseholdStore.clearSession();
  }

  @override
  Future<bool> restoreSession() async {
    final liveClient = _liveClient;
    if (liveClient == null) return false;

    final user = liveClient.auth.currentUser;
    if (user == null) return false;

    final membership = await liveClient
        .from('members')
        .select('household_id, name, role, households(name, join_code)')
        .eq('id', user.id)
        .maybeSingle();
    if (membership == null) return false;

    final household = membership['households'] as Map<String, dynamic>;
    MockHouseholdStore.setSession(
      householdIdValue: membership['household_id'] as String,
      householdNameValue: household['name'] as String,
      joinCodeValue: household['join_code'] as String,
      role: membership['role'] as String,
      authenticated: true,
    );
    return true;
  }

  @override
  Future<void> authenticateWithEmail(
    String email,
    String password, {
    required bool createAccount,
  }) async {
    final liveClient = _liveClient;
    if (liveClient != null) {
      if (createAccount) {
        final response = await liveClient.auth.signUp(
          email: email.trim(),
          password: password,
        );
        if (response.session == null) {
          throw Exception('Account created. Confirm your email, then sign in.');
        }
      } else {
        await liveClient.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
      }
      return;
    }

    await Future.delayed(const Duration(seconds: 1));
    MockHouseholdStore.isAuthenticated = true;
  }

  @override
  Future<void> createHousehold(String householdName, String userName) async {
    final cleanHouseholdName = householdName.trim();
    final cleanUserName = userName.trim();
    if (cleanHouseholdName.isEmpty || cleanUserName.isEmpty) {
      throw Exception('Name fields cannot be empty.');
    }

    final liveClient = _liveClient;
    if (liveClient != null) {
      final userId = liveClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Please sign in before creating a household.');
      }

      final generatedCode = MockHouseholdStore.generateJoinCode();
      final household = await liveClient
          .rpc(
            'create_household',
            params: {
              'p_name': cleanHouseholdName,
              'p_user_name': cleanUserName,
              'p_join_code': generatedCode,
            },
          )
          .single();

      MockHouseholdStore.setSession(
        householdIdValue: household['id'] as String,
        householdNameValue: household['name'] as String,
        joinCodeValue: household['join_code'] as String,
        role: household['role'] as String,
        authenticated: true,
      );
      return;
    }

    await Future.delayed(const Duration(seconds: 1));

    final generatedCode = MockHouseholdStore.generateJoinCode();
    MockHouseholdStore.householdCodes[generatedCode] = cleanHouseholdName;

    MockHouseholdStore.setSession(
      householdIdValue: 'household-${DateTime.now().millisecondsSinceEpoch}',
      householdNameValue: cleanHouseholdName,
      joinCodeValue: generatedCode,
      role: 'planner',
      authenticated: true,
    );
  }

  @override
  Future<void> joinHousehold(String joinCode, String userName) async {
    final cleanJoinCode = joinCode.trim();
    final cleanUserName = userName.trim();
    if (cleanJoinCode.length != 6 || cleanUserName.isEmpty) {
      throw Exception('Join code must be 6 digits and name cannot be empty.');
    }

    final liveClient = _liveClient;
    if (liveClient != null) {
      final userId = liveClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Please sign in before joining a household.');
      }

      final household = await liveClient
          .rpc(
            'join_household',
            params: {
              'p_join_code': cleanJoinCode,
              'p_user_name': cleanUserName,
            },
          )
          .single();

      MockHouseholdStore.setSession(
        householdIdValue: household['id'] as String,
        householdNameValue: household['name'] as String,
        joinCodeValue: household['join_code'] as String,
        role: household['role'] as String,
        authenticated: true,
      );
      return;
    }

    await Future.delayed(const Duration(seconds: 1));

    final householdName = MockHouseholdStore.householdNameForCode(
      cleanJoinCode,
    );
    if (householdName == null) {
      throw Exception('That join code does not match a household.');
    }

    MockHouseholdStore.setSession(
      householdIdValue: 'household-$cleanJoinCode',
      householdNameValue: householdName,
      joinCodeValue: cleanJoinCode,
      role: 'member',
      authenticated: true,
    );
  }
}
