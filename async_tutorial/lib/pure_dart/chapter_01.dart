// 运行: dart run lib/pure_dart/chapter_01.dart
//
// 对比同步阻塞 sleep 与异步 Future.delayed 的差别。
// 观察重点：blockingDemo 执行期间，进程什么都不能做；
// nonBlockingDemo 只是把当前函数挂起，事件循环仍然活着。

import 'dart:io';
import 'dart:async';

void blockingDemo() {
  print('[blocking] 开始 t=${DateTime.now().toIso8601String()}');
  sleep(const Duration(seconds: 2));
  print('[blocking] 结束 t=${DateTime.now().toIso8601String()}');
}

Future<void> nonBlockingDemo() async {
  print('[async] 开始 t=${DateTime.now().toIso8601String()}');
  await Future.delayed(const Duration(seconds: 2));
  print('[async] 结束 t=${DateTime.now().toIso8601String()}');
}

Future<void> main() async {
  blockingDemo();
  print('--- 分割线 ---');

  // 观察: 我们在 nonBlockingDemo 等待期间，事件循环仍能处理别的任务
  Timer.periodic(const Duration(milliseconds: 500), (t) {
    if (t.tick > 4) {
      t.cancel();
      return;
    }
    print('[其它任务] 事件循环还活着 tick=${t.tick}');
  });

  await nonBlockingDemo();
  print('main 结束');
}
