import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'pages.dart';

part 'router.gr.dart';

/// 顶层路由表。`@AutoRouterConfig` 让 build_runner 扫描所有 @RoutePage,
/// 把路由目的地在 `router.gr.dart` 里生成成类型安全的 `HomeRoute` / `DetailRoute` /
/// `SettingsRoute` 类 (全是 `PageRouteInfo` 的子类)。
///
/// auto_route 11.x 起不再生成 `_$AppRouter` 基类, 你直接继承 `RootStackRouter` 即可。
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, path: '/', initial: true),
        AutoRoute(page: DetailRoute.page, path: '/detail/:id'),
        AutoRoute(page: SettingsRoute.page, path: '/settings'),
      ];
}
