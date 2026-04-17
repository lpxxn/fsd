import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 15 章 Demo: 和 build_runner 的可视对比, 纯文字/代码展示。
class Chapter15Page extends StatelessWidget {
  const Chapter15Page({super.key});

  static const _oldWay = '''
// 今天你写的 (build_runner + json_serializable)
@JsonSerializable()
class User {
  User({required this.name, required this.age});
  final String name;
  final int age;

  factory User.fromJson(Map<String, dynamic> json) => _\$UserFromJson(json);
  Map<String, dynamic> toJson() => _\$UserToJson(this);
}

// + part 'user.g.dart';
// + dart run build_runner build
''';

  static const _newWay = '''
// 如果用 Dart Macros (实验)
@JsonCodable()
class User {
  final String name;
  final int age;
}

// 不用 part 指令
// 不用跑 build_runner
// 不用写 fromJson / toJson —— 编译器自动合成
''';

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '15 · Dart Macros (实验性)',
      intro: 'macros 是语言级元编程, 不产生 .g.dart 文件, 不需要 build_runner。'
          '2026 初仍在 experimental, 本 Demo 只做对比, 不真正启用。',
      child: Row(
        children: [
          Expanded(
            child: _Box(
              title: '今天 (build_runner + source_gen)',
              code: _oldWay,
              color: Colors.blue.shade50,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Box(
              title: '未来 (Dart Macros)',
              code: _newWay,
              color: Colors.green.shade50,
            ),
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.title, required this.code, required this.color});
  final String title;
  final String code;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                code,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
