import 'dart:async';

import 'package:flutter/material.dart';

typedef FutureFunction<T> = Future<T> Function();
typedef SuccessCallBack<T> = FutureOr<T> Function(T);
typedef ErrorCallBack = void Function(FutureManagerError);

Widget _emptyErrorFn(_) {
  return const SizedBox();
}

// ignore: constant_identifier_names
const EmptyErrorFunction = _emptyErrorFn;

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



class FutureManagerError {
  final dynamic exception;
  final StackTrace? stackTrace;

  FutureManagerError({required this.exception, this.stackTrace});
  
}
