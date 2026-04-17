import 'package:flutter/material.dart';

import '../common/chapter_scaffold.dart';
import '10_routes/router.dart';

/// 第 10 章 Demo: 嵌入一个 auto_route 子路由器 (嵌在 Chapter10Page 里)。
///
/// 直接在当前 MaterialApp 内部用 `Router` widget, 不影响外层导航。
/// 使用 `AppRouter().config()` 作为子 Router 的配置。
class Chapter10Page extends StatefulWidget {
  const Chapter10Page({super.key});

  @override
  State<Chapter10Page> createState() => _Chapter10PageState();
}

class _Chapter10PageState extends State<Chapter10Page> {
  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '10 · auto_route',
      intro: '下面这个内嵌的小 app 就是一个 auto_route 子路由系统。'
          'Home → Detail(itemId) → Settings, 所有跳转都是类型安全的, '
          'URL 也能正确反解参数。',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
          child: Router(
            routerDelegate: _router.delegate(),
            routeInformationParser: _router.defaultRouteParser(),
          ),
        ),
      ),
    );
  }
}
