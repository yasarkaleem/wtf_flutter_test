import 'dart:async';
import 'dart:convert';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'log_service.dart';

/// Wraps the 100ms HMSSDK for video calling.
///
/// Lifecycle: build → getToken → join → (call active) → leave → destroy
class HmsService implements HMSUpdateListener, HMSActionResultListener {
  HmsService._();
  static final HmsService instance = HmsService._();

  HMSSDK? _hmsSdk;
  bool _isInitialized = false;

  // Streams for the CallBloc to listen to
  final _onJoinController = StreamController<HMSRoom>.broadcast();
  final _peerUpdateController =
      StreamController<({HMSPeer peer, HMSPeerUpdate update})>.broadcast();
  final _trackUpdateController = StreamController<
      ({HMSTrack track, HMSTrackUpdate update, HMSPeer peer})>.broadcast();
  final _errorController = StreamController<HMSException>.broadcast();
  final _messageController = StreamController<HMSMessage>.broadcast();
  final _reconnectController = StreamController<bool>.broadcast();

  Stream<HMSRoom> get onJoinStream => _onJoinController.stream;
  Stream<({HMSPeer peer, HMSPeerUpdate update})> get peerUpdateStream =>
      _peerUpdateController.stream;
  Stream<({HMSTrack track, HMSTrackUpdate update, HMSPeer peer})>
      get trackUpdateStream => _trackUpdateController.stream;
  Stream<HMSException> get errorStream => _errorController.stream;
  Stream<bool> get reconnectStream => _reconnectController.stream;

  HMSSDK? get sdk => _hmsSdk;

  /// Build and initialize the SDK with camera+mic permissions.
  Future<void> build() async {
    if (_isInitialized) return;

    _hmsSdk = HMSSDK(
      hmsTrackSetting: HMSTrackSetting(
        audioTrackSetting: HMSAudioTrackSetting(),
        videoTrackSetting: HMSVideoTrackSetting(),
      ),
    );
    await _hmsSdk!.build();
    _hmsSdk!.addUpdateListener(listener: this);
    _isInitialized = true;
    LogService.instance.log(AppConstants.tagRtc, 'HMSSDK built');
  }


  /// Get an auth token using the room-code flow.
  ///
  /// 1. Fetch a room code from our token server
  /// 2. Pass it to HMSSDK.getAuthTokenByRoomCode() which handles
  ///    permissions and returns a valid auth token.
  Future<String> getAuthToken({
    required String roomId,
    required String userId,
    required String role,
  }) async {
    LogService.instance.log(AppConstants.tagRtc, 'Fetching room code for role: $role');

    try {
      // Step 1: Get room code from our server
      final response = await http
          .post(
            Uri.parse('${AppConstants.hmsTokenServerUrl}/api/room-code'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'role': role}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Server returned ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final roomCode = data['room_code'] as String;
      LogService.instance.log(AppConstants.tagRtc, 'Room code received');

      // Step 2: Exchange room code for auth token via the SDK
      final tokenResult = await _hmsSdk!.getAuthTokenByRoomCode(roomCode: roomCode);

      if (tokenResult is String) {
        LogService.instance.log(AppConstants.tagRtc, 'Auth token received');
        return tokenResult;
      } else if (tokenResult is HMSException) {
        throw Exception('${tokenResult.message} ${tokenResult.description}');
      }

      throw Exception('Unexpected token result: $tokenResult');
    } catch (e) {
      LogService.instance.error(AppConstants.tagRtc, 'Token fetch failed', e);
      rethrow;
    }
  }

  /// Join a room.
  Future<void> join({
    required String token,
    required String userName,
  }) async {
    final config = HMSConfig(authToken: token, userName: userName);
    _hmsSdk?.join(config: config);
    LogService.instance.log(AppConstants.tagRtc, 'Joining room...');
  }

  /// Leave the room.
  Future<void> leave() async {
    _hmsSdk?.leave(hmsActionResultListener: this);
    LogService.instance.log(AppConstants.tagRtc, 'Left room');
  }

  /// Toggle local audio.
  void toggleAudio(bool mute) {
    _hmsSdk?.toggleMicMuteState();
    LogService.instance.log(
      AppConstants.tagRtc,
      'Audio ${mute ? "muted" : "unmuted"}',
    );
  }

  /// Toggle local video.
  void toggleVideo(bool mute) {
    _hmsSdk?.toggleCameraMuteState();
    LogService.instance.log(
      AppConstants.tagRtc,
      'Video ${mute ? "off" : "on"}',
    );
  }

  /// Switch camera front/back.
  void switchCamera() {
    _hmsSdk?.switchCamera();
    LogService.instance.log(AppConstants.tagRtc, 'Camera switched');
  }

  /// Destroy the SDK.
  Future<void> destroy() async {
    _hmsSdk?.removeUpdateListener(listener: this);
    _hmsSdk?.destroy();
    _hmsSdk = null;
    _isInitialized = false;
    LogService.instance.log(AppConstants.tagRtc, 'HMSSDK destroyed');
  }

  // ─── HMSUpdateListener ─────────────────────────────────────

  @override
  void onJoin({required HMSRoom room}) {
    LogService.instance.log(AppConstants.tagRtc, 'Joined room: ${room.id}');
    _onJoinController.add(room);
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    LogService.instance.log(
      AppConstants.tagRtc,
      'Peer update: ${peer.name}',
    );
    _peerUpdateController.add((peer: peer, update: update));
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    LogService.instance.log(
      AppConstants.tagRtc,
      'Track update: ${peer.name} (${track.kind.name})',
    );
    _trackUpdateController.add((
      track: track,
      update: trackUpdate,
      peer: peer,
    ));
  }

  @override
  void onHMSError({required HMSException error}) {
    LogService.instance.error(
      AppConstants.tagRtc,
      'HMS error [${error.code}]: ${error.message ?? ''} ${error.description}',
    );
    _errorController.add(error);
  }

  @override
  void onMessage({required HMSMessage message}) {
    _messageController.add(message);
  }

  @override
  void onReconnecting() {
    LogService.instance.log(AppConstants.tagRtc, 'Reconnecting...');
    _reconnectController.add(true);
  }

  @override
  void onReconnected() {
    LogService.instance.log(AppConstants.tagRtc, 'Reconnected');
    _reconnectController.add(false);
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onPeerListUpdate(
      {required List<HMSPeer> addedPeers,
      required List<HMSPeer> removedPeers}) {
    for (final peer in addedPeers) {
      if (!peer.isLocal) {
        _peerUpdateController
            .add((peer: peer, update: HMSPeerUpdate.peerJoined));
      }
    }
    for (final peer in removedPeers) {
      if (!peer.isLocal) {
        _peerUpdateController.add((peer: peer, update: HMSPeerUpdate.peerLeft));
      }
    }
  }

  // ─── HMSActionResultListener ───────────────────────────────

  @override
  void onSuccess(
      {HMSActionResultListenerMethod methodType =
          HMSActionResultListenerMethod.unknown,
      Map<String, dynamic>? arguments}) {
    LogService.instance.log(
      AppConstants.tagRtc,
      'Action success: ${methodType.name}',
    );
  }

  @override
  void onException(
      {HMSActionResultListenerMethod methodType =
          HMSActionResultListenerMethod.unknown,
      Map<String, dynamic>? arguments,
      required HMSException hmsException}) {
    LogService.instance.error(
      AppConstants.tagRtc,
      'Action failed: ${methodType.name} - ${hmsException.message}',
    );
  }

  void dispose() {
    _onJoinController.close();
    _peerUpdateController.close();
    _trackUpdateController.close();
    _errorController.close();
    _messageController.close();
    _reconnectController.close();
  }
}
