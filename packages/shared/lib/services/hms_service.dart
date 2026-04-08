import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/constants.dart';
import 'log_service.dart';

/// Service for 100ms video call integration.
///
/// This service handles token generation, room management, and provides
/// the interface for the UI to interact with 100ms SDK.
/// The actual HMSSDK initialization and peer management happens in the
/// CallBloc which holds the HMSSDK instance.
class HmsService {
  HmsService._();
  static final HmsService instance = HmsService._();

  bool _isInitialized = false;
  String? _authToken;
  ActiveCallState _callState = const ActiveCallState();

  final _callStateController = StreamController<ActiveCallState>.broadcast();
  Stream<ActiveCallState> get callStateStream => _callStateController.stream;
  ActiveCallState get currentCallState => _callState;

  /// Fetch auth token from token server.
  Future<String> getAuthToken({
    required String roomId,
    required String userId,
    required String role, // 'trainer' or 'member'
  }) async {
    LogService.instance.log(
      AppConstants.tagRtc,
      'Fetching auth token for role: $role',
    );

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.hmsTokenServerUrl}/api/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'room_id': roomId,
          'user_id': userId,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'] as String;
        LogService.instance.log(AppConstants.tagRtc, 'Auth token received');
        return _authToken!;
      } else {
        throw Exception('Token server returned ${response.statusCode}');
      }
    } catch (e) {
      LogService.instance.error(
        AppConstants.tagRtc,
        'Failed to get auth token, using mock token',
        e,
      );
      // Return a mock token for local development
      _authToken = 'mock_token_${userId}_$role';
      return _authToken!;
    }
  }

  /// Update call state.
  void updateCallState(ActiveCallState state) {
    _callState = state;
    _callStateController.add(state);
  }

  /// Initialize the service.
  void init() {
    if (_isInitialized) return;
    _isInitialized = true;
    LogService.instance.log(AppConstants.tagRtc, 'HMS service initialized');
  }

  /// Reset call state.
  void resetCallState() {
    _callState = const ActiveCallState();
    _callStateController.add(_callState);
  }

  void dispose() {
    _callStateController.close();
  }
}
