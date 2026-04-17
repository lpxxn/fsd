import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';
import '09_retrofit/api.dart';
import '09_retrofit/models.dart';

/// 第 9 章 Demo: 调 jsonplaceholder.typicode.com 的公开 API。
/// 需要联网。
class Chapter09Page extends StatefulWidget {
  const Chapter09Page({super.key});

  @override
  State<Chapter09Page> createState() => _Chapter09PageState();
}

class _Chapter09PageState extends State<Chapter09Page> {
  final _api = JsonPlaceholderApi(Dio());
  Post? _post;
  String _error = '';
  bool _loading = false;

  Future<void> _load(int id) async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final p = await _api.getPost(id);
      if (!mounted) return;
      setState(() => _post = p);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '09 · retrofit',
      intro: '点按钮发真实 HTTP 请求 (jsonplaceholder.typicode.com)。'
          '整个调用链 api.getPost(1) → _JsonPlaceholderApi.getPost (生成) → dio.fetch → Post.fromJson。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              FilledButton(
                onPressed: _loading ? null : () => _load(1),
                child: const Text('GET /posts/1'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading ? null : () => _load(42),
                child: const Text('GET /posts/42'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading) const LinearProgressIndicator(),
          if (_error.isNotEmpty)
            Text('错误: $_error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _post == null
                      ? '(还没请求)'
                      : const JsonEncoder.withIndent('  ').convert(_post!.toJson()),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
