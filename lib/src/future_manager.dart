import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sura_manager/src/imanager.dart';

import 'future_manager_builder.dart';
import 'type.dart';

///[FutureManager] is a wrap around [Future] and [ChangeNotifier]
///
///[FutureManager] use [FutureManagerBuilder] instead of FutureBuilder to handle data
///
///[FutureManager] provide a method [asyncOperation] to handle or call async function
class FutureManager<T> extends IManager<T> {
  ///A future function that return the type of T
  final FutureFunction<T>? futureFunction;

  /// A function that call after [asyncOperation] is success and you want to manipulate data before
  /// adding it to manager
  final SuccessCallBack<T>? onSuccess;

  /// A function that call after everything is done
  final VoidCallback? onDone;

  /// A function that call after there is an error in our [asyncOperation]
  final ErrorCallBack? onError;

  /// if [reloading] is true, every time there's a new data, FutureManager will reset it's state to loading
  /// default value is [false]
  final bool reloading;

  ///Create a FutureManager instance, You can define a [futureFunction] here then [asyncOperation] will be call immediately
  FutureManager({
    this.futureFunction,
    this.reloading = true,
    this.onSuccess,
    this.onDone,
    this.onError,
  }) {
    if (futureFunction != null) {
      asyncOperation(
        futureFunction!,
        reloading: reloading,
        onSuccess: onSuccess,
        onDone: onDone,
        onError: onError,
      );
    }
  }

  ///The Future that this class is doing in [asyncOperation]
  ///Sometime you want to use [FutureManager] class with FutureBuilder, so you can use this field
  Future<T>? future;

  ///
  T? _data;
  FutureManagerError? _error;
  ManagerViewState _viewState = ManagerViewState.loading;
  final ValueNotifier<ManagerProcessState> _processingState = ValueNotifier(ManagerProcessState.idle);

  ManagerViewState get viewState => _viewState;
  ValueNotifier<ManagerProcessState> get processingState => _processingState;
  T? get data => _data;
  FutureManagerError? get error => _error;

  ///
  bool get isRefreshing => hasData || hasError;
  bool get hasData => _data != null;
  bool get hasError => _error != null;
  bool _disposed = false;

  @override
  Widget when({
    required Widget Function(T) ready,
    Widget? loading,
    Widget Function(dynamic)? error,
  }) {
    return FutureManagerBuilder<T>(
      futureManager: this,
      ready: (context, data) => ready(data),
      loading: loading,
      error: error,
    );
  }

  ///Similar to [when] but Only listen and display [data]. Default to Display blank when there is [loading] and [error] But can still customize
  Widget listen({
    required Widget Function(T) ready,
    Widget loading = const SizedBox(),
    Widget Function(dynamic) error = EmptyErrorFunction,
  }) {
    return FutureManagerBuilder<T>(
      futureManager: this,
      ready: (context, data) => ready(data),
      loading: loading,
      error: error,
    );
  }

  ///refresh is a function that call [asyncOperation] again,
  ///but doesn't reserve configuration
  ///return null if [futureFunction] hasn't been initialize
  late Future<T?> Function({
    bool? reloading,
    SuccessCallBack<T>? onSuccess,
    VoidCallback? onDone,
    ErrorCallBack? onError,
    bool? throwError,
  }) refresh = _emptyRefreshFunction;

  Future<T?> _emptyRefreshFunction({reloading, onSuccess, onDone, onError, throwError}) async {
    log("refresh() is depend on asyncOperation(),"
        " You need to call asyncOperation() once before you can call refresh()");
    return null;
  }

  @override
  Future<T?> asyncOperation(
    FutureFunction<T> futureFunction, {
    bool? reloading,
    SuccessCallBack<T>? onSuccess,
    VoidCallback? onDone,
    ErrorCallBack? onError,
    bool throwError = false,
  }) async {
    refresh = ({reloading, onSuccess, onDone, onError, throwError}) async {
      bool shouldReload = reloading ?? this.reloading;
      SuccessCallBack<T>? successCallBack = onSuccess ?? this.onSuccess;
      ErrorCallBack? errorCallBack = onError ?? this.onError;
      VoidCallback? onOperationDone = onDone ?? this.onDone;
      bool? shouldThrowError = throwError ?? false;
      //
      bool triggerError = true;
      if (isRefreshing) {
        triggerError = shouldReload;
      }
      try {
        await resetData(updateViewState: shouldReload);
        future = futureFunction.call();
        T result = await future!;
        if (successCallBack != null) {
          result = await successCallBack.call(result);
        }
        updateData(result);
        return result;
      } catch (exception, stackTrace) {
        FutureManagerError error = FutureManagerError(
          exception: exception,
          stackTrace: stackTrace,
        );

        ///Only update viewState if [triggerError] is true
        addError(error, updateViewState: triggerError);
        errorCallBack?.call(error);
        if (shouldThrowError) {
          rethrow;
        }
        return null;
      } finally {
        onOperationDone?.call();
      }
    };
    return refresh(
      reloading: reloading,
      onSuccess: onSuccess,
      onDone: onDone,
      onError: onError,
      throwError: throwError,
    );
  }

  ///Custom [notifyListeners] to support Future that can be useful in some casse
  void _notifyListeners({required bool useMicrotask}) {
    if (useMicrotask) {
      Future.microtask(() => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  ///[useMicrotask] param can be use to prevent schedule rebuilt while navigating or rebuilt
  void _updateManagerViewState(ManagerViewState state, {bool useMicrotask = false}) {
    if (_disposed) return;
    _viewState = state;
    _notifyListeners(useMicrotask: useMicrotask);
  }

  ///Wrap with [microtask] to prevent schedule rebuilt while navigating or rebuilt
  void _updateManagerProcessState(ManagerProcessState state, {bool useMicrotask = false}) {
    if (_disposed) return;

    void update() {
      if (_processingState.value == state) {
        _processingState.notifyListeners();
      }
      _processingState.value = state;
    }

    ///notify the ValueNotifier because it doesn't update if data is the same
    if (useMicrotask) {
      Future.microtask(update);
    } else {
      update();
    }
  }

  ///Similar to [updateData] but provide current current [data] in Manager as param.
  ///return updated [data] result once completed.
  Future<T?> modifyData(FutureOr<T> Function(T?) onChange) async {
    T? data = await onChange(_data);
    updateData(data);
    return data;
  }

  ///Update current data in our Manager.
  ///Ignore if data is null.
  ///Use [resetData] instead if you want to reset to [loading] state
  @override
  T? updateData(T? data, {bool useMicrotask = false}) {
    if (data != null) {
      _data = data;
      _error = null;
      _updateManagerProcessState(ManagerProcessState.ready, useMicrotask: useMicrotask);
      _updateManagerViewState(ManagerViewState.ready, useMicrotask: useMicrotask);
      return data;
    }
    return null;
  }

  ///Clear the error on this manager
  ///Only work when ViewState isn't error
  ///Best use case with Pagination when there is an error and you want to clear the error to show loading again
  void clearError() {
    if (viewState != ManagerViewState.error) {
      _error = null;
      _notifyListeners(useMicrotask: false);
    }
  }

  ///Add [error] our current manager, reset current [data] if [updateViewState] to null
  ///
  @override
  void addError(
    Object error, {
    bool updateViewState = true,
    bool useMicrotask = false,
  }) {
    FutureManagerError err = error is! FutureManagerError ? FutureManagerError(exception: error) : error;
    _error = err;
    if (updateViewState) {
      _data = null;
      _updateManagerViewState(
        ManagerViewState.error,
        useMicrotask: useMicrotask,
      );
    } else {
      _notifyListeners(useMicrotask: useMicrotask);
    }
    _updateManagerProcessState(
      ManagerProcessState.error,
      useMicrotask: useMicrotask,
    );
  }

  ///Reset all [data] and [error] to [loading] state.
  ///Only [notifyListeners] if [updateViewState] is false.
  @override
  Future<void> resetData({bool updateViewState = true}) async {
    const bool useMicroTask = true;
    if (updateViewState) {
      _error = null;
      _data = null;
      _updateManagerViewState(
        ManagerViewState.loading,
        useMicrotask: useMicroTask,
      );
    } else {
      _notifyListeners(useMicrotask: useMicroTask);
    }
    _updateManagerProcessState(
      ManagerProcessState.processing,
      useMicrotask: useMicroTask,
    );
  }

  @override
  String toString() {
    return "Data: $_data, Error: $_error, ViewState: $viewState, ProcessState: $processingState";
  }

  @override
  void dispose() {
    _data = null;
    _error = null;
    _processingState.dispose();
    _disposed = true;
    super.dispose();
  }
}
