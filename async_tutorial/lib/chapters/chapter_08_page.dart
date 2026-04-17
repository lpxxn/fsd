import 'dart:async';

import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 8 章：事件循环。在 UI 里可视化微任务 vs 事件的顺序。
class Chapter08Page extends StatefulWidget {
  const Chapter08Page({super.key});

  @override
  State<Chapter08Page> createState() => _Chapter08PageState();
}

class _Chapter08PageState extends State<Chapter08Page> {
  final List<String> _logs = [];

  void _log(String s) => _logs.add(s);

  void _runClassic() {
    _logs.clear();
    _log('1 sync');
    scheduleMicrotask(() => _log('2 micro-a'));
    Future(() => _log('3 event-a')).then((_) {
      _log('4 then-after-event-a');
      scheduleMicrotask(() => _log('5 micro-inside-then'));
    });
    Future.microtask(() => _log('6 micro-b'));
    Future(() => _log('7 event-b'));
    _log('8 sync');

    // 等所有队列排空后一次性展示
    Future(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _runFutureValueStillAsync() {
    _logs.clear();
    _log('A');
    Future.value(1).then((_) => _log('B (通过 .then, 虽然值已就绪)'));
    _log('C');
    Future(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _runTimerVsMicro() {
    _logs.clear();
    _log('开始');
    Timer(Duration.zero, () => _log('timer(0)'));
    Future(() => _log('Future()'));
    scheduleMicrotask(() => _log('scheduleMicrotask'));
    Future(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '08 · 事件循环 (核心)',
      intro: '同步 > 微任务 > 事件。同步代码跑完才开始处理队列；'
          '每次跑一个事件前，都会先清空微任务队列。',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _runClassic,
                child: const Text('经典题 (1~8)'),
              ),
              ElevatedButton(
                onPressed: _runFutureValueStillAsync,
                child: const Text('Future.value.then 仍异步'),
              ),
              ElevatedButton(
                onPressed: _runTimerVsMicro,
                child: const Text('Timer(0) vs micro'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LogPanel(
              title: '执行顺序 (等全部完成后渲染)',
              lines: _logs,
            ),
          ),
        ],
      ),
    );
  }
}
