// 运行: dart run lib/pure_dart/chapter_10.dart

import 'dart:isolate';

int heavySum(int n) {
  var s = 0;
  for (var i = 0; i < n; i++) {
    s += i;
  }
  return s;
}

Future<void> main() async {
  print('== 主 Isolate 直接算 ==');
  final sw1 = Stopwatch()..start();
  final r1 = heavySum(500000000);
  sw1.stop();
  print('  结果=$r1  耗时=${sw1.elapsedMilliseconds}ms');

  print('\n== 用 Isolate.run 算 (不阻塞主 Isolate) ==');
  final sw2 = Stopwatch()..start();
  final r2 = await Isolate.run(() => heavySum(500000000));
  sw2.stop();
  print('  结果=$r2  耗时=${sw2.elapsedMilliseconds}ms');

  print('\n== 手动 spawn + 双向通信 ==');
  final rx = ReceivePort();
  await Isolate.spawn(_worker, rx.sendPort);
  final tx = await rx.first as SendPort;

  final ans = ReceivePort();
  tx.send([9, ans.sendPort]);
  print('  9 的平方 = ${await ans.first}');
  ans.close();
  rx.close();
}

void _worker(SendPort mainPort) {
  final port = ReceivePort();
  mainPort.send(port.sendPort);
  port.listen((msg) {
    final x = msg[0] as int;
    final reply = msg[1] as SendPort;
    reply.send(x * x);
  });
}
