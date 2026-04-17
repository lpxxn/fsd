# 第 10 章 测试与 override

## 测试 Riverpod 的两个抓手

1. **`ProviderContainer`** —— 绕开 Flutter Widget 树，直接操纵 Provider
2. **`ProviderScope(overrides: [...])`** —— 在 Widget 测试里**替换**某个 Provider 的实现

用好这两个 API，Provider 的**业务逻辑测试** 和 **UI 测试** 都能写。

## 无 Widget 的单元测试：ProviderContainer

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('counter 自增', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(counterProvider), 0);
    container.read(counterProvider.notifier).increment();
    expect(container.read(counterProvider), 1);
  });
}
```

关键点：
- `ProviderContainer()` = 全新的"容器"，和 Widget 树无关
- 测试结束必须 `container.dispose()`（用 `addTearDown` 保证）
- `container.read(p)` 同 `ref.read(p)` —— 当前值
- `container.listen(p, cb)` 同 `ref.listen` —— 订阅（测试异步）

## 异步测试：await container.read(p.future)

```dart
test('quoteProvider 拿到字符串', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  final first = container.read(quoteProvider);
  expect(first, isA<AsyncLoading<String>>());

  final value = await container.read(quoteProvider.future);
  expect(value, isNotEmpty);
});
```

## 最重要的工具：overrides

真实测试要 mock 网络 / 数据库 / 时间。Riverpod 的 override：

```dart
test('userProvider 返回 mock 用户', () async {
  final container = ProviderContainer(overrides: [
    // 把 httpClientProvider 换掉
    httpClientProvider.overrideWithValue(FakeHttp()),
  ]);
  addTearDown(container.dispose);

  final user = await container.read(userProvider.future);
  expect(user.name, 'fake name');
});
```

### overrideWithValue vs overrideWith

```dart
// 1) overrideWithValue：只能替换 Provider<T> / StateProvider<T> 的简单值
someConfigProvider.overrideWithValue('test-mode'),

// 2) overrideWith：最通用, 可以替换工厂函数（含 Notifier、Future、Stream）
todosProvider.overrideWith(() => FakeTodosNotifier()),
userProvider.overrideWith((ref) async => const User(name: 'mock')),
```

### override family：override 里 match family 参数

```dart
postProvider.overrideWith((ref, arg) => mockPost(arg)),
```

## Widget 测试：ProviderScope(overrides: [...])

```dart
testWidgets('显示 mock 用户', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userProvider.overrideWith((ref) async => const User(name: 'Alice')),
      ],
      child: const MaterialApp(home: UserPage()),
    ),
  );

  expect(find.text('Alice'), findsNothing); // loading 中
  await tester.pumpAndSettle();
  expect(find.text('你好, Alice'), findsOneWidget);
});
```

套路完全一样，区别是：
- 单元测试用 `ProviderContainer`
- Widget 测试用 `ProviderScope(overrides: ...)`（内部其实也是一个 `ProviderContainer`）

## 用 mock 包替代 Fake 类

推荐 [`mocktail`](https://pub.dev/packages/mocktail)（不依赖 codegen，适合 null-safety 时代）：

```dart
class MockHttpClient extends Mock implements HttpClient {}

test('...', () async {
  final mock = MockHttpClient();
  when(() => mock.getUser(any())).thenAnswer((_) async => const User(name: 'x'));

  final container = ProviderContainer(overrides: [
    httpClientProvider.overrideWithValue(mock),
  ]);
  addTearDown(container.dispose);

  await container.read(userProvider.future);
  verify(() => mock.getUser(any())).called(1);
});
```

## listen 做断言：验证状态变迁序列

```dart
test('toggle 成功和失败会发出两种序列', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  final states = <AsyncValue<List<Todo>>>[];
  container.listen(todosProvider, (_, next) => states.add(next),
      fireImmediately: true);

  await container.read(todosProvider.future);
  await container.read(todosProvider.notifier).toggle('1');

  // 断言状态序列：[loading, data, data(new)]
  expect(states.length, greaterThanOrEqualTo(3));
});
```

## 分层架构 → 测试更容易（剧透下一章）

业务层如果是这样组织的：
- `fooRepositoryProvider` —— 只做 IO，抽象接口
- `fooNotifierProvider` —— 业务状态，内部 `ref.watch(fooRepositoryProvider)`

测试就只要 override `fooRepositoryProvider` 到一个 `FakeRepository`，上层 Notifier 全部能用真实代码测到。这就是 Riverpod 推荐的分层模式（第 12 章细讲）。

## 常见坑

1. **忘了 `addTearDown(container.dispose)`**：测试之间状态泄漏
2. **async watch 没 `pumpAndSettle`**：Widget 测试里 FutureProvider 还是 loading，断言失败
3. **overrideWithValue 用在 Notifier 上**：语法报错，要用 `overrideWith(() => notifier)`
4. **mock 时忘了 `registerFallbackValue` (mocktail)**：`any()` 对自定义类型需要先注册 fallback

## 实用测试清单

对一个 Notifier，你通常要覆盖：
- [ ] 初始状态正确
- [ ] 每个方法调用后状态符合预期
- [ ] 错误路径（抛异常时 state 变成 AsyncError）
- [ ] 依赖 Provider 变化时自己正确刷新（用 `container.read` + `invalidate`）

## 练习

1. 给第 3 章的 `CounterNotifier` 写 3 个单元测试：初始值、increment 3 次、reset。
2. 给第 5 章的 `TodosNotifier` 写测试：初始加载后 2 条、add 后变 3 条、remove 后变 1 条。
3. 写一个 Widget 测试：用 ProviderScope.override 把 quoteProvider 换成固定值，验证屏幕出现对应文本。

下一章：**Riverpod 内部到底怎么运作的** → [第 11 章](11_internals_scope_graph.md)。
