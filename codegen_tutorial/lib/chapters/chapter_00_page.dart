import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';

/// 第 0 章的 Demo: 只是一块静态介绍。
///
/// 这章没什么"可交互"的东西, 目的是让你打开 app 就能看到全景图。
class Chapter00Page extends StatelessWidget {
  const Chapter00Page({super.key});

  @override
  Widget build(BuildContext context) {
    const items = <_ToolEntry>[
      _ToolEntry('json_serializable', 'JSON 序列化', '加 @JsonSerializable 自动生成 fromJson/toJson'),
      _ToolEntry('freezed', '不可变 data class', '加 @freezed 自动生成 copyWith / ==  / union'),
      _ToolEntry('riverpod_generator', '状态管理', '加 @riverpod 自动挑选合适的 Provider 类型'),
      _ToolEntry('injectable', '依赖注入', '@injectable → configureDependencies()'),
      _ToolEntry('retrofit', 'HTTP 客户端', '@RestApi + 接口方法 → 基于 dio 的实现'),
      _ToolEntry('auto_route', '路由', '类型安全的路由表 + 生成 router'),
      _ToolEntry('drift', 'SQLite ORM', '声明表, 生成类型安全 query'),
      _ToolEntry('flutter_gen', '资源', 'Assets.images.xxx 替代字符串路径'),
      _ToolEntry('gen_l10n', '国际化', 'ARB 文件 → AppLocalizations'),
      _ToolEntry('mockito', '测试 Mock', '@GenerateMocks([Repo]) → MockRepo'),
      _ToolEntry('Dart Macros', '静态元编程', '无需 build_runner (实验)'),
    ];

    return ChapterScaffold(
      title: '00 · 总览',
      intro: '代码生成 (codegen) = 把"重复、机械、能从已有代码推出来"的样板代码交给工具写。'
          'Flutter 没有运行时反射, 所以常用的解决方案就是 build_runner + source_gen 家族。',
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final it = items[i];
          return ListTile(
            title: Text(it.name),
            subtitle: Text('${it.category} · ${it.desc}'),
          );
        },
      ),
    );
  }
}

class _ToolEntry {
  const _ToolEntry(this.name, this.category, this.desc);
  final String name;
  final String category;
  final String desc;
}
