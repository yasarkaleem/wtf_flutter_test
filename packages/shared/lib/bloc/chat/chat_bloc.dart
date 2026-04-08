import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';
import '../../services/services.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatLoadMessages extends ChatEvent {
  final String chatRoomId;
  const ChatLoadMessages(this.chatRoomId);
  @override
  List<Object?> get props => [chatRoomId];
}

class ChatSendMessage extends ChatEvent {
  final String content;
  final String chatRoomId;
  const ChatSendMessage({required this.content, required this.chatRoomId});
  @override
  List<Object?> get props => [content, chatRoomId];
}

class ChatRefresh extends ChatEvent {
  const ChatRefresh();
}

class ChatMarkAsRead extends ChatEvent {
  final String chatRoomId;
  const ChatMarkAsRead(this.chatRoomId);
  @override
  List<Object?> get props => [chatRoomId];
}

class ChatSetTyping extends ChatEvent {
  final String chatRoomId;
  final bool isTyping;
  const ChatSetTyping({required this.chatRoomId, required this.isTyping});
  @override
  List<Object?> get props => [chatRoomId, isTyping];
}

class ChatTypingUpdated extends ChatEvent {
  final Map<String, bool> typingStatus;
  const ChatTypingUpdated(this.typingStatus);
  @override
  List<Object?> get props => [typingStatus];
}

class ChatSendQuickReply extends ChatEvent {
  final String content;
  final String chatRoomId;
  const ChatSendQuickReply({required this.content, required this.chatRoomId});
  @override
  List<Object?> get props => [content, chatRoomId];
}

// States
class ChatState extends Equatable {
  final List<Message> messages;
  final List<ChatRoom> chatRooms;
  final Map<String, bool> typingStatus;
  final bool isLoading;
  final String? error;
  final String? activeChatRoomId;
  final int version;

  const ChatState({
    this.messages = const [],
    this.chatRooms = const [],
    this.typingStatus = const {},
    this.isLoading = false,
    this.error,
    this.activeChatRoomId,
    this.version = 0,
  });

  bool get isOtherUserTyping {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) return false;
    return typingStatus.entries
        .any((e) => e.key != currentUser.id && e.value);
  }

  ChatState copyWith({
    List<Message>? messages,
    List<ChatRoom>? chatRooms,
    Map<String, bool>? typingStatus,
    bool? isLoading,
    String? error,
    String? activeChatRoomId,
    int? version,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      chatRooms: chatRooms ?? this.chatRooms,
      typingStatus: typingStatus ?? this.typingStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeChatRoomId: activeChatRoomId ?? this.activeChatRoomId,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
        messages, chatRooms, typingStatus,
        isLoading, error, activeChatRoomId, version,
      ];
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _roomSubscription;
  int _version = 0;

  ChatBloc()
      : super(ChatState(
          chatRooms: ChatService.instance.getAllChatRooms(),
        )) {
    on<ChatLoadMessages>(_onLoadMessages);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatRefresh>(_onRefresh);
    on<ChatMarkAsRead>(_onMarkAsRead);
    on<ChatSetTyping>(_onSetTyping);
    on<ChatTypingUpdated>(_onTypingUpdated);
    on<ChatSendQuickReply>(_onSendQuickReply);

    _messageSubscription = ChatService.instance.messageNotifier.listen(
      (_) => add(const ChatRefresh()),
    );
    _roomSubscription = ChatService.instance.roomNotifier.listen(
      (_) => add(const ChatRefresh()),
    );
    _typingSubscription = ChatService.instance.typingStream.listen(
      (status) => add(ChatTypingUpdated(status)),
    );
  }

  void _onLoadMessages(ChatLoadMessages event, Emitter<ChatState> emit) {
    final messages =
        StorageService.instance.getMessagesForRoom(event.chatRoomId);
    emit(state.copyWith(
      activeChatRoomId: event.chatRoomId,
      messages: messages,
      isLoading: false,
      version: ++_version,
    ));
  }

  Future<void> _onSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    try {
      await ChatService.instance.sendMessage(
        chatRoomId: event.chatRoomId,
        senderId: user.id,
        senderName: user.name,
        content: event.content,
      );
    } catch (e) {
      LogService.instance.error('[CHAT]', 'Send failed', e);
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onRefresh(ChatRefresh event, Emitter<ChatState> emit) {
    final rooms = StorageService.instance.getAllChatRooms();
    final messages = state.activeChatRoomId != null
        ? StorageService.instance.getMessagesForRoom(state.activeChatRoomId!)
        : <Message>[];
    emit(state.copyWith(
      chatRooms: rooms,
      messages: messages,
      version: ++_version,
    ));
  }

  Future<void> _onMarkAsRead(
    ChatMarkAsRead event,
    Emitter<ChatState> emit,
  ) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    await ChatService.instance.markAsRead(event.chatRoomId, user.id);
  }

  void _onSetTyping(ChatSetTyping event, Emitter<ChatState> emit) {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    // Update locally
    ChatService.instance.setTyping(event.chatRoomId, user.id, event.isTyping);
    // Sync to the other app
    ChatService.instance.sendTypingToRemote(
      event.chatRoomId,
      user.id,
      event.isTyping,
    );
  }

  void _onTypingUpdated(ChatTypingUpdated event, Emitter<ChatState> emit) {
    emit(state.copyWith(typingStatus: event.typingStatus, version: ++_version));
  }

  Future<void> _onSendQuickReply(
    ChatSendQuickReply event,
    Emitter<ChatState> emit,
  ) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    await ChatService.instance.sendMessage(
      chatRoomId: event.chatRoomId,
      senderId: user.id,
      senderName: user.name,
      content: event.content,
      type: 'quickReply',
    );
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _roomSubscription?.cancel();
    return super.close();
  }
}
