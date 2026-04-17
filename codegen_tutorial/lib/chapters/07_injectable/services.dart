import 'package:injectable/injectable.dart';

/// 抽象接口 + 两个实现, 用 @Named 区分。
abstract class Greeter {
  String hello(String who);
}

@Named('polite')
@Injectable(as: Greeter)
class PoliteGreeter implements Greeter {
  @override
  String hello(String who) => 'Hello, dear $who.';
}

@Named('casual')
@Injectable(as: Greeter)
class CasualGreeter implements Greeter {
  @override
  String hello(String who) => 'Yo $who!';
}

/// 单例: 整个 app 生命周期内只一份。
@singleton
class ClickCounter {
  int _count = 0;
  int get count => _count;
  void inc() => _count++;
}

/// 有构造依赖 + LazySingleton: 第一次被取出时才实例化。
@lazySingleton
class HelloBot {
  HelloBot(@Named('polite') this._greeter, this._counter);
  final Greeter _greeter;
  final ClickCounter _counter;

  String sayHiTo(String name) {
    _counter.inc();
    return '${_greeter.hello(name)} (#${_counter.count})';
  }
}
