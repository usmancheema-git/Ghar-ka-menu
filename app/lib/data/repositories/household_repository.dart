import 'package:supabase_flutter/supabase_flutter.dart';

import '../mock/mock_household_store.dart';

class HouseholdMember {
  const HouseholdMember({required this.name, required this.role});

  final String name;
  final String role;
}

class HouseholdSettings {
  const HouseholdSettings({
    required this.name,
    required this.joinCode,
    required this.alertTime,
    required this.members,
    required this.currentRole,
    required this.currentMemberName,
  });

  final String name;
  final String joinCode;
  final String alertTime;
  final List<HouseholdMember> members;
  final String currentRole;
  final String currentMemberName;
}

abstract class HouseholdRepository {
  Future<HouseholdSettings> fetchSettings(String householdId);
  Future<void> updateAlertTime(String householdId, String alertTime);
  Future<void> updateCurrentMemberRole(String householdId, String role);
  Future<void> updateCurrentMemberToken(String token);
}

class SupabaseHouseholdRepository implements HouseholdRepository {
  SupabaseHouseholdRepository(this._supabase);

  final SupabaseClient? _supabase;

  @override
  Future<HouseholdSettings> fetchSettings(String householdId) async {
    if (_supabase != null) {
      final household = await _supabase
          .from('households')
          .select('name, join_code, alert_time')
          .eq('id', householdId)
          .single();
      final members = await _supabase
          .from('members')
          .select('name, role')
          .eq('household_id', householdId)
          .order('created_at');
      final currentUserId = _supabase.auth.currentUser?.id;
      final currentMember = await _supabase
          .from('members')
          .select('name, role')
          .eq('id', currentUserId ?? '')
          .maybeSingle();

      return HouseholdSettings(
        name: household['name'] as String,
        joinCode: household['join_code'] as String,
        alertTime: (household['alert_time'] as String).substring(0, 5),
        members: members
            .map(
              (member) => HouseholdMember(
                name: member['name'] as String,
                role: member['role'] as String,
              ),
            )
            .toList(),
        currentRole: currentMember?['role'] as String? ?? 'member',
        currentMemberName: currentMember?['name'] as String? ?? 'You',
      );
    }

    return HouseholdSettings(
      name: MockHouseholdStore.householdName,
      joinCode: MockHouseholdStore.joinCode,
      alertTime: '20:00',
      currentRole: MockHouseholdStore.userRole,
      currentMemberName: 'Awais',
      members: const [
        HouseholdMember(name: 'Dado', role: 'planner'),
        HouseholdMember(name: 'Maryam', role: 'member'),
        HouseholdMember(name: 'Zainab', role: 'member'),
        HouseholdMember(name: 'Bilal', role: 'member'),
        HouseholdMember(name: 'Ayesha', role: 'member'),
      ],
    );
  }

  @override
  Future<void> updateAlertTime(String householdId, String alertTime) async {
    if (_supabase != null) {
      await _supabase
          .from('households')
          .update({'alert_time': alertTime})
          .eq('id', householdId);
    }
  }

  @override
  Future<void> updateCurrentMemberRole(String householdId, String role) async {
    if (_supabase != null) {
      await _supabase.rpc(
        'update_member_role',
        params: {
          'p_household_id': householdId,
          'p_member_id': _supabase.auth.currentUser!.id,
          'p_role': role.toLowerCase(),
        },
      );
    }
    MockHouseholdStore.setUserRole(role);
  }

  @override
  Future<void> updateCurrentMemberToken(String token) async {
    if (_supabase != null && _supabase.auth.currentUser != null) {
      await _supabase
          .from('members')
          .update({'fcm_token': token})
          .eq('id', _supabase.auth.currentUser!.id);
    }
  }
}
