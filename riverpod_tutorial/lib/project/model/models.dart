class User {
  const User({required this.id, required this.name, required this.email});
  final String id;
  final String name;
  final String email;
}

class Todo {
  const Todo({required this.id, required this.title, this.done = false});
  final String id;
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(id: id, title: title ?? this.title, done: done ?? this.done);
}

class Paged<T> {
  const Paged({required this.items, required this.page, required this.hasMore});
  final List<T> items;
  final int page;
  final bool hasMore;

  Paged<T> copyWith({List<T>? items, int? page, bool? hasMore}) =>
      Paged<T>(
        items: items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
      );
}

sealed class AuthState {
  const AuthState();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);
  final User user;
}
