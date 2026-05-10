import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_books_mobile/features/onboarding/logic/cubit/onboarding_cubit.dart';


void main() {
  group('OnboardingCubit', () {
    blocTest<OnboardingCubit, OnboardingState>(
      'initial state is OnboardingInitial',
      build: () => OnboardingCubit(),
      verify: (cubit) {
        expect(cubit.state, isA<OnboardingInitial>());
      },
    );

    group('checkOnboardingStatus', () {
      blocTest<OnboardingCubit, OnboardingState>(
        'emits OnboardingChecked with hasSeenOnboarding false when not seen',
        setUp: () {
          SharedPreferences.setMockInitialValues({'has_seen_onboarding': false});
        },
        build: () => OnboardingCubit(),
        act: (cubit) => cubit.checkOnboardingStatus(),
        expect: () => [
          const OnboardingChecked(hasSeenOnboarding: false),
        ],
      );

      blocTest<OnboardingCubit, OnboardingState>(
        'emits OnboardingChecked with hasSeenOnboarding true when already seen',
        setUp: () {
          SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
        },
        build: () => OnboardingCubit(),
        act: (cubit) => cubit.checkOnboardingStatus(),
        expect: () => [
          const OnboardingChecked(hasSeenOnboarding: true),
        ],
      );
    });

    group('completeOnboarding', () {
      blocTest<OnboardingCubit, OnboardingState>(
        'sets hasSeenOnboarding to true',
        setUp: () {
          SharedPreferences.setMockInitialValues({'has_seen_onboarding': false});
        },
        build: () => OnboardingCubit(),
        act: (cubit) => cubit.completeOnboarding(),
        expect: () => [
          const OnboardingChecked(hasSeenOnboarding: true),
        ],
      );
    });

    group('resetOnboarding', () {
      blocTest<OnboardingCubit, OnboardingState>(
        'sets hasSeenOnboarding to false',
        setUp: () {
          SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
        },
        build: () => OnboardingCubit(),
        act: (cubit) => cubit.resetOnboarding(),
        expect: () => [
          const OnboardingChecked(hasSeenOnboarding: false),
        ],
      );
    });
  });
}
