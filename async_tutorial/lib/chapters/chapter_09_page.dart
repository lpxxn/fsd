import 'dart:async';

import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 9 章：Zone 与全局错误。演示 runZonedGuarded 如何捕获未处理异步异常。
class Chapter09Page extends StatefulWidget {
  const Chapter09Page({super.key});

  @override
  State<Chapter09Page> createState() => _Chapter09PageState();
}

class _Chapter09PageState extends State<Chapter09Page> {
  final List<String> _logs = [];

  void _log(String s) => setState(() => _logs.add(s));

  void _runGuarded() {
    _log('--- 用 runZonedGuarded 包一层 ---');
    runZonedGuarded(() {
      Future(() => throw StateError('async-boom-A'));
      Future.delayed(const Duration(milliseconds: 100),
          () => throw StateError('async-boom-B'));
    }, (error, stack) {
      _log('兜底捕获: $error');
    });
  }

  void _runUnguarded() {
    _log('--- 没有 zone 兜底 (看控制台有红色错误) ---');
    Future(() => throw StateError('async-ungaurded'));
  }

  void _runZoneValues() {
    runZoned(() async {
      final traceId = Zone.current['traceId'];
      _log('同步读到 traceId=$traceId');
      await Future.delayed(const Duration(milliseconds: 100));
      final t2 = Zone.current['traceId'];
      _log('await 之后依然能拿到 traceId=$t2 (异步上下文)');
    }, zoneValues: {'traceId': 'req-42'});
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '09 · Zone 与全局错误',
      intro: 'runZonedGuarded 可以兜住 zone 内所有未处理的异步异常。'
          'zoneValues 让你像 "异步 ThreadLocal" 一样传递 traceId 等上下文。',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _runGuarded,
                child: const Text('guarded 抛 2 个异常'),
              ),
              ElevatedButton(
                onPressed: _runUnguarded,
                child: const Text('不 guard 抛 1 个 (看控制台)'),
              ),
              ElevatedButton(
                onPressed: _runZoneValues,
                child: const Text('zoneValues 传 traceId'),
              ),
              OutlinedButton(
                onPressed: () => setState(_logs.clear),
                child: const Text('清空'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: LogPanel(lines: _logs)),
        ],
      ),
    );
  }
}
