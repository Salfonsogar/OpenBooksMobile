import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  static const String _seenKey = 'has_seen_onboarding';

  OnboardingCubit() : super(const OnboardingInitial());

  Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(_seenKey) ?? false;
    
    emit(OnboardingChecked(hasSeenOnboarding: hasSeen));
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
    
    emit(const OnboardingChecked(hasSeenOnboarding: true));
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, false);
    
    emit(const OnboardingChecked(hasSeenOnboarding: false));
  }
}