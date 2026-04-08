import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../utils/constants.dart';

// Events
abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();
  @override
  List<Object?> get props => [];
}

class ScheduleLoad extends ScheduleEvent {}

class ScheduleCreate extends ScheduleEvent {
  final DateTime scheduledAt;
  final String? notes;
  const ScheduleCreate({required this.scheduledAt, this.notes});
  @override
  List<Object?> get props => [scheduledAt, notes];
}

class ScheduleApprove extends ScheduleEvent {
  final String scheduleId;
  const ScheduleApprove(this.scheduleId);
  @override
  List<Object?> get props => [scheduleId];
}

class ScheduleDecline extends ScheduleEvent {
  final String scheduleId;
  const ScheduleDecline(this.scheduleId);
  @override
  List<Object?> get props => [scheduleId];
}

class ScheduleCancel extends ScheduleEvent {
  final String scheduleId;
  const ScheduleCancel(this.scheduleId);
  @override
  List<Object?> get props => [scheduleId];
}

class ScheduleSelectDay extends ScheduleEvent {
  final DateTime day;
  const ScheduleSelectDay(this.day);
  @override
  List<Object?> get props => [day];
}

class ScheduleSelectSlot extends ScheduleEvent {
  final DateTime slot;
  const ScheduleSelectSlot(this.slot);
  @override
  List<Object?> get props => [slot];
}

class SchedulesUpdated extends ScheduleEvent {
  final List<Schedule> schedules;
  const SchedulesUpdated(this.schedules);
  @override
  List<Object?> get props => [schedules];
}

class _ScheduleTick extends ScheduleEvent {
  const _ScheduleTick();
}

// States
class ScheduleState extends Equatable {
  final List<Schedule> schedules;
  final List<DateTime> availableDays;
  final List<DateTime> availableSlots;
  final DateTime? selectedDay;
  final DateTime? selectedSlot;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final int version;

  const ScheduleState({
    this.schedules = const [],
    this.availableDays = const [],
    this.availableSlots = const [],
    this.selectedDay,
    this.selectedSlot,
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.version = 0,
  });

  List<Schedule> get pendingSchedules =>
      schedules.where((s) => s.status == 'pending').toList();

  List<Schedule> get upcomingApproved =>
      schedules
          .where((s) =>
              s.status == 'approved' && s.scheduledAt.isAfter(DateTime.now()))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  /// The nearest approved call that starts within 10 minutes (or ongoing).
  Schedule? get imminentCall {
    final joinable = schedules.where((s) => s.isJoinable).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return joinable.isNotEmpty ? joinable.first : null;
  }

  ScheduleState copyWith({
    List<Schedule>? schedules,
    List<DateTime>? availableDays,
    List<DateTime>? availableSlots,
    DateTime? selectedDay,
    DateTime? selectedSlot,
    bool? isLoading,
    String? error,
    String? successMessage,
    int? version,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      availableDays: availableDays ?? this.availableDays,
      availableSlots: availableSlots ?? this.availableSlots,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
        schedules, availableDays, availableSlots,
        selectedDay, selectedSlot, isLoading, error, successMessage, version,
      ];
}

// BLoC
class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository _scheduleRepo;
  final AuthRepository _authRepo;

  StreamSubscription? _scheduleSubscription;
  Timer? _ticker;
  int _version = 0;

  ScheduleBloc({
    required ScheduleRepository scheduleRepo,
    required AuthRepository authRepo,
  })  : _scheduleRepo = scheduleRepo,
        _authRepo = authRepo,
        super(const ScheduleState()) {
    on<ScheduleLoad>(_onLoad);
    on<ScheduleCreate>(_onCreate);
    on<ScheduleApprove>(_onApprove);
    on<ScheduleDecline>(_onDecline);
    on<ScheduleCancel>(_onCancel);
    on<ScheduleSelectDay>(_onSelectDay);
    on<ScheduleSelectSlot>(_onSelectSlot);
    on<SchedulesUpdated>(_onUpdated);
    on<_ScheduleTick>(_onTick);

    _scheduleSubscription = _scheduleRepo.scheduleStream.listen(
      (schedules) => add(SchedulesUpdated(schedules)),
    );

    // Re-evaluate isJoinable every 30 seconds
    _ticker = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const _ScheduleTick()),
    );
  }

  void _onLoad(ScheduleLoad event, Emitter<ScheduleState> emit) {
    final user = _authRepo.currentUser;
    if (user == null) return;

    final days = _scheduleRepo.getSchedulableDays();
    final schedules = _scheduleRepo.getSchedulesForUser(user.id);

    emit(state.copyWith(
      schedules: schedules,
      availableDays: days,
      selectedDay: days.isNotEmpty ? days.first : null,
      availableSlots: days.isNotEmpty
          ? _scheduleRepo.getAvailableSlots(days.first)
          : [],
    ));
  }

  Future<void> _onCreate(
    ScheduleCreate event,
    Emitter<ScheduleState> emit,
  ) async {
    final user = _authRepo.currentUser;
    if (user == null) return;

    emit(state.copyWith(isLoading: true));

    try {
      final otherUser = _authRepo.getOtherUser();
      if (otherUser == null) throw Exception('No connected user found');

      await _scheduleRepo.createSchedule(
        guruId: user.role == 'guru' ? user.id : otherUser.id,
        trainerId: user.role == 'trainer' ? user.id : otherUser.id,
        guruName: user.role == 'guru' ? user.name : otherUser.name,
        trainerName: user.role == 'trainer' ? user.name : otherUser.name,
        scheduledAt: event.scheduledAt,
        chatRoomId: AppConstants.defaultChatRoomId,
        notes: event.notes,
      );

      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Session request sent!',
        selectedSlot: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onApprove(
    ScheduleApprove event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await _scheduleRepo.approveSchedule(event.scheduleId);
      emit(state.copyWith(successMessage: 'Session approved!'));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDecline(
    ScheduleDecline event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await _scheduleRepo.declineSchedule(event.scheduleId);
      emit(state.copyWith(successMessage: 'Session declined'));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onCancel(
    ScheduleCancel event,
    Emitter<ScheduleState> emit,
  ) async {
    final user = _authRepo.currentUser;
    if (user == null) return;

    try {
      await _scheduleRepo.cancelSchedule(
        event.scheduleId,
        user.name,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onSelectDay(ScheduleSelectDay event, Emitter<ScheduleState> emit) {
    final slots = _scheduleRepo.getAvailableSlots(event.day);
    emit(state.copyWith(
      selectedDay: event.day,
      availableSlots: slots,
      selectedSlot: null,
    ));
  }

  void _onSelectSlot(ScheduleSelectSlot event, Emitter<ScheduleState> emit) {
    emit(state.copyWith(selectedSlot: event.slot));
  }

  void _onUpdated(SchedulesUpdated event, Emitter<ScheduleState> emit) {
    emit(state.copyWith(schedules: event.schedules, version: ++_version));
  }

  /// Periodic tick to re-evaluate time-sensitive getters (isJoinable).
  void _onTick(_ScheduleTick event, Emitter<ScheduleState> emit) {
    emit(state.copyWith(version: ++_version));
  }

  @override
  Future<void> close() {
    _scheduleSubscription?.cancel();
    _ticker?.cancel();
    return super.close();
  }
}
