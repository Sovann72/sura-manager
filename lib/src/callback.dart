import 'dart:async';

typedef FutureFunction<T> = Future<T> Function();
typedef SuccessCallBack<T> = FutureOr<T> Function(T);
typedef ErrorCallBack = void Function(dynamic);

enum ManagerViewState {
  loading,
  done,
  error,
}

enum ManagerProcessingState {
  idle,
  processing,
  ready,
  error,
}
