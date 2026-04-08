import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';
import '../../services/services.dart';

// Events
abstract class SessionEvent extends Equatable {
  const SessionEvent();
  @override
  List<Object?> get props => [];
}

class SessionLoad extends SessionEvent {}

class SessionFilterChanged extends SessionEvent {
  final SessionFilter filter;
  const SessionFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class SessionAddRating extends SessionEvent {
  final String sessionId;
  final int rating;
  const SessionAddRating({required this.sessionId, required this.rating});
  @override
  List<Object?> get props => [sessionId, rating];
}

class SessionAddNotes extends SessionEvent {
  final String sessionId;
  final String notes;
  final bool isTrainer;
  const SessionAddNotes({
    required this.sessionId,
    required this.notes,
    required this.isTrainer,
  });
  @override
  List<Object?> get props => [sessionId, notes, isTrainer];
}

class SessionsUpdated extends SessionEvent {
  final List<SessionLog> sessions;
  const SessionsUpdated(this.sessions);
  @override
  List<Object?> get props => [sessions];
}

class SessionCreateFromCall extends SessionEvent {
  final String scheduleId;
  final DateTime startedAt;
  final DateTime endedAt;
  const SessionCreateFromCall({
    required this.scheduleId,
    required this.startedAt,
    required this.endedAt,
  });
  @override
  List<Object?> get props => [scheduleId, startedAt, endedAt];
}

// States
class SessionState extends Equatable {
  final List<SessionLog> sessions;
  final List<SessionLog> filteredSessions;
  final SessionFilter currentFilter;
  final bool isLoading;
  final String? error;

  const SessionState({
    this.sessions = const [],
    this.filteredSessions = const [],
    this.currentFilter = SessionFilter.all,
    this.isLoading = false,
    this.error,
  });

  SessionState copyWith({
    List<SessionLog>? sessions,
    List<SessionLog>? filteredSessions,
    SessionFilter? currentFilter,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      sessions: sessions ?? this.sessions,
      filteredSessions: filteredSessions ?? this.filteredSessions,
      currentFilter: currentFilter ?? this.currentFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        sessions, filteredSessions, currentFilter, isLoading, error,
      ];
}

// BLoC
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  StreamSubscription? _sessionSubscription;

  SessionBloc() : super(const SessionState()) {
    on<SessionLoad>(_onLoad);
    on<SessionFilterChanged>(_onFilterChanged);
    on<SessionAddRating>(_onAddRating);
    on<SessionAddNotes>(_onAddNotes);
    on<SessionsUpdated>(_onUpdated);
    on<SessionCreateFromCall>(_onCreateFromCall);

    _sessionSubscription = SessionService.instance.sessionStream.listen(
      (sessions) => add(SessionsUpdated(sessions)),
    );
  }

  void _onLoad(SessionLoad event, Emitter<SessionState> emit) {
    final sessions =
        SessionService.instance.getFilteredSessions(state.currentFilter);
    emit(state.copyWith(
      sessions: SessionService.instance.getFilteredSessions(SessionFilter.all),
      filteredSessions: sessions,
    ));
  }

  void _onFilterChanged(
    SessionFilterChanged event,
    Emitter<SessionState> emit,
  ) {
    final filtered = SessionService.instance.getFilteredSessions(event.filter);
    emit(state.copyWith(
      currentFilter: event.filter,
      filteredSessions: filtered,
    ));
  }

  Future<void> _onAddRating(
    SessionAddRating event,
    Emitter<SessionState> emit,
  ) async {
    await SessionService.instance.addRating(event.sessionId, event.rating);
  }

  Future<void> _onAddNotes(
    SessionAddNotes event,
    Emitter<SessionState> emit,
  ) async {
    await SessionService.instance.addNotes(
      sessionId: event.sessionId,
      notes: event.notes,
      isTrainer: event.isTrainer,
    );
  }

  void _onUpdated(SessionsUpdated event, Emitter<SessionState> emit) {
    final filtered =
        SessionService.instance.getFilteredSessions(state.currentFilter);
    emit(state.copyWith(
      sessions: event.sessions,
      filteredSessions: filtered,
    ));
  }

  Future<void> _onCreateFromCall(
    SessionCreateFromCall event,
    Emitter<SessionState> emit,
  ) async {
    final user = AuthService.instance.currentUser;
    final otherUser = AuthService.instance.getOtherUser();
    if (user == null || otherUser == null) return;

    await SessionService.instance.createSessionLog(
      scheduleId: event.scheduleId,
      guruId: user.role == 'guru' ? user.id : otherUser.id,
      trainerId: user.role == 'trainer' ? user.id : otherUser.id,
      guruName: user.role == 'guru' ? user.name : otherUser.name,
      trainerName: user.role == 'trainer' ? user.name : otherUser.name,
      startedAt: event.startedAt,
      endedAt: event.endedAt,
    );
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    return super.close();
  }
}
