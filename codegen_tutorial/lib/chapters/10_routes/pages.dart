import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'router.dart';

/// 三个目标页, 都用 @RoutePage() 标注, 让 auto_route 把它们纳入路由表。
@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home (auto_route)')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Welcome home!'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.router.pushPath('/detail/42'),
              child: const Text('跳 /detail/42 (by path)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.router.push(DetailRoute(itemId: 7)),
              child: const Text('跳 DetailRoute(itemId: 7) (类型安全)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.router.push(const SettingsRoute()),
              child: const Text('跳 SettingsRoute'),
            ),
          ],
        ),
      ),
    );
  }
}

@RoutePage()
class DetailPage extends StatelessWidget {
  const DetailPage({super.key, @PathParam('id') required this.itemId});
  final int itemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail $itemId')),
      body: Center(
        child: Text('你是通过类型安全路由拿到的 itemId = $itemId',
            style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('这里是设置页。')),
    );
  }
}
