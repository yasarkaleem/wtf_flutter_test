import 'package:equatable/equatable.dart';

enum CallConnectionState {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
  failed,
}

class CallParticipant extends Equatable {
  final String peerId;
  final String name;
  final String role;
  final bool isAudioMuted;
  final bool isVideoMuted;
  final bool isLocal;

  const CallParticipant({
    required this.peerId,
    required this.name,
    required this.role,
    this.isAudioMuted = false,
    this.isVideoMuted = false,
    this.isLocal = false,
  });

  CallParticipant copyWith({
    String? peerId,
    String? name,
    String? role,
    bool? isAudioMuted,
    bool? isVideoMuted,
    bool? isLocal,
  }) {
    return CallParticipant(
      peerId: peerId ?? this.peerId,
      name: name ?? this.name,
      role: role ?? this.role,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  @override
  List<Object?> get props => [peerId, name, role, isAudioMuted, isVideoMuted, isLocal];
}

class ActiveCallState extends Equatable {
  final CallConnectionState connectionState;
  final List<CallParticipant> participants;
  final bool isLocalAudioMuted;
  final bool isLocalVideoMuted;
  final bool isFrontCamera;
  final DateTime? callStartTime;
  final String? roomId;
  final String? error;

  const ActiveCallState({
    this.connectionState = CallConnectionState.idle,
    this.participants = const [],
    this.isLocalAudioMuted = false,
    this.isLocalVideoMuted = false,
    this.isFrontCamera = true,
    this.callStartTime,
    this.roomId,
    this.error,
  });

  Duration get callDuration {
    if (callStartTime == null) return Duration.zero;
    return DateTime.now().difference(callStartTime!);
  }

  ActiveCallState copyWith({
    CallConnectionState? connectionState,
    List<CallParticipant>? participants,
    bool? isLocalAudioMuted,
    bool? isLocalVideoMuted,
    bool? isFrontCamera,
    DateTime? callStartTime,
    String? roomId,
    String? error,
  }) {
    return ActiveCallState(
      connectionState: connectionState ?? this.connectionState,
      participants: participants ?? this.participants,
      isLocalAudioMuted: isLocalAudioMuted ?? this.isLocalAudioMuted,
      isLocalVideoMuted: isLocalVideoMuted ?? this.isLocalVideoMuted,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      callStartTime: callStartTime ?? this.callStartTime,
      roomId: roomId ?? this.roomId,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        connectionState, participants, isLocalAudioMuted,
        isLocalVideoMuted, isFrontCamera, callStartTime, roomId, error,
      ];
}
