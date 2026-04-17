import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';
import '02_custom/person.dart';

/// 第 2 章 Demo: 用自己写的 `@ToStringGen` 生成 toString。
///
/// Person 类打了 @ToStringGen, 我们在此处创建实例并显示 toString。
/// 你可以打开 `lib/chapters/02_custom/person.g.dart` 看到真正被 build_runner 生成的函数。
class Chapter02Page extends StatefulWidget {
  const Chapter02Page({super.key});

  @override
  State<Chapter02Page> createState() => _Chapter02PageState();
}

class _Chapter02PageState extends State<Chapter02Page> {
  final _name = TextEditingController(text: 'Alice');
  final _age = TextEditingController(text: '30');

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final person = Person(
      name: _name.text,
      age: int.tryParse(_age.text) ?? 0,
    );

    return ChapterScaffold(
      title: '02 · 写自己的 Generator',
      intro: '我们在 packages/my_generator/ 实现了 @ToStringGen。'
          '下面这个 Person.toString() 不是你手写的, 是 person.g.dart 里'
          '生成的 _\$PersonToString 函数负责的。改两个字段观察输出。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'name'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _age,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'age'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Text(
            'person.toString() =',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              person.toString(),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '生成的源码 (person.g.dart):',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'String _\$PersonToString(Person self) {\n'
              "  return 'Person(name=\${self.name}, age=\${self.age})';\n"
              '}',
              style: TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
