import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

enum _AppPhase { splash, onboarding, ready }

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  _AppPhase _phase = _AppPhase.splash;

  @override
  void initState() {
    super.initState();
  }

  void _onSplashDone() {
    if (!isOnboardingComplete()) {
      setState(() => _phase = _AppPhase.onboarding);
    } else {
      _enterReady();
    }
  }

  void _enterReady() {
    setState(() => _phase = _AppPhase.ready);

    final savedUserId =
        StorageService.instance.getSetting('logged_in_user_id');
    if (savedUserId == AppConstants.trainerId) {
      context.read<AuthBloc>().add(AuthLoginAsTrainer());
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _AppPhase.splash:
        return SplashScreen(
          primaryColor: AppTheme.trainerPrimary,
          icon: Icons.fitness_center,
          appName: 'Trainer',
          onComplete: _onSplashDone,
        );

      case _AppPhase.onboarding:
        return OnboardingScreen(
          primaryColor: AppTheme.trainerPrimary,
          slides: const [
            OnboardingSlide(
              icon: Icons.fitness_center,
              title: 'Manage Your\nClients & Sessions',
              subtitle:
                  'Stay connected with your clients, manage schedules, and deliver sessions — all from one app.',
            ),
            OnboardingSlide(
              icon: Icons.videocam_rounded,
              title: 'HD Video Calls\n& Instant Chat',
              subtitle:
                  'Chat in real-time, approve session requests, and join video calls with your clients.',
            ),
          ],
          onComplete: _enterReady,
        );

      case _AppPhase.ready:
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              StorageService.instance
                  .saveSetting('logged_in_user_id', state.user.id);
            }
            if (state is AuthUnauthenticated) {
              StorageService.instance.saveSetting('logged_in_user_id', null);
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          ),
        );
    }
  }
}
