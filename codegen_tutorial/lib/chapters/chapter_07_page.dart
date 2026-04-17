import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../common/chapter_scaffold.dart';
import '07_injectable/di.dart' as di;
import '07_injectable/services.dart';

/// 第 7 章 Demo: 用 injectable 注入的单例服务, 点按钮看计数增长。
class Chapter07Page extends StatefulWidget {
  const Chapter07Page({super.key});

  @override
  State<Chapter07Page> createState() => _Chapter07PageState();
}

class _Chapter07PageState extends State<Chapter07Page> {
  bool _ready = false;
  String _lastOutput = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!GetIt.I.isRegistered<HelloBot>()) {
      await di.configureDependencies();
    }
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return ChapterScaffold(
      title: '07 · injectable + get_it',
      intro: '点"打招呼", 从 GetIt 里取 HelloBot 执行。'
          '每次点击都共享同一个 ClickCounter (@singleton), 所以编号递增。',
      child: !_ready
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: () {
                    final bot = di.getIt<HelloBot>();
                    setState(() => _lastOutput = bot.sayHiTo('World'));
                  },
                  child: const Text('打招呼'),
                ),
                const SizedBox(height: 12),
                Text('输出: $_lastOutput'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '类型一览:\n'
                    '  • @singleton  ClickCounter      (饿汉单例)\n'
                    '  • @lazySingleton HelloBot       (懒汉单例)\n'
                    '  • @Injectable(as: Greeter) + @Named("polite"/"casual")',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            ),
    );
  }
}
