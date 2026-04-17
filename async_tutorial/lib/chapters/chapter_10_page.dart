import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

int _fib(int n) => n < 2 ? n : _fib(n - 1) + _fib(n - 2);

/// 第 10 章：Isolate / compute。
/// 对比在主 Isolate 和子 Isolate 里算斐波那契时 UI 流畅度。
class Chapter10Page extends StatefulWidget {
  const Chapter10Page({super.key});

  @override
  State<Chapter10Page> createState() => _Chapter10PageState();
}

class _Chapter10PageState extends State<Chapter10Page> {
  final List<String> _logs = [];
  bool _busy = false;

  void _log(String s) => setState(() => _logs.add(s));

  Future<void> _runOnMain() async {
    setState(() => _busy = true);
    _log('--- 主 Isolate 算 fib(40) (会卡住界面) ---');
    final sw = Stopwatch()..start();
    final r = _fib(40);
    sw.stop();
    _log('结果=$r  耗时=${sw.elapsedMilliseconds}ms  (这期间旋转指示器冻住了)');
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _runOnCompute() async {
    setState(() => _busy = true);
    _log('--- compute 在子 Isolate 算 fib(40) (UI 不卡) ---');
    final sw = Stopwatch()..start();
    final r = await compute(_fib, 40);
    sw.stop();
    _log('结果=$r  耗时=${sw.elapsedMilliseconds}ms');
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _runOnIsolateRun() async {
    setState(() => _busy = true);
    _log('--- Isolate.run 在子 Isolate 算 fib(40) ---');
    final sw = Stopwatch()..start();
    final r = await Isolate.run(() => _fib(40));
    sw.stop();
    _log('结果=$r  耗时=${sw.elapsedMilliseconds}ms');
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '10 · Isolate 真并发',
      intro: '"主 Isolate 算" 按钮会卡住下方的旋转指示器；'
          '"compute / Isolate.run" 按钮不会。亲自对比感受。',
      child: Column(
        children: [
          const SizedBox(
            height: 60,
            child: Center(
              child: SizedBox(
                width: 40, height: 40,
                child: CircularProgressIndicator(strokeWidth: 4),
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _busy ? null : _runOnMain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                ),
                child: const Text('主 Isolate (会卡)'),
              ),
              ElevatedButton(
                onPressed: _busy ? null : _runOnCompute,
                child: const Text('compute'),
              ),
              ElevatedButton(
                onPressed: _busy ? null : _runOnIsolateRun,
                child: const Text('Isolate.run'),
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
