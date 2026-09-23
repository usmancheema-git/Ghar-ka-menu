import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ghar_ka_menu/core/theme/app_theme.dart';
import 'package:ghar_ka_menu/config/di.dart';
import 'package:ghar_ka_menu/data/mock/mock_household_store.dart';
import 'package:ghar_ka_menu/data/repositories/auth_repository.dart';
import 'package:ghar_ka_menu/data/repositories/household_repository.dart';
import 'package:ghar_ka_menu/presentation/widgets/app_bottom_nav.dart';
import 'package:google_fonts/google_fonts.dart';

/// S8 Settings — household info, notification time, and member roster.
/// Reference: `prototype/s8_settings/index.html`.
class S8SettingsScreen extends StatefulWidget {
  const S8SettingsScreen({super.key});

  @override
  State<S8SettingsScreen> createState() => _S8SettingsScreenState();
}

class _S8SettingsScreenState extends State<S8SettingsScreen> {
  String _householdName = MockHouseholdStore.householdName;
  String _joinCode = MockHouseholdStore.joinCode;
  String _alertTime = '20:00';
  String _currentMemberName = 'Awais';
  String _activeRole = MockHouseholdStore.userRole == 'member'
      ? 'Member'
      : 'Planner';
  List<HouseholdMember> _members = const [
    HouseholdMember(name: 'Dado', role: 'planner'),
    HouseholdMember(name: 'Maryam', role: 'member'),
    HouseholdMember(name: 'Zainab', role: 'member'),
    HouseholdMember(name: 'Bilal', role: 'member'),
    HouseholdMember(name: 'Ayesha', role: 'member'),
  ];

  HouseholdRepository get _repository =>
      getIt.isRegistered<HouseholdRepository>()
      ? getIt<HouseholdRepository>()
      : SupabaseHouseholdRepository(null);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _repository.fetchSettings(
      MockHouseholdStore.householdId,
    );
    if (!mounted) return;
    setState(() {
      _householdName = settings.name;
      _joinCode = settings.joinCode;
      _alertTime = settings.alertTime;
      _currentMemberName = settings.currentMemberName;
      _activeRole = settings.currentRole == 'member' ? 'Member' : 'Planner';
      _members = settings.members;
    });
  }

  Future<void> _pickAlertTime() async {
    final parts = _alertTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 20,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked == null || !mounted) return;

    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() => _alertTime = value);
    await _repository.updateAlertTime(MockHouseholdStore.householdId, value);
  }

  Future<void> _logout() async {
    await getIt<AuthRepository>().signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final members = [
      ('$_currentMemberName (You)', _activeRole),
      ..._members.map(
        (member) =>
            (member.name, member.role == 'member' ? 'Member' : 'Planner'),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: Column(
        children: [
          const _SettingsHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                const _SectionTitle('Household Info'),
                _SettingsCard(
                  rows: [
                    _SettingsRow(
                      label: 'Household Name',
                      value: _householdName,
                    ),
                    _SettingsRow(
                      label: 'Join Code',
                      value: _joinCode,
                      isCode: true,
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: _joinCode));
                      },
                    ),
                  ],
                ),
                const _SectionTitle('Notifications'),
                _SettingsCard(
                  rows: [
                    _SettingsRow(
                      label: 'Next-Day Alert Time',
                      value: _alertTime,
                      isTime: true,
                      onTap: _pickAlertTime,
                    ),
                  ],
                ),
                const _SectionTitle('My Role'),
                _SettingsCard(
                  rows: [
                    _SettingsRow(
                      label: 'Active Role',
                      value: _activeRole,
                      isRole: true,
                      onRoleChanged: (value) {
                        setState(() {
                          _activeRole = value;
                          _repository.updateCurrentMemberRole(
                            MockHouseholdStore.householdId,
                            value,
                          );
                        });
                      },
                    ),
                  ],
                ),
                _SectionTitle('Family Members (${members.length})'),
                _SettingsCard(
                  rows: members.map((member) {
                    final (name, role) = member;
                    return _MemberRow(name: name, role: role);
                  }).toList(),
                ),
                const _SectionTitle('Account'),
                _SettingsCard(
                  rows: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const FaIcon(FontAwesomeIcons.rightFromBracket),
                        label: const Text('Log Out'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const AppBottomNav(activeIndex: 3),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
              ),
            ),
            Text(
              'Manage household parameters',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(children: rows),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.value,
    this.isCode = false,
    this.isTime = false,
    this.isRole = false,
    this.onTap,
    this.onRoleChanged,
  });

  final String label;
  final String value;
  final bool isCode;
  final bool isTime;
  final bool isRole;
  final VoidCallback? onTap;
  final ValueChanged<String>? onRoleChanged;

  @override
  Widget build(BuildContext context) {
    final isValueAction = isCode || isRole || isTime;

    return GestureDetector(
      onTap: isValueAction ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (isCode) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const FaIcon(
                      FontAwesomeIcons.copy,
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ] else if (isTime) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgApp,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ] else if (isRole) ...[
              Row(
                children: [
                  _RoleChip(
                    key: const ValueKey('role-planner-chip'),
                    label: 'Planner',
                    selected: value == 'Planner',
                    onTap: () => onRoleChanged?.call('Planner'),
                  ),
                  const SizedBox(width: 8),
                  _RoleChip(
                    key: const ValueKey('role-member-chip'),
                    label: 'Member',
                    selected: value == 'Member',
                    onTap: () => onRoleChanged?.call('Member'),
                  ),
                ],
              ),
            ] else ...[
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.bgApp,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.name, required this.role});

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    final isPlanner = role == 'Planner';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: isPlanner
                  ? AppColors.primaryLight
                  : AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              role,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: isPlanner ? AppColors.primary : AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
