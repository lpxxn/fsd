import 'package:flutter/material.dart';

/// 所有章节 Demo 页共用的脚手架: 标题 + 简介卡片 + 主体区域。
///
/// 风格复用 async_tutorial / riverpod_tutorial, 让三个教程视觉上一致。
class ChapterScaffold extends StatelessWidget {
  const ChapterScaffold({
    super.key,
    required this.title,
    required this.intro,
    required this.child,
    this.actions,
  });

  final String title;
  final String intro;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(intro, style: const TextStyle(height: 1.5)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: child,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// 一个小的日志面板, 章节需要 "看事件发生" 时可以挂上去。
class LogPanel extends StatelessWidget {
  const LogPanel({super.key, required this.logs});
  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        reverse: true,
        itemCount: logs.length,
        itemBuilder: (context, i) {
          final log = logs[logs.length - 1 - i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(log, style: const TextStyle(fontFamily: 'monospace')),
          );
        },
      ),
    );
  }
}
