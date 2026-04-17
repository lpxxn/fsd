import 'dart:async';

import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 5 章：Stream 基础。演示 listen、取消、广播、await for。
class Chapter05Page extends StatefulWidget {
  const Chapter05Page({super.key});

  @override
  State<Chapter05Page> createState() => _Chapter05PageState();
}

class _Chapter05PageState extends State<Chapter05Page> {
  final List<String> _logs = [];
  StreamSubscription<int>? _sub;

  void _log(String s) => setState(() => _logs.add(s));

  Stream<int> _ticker() => Stream<int>.periodic(
        const Duration(milliseconds: 500),
        (i) => i,
      ).take(10);

  void _startListen() {
    if (_sub != null) {
      _log('(已经在听了，请先取消)');
      return;
    }
    _log('--- 开始 listen (每 500ms 发一次) ---');
    _sub = _ticker().listen(
      (v) => _log('  收到 $v'),
      onDone: () {
        _log('  done');
        _sub = null;
      },
    );
  }

  Future<void> _cancelListen() async {
    if (_sub == null) {
      _log('(没有订阅)');
      return;
    }
    await _sub!.cancel();
    _sub = null;
    _log('--- 已取消订阅，Stream 不再往这里推 ---');
  }

  Future<void> _runAwaitFor() async {
    _log('--- await for, 收到 3 就 break ---');
    await for (final v in _ticker()) {
      _log('  await for 收到 $v');
      if (v >= 3) {
        _log('  break, 自动 cancel');
        break;
      }
    }
    _log('  循环结束');
  }

  Future<void> _runBroadcast() async {
    _log('--- 广播 Stream, 两个 listener ---');
    final ctrl = StreamController<int>.broadcast();
    final s1 = ctrl.stream.listen((v) => _log('  A 收到 $v'));
    final s2 = ctrl.stream.listen((v) => _log('  B 收到 $v'));
    for (var i = 1; i <= 3; i++) {
      ctrl.add(i);
      await Future.delayed(const Duration(milliseconds: 200));
    }
    await s1.cancel();
    await s2.cancel();
    await ctrl.close();
    _log('  广播完成');
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '05 · Stream 基础',
      intro: '体会 listen / cancel / await for / 广播 Stream 的差别。'
          '注意：离开页面前要 cancel 订阅 (dispose 里已经做了)。',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _startListen,
                child: const Text('开始 listen'),
              ),
              ElevatedButton(
                onPressed: _cancelListen,
                child: const Text('取消订阅'),
              ),
              ElevatedButton(
                onPressed: _runAwaitFor,
                child: const Text('await for + break'),
              ),
              ElevatedButton(
                onPressed: _runBroadcast,
                child: const Text('广播 Stream'),
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
