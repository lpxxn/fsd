// 运行: dart run lib/pure_dart/chapter_03.dart

Future<int> login() => Future.delayed(const Duration(milliseconds: 200), () => 1001);
Future<String> fetchUser(int token) =>
    Future.delayed(const Duration(milliseconds: 200), () => 'user#$token');
Future<List<String>> fetchOrders(String user) => Future.delayed(
      const Duration(milliseconds: 200),
      () => ['o1', 'o2', 'o3'],
    );

Future<void> chainVersion() async {
  print('== 回调写法 ==');
  await login().then((token) {
    return fetchUser(token).then((user) {
      return fetchOrders(user).then((orders) {
        print('  $user 有 ${orders.length} 张订单');
      });
    });
  }).catchError((Object e) {
    print('  出错 $e');
  });
}

Future<void> asyncVersion() async {
  print('== async/await 写法 ==');
  try {
    final token = await login();
    final user = await fetchUser(token);
    final orders = await fetchOrders(user);
    print('  $user 有 ${orders.length} 张订单');
  } catch (e) {
    print('  出错 $e');
  }
}

Future<void> pauseDemo() async {
  print('\n== await 的 "伪暂停" ==');
  Future<void> fn() async {
    print('  A');
    await Future.delayed(const Duration(milliseconds: 300));
    print('  B');
  }

  fn(); // 故意不 await
  print('  C');
  await Future.delayed(const Duration(milliseconds: 500));
}

Future<void> main() async {
  await chainVersion();
  await asyncVersion();
  await pauseDemo();
  print('\n== 不要忘了 await ==');
  print('  (代码里如果忘了 await, 分析器会警告 discarded_futures)');
}
