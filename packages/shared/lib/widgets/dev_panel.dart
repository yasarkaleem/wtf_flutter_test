import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/log_service.dart';
import '../utils/theme.dart';

class DevPanel extends StatefulWidget {
  const DevPanel({super.key});

  @override
  State<DevPanel> createState() => _DevPanelState();
}

class _DevPanelState extends State<DevPanel> {
  String? _filterTag;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLg),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.terminal, color: Colors.greenAccent, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Dev Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    // Filter chips
                    _buildFilterChip(null, 'All'),
                    _buildFilterChip('[CHAT]', 'Chat'),
                    _buildFilterChip('[RTC]', 'RTC'),
                    _buildFilterChip('[SCHEDULE]', 'Sched'),
                    const SizedBox(width: 8),
                    // Clear button
                    GestureDetector(
                      onTap: () {
                        LogService.instance.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.delete_outline,
                          color: Colors.white54, size: 18),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              // Log entries
              Expanded(
                child: StreamBuilder<LogEntry>(
                  stream: LogService.instance.logStream,
                  builder: (context, snapshot) {
                    final logs = _filterTag != null
                        ? LogService.instance.getByTag(_filterTag!)
                        : LogService.instance.logs;

                    if (logs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No logs yet',
                          style: TextStyle(color: Colors.white38),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: logs.length,
                      reverse: true,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final entry = logs[logs.length - 1 - index];
                        return _buildLogEntry(entry);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String? tag, String label) {
    final isSelected = _filterTag == tag;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: GestureDetector(
        onTap: () => setState(() => _filterTag = tag),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white12 : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? Colors.white24 : Colors.white12,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogEntry(LogEntry entry) {
    Color tagColor;
    switch (entry.tag) {
      case '[CHAT]':
        tagColor = Colors.cyanAccent;
      case '[RTC]':
        tagColor = Colors.purpleAccent;
      case '[SCHEDULE]':
        tagColor = Colors.orangeAccent;
      case '[AUTH]':
        tagColor = Colors.greenAccent;
      case '[SESSION]':
        tagColor = Colors.amberAccent;
      default:
        tagColor = Colors.white54;
    }

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: entry.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Log entry copied'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text:
                    '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')} ',
                style: const TextStyle(color: Colors.white38),
              ),
              TextSpan(
                text: '${entry.tag} ',
                style: TextStyle(color: tagColor, fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: entry.message,
                style: TextStyle(
                  color: entry.error != null ? Colors.redAccent : Colors.white70,
                ),
              ),
              if (entry.error != null)
                TextSpan(
                  text: '\n  ${entry.error}',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 10),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating button to open dev panel.
class DevPanelButton extends StatelessWidget {
  const DevPanelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: FloatingActionButton.small(
        heroTag: 'dev_panel',
        backgroundColor: const Color(0xFF1E1E2E),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const DevPanel(),
          );
        },
        child: const Icon(Icons.terminal, color: Colors.greenAccent, size: 20),
      ),
    );
  }
}
