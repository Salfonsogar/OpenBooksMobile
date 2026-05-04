import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../logic/cubit/onboarding_cubit.dart';
import '../../../../shared/ui/widgets/app_button.dart';
import '../../../../shared/core/constants/app_constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    const OnboardingSlide(
      title: 'Bienvenido a OpenBooks',
      subtitle: 'Tu biblioteca personal de libros gratuitos. Descubre, Lee y Comparte.',
      animationPath: 'assets/animations/book_onboarding.json',
      color: AppColors.primary,
    ),
    const OnboardingSlide(
      title: 'Tu Biblioteca',
      subtitle: 'Guarda tus libros favoritos y gestionalos fácilmente.',
      animationPath: 'assets/animations/library_onboarding.json',
      color: AppColors.secondary,
    ),
    const OnboardingSlide(
      title: 'Comparte y Descubre',
      subtitle: 'Comparte tus libros con amigos y encuentra nuevas lecturas.',
      animationPath: 'assets/animations/share_onboarding.json',
      color: AppColors.primaryLight,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    context.read<OnboardingCubit>().completeOnboarding();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _OnboardingSlideWidget(slide: _slides[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.textHint.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    label: _currentPage == _slides.length - 1 ? 'Comenzar' : 'Siguiente',
                    onPressed: _nextPage,
                    icon: _currentPage == _slides.length - 1
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    width: double.infinity,
                  ),
                  if (_currentPage < _slides.length - 1) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text(
                        'Saltar',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String subtitle;
  final String animationPath;
  final Color color;

  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.animationPath,
    required this.color,
  });
}

class _OnboardingSlideWidget extends StatelessWidget {
  final OnboardingSlide slide;

  const _OnboardingSlideWidget({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: Lottie.asset(
              slide.animationPath,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            slide.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}