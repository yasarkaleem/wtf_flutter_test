import 'package:flutter/material.dart';
import '../utils/theme.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback? onTypingStarted;
  final VoidCallback? onTypingStopped;
  final List<String> quickReplies;
  final Function(String)? onQuickReply;

  const MessageInput({
    super.key,
    required this.onSend,
    this.onTypingStarted,
    this.onTypingStopped,
    this.quickReplies = const [],
    this.onQuickReply,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);
    _controller.clear();
    setState(() => _isComposing = false);
    widget.onTypingStopped?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick reply chips
        if (widget.quickReplies.isNotEmpty)
          Container(
            height: 44,
            padding: const EdgeInsets.only(bottom: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(
                    widget.quickReplies[index],
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2),
                  ),
                  onPressed: () {
                    widget.onQuickReply?.call(widget.quickReplies[index]);
                  },
                );
              },
            ),
          ),

        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.divider)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: AppTheme.textTertiary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (text) {
                        final composing = text.trim().isNotEmpty;
                        if (composing != _isComposing) {
                          setState(() => _isComposing = composing);
                          if (composing) {
                            widget.onTypingStarted?.call();
                          } else {
                            widget.onTypingStopped?.call();
                          }
                        }
                      },
                      onSubmitted: (_) => _handleSubmit(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: AppTheme.animFast,
                  child: Material(
                    color: _isComposing
                        ? Theme.of(context).colorScheme.primary
                        : AppTheme.textTertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      onTap: _isComposing ? _handleSubmit : null,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
