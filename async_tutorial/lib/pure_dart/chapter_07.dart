// 运行: dart run lib/pure_dart/chapter_07.dart
//
// 第 7 章本身是讲 Flutter 的 FutureBuilder/StreamBuilder, 离开 UI 意义不大。
// 这份脚本仅演示 FutureBuilder 背后的 "三态模式" (loading / data / error)
// 自己手写等价实现, 便于理解 builder 帮你做了什么。

sealed class LoadState<T> {
  const LoadState();
}

class Loading<T> extends LoadState<T> {
  const Loading();
}

class Loaded<T> extends LoadState<T> {
  const Loaded(this.data);
  final T data;
}

class Failed<T> extends LoadState<T> {
  const Failed(this.error);
  final Object error;
}

Future<String> fakeLoad({bool fail = false}) async {
  await Future.delayed(const Duration(milliseconds: 300));
  if (fail) throw Exception('500');
  return 'user#1001';
}

void render<T>(LoadState<T> s) {
  switch (s) {
    case Loading<T>():
      print('  [UI] loading...');
    case Loaded<T>(:final data):
      print('  [UI] data=$data');
    case Failed<T>(:final error):
      print('  [UI] error=$error');
  }
}

Future<LoadState<T>> wrap<T>(Future<T> f) async {
  try {
    return Loaded(await f);
  } catch (e) {
    return Failed(e);
  }
}

Future<void> main() async {
  print('== 成功 ==');
  render<String>(const Loading());
  render(await wrap(fakeLoad()));

  print('\n== 失败 ==');
  render<String>(const Loading());
  render(await wrap(fakeLoad(fail: true)));
}
