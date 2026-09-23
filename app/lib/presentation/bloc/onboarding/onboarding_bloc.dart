import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final AuthRepository _authRepository;

  OnboardingBloc({required AuthRepository authRepository})
    // ignore: prefer_initializing_formals
    : _authRepository = authRepository,
      super(OnboardingInitial()) {
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<CreateHouseholdRequested>(_onCreateHousehold);
    on<JoinHouseholdRequested>(_onJoinHousehold);
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    if (event.email.trim().isEmpty || event.password.length < 6) {
      emit(
        const OnboardingError(
          'Enter a valid email and a password of at least 6 characters.',
        ),
      );
      return;
    }

    emit(OnboardingLoading());
    try {
      await _authRepository.authenticateWithEmail(
        event.email,
        event.password,
        createAccount: event.createAccount,
      );
      final hasHousehold = await _authRepository.restoreSession();
      emit(hasHousehold ? OnboardingSuccess() : OnboardingAuthenticated());
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }

  Future<void> _onCreateHousehold(
    CreateHouseholdRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    if (event.householdName.isEmpty || event.userName.isEmpty) {
      emit(const OnboardingError("Name fields cannot be empty."));
      emit(OnboardingAuthenticated()); // Reset back to form
      return;
    }

    emit(OnboardingLoading());
    try {
      await _authRepository.createHousehold(
        event.householdName,
        event.userName,
      );
      emit(OnboardingSuccess());
    } catch (e) {
      emit(OnboardingError(e.toString()));
      emit(OnboardingAuthenticated());
    }
  }

  Future<void> _onJoinHousehold(
    JoinHouseholdRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    if (event.joinCode.length != 6 || event.userName.isEmpty) {
      emit(
        const OnboardingError(
          "Join code must be 6 digits and name cannot be empty.",
        ),
      );
      emit(OnboardingAuthenticated()); // Reset back to form
      return;
    }

    emit(OnboardingLoading());
    try {
      await _authRepository.joinHousehold(event.joinCode, event.userName);
      emit(OnboardingSuccess());
    } catch (e) {
      emit(OnboardingError(e.toString()));
      emit(OnboardingAuthenticated());
    }
  }
}
