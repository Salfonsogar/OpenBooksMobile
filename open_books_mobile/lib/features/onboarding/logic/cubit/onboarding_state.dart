part of 'onboarding_cubit.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingChecked extends OnboardingState {
  final bool hasSeenOnboarding;

  const OnboardingChecked({required this.hasSeenOnboarding});

  @override
  List<Object?> get props => [hasSeenOnboarding];
}