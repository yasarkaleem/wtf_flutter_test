import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/constants.dart';

// Events
abstract class CallEvent extends Equatable {
  const CallEvent();
  @override
  List<Object?> get props => [];
}

class CallJoin extends CallEvent {
  final String roomId;
  final String role;
  const CallJoin({required this.roomId, required this.role});
  @override
  List<Object?> get props => [roomId, role];
}

class CallLeave extends CallEvent {}

class CallToggleAudio extends CallEvent {}

class CallToggleVideo extends CallEvent {}

class CallFlipCamera extends CallEvent {}

class CallStateUpdated extends CallEvent {
  final ActiveCallState callState;
  const CallStateUpdated(this.callState);
  @override
  List<Object?> get props => [callState];
}

class CallReconnect extends CallEvent {}

// States
abstract class CallBlocState extends Equatable {
  const CallBlocState();
  @override
  List<Object?> get props => [];
}

class CallIdle extends CallBlocState {}

class CallConnecting extends CallBlocState {}

class CallConnected extends CallBlocState {
  final ActiveCallState callState;
  const CallConnected(this.callState);
  @override
  List<Object?> get props => [callState];
}

class CallReconnecting extends CallBlocState {}

class CallDisconnected extends CallBlocState {
  final Duration duration;
  const CallDisconnected(this.duration);
  @override
  List<Object?> get props => [duration];
}

class CallFailed extends CallBlocState {
  final String error;
  const CallFailed(this.error);
  @override
  List<Object?> get props => [error];
}

// BLoC
class CallBloc extends Bloc<CallEvent, CallBlocState> {
  StreamSubscription? _callStateSubscription;
  Timer? _durationTimer;

  CallBloc() : super(CallIdle()) {
    on<CallJoin>(_onJoin);
    on<CallLeave>(_onLeave);
    on<CallToggleAudio>(_onToggleAudio);
    on<CallToggleVideo>(_onToggleVideo);
    on<CallFlipCamera>(_onFlipCamera);
    on<CallStateUpdated>(_onStateUpdated);
    on<CallReconnect>(_onReconnect);

    _callStateSubscription = HmsService.instance.callStateStream.listen(
      (callState) => add(CallStateUpdated(callState)),
    );
  }

  Future<void> _onJoin(CallJoin event, Emitter<CallBlocState> emit) async {
    emit(CallConnecting());
    LogService.instance.log(AppConstants.tagRtc, 'Joining room: ${event.roomId}');

    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // Get auth token
      await HmsService.instance.getAuthToken(
        roomId: event.roomId,
        userId: user.id,
        role: event.role,
      );

      // Simulate connection delay (in real implementation, HMSSDK.join() is called here)
      await Future.delayed(const Duration(milliseconds: 1500));

      final localParticipant = CallParticipant(
        peerId: user.id,
        name: user.name,
        role: event.role,
        isLocal: true,
      );

      final callState = ActiveCallState(
        connectionState: CallConnectionState.connected,
        participants: [localParticipant],
        callStartTime: DateTime.now(),
        roomId: event.roomId,
      );

      HmsService.instance.updateCallState(callState);
      emit(CallConnected(callState));
      LogService.instance.log(AppConstants.tagRtc, 'Connected to room');

      // Simulate remote peer joining after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        final otherUser = AuthService.instance.getOtherUser();
        if (otherUser != null) {
          final remotePeer = CallParticipant(
            peerId: otherUser.id,
            name: otherUser.name,
            role: otherUser.role == 'trainer' ? 'trainer' : 'member',
          );

          final updated = callState.copyWith(
            participants: [...callState.participants, remotePeer],
          );
          HmsService.instance.updateCallState(updated);
        }
      });
    } catch (e) {
      LogService.instance.error(AppConstants.tagRtc, 'Join failed', e);
      emit(CallFailed(e.toString()));
    }
  }

  Future<void> _onLeave(CallLeave event, Emitter<CallBlocState> emit) async {
    LogService.instance.log(AppConstants.tagRtc, 'Leaving call');

    final currentState = HmsService.instance.currentCallState;
    final duration = currentState.callDuration;

    HmsService.instance.resetCallState();
    _durationTimer?.cancel();
    emit(CallDisconnected(duration));
  }

  void _onToggleAudio(CallToggleAudio event, Emitter<CallBlocState> emit) {
    final current = HmsService.instance.currentCallState;
    final updated = current.copyWith(
      isLocalAudioMuted: !current.isLocalAudioMuted,
    );
    HmsService.instance.updateCallState(updated);
    LogService.instance.log(
      AppConstants.tagRtc,
      'Audio ${updated.isLocalAudioMuted ? "muted" : "unmuted"}',
    );
  }

  void _onToggleVideo(CallToggleVideo event, Emitter<CallBlocState> emit) {
    final current = HmsService.instance.currentCallState;
    final updated = current.copyWith(
      isLocalVideoMuted: !current.isLocalVideoMuted,
    );
    HmsService.instance.updateCallState(updated);
    LogService.instance.log(
      AppConstants.tagRtc,
      'Video ${updated.isLocalVideoMuted ? "off" : "on"}',
    );
  }

  void _onFlipCamera(CallFlipCamera event, Emitter<CallBlocState> emit) {
    final current = HmsService.instance.currentCallState;
    final updated = current.copyWith(
      isFrontCamera: !current.isFrontCamera,
    );
    HmsService.instance.updateCallState(updated);
    LogService.instance.log(
      AppConstants.tagRtc,
      'Camera flipped to ${updated.isFrontCamera ? "front" : "back"}',
    );
  }

  void _onStateUpdated(
    CallStateUpdated event,
    Emitter<CallBlocState> emit,
  ) {
    if (event.callState.connectionState == CallConnectionState.connected) {
      emit(CallConnected(event.callState));
    } else if (event.callState.connectionState ==
        CallConnectionState.reconnecting) {
      emit(CallReconnecting());
    }
  }

  Future<void> _onReconnect(
    CallReconnect event,
    Emitter<CallBlocState> emit,
  ) async {
    emit(CallReconnecting());
    LogService.instance.log(AppConstants.tagRtc, 'Attempting reconnection...');

    await Future.delayed(const Duration(seconds: 2));

    final current = HmsService.instance.currentCallState;
    final updated = current.copyWith(
      connectionState: CallConnectionState.connected,
    );
    HmsService.instance.updateCallState(updated);
  }

  @override
  Future<void> close() {
    _callStateSubscription?.cancel();
    _durationTimer?.cancel();
    return super.close();
  }
}
