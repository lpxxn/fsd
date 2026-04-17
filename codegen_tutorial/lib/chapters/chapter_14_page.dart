import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/chapter_scaffold.dart';
import '../gen/assets.gen.dart';

/// 第 14 章 Demo: Assets 强类型访问。
class Chapter14Page extends StatefulWidget {
  const Chapter14Page({super.key});

  @override
  State<Chapter14Page> createState() => _Chapter14PageState();
}

class _Chapter14PageState extends State<Chapter14Page> {
  String? _jsonContent;

  @override
  void initState() {
    super.initState();
    _loadSample();
  }

  Future<void> _loadSample() async {
    final s = await rootBundle.loadString(Assets.data.sample);
    if (!mounted) return;
    setState(() => _jsonContent = s);
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '14 · flutter_gen',
      intro: 'Assets.images.logo / Assets.data.sample 都是生成的, 打错编译不过。'
          '打开 lib/gen/assets.gen.dart 看生成类结构。',
      child: ListView(
        children: [
          const Text('Assets.images.logo.image():'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              children: [
                Assets.images.logo.image(width: 48, height: 48, fit: BoxFit.contain),
                const SizedBox(width: 16),
                Text('path = ${Assets.images.logo.path}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('所有生成的 image 资源:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...Assets.images.values.map((a) => Text('  · ${a.path}')),
          const SizedBox(height: 16),
          const Text('所有生成的 data 资源:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...Assets.data.values.map((p) => Text('  · $p')),
          const SizedBox(height: 16),
          Text('读 Assets.data.sample 内容:', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _jsonContent ?? '...',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
