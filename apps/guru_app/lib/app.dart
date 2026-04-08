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

    // Auto-login if user was previously logged in
    final savedUserId =
        StorageService.instance.getSetting('logged_in_user_id');
    if (savedUserId == AppConstants.guruId) {
      context.read<AuthBloc>().add(AuthLoginAsGuru());
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _AppPhase.splash:
        return SplashScreen(
          primaryColor: AppTheme.guruPrimary,
          icon: Icons.self_improvement,
          appName: 'Guru',
          onComplete: _onSplashDone,
        );

      case _AppPhase.onboarding:
        return OnboardingScreen(
          primaryColor: AppTheme.guruPrimary,
          slides: const [
            OnboardingSlide(
              icon: Icons.self_improvement,
              title: 'Your Personal\nTraining Companion',
              subtitle:
                  'Connect with your trainer, schedule sessions, and track your progress — all in one place.',
            ),
            OnboardingSlide(
              icon: Icons.videocam_rounded,
              title: 'Live Video Sessions\n& Real-Time Chat',
              subtitle:
                  'Chat instantly, schedule calls, and join HD video sessions with your trainer.',
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
