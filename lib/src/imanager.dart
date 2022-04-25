import 'package:flutter/material.dart';
import 'package:sura_manager/src/type.dart';

abstract class IManager<T> extends ChangeNotifier {
  ///Perform async function in manager
  Future<T?> asyncOperation(
    FutureFunction<T> futureFunction, {
    bool? reloading,
    SuccessCallBack<T>? onSuccess,
    VoidCallback? onDone,
    ErrorCallBack? onError,
    bool throwError = false,
  });

  ///Update current data in manager
  T? updateData(T data);

  ///Reset everything to starting point
  Future<void> resetData();

  ///Add error into manager
  void addError(Object error);

  ///handle widget to show with manager state
  Widget when({
    required Widget Function(T) ready,
    Widget? loading,
    Widget Function(dynamic)? error,
  });

  ///dispose everything
  @override
  void dispose();
}
