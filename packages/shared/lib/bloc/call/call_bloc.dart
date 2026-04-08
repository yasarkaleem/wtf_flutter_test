import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import '../../services/services.dart';
import '../../utils/constants.dart';

// ─── Events ──────────────────────────────────────────────────

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

/// Internal events fired by HMS listeners
class _CallJoined extends CallEvent {
  final HMSRoom room;
  const _CallJoined(this.room);
}

class _CallPeerUpdate extends CallEvent {
  final HMSPeer peer;
  final HMSPeerUpdate update;
  const _CallPeerUpdate(this.peer, this.update);
}

class _CallTrackUpdate extends CallEvent {
  final HMSTrack track;
  final HMSTrackUpdate update;
  final HMSPeer peer;
  const _CallTrackUpdate(this.track, this.update, this.peer);
}

class _CallError extends CallEvent {
  final String message;
  const _CallError(this.message);
}

class _CallReconnect extends CallEvent {
  final bool reconnecting;
  const _CallReconnect(this.reconnecting);
}

// ─── States ──────────────────────────────────────────────────

abstract class CallBlocState extends Equatable {
  const CallBlocState();
  @override
  List<Object?> get props => [];
}

class CallIdle extends CallBlocState {}

class CallConnecting extends CallBlocState {}

class CallConnected extends CallBlocState {
  final HMSPeer? localPeer;
  final HMSVideoTrack? localVideoTrack;
  final List<HMSPeer> remotePeers;
  final Map<String, HMSVideoTrack> remoteVideoTracks;
  final bool isAudioMuted;
  final bool isVideoMuted;
  final DateTime callStartTime;
  final int version;

  const CallConnected({
    this.localPeer,
    this.localVideoTrack,
    this.remotePeers = const [],
    this.remoteVideoTracks = const {},
    this.isAudioMuted = false,
    this.isVideoMuted = false,
    required this.callStartTime,
    this.version = 0,
  });

  CallConnected copyWith({
    HMSPeer? localPeer,
    HMSVideoTrack? localVideoTrack,
    List<HMSPeer>? remotePeers,
    Map<String, HMSVideoTrack>? remoteVideoTracks,
    bool? isAudioMuted,
    bool? isVideoMuted,
    DateTime? callStartTime,
    int? version,
  }) {
    return CallConnected(
      localPeer: localPeer ?? this.localPeer,
      localVideoTrack: localVideoTrack ?? this.localVideoTrack,
      remotePeers: remotePeers ?? this.remotePeers,
      remoteVideoTracks: remoteVideoTracks ?? this.remoteVideoTracks,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
      callStartTime: callStartTime ?? this.callStartTime,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
        localPeer,
        localVideoTrack,
        remotePeers,
        remoteVideoTracks,
        isAudioMuted,
        isVideoMuted,
        callStartTime,
        version,
      ];
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

// ─── BLoC ────────────────────────────────────────────────────

class CallBloc extends Bloc<CallEvent, CallBlocState> {
  final List<StreamSubscription> _subs = [];
  DateTime? _callStart;
  int _version = 0;

  CallBloc() : super(CallIdle()) {
    on<CallJoin>(_onJoin);
    on<CallLeave>(_onLeave);
    on<CallToggleAudio>(_onToggleAudio);
    on<CallToggleVideo>(_onToggleVideo);
    on<CallFlipCamera>(_onFlipCamera);
    on<_CallJoined>(_onJoined);
    on<_CallPeerUpdate>(_onPeerUpdate);
    on<_CallTrackUpdate>(_onTrackUpdate);
    on<_CallError>(_onError);
    on<_CallReconnect>(_onReconnectEvent);

    _subscribeToHms();
  }

  void _subscribeToHms() {
    final hms = HmsService.instance;
    _subs.add(hms.onJoinStream.listen((room) => add(_CallJoined(room))));
    _subs.add(hms.peerUpdateStream.listen(
      (e) => add(_CallPeerUpdate(e.peer, e.update)),
    ));
    _subs.add(hms.trackUpdateStream.listen(
      (e) => add(_CallTrackUpdate(e.track, e.update, e.peer)),
    ));
    _subs.add(hms.errorStream.listen(
      (e) => add(_CallError(e.message ?? 'Unknown error')),
    ));
    _subs.add(hms.reconnectStream.listen(
      (reconnecting) => add(_CallReconnect(reconnecting)),
    ));
  }

  Future<void> _onJoin(CallJoin event, Emitter<CallBlocState> emit) async {
    emit(CallConnecting());

    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // Build SDK
      await HmsService.instance.build();

      // Get token
      final token = await HmsService.instance.getAuthToken(
        roomId: event.roomId,
        userId: user.id,
        role: event.role,
      );

      // Join — the _CallJoined event will be fired via the listener
      await HmsService.instance.join(token: token, userName: user.name);
    } catch (e) {
      LogService.instance.error(AppConstants.tagRtc, 'Join failed', e);
      emit(CallFailed(e.toString()));
    }
  }

  void _onJoined(_CallJoined event, Emitter<CallBlocState> emit) {
    _callStart = DateTime.now();
    // Don't pre-populate remote peers here — wait for onPeerUpdate /
    // onPeerListUpdate which fire only when peers are fully connected.
    emit(CallConnected(callStartTime: _callStart!));
    LogService.instance.log(AppConstants.tagRtc, 'Call connected');
  }

  void _onPeerUpdate(_CallPeerUpdate event, Emitter<CallBlocState> emit) {
    final current = state;
    if (current is! CallConnected) return;

    final peer = event.peer;
    final update = event.update;
    var remotePeers = List<HMSPeer>.from(current.remotePeers);

    switch (update) {
      case HMSPeerUpdate.peerJoined:
        if (!peer.isLocal) {
          remotePeers.add(peer);
          LogService.instance.log(
            AppConstants.tagRtc,
            'Peer joined: ${peer.name}',
          );
        }
      case HMSPeerUpdate.peerLeft:
        remotePeers.removeWhere((p) => p.peerId == peer.peerId);
        LogService.instance.log(
          AppConstants.tagRtc,
          'Peer left: ${peer.name}',
        );
      default:
        // Update existing peer
        final idx = remotePeers.indexWhere((p) => p.peerId == peer.peerId);
        if (idx >= 0) remotePeers[idx] = peer;
    }

    emit(current.copyWith(
      localPeer: peer.isLocal ? peer : current.localPeer,
      remotePeers: remotePeers,
      version: ++_version,
    ));
  }

  void _onTrackUpdate(_CallTrackUpdate event, Emitter<CallBlocState> emit) {
    final current = state;
    if (current is! CallConnected) return;

    final track = event.track;
    final peer = event.peer;

    // Local video track
    if (peer.isLocal && track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      emit(current.copyWith(
        localVideoTrack: track as HMSVideoTrack,
        version: ++_version,
      ));
      return;
    }

    // Remote video tracks
    if (!peer.isLocal && track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      final tracks = Map<String, HMSVideoTrack>.from(current.remoteVideoTracks);

      if (event.update == HMSTrackUpdate.trackRemoved) {
        tracks.remove(peer.peerId);
      } else {
        tracks[peer.peerId] = track as HMSVideoTrack;
      }

      emit(current.copyWith(
        remoteVideoTracks: tracks,
        version: ++_version,
      ));
    }
  }

  Future<void> _onLeave(CallLeave event, Emitter<CallBlocState> emit) async {
    final duration = _callStart != null
        ? DateTime.now().difference(_callStart!)
        : Duration.zero;

    await HmsService.instance.leave();
    await HmsService.instance.destroy();

    emit(CallDisconnected(duration));
    LogService.instance.log(AppConstants.tagRtc, 'Call ended');
  }

  void _onToggleAudio(CallToggleAudio event, Emitter<CallBlocState> emit) {
    final current = state;
    if (current is! CallConnected) return;

    final newMute = !current.isAudioMuted;
    HmsService.instance.toggleAudio(newMute);
    emit(current.copyWith(isAudioMuted: newMute, version: ++_version));
  }

  void _onToggleVideo(CallToggleVideo event, Emitter<CallBlocState> emit) {
    final current = state;
    if (current is! CallConnected) return;

    final newMute = !current.isVideoMuted;
    HmsService.instance.toggleVideo(newMute);
    emit(current.copyWith(isVideoMuted: newMute, version: ++_version));
  }

  void _onFlipCamera(CallFlipCamera event, Emitter<CallBlocState> emit) {
    HmsService.instance.switchCamera();
  }

  void _onError(_CallError event, Emitter<CallBlocState> emit) {
    emit(CallFailed(event.message));
  }

  void _onReconnectEvent(
      _CallReconnect event, Emitter<CallBlocState> emit) {
    if (event.reconnecting) {
      emit(CallReconnecting());
    }
    // On reconnected, the onJoin/onTrackUpdate listeners will fire again
  }

  @override
  Future<void> close() {
    for (final sub in _subs) {
      sub.cancel();
    }
    return super.close();
  }
}
