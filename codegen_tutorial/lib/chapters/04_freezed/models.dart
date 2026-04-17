import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

/// 最基础的 freezed: 一个不可变 data class, 带 copyWith / == / hashCode / toString。
@freezed
abstract class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    @Default(false) bool done,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}

/// 带嵌套和自定义方法的 freezed: 要加一个 const 构造函数才能用实例方法。
@freezed
abstract class CartItem with _$CartItem {
  const CartItem._();  // 私有构造函数, 让我们能在 class 里加方法

  const factory CartItem({
    required String sku,
    required double unitPrice,
    @Default(1) int quantity,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  double get total => unitPrice * quantity;
}

/// Sealed / union 类型: 用 when / switch 穷尽地处理每个情况。
@freezed
sealed class LoadState<T> with _$LoadState<T> {
  const factory LoadState.idle() = LoadIdle<T>;
  const factory LoadState.loading() = LoadLoading<T>;
  const factory LoadState.success(T data) = LoadSuccess<T>;
  const factory LoadState.failure(Object error) = LoadFailure<T>;
}
