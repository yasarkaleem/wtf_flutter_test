import 'dart:async';

import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../../domain/repositories/call_repository.dart';
import '../../services/hms_service.dart';

/// Thin wrapper around [HmsService] that satisfies the [CallRepository]
/// contract.  Delegates every call to the existing singleton.
///
/// No mappers are needed here — the domain interface deliberately uses the
/// raw HMS SDK types ([HMSRoom], [HMSPeer], [HMSTrack], etc.) because the
/// call UI needs direct access to them.
class CallRepositoryImpl implements CallRepository {
  final HmsService _service = HmsService.instance;

  @override
  Stream<HMSRoom> get onJoinStream => _service.onJoinStream;

  @override
  Stream<({HMSPeer peer, HMSPeerUpdate update})> get peerUpdateStream =>
      _service.peerUpdateStream;

  @override
  Stream<({HMSTrack track, HMSTrackUpdate update, HMSPeer peer})>
      get trackUpdateStream => _service.trackUpdateStream;

  @override
  Stream<HMSException> get errorStream => _service.errorStream;

  @override
  Stream<bool> get reconnectStream => _service.reconnectStream;

  @override
  Future<void> build() => _service.build();

  @override
  Future<String> getAuthToken({
    required String roomId,
    required String userId,
    required String role,
  }) =>
      _service.getAuthToken(roomId: roomId, userId: userId, role: role);

  @override
  Future<void> join({
    required String token,
    required String userName,
  }) =>
      _service.join(token: token, userName: userName);

  @override
  Future<void> leave() => _service.leave();

  @override
  void toggleAudio(bool mute) => _service.toggleAudio(mute);

  @override
  void toggleVideo(bool mute) => _service.toggleVideo(mute);

  @override
  void switchCamera() => _service.switchCamera();

  @override
  Future<void> destroy() => _service.destroy();

  @override
  void dispose() => _service.dispose();
}
