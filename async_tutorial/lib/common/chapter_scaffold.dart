import 'package:flutter/material.dart';

/// 所有章节 Demo 页公用的外壳：顶部是标题，内容区是一段说明 + 可交互区域。
class ChapterScaffold extends StatelessWidget {
  const ChapterScaffold({
    super.key,
    required this.title,
    required this.intro,
    required this.child,
  });

  final String title;
  final String intro;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(intro),
            ),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// 一个等宽字体的日志面板，用于展示 Demo 的运行输出。
class LogPanel extends StatelessWidget {
  const LogPanel({super.key, required this.lines, this.title = '运行日志'});
  final List<String> lines;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white24, height: 16),
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: SelectableText(
                lines.isEmpty ? '(尚无输出)' : lines.join('\n'),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
