import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';
import 'call_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatDetailScreen({super.key, required this.chatRoom});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _scrollController = ScrollController();

  static const _quickReplies = [
    'Thanks!',
    'Sounds good',
    'When works for you?',
    'Let\'s schedule a call',
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
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  buildWhen: (prev, curr) =>
                      prev.isOtherUserTyping != curr.isOtherUserTyping,
                  builder: (context, state) {
                    return Text(
                      state.isOtherUserTyping ? 'typing...' : 'Online',
                      style: const TextStyle(
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
                  builder: (_) => const PreJoinScreen(),
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
