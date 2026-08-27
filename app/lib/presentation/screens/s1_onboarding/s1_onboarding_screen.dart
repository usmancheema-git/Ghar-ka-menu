import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghar_ka_menu/core/theme/app_theme.dart';
import 'package:ghar_ka_menu/config/di.dart';
import 'package:ghar_ka_menu/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:ghar_ka_menu/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:ghar_ka_menu/presentation/bloc/onboarding/onboarding_state.dart';

class S1OnboardingScreen extends StatefulWidget {
  const S1OnboardingScreen({super.key});

  @override
  State<S1OnboardingScreen> createState() => _S1OnboardingScreenState();
}

class _S1OnboardingScreenState extends State<S1OnboardingScreen> {
  String _activeForm = ''; // 'create' or 'join'

  final TextEditingController _householdNameController = TextEditingController(text: 'Awais Family');
  final TextEditingController _yourNameController = TextEditingController(text: 'Awais');
  final TextEditingController _joinCodeController = TextEditingController();
  final TextEditingController _joinNameController = TextEditingController();

  void _signInWithGoogle(BuildContext context) {
    context.read<OnboardingBloc>().add(SignInWithGoogleRequested());
  }

  void _showForm(String type) {
    setState(() {
      _activeForm = type;
    });
  }

  void _showChoices() {
    setState(() {
      _activeForm = '';
    });
  }

  @override
  void dispose() {
    _householdNameController.dispose();
    _yourNameController.dispose();
    _joinCodeController.dispose();
    _joinNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(authRepository: getIt()),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: BlocConsumer<OnboardingBloc, OnboardingState>(
              listener: (context, state) {
                if (state is OnboardingSuccess) {
                  context.go('/home');
                } else if (state is OnboardingError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is OnboardingLoading;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBrandSection(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            if (isLoading)
                              const Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            if (!isLoading) ...[
                              if (state is OnboardingInitial) _buildSignInStep(context),
                              if (state is OnboardingAuthenticated && _activeForm.isEmpty) _buildChoicesStep(),
                              if (state is OnboardingAuthenticated && _activeForm == 'create') _buildCreateForm(context),
                              if (state is OnboardingAuthenticated && _activeForm == 'join') _buildJoinForm(context),
                            ],
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      children: [
        const SizedBox(height: 15),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textMain.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const FaIcon(
            FontAwesomeIcons.utensils,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ghar ka Menu',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Joint family lunch planner',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInStep(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => _signInWithGoogle(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textMain.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.google, color: Colors.blue, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Sign in with Google',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border, thickness: 1.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'secure authentication',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border, thickness: 1.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildChoicesStep() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Awais', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 13)),
                    Text('awais@gmail.com', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.5)),
                  ],
                ),
              ),
              const FaIcon(FontAwesomeIcons.circleCheck, color: AppColors.secondary, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _showForm('create'),
          icon: const FaIcon(FontAwesomeIcons.houseChimneyUser, size: 18),
          label: const Text('Create New Household'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showForm('join'),
          icon: const FaIcon(FontAwesomeIcons.key, size: 18),
          label: const Text('Join Existing Code'),
        ),
      ],
    );
  }

  Widget _buildCreateForm(BuildContext context) {
    return _buildFormCard(
      titleIconWidget: const FaIcon(FontAwesomeIcons.circlePlus, color: AppColors.primary, size: 16),
      title: 'Setup Household',
      onBack: _showChoices,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('HOUSEHOLD NAME'),
          TextField(
            controller: _householdNameController,
            decoration: const InputDecoration(hintText: 'e.g., Awais Joint Family'),
          ),
          const SizedBox(height: 12),
          _buildInputLabel('YOUR NAME'),
          TextField(
            controller: _yourNameController,
            decoration: const InputDecoration(hintText: 'e.g., Awais'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<OnboardingBloc>().add(
                CreateHouseholdRequested(
                  householdName: _householdNameController.text,
                  userName: _yourNameController.text,
                )
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Create & Plan Menu'),
                const SizedBox(width: 8),
                const FaIcon(FontAwesomeIcons.arrowRight, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinForm(BuildContext context) {
    return _buildFormCard(
      titleIconWidget: const FaIcon(FontAwesomeIcons.key, color: AppColors.secondary, size: 16),
      title: 'Join Code',
      onBack: _showChoices,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('6-DIGIT CODE'),
          TextField(
            controller: _joinCodeController,
            decoration: const InputDecoration(hintText: 'e.g., 482910'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildInputLabel('YOUR NAME'),
          TextField(
            controller: _joinNameController,
            decoration: const InputDecoration(hintText: 'e.g., Maryam'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
               context.read<OnboardingBloc>().add(
                JoinHouseholdRequested(
                  joinCode: _joinCodeController.text,
                  userName: _joinNameController.text,
                )
              );
            },
            child: const Text('Join Household'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 10.5,
          color: AppColors.textMain,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required Widget titleIconWidget,
    required String title,
    required VoidCallback onBack,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textMain.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  titleIconWidget,
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 14),
                  ),
                ],
              ),
              InkWell(
                onTap: onBack,
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.chevronLeft, size: 10, color: AppColors.primary),
                    const SizedBox(width: 3),
                    Text(
                      'Back',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}
