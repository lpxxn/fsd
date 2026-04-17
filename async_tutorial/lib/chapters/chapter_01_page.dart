import 'dart:io' show sleep;

import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 1 章：同步 vs 异步。
///
/// 页面上有一个持续旋转的 CircularProgressIndicator，还有两个按钮：
/// "同步卡 2 秒" 会把 UI 线程卡住，进度圈肉眼可见地冻住；
/// "异步等 2 秒" 只是挂起当前函数，进度圈继续转。
class Chapter01Page extends StatefulWidget {
  const Chapter01Page({super.key});

  @override
  State<Chapter01Page> createState() => _Chapter01PageState();
}

class _Chapter01PageState extends State<Chapter01Page> {
  String _result = '(还没点按钮)';
  bool _busy = false;

  void _runBlocking() {
    setState(() {
      _busy = true;
      _result = '同步卡住中... 注意进度圈';
    });
    sleep(const Duration(seconds: 2));
    setState(() {
      _busy = false;
      _result = '同步完成 (UI 刚才冻住了 2 秒)';
    });
  }

  Future<void> _runAsync() async {
    setState(() {
      _busy = true;
      _result = '异步等待中... 进度圈照常转';
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = '异步完成 (刚才 UI 没卡)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '01 · 同步 vs 异步',
      intro: '对比同步 sleep 和异步 Future.delayed 对 UI 流畅度的影响。'
          '观察正中间的进度圈：同步按钮会让它卡住，异步按钮不会。',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(strokeWidth: 6),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _result,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _busy ? null : _runBlocking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade900,
                ),
                child: const Text('同步卡 2 秒 (坏例子)'),
              ),
              ElevatedButton(
                onPressed: _busy ? null : _runAsync,
                child: const Text('异步等 2 秒 (推荐)'),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            '说明：sleep() 来自 dart:io，会霸占当前线程；\n'
            'Future.delayed() 只是向事件循环注册一个定时事件，'
            '等待期间 UI 线程可以去渲染/响应手势。',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
