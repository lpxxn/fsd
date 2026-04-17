# 第 10 章 auto_route: 类型安全的路由

## 目标

- 告别 `Navigator.pushNamed('/detail', arguments: {'id': 42})` 这种字符串路由。
- 用 `@RoutePage` + `@AutoRouterConfig` 声明路由, 让 `auto_route_generator` 生成 typed route 类。
- 实现 `context.router.push(DetailRoute(itemId: 42))` 这种编译期检查。

## 三个步骤

### 1. 页面 class 打 @RoutePage

```dart
@RoutePage()
class HomePage extends StatelessWidget { ... }

@RoutePage()
class DetailPage extends StatelessWidget {
  const DetailPage({super.key, @PathParam('id') required this.itemId});
  final int itemId;
}

@RoutePage()
class SettingsPage extends StatelessWidget { ... }
```

`@RoutePage` 告诉 auto_route: "这个 widget 是一个路由目的地"。

### 2. 声明路由表

```dart
@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, path: '/', initial: true),
    AutoRoute(page: DetailRoute.page, path: '/detail/:id'),
    AutoRoute(page: SettingsRoute.page, path: '/settings'),
  ];
}
```

跑 `build_runner` 后, `router.gr.dart` 里会出现:

- `_$AppRouter` 基类 (我们继承它)
- `HomeRoute` / `DetailRoute` / `SettingsRoute` 这些强类型的 `PageRouteInfo` 子类
- `HomeRoute.page` / `DetailRoute.page` 这些 `PageInfo` 占位

### 3. 用它

```dart
MaterialApp.router(
  routerConfig: AppRouter().config(),
)

// 任意 Widget 里:
context.router.push(DetailRoute(itemId: 42));   // 类型安全!
context.router.pushNamed('/detail/42');         // 也行, 字符串方式
```

## 对比手写 Navigator 2.0

手写 Navigator 2.0 + `RouterDelegate` 动辄 150 行代码; auto_route 让你写三行声明就完事。

| 能力 | 手写 Navigator | auto_route |
|------|---------------|-----------|
| 声明 | 分散在各处 `pushNamed` | 集中在 AppRouter |
| 参数 | `arguments: {...}` (Map, 容易打错) | 强类型 `DetailRoute(itemId: 42)` |
| Deep link | 自己解析 | 自动, `path: '/detail/:id'` |
| 守卫 | 手写 `RouteObserver` | `AutoRouteGuard` |
| Tab / 嵌套 | 痛 | `AutoTabsRouter`, `AutoRouter.declarative` |

## 生成了什么

`router.gr.dart` 关键片段:

```dart
class DetailRoute extends PageRouteInfo<DetailRouteArgs> {
  DetailRoute({Key? key, required int itemId, List<PageRouteInfo>? children})
      : super(
          DetailRoute.name,
          args: DetailRouteArgs(key: key, itemId: itemId),
          rawPathParams: {'id': itemId},
          initialChildren: children,
        );

  static const String name = 'DetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DetailRouteArgs>(
        orElse: () => DetailRouteArgs(itemId: pathParams.getInt('id')),
      );
      return DetailPage(key: args.key, itemId: args.itemId);
    },
  );
}
```

**看点**:

- `rawPathParams` 把 `itemId: 42` 塞到 URL `/detail/42`。
- `builder` 从 URL 反解 `id` 再 `new DetailPage(itemId: ...)`。
- 用户不用管这些, 只面对 `DetailRoute(itemId: 42)` 这一个 API。

## 守卫 (AutoRouteGuard)

```dart
class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (loggedIn) {
      resolver.next();
    } else {
      router.push(const LoginRoute());
    }
  }
}

AutoRoute(page: HomeRoute.page, path: '/home', guards: [AuthGuard()])
```

## 常见坑

1. **`@RoutePage()` 的类一改名, 记得重跑 build_runner**, 否则 `HomeRoute` 还指着旧类。
2. **参数重命名**: 路径参数名 (`/:id`) 和 `@PathParam('id')` 名字要对齐。
3. **版本**: `auto_route` 和 `auto_route_generator` 大版本必须匹配。本工程都用 `any` 自动求解。
4. **web hash vs path url**: 默认 hash URL (`/#/detail/42`), 想去掉 `#` 要加 `usePathUrlStrategy()`。

## 在本工程的 Demo

第 10 章 Demo 页把 `AppRouter().config()` 嵌在一个 `Router` 里, 让你在当前 app 内部体验"子 router"。点按钮演示三种跳转: `pushNamed`、`push(DetailRoute(...))` 和 `SettingsRoute`。

## 练习

1. 新增一个 `ProfilePage`, 在路由表加对应 entry, 从 Home 跳过去。
2. 给 `DetailRoute` 加一个 `@QueryParam('tab')` 参数, URL 形如 `/detail/42?tab=comments`。
3. 写一个 `AuthGuard`, 未登录时跳 `/login`, 登录后跳回原路由。
