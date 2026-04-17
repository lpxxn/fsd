import 'package:flutter/material.dart';

import '../project/presentation/app.dart';

/// 第 13 章入口: 直接把综合项目挂进来。
/// 所有 Provider 复用全局 ProviderScope (main.dart 中已经挂好)。
class Chapter13Page extends StatelessWidget {
  const Chapter13Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const TodoApp();
  }
}
