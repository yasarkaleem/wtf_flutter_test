import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';
import '../../services/services.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthLoginAsGuru extends AuthEvent {}

class AuthLoginAsTrainer extends AuthEvent {}

class AuthLogout extends AuthEvent {}

class AuthCheckSession extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginAsGuru>(_onLoginAsGuru);
    on<AuthLoginAsTrainer>(_onLoginAsTrainer);
    on<AuthLogout>(_onLogout);
    on<AuthCheckSession>(_onCheckSession);
  }

  Future<void> _initServices(AppUser user) async {
    await ChatService.instance.init(user.id);
    ScheduleService.instance.init();
    SessionService.instance.init();
    await SessionService.instance.seedDemoSessions();
    HmsService.instance.init();

    // Connect to WebSocket server for cross-app sync
    await SyncService.instance.connect(user.id);
  }

  Future<void> _onLoginAsGuru(
    AuthLoginAsGuru event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await AuthService.instance.loginAsGuru();
      await _initServices(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginAsTrainer(
    AuthLoginAsTrainer event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await AuthService.instance.loginAsTrainer();
      await _initServices(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogout event,
    Emitter<AuthState> emit,
  ) async {
    await SyncService.instance.disconnect();
    await AuthService.instance.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckSession(
    AuthCheckSession event,
    Emitter<AuthState> emit,
  ) async {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
