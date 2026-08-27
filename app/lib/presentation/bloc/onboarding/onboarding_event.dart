import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class SignInWithGoogleRequested extends OnboardingEvent {}

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
