import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatDetailScreen({super.key, required this.chatRoom});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _scrollController = ScrollController();

  static const _quickReplies = [
    'Great work!',
    'See you then',
    'Let\'s review your form',
    'How are you feeling?',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatLoadMessages(widget.chatRoom.id));
    context.read<ChatBloc>().add(ChatMarkAsRead(widget.chatRoom.id));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;
    final otherName = widget.chatRoom.getOtherUserName(currentUser?.id ?? '');

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AvatarWidget(
              name: otherName,
              radius: 18,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  otherName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  buildWhen: (prev, curr) =>
                      prev.typingStatus != curr.typingStatus,
                  builder: (context, state) {
                    if (state.isOtherUserTyping) {
                      return const Text(
                        'typing...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.white70,
                        ),
                      );
                    }
                    return const Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.white70,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const _TrainerPreJoinScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listenWhen: (prev, curr) =>
                  curr.messages.length > prev.messages.length,
              listener: (context, state) {
                context
                    .read<ChatBloc>()
                    .add(ChatMarkAsRead(widget.chatRoom.id));
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const ChatListSkeleton(itemCount: 8);
                }

                if (state.messages.isEmpty) {
                  return const EmptyState(
                    icon: Icons.chat_outlined,
                    title: 'No messages yet',
                    subtitle: 'Send a message to start the conversation',
                  );
                }

                final itemCount = state.messages.length +
                    (state.isOtherUserTyping ? 1 : 0);

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (state.isOtherUserTyping && index == 0) {
                      return const TypingIndicator();
                    }

                    final msgIndex = state.isOtherUserTyping
                        ? state.messages.length - index
                        : state.messages.length - 1 - index;

                    if (msgIndex < 0 || msgIndex >= state.messages.length) {
                      return const SizedBox.shrink();
                    }

                    final message = state.messages[msgIndex];
                    return ChatBubble(
                      message: message,
                      isMine: message.senderId == currentUser?.id,
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(
            onSend: (text) {
              context.read<ChatBloc>().add(ChatSendMessage(
                    content: text,
                    chatRoomId: widget.chatRoom.id,
                  ));
              context.read<ChatBloc>().add(ChatSetTyping(
                    chatRoomId: widget.chatRoom.id,
                    isTyping: false,
                  ));
            },
            onTypingStarted: () {
              context.read<ChatBloc>().add(ChatSetTyping(
                    chatRoomId: widget.chatRoom.id,
                    isTyping: true,
                  ));
            },
            onTypingStopped: () {
              context.read<ChatBloc>().add(ChatSetTyping(
                    chatRoomId: widget.chatRoom.id,
                    isTyping: false,
                  ));
            },
            quickReplies: _quickReplies,
            onQuickReply: (reply) {
              context.read<ChatBloc>().add(ChatSendQuickReply(
                    content: reply,
                    chatRoomId: widget.chatRoom.id,
                  ));
            },
          ),
        ],
      ),
    );
  }
}

class _TrainerPreJoinScreen extends StatelessWidget {
  const _TrainerPreJoinScreen();

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
                      'Camera Preview',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlBtn(Icons.mic, 'Mic', true),
                  const SizedBox(width: 24),
                  _controlBtn(Icons.videocam, 'Camera', true),
                  const SizedBox(width: 24),
                  _controlBtn(Icons.flip_camera_android, 'Flip', true),
                ],
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
                          builder: (_) => const _TrainerVideoCallScreen(),
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
                                    role: 'trainer',
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
                      label: Text(isConnecting ? 'Connecting...' : 'Join as Trainer'),
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

  Widget _controlBtn(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: active ? AppTheme.surface : AppTheme.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.divider),
          ),
          child: Icon(icon, size: 24, color: active ? AppTheme.textPrimary : AppTheme.error),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _TrainerVideoCallScreen extends StatefulWidget {
  const _TrainerVideoCallScreen();

  @override
  State<_TrainerVideoCallScreen> createState() => _TrainerVideoCallScreenState();
}

class _TrainerVideoCallScreenState extends State<_TrainerVideoCallScreen> {
  DateTime? _callStart;

  @override
  void initState() {
    super.initState();
    _callStart = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: SafeArea(
        child: BlocConsumer<CallBloc, CallBlocState>(
          listener: (context, state) {
            if (state is CallDisconnected) {
              context.read<SessionBloc>().add(SessionCreateFromCall(
                    scheduleId: 'direct_call_${DateTime.now().millisecondsSinceEpoch}',
                    startedAt: _callStart ?? DateTime.now(),
                    endedAt: DateTime.now(),
                  ));
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.showSnackBar('Call ended - ${state.duration.formatted}');
            }
          },
          builder: (context, state) {
            ActiveCallState? callState;
            if (state is CallConnected) callState = state.callState;

            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFF2D2D3E),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AvatarWidget(
                        name: 'DK',
                        radius: 48,
                        backgroundColor: Color(0xFF3D3D4E),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'DK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        callState?.participants.length == 2
                            ? 'Connected'
                            : 'Waiting to join...',
                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D3D4E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white38, size: 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, _) {
                          final duration = _callStart != null
                              ? DateTime.now().difference(_callStart!)
                              : Duration.zero;
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
                          Text('Reconnecting...', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _callControl(
                        icon: callState?.isLocalAudioMuted == true ? Icons.mic_off : Icons.mic,
                        label: 'Mic',
                        isActive: callState?.isLocalAudioMuted != true,
                        onTap: () => context.read<CallBloc>().add(CallToggleAudio()),
                      ),
                      const SizedBox(width: 20),
                      _callControl(
                        icon: callState?.isLocalVideoMuted == true ? Icons.videocam_off : Icons.videocam,
                        label: 'Camera',
                        isActive: callState?.isLocalVideoMuted != true,
                        onTap: () => context.read<CallBloc>().add(CallToggleVideo()),
                      ),
                      const SizedBox(width: 20),
                      _callControl(
                        icon: Icons.flip_camera_android,
                        label: 'Flip',
                        isActive: true,
                        onTap: () => context.read<CallBloc>().add(CallFlipCamera()),
                      ),
                      const SizedBox(width: 20),
                      _callControl(
                        icon: Icons.call_end,
                        label: 'End',
                        isActive: false,
                        isDestructive: true,
                        onTap: () => context.read<CallBloc>().add(CallLeave()),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _callControl({
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
              color: isDestructive ? AppTheme.error : (isActive ? Colors.white12 : Colors.white24),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}
