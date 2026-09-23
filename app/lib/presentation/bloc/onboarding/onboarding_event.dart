import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class SignInWithEmailRequested extends OnboardingEvent {
  final String email;
  final String password;
  final bool createAccount;

  const SignInWithEmailRequested({
    required this.email,
    required this.password,
    this.createAccount = false,
  });

  @override
  List<Object?> get props => [email, password, createAccount];
}

class CreateHouseholdRequested extends OnboardingEvent {
  final String householdName;
  final String userName;

  const CreateHouseholdRequested({
    required this.householdName,
    required this.userName,
  });

  @override
  List<Object?> get props => [householdName, userName];
}

class JoinHouseholdRequested extends OnboardingEvent {
  final String joinCode;
  final String userName;

  const JoinHouseholdRequested({
    required this.joinCode,
    required this.userName,
  });

  @override
  List<Object?> get props => [joinCode, userName];
}
