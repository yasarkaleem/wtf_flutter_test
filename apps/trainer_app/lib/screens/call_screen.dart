import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:shared/shared.dart';

// ─── Pre-Join Screen ─────────────────────────────────────────

class PreJoinScreen extends StatelessWidget {
  const PreJoinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Session')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, color: Colors.white54, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Ready to join?',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Camera will activate when you join',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: BlocConsumer<CallBloc, CallBlocState>(
                  listener: (context, state) {
                    if (state is CallConnected) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VideoCallScreen(),
                        ),
                      );
                    }
                    if (state is CallFailed) {
                      context.showSnackBar(state.error, isError: true);
                    }
                  },
                  builder: (context, state) {
                    final isConnecting = state is CallConnecting;
                    return ElevatedButton.icon(
                      onPressed: isConnecting
                          ? null
                          : () {
                              context.read<CallBloc>().add(const CallJoin(
                                    roomId: AppConstants.hmsRoomId,
                                    role: 'host',
                                  ));
                            },
                      icon: isConnecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.videocam),
                      label: Text(
                          isConnecting ? 'Connecting...' : 'Join as Trainer'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Video Call Screen ───────────────────────────────────────

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: SafeArea(
        child: BlocConsumer<CallBloc, CallBlocState>(
          listener: (context, state) {
            if (state is CallDisconnected) {
              context.read<SessionBloc>().add(SessionCreateFromCall(
                    scheduleId:
                        'call_${DateTime.now().millisecondsSinceEpoch}',
                    startedAt: DateTime.now().subtract(state.duration),
                    endedAt: DateTime.now(),
                  ));
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.showSnackBar('Call ended - ${state.duration.formatted}');
            }
            if (state is CallFailed) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.showSnackBar(state.error, isError: true);
            }
          },
          builder: (context, state) {
            if (state is! CallConnected) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Connecting...',
                        style: TextStyle(color: Colors.white54)),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                // Remote video
                _RemoteVideoView(state: state),

                // Local video PiP
                Positioned(
                  top: 16,
                  right: 16,
                  child: _LocalVideoView(state: state),
                ),

                // Duration
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: StreamBuilder(
                        stream:
                            Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, _) {
                          final duration = DateTime.now()
                              .difference(state.callStartTime);
                          return Text(
                            duration.formatted,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                if (state is CallReconnecting)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text('Reconnecting...',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),

                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: _CallControls(state: state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RemoteVideoView extends StatelessWidget {
  final CallConnected state;
  const _RemoteVideoView({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.remotePeers.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF2D2D3E),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, color: Colors.white24, size: 80),
            SizedBox(height: 16),
            Text('Waiting for other participant...',
                style: TextStyle(color: Colors.white54, fontSize: 16)),
          ],
        ),
      );
    }

    final remotePeer = state.remotePeers.first;
    final remoteTrack = state.remoteVideoTracks[remotePeer.peerId];

    if (remoteTrack == null || remoteTrack.isMute) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF2D2D3E),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AvatarWidget(
              name: remotePeer.name,
              radius: 48,
              backgroundColor: const Color(0xFF3D3D4E),
            ),
            const SizedBox(height: 16),
            Text(remotePeer.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Camera off',
                style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: HMSVideoView(track: remoteTrack),
    );
  }
}

class _LocalVideoView extends StatelessWidget {
  final CallConnected state;
  const _LocalVideoView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D4E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: state.localVideoTrack != null && !state.isVideoMuted
          ? HMSVideoView(track: state.localVideoTrack!, setMirror: true)
          : const Center(
              child: Icon(Icons.person, color: Colors.white38, size: 40)),
    );
  }
}

class _CallControls extends StatelessWidget {
  final CallConnected state;
  const _CallControls({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _btn(
          icon: state.isAudioMuted ? Icons.mic_off : Icons.mic,
          label: 'Mic',
          isActive: !state.isAudioMuted,
          onTap: () => context.read<CallBloc>().add(CallToggleAudio()),
        ),
        const SizedBox(width: 20),
        _btn(
          icon: state.isVideoMuted ? Icons.videocam_off : Icons.videocam,
          label: 'Camera',
          isActive: !state.isVideoMuted,
          onTap: () => context.read<CallBloc>().add(CallToggleVideo()),
        ),
        const SizedBox(width: 20),
        _btn(
          icon: Icons.flip_camera_android,
          label: 'Flip',
          isActive: true,
          onTap: () => context.read<CallBloc>().add(CallFlipCamera()),
        ),
        const SizedBox(width: 20),
        _btn(
          icon: Icons.call_end,
          label: 'End',
          isActive: false,
          isDestructive: true,
          onTap: () => context.read<CallBloc>().add(CallLeave()),
        ),
      ],
    );
  }

  Widget _btn({
    required IconData icon,
    required String label,
    required bool isActive,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppTheme.error
                  : (isActive ? Colors.white12 : Colors.white24),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}
