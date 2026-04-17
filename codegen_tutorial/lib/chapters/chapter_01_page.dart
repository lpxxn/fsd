import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 1 章 Demo: 把一段输入源码"走一遍" build_runner 的流水线, 可视化各阶段结果。
///
/// 我们并不真的启动 build_runner (那是命令行工具), 这里用硬编码的字符串,
/// 直观展示 "你写的代码 → 解析出的类/字段 → 生成的代码" 三个阶段。
class Chapter01Page extends StatefulWidget {
  const Chapter01Page({super.key});

  @override
  State<Chapter01Page> createState() => _Chapter01PageState();
}

class _Chapter01PageState extends State<Chapter01Page> {
  int _stage = 0;

  static const _source = '''
@JsonSerializable()
class User {
  User({required this.name, required this.age});
  final String name;
  final int age;
}
''';

  static const _analyzed = '''
LibraryElement
 └─ ClassElement(name: "User")
     ├─ field(name: "name", type: String)
     ├─ field(name: "age",  type: int)
     └─ annotation: JsonSerializable()
''';

  static const _generated = '''
// user.g.dart  (GENERATED CODE - DO NOT MODIFY)
part of 'user.dart';

User _\$UserFromJson(Map<String, dynamic> json) => User(
      name: json['name'] as String,
      age: json['age'] as int,
    );

Map<String, dynamic> _\$UserToJson(User self) => <String, dynamic>{
      'name': self.name,
      'age': self.age,
    };
''';

  @override
  Widget build(BuildContext context) {
    final stages = [
      ('1. 你写的源码 (user.dart)', _source),
      ('2. analyzer 解析出的元素树', _analyzed),
      ('3. source_gen + json_serializable 生成的 user.g.dart', _generated),
    ];
    final current = stages[_stage];

    return ChapterScaffold(
      title: '01 · build_runner 流水线',
      intro: '一次代码生成的三个关键阶段: 源码 → 元素树 → 生成文件。'
          '点下面按钮可以在三个阶段之间切换, 直观感受每一步的形态。',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            children: List.generate(stages.length, (i) {
              return ChoiceChip(
                label: Text(stages[i].$1),
                selected: _stage == i,
                onSelected: (_) => setState(() => _stage = i),
              );
            }),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  current.$2,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
