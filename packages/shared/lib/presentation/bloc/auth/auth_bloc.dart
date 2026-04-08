import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';

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
  final AuthRepository _authRepo;
  final ChatRepository _chatRepo;
  final ScheduleRepository _scheduleRepo;
  final SessionRepository _sessionRepo;
  final SyncRepository _syncRepo;

  AuthBloc({
    required AuthRepository authRepo,
    required ChatRepository chatRepo,
    required ScheduleRepository scheduleRepo,
    required SessionRepository sessionRepo,
    required SyncRepository syncRepo,
  })  : _authRepo = authRepo,
        _chatRepo = chatRepo,
        _scheduleRepo = scheduleRepo,
        _sessionRepo = sessionRepo,
        _syncRepo = syncRepo,
        super(AuthInitial()) {
    on<AuthLoginAsGuru>(_onLoginAsGuru);
    on<AuthLoginAsTrainer>(_onLoginAsTrainer);
    on<AuthLogout>(_onLogout);
    on<AuthCheckSession>(_onCheckSession);
  }

  Future<void> _initServices(AppUser user) async {
    await _chatRepo.init(user.id);
    _scheduleRepo.init();
    _sessionRepo.init();
    await _sessionRepo.seedDemoSessions();
    await _syncRepo.connect(user.id);
  }

  Future<void> _onLoginAsGuru(AuthLoginAsGuru event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.loginAsGuru();
      await _initServices(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginAsTrainer(AuthLoginAsTrainer event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.loginAsTrainer();
      await _initServices(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await _syncRepo.disconnect();
    await _authRepo.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckSession(AuthCheckSession event, Emitter<AuthState> emit) async {
    final user = _authRepo.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
