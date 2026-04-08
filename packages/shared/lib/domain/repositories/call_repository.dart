import 'dart:async';

import 'package:hmssdk_flutter/hmssdk_flutter.dart';

/// Abstract interface for video-call (100ms) operations.
///
/// Uses raw HMS types from `hmssdk_flutter` because the call UI and
/// state management need direct access to [HMSPeer], [HMSTrack], etc.
abstract class CallRepository {
  /// Stream that emits the [HMSRoom] once the local user has joined.
  Stream<HMSRoom> get onJoinStream;

  /// Stream of peer updates (join, leave, role change, etc.).
  Stream<({HMSPeer peer, HMSPeerUpdate update})> get peerUpdateStream;

  /// Stream of track updates (mute, unmute, add, remove).
  Stream<({HMSTrack track, HMSTrackUpdate update, HMSPeer peer})>
      get trackUpdateStream;

  /// Stream of HMS errors.
  Stream<HMSException> get errorStream;

  /// Stream of reconnection state (true = reconnecting, false = reconnected).
  Stream<bool> get reconnectStream;

  /// Build and initialise the underlying SDK.
  Future<void> build();

  /// Obtain an auth token for joining a room.
  Future<String> getAuthToken({
    required String roomId,
    required String userId,
    required String role,
  });

  /// Join a room with the given [token] and display [userName].
  Future<void> join({
    required String token,
    required String userName,
  });

  /// Leave the current room.
  Future<void> leave();

  /// Toggle the local microphone. Pass `true` to mute.
  void toggleAudio(bool mute);

  /// Toggle the local camera. Pass `true` to disable video.
  void toggleVideo(bool mute);

  /// Switch between front and back camera.
  void switchCamera();

  /// Destroy the SDK and free resources.
  Future<void> destroy();

  /// Release stream resources.
  void dispose();
}
