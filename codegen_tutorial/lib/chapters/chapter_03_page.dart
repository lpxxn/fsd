import 'dart:convert';

import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';
import '03_json/models.dart';

/// 第 3 章 Demo: JSON 串 ↔ 对象 来回切换, 看 fromJson / toJson 实际产出。
class Chapter03Page extends StatefulWidget {
  const Chapter03Page({super.key});

  @override
  State<Chapter03Page> createState() => _Chapter03PageState();
}

class _Chapter03PageState extends State<Chapter03Page> {
  static const _samplePost = '''
{
  "author": {"id": 1, "name": "Alice", "email": "alice@example.com"},
  "article": {
    "id": 42,
    "title": "json_serializable 手册",
    "author_name": "Alice",
    "visibility": "public",
    "tags": ["dart", "codegen"]
  }
}''';

  String _input = _samplePost;
  String _output = '';
  String _error = '';

  void _decode() {
    setState(() {
      _error = '';
      try {
        final map = jsonDecode(_input) as Map<String, dynamic>;
        final post = Post.fromJson(map);
        _output = const JsonEncoder.withIndent('  ').convert(post.toJson());
      } catch (e) {
        _error = '$e';
        _output = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '03 · json_serializable',
      intro: '左边是 JSON 字符串, 点按钮触发 Post.fromJson 再 toJson, '
          '结果显示在右边。fromJson / toJson 都是 _\$PostFromJson / _\$PostToJson '
          '这些生成函数在干活。',
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: _input),
                    onChanged: (v) => _input = v,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '输入 JSON',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _error.isNotEmpty ? '错误: $_error' : _output,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: _error.isNotEmpty ? Colors.red : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: _decode,
                child: const Text('fromJson → toJson'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _input = _samplePost;
                    _output = '';
                    _error = '';
                  });
                },
                child: const Text('重置样例'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
