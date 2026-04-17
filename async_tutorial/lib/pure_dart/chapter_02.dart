// 运行: dart run lib/pure_dart/chapter_02.dart

import 'dart:async';

Future<int> fetchNumber() =>
    Future.delayed(const Duration(milliseconds: 500), () => 42);

Future<int> step1() => Future.value(1);
Future<int> step2(int v) => Future.value(v + 10);

Future<void> main() async {
  print('== 1) 三种创建方式 ==');
  final f1 = Future<int>.value(42);
  final f2 = Future<String>.delayed(const Duration(milliseconds: 200), () => 'hello');
  final f3 = Future<int>(() => 1 + 2);
  print('f1=${await f1}');
  print('f2=${await f2}');
  print('f3=${await f3}');

  print('\n== 2) .then / .catchError / .whenComplete ==');
  fetchNumber()
      .then((v) => print('  then 拿到 $v'))
      .catchError((e, st) => print('  catchError: $e'))
      .whenComplete(() => print('  whenComplete: 完结'));
  print('  同步代码先跑完');
  await Future.delayed(const Duration(seconds: 1));

  print('\n== 3) .then 链会自动摊平 Future ==');
  await step1()
      .then((v) => step2(v))
      .then((v) => print('  最终结果 $v (应该是 11)'));

  print('\n== 4) 异常沿着链传播 ==');
  await Future.value(1)
      .then((_) => throw Exception('boom'))
      .then((_) => print('  不会到这里'))
      .catchError((e) => print('  在 catchError 中接住: $e'));

  print('\n== 5) 裸创建未 await 的 Future ==');
  Future.delayed(const Duration(milliseconds: 300), () => print('  [裸 future 到期]'));
  print('  这一行先打印');
  await Future.delayed(const Duration(milliseconds: 500));

  print('\nmain 结束');
}
