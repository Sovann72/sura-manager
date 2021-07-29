import 'dart:async';

typedef FutureFunction<T> = Future<T> Function();
typedef SuccessCallBack<T> = FutureOr<T> Function(T);
typedef ErrorCallBack = void Function(dynamic);

///A state that control the state of our manager's UI
enum ManagerViewState {
  loading,
  ready,
  error,
}

///A state that indicate the state of our manager, doesn't reflect on UI
enum ManagerProcessState {
  idle,
  processing,
  ready,
  error,
}
