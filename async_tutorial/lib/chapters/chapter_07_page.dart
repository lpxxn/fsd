import 'dart:async';

import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 7 章：FutureBuilder / StreamBuilder 正确用法。
class Chapter07Page extends StatefulWidget {
  const Chapter07Page({super.key});

  @override
  State<Chapter07Page> createState() => _Chapter07PageState();
}

class _Chapter07PageState extends State<Chapter07Page> {
  late Future<String> _userFuture;
  late final Stream<int> _ticker =
      Stream<int>.periodic(const Duration(seconds: 1), (i) => i + 1);
  int _buildCount = 0;
  int _fetchCount = 0;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  Future<String> _loadUser({bool fail = false}) async {
    _fetchCount++;
    await Future.delayed(const Duration(milliseconds: 800));
    if (fail) throw Exception('服务器 500');
    return '张三 (第 $_fetchCount 次请求)';
  }

  void _retry({bool fail = false}) {
    setState(() {
      _userFuture = _loadUser(fail: fail);
    });
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    return ChapterScaffold(
      title: '07 · FutureBuilder / StreamBuilder',
      intro: '上方：FutureBuilder 展示加载/成功/失败三态；'
          '下方：StreamBuilder 展示每秒递增的计数器。'
          '注意：Future 是缓存到 State 里的，不会每次 build 重新请求。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('build 次数: $_buildCount   请求次数: $_fetchCount',
              style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          _futureSection(),
          const Divider(height: 32),
          _streamSection(),
        ],
      ),
    );
  }

  Widget _futureSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FutureBuilder', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: FutureBuilder<String>(
                future: _userFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Row(children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('加载中...'),
                    ]);
                  }
                  if (snap.hasError) {
                    return Text('错误: ${snap.error}',
                        style: const TextStyle(color: Colors.red));
                  }
                  return Text('你好, ${snap.data}',
                      style: const TextStyle(fontSize: 18));
                },
              ),
            ),
            Row(children: [
              ElevatedButton(
                onPressed: () => _retry(),
                child: const Text('重新请求 (成功)'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _retry(fail: true),
                child: const Text('重新请求 (失败)'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _streamSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('StreamBuilder', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<int>(
              stream: _ticker,
              initialData: 0,
              builder: (context, snap) {
                return Text('tick = ${snap.data}',
                    style: const TextStyle(fontSize: 24));
              },
            ),
          ],
        ),
      ),
    );
  }
}
