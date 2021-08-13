import 'package:flutter/material.dart';
import 'package:sura_flutter/sura_flutter.dart';
import 'package:sura_manager/sura_manager.dart';

import 'future_manager.dart';

/// A widget that build base on the state a [FutureManager]
class FutureManagerBuilder<T> extends StatefulWidget {
  ///A required [FutureManager] that this widget depends on
  final FutureManager<T> futureManager;

  /// A widget to show when [FutureManager] state is loading
  final Widget? loading;

  /// A widget to show when [FutureManager] state is error
  final Widget Function(dynamic)? error;

  /// A callback function that call when [FutureManager] state is error
  final void Function(dynamic)? onError;

  ///A widget to show on top of this widget when refreshing
  final Widget? onRefreshing;

  ///A widget to show when [FutureManager] state is success
  final Widget Function(BuildContext, T) ready;

  /// A widget that build base on the state a [FutureManager]
  const FutureManagerBuilder({
    Key? key,
    required this.futureManager,
    required this.ready,
    this.loading,
    this.error,
    this.onError,
    this.onRefreshing,
  }) : super(key: key);
  @override
  _FutureManagerBuilderState createState() => _FutureManagerBuilderState<T>();
}

class _FutureManagerBuilderState<T> extends State<FutureManagerBuilder<T>> {
  //
  SuraProvider? suraProvider;

  //
  void managerListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void processStateListener() {
    if (mounted) {
      if (widget.futureManager.processingState.value ==
          ManagerProcessState.error) {
        widget.onError?.call(widget.futureManager.error);
      }
    }
  }

  @override
  void initState() {
    widget.futureManager.addListener(managerListener);
    widget.futureManager.processingState.addListener(processStateListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.futureManager.removeListener(managerListener);
    widget.futureManager.processingState.removeListener(processStateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    suraProvider = SuraProvider.of(context);
    //
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        _buildWidgetByState(),
        if (widget.onRefreshing != null &&
            widget.futureManager.isRefreshing) ...[
          ValueListenableBuilder<ManagerProcessState>(
            valueListenable: widget.futureManager.processingState,
            builder: (context, value, child) {
              if (value == ManagerProcessState.processing) return child!;
              return const SizedBox();
            },
            child: widget.onRefreshing,
          ),
        ],
      ],
    );
  }

  Widget _buildWidgetByState() {
    switch (widget.futureManager.viewState) {
      case ManagerViewState.loading:
        if (widget.loading != null) {
          return widget.loading!;
        }
        return suraProvider?.loadingWidget ??
            const Center(child: const CircularProgressIndicator());

      case ManagerViewState.error:
        if (widget.error != null) {
          return widget.error!(widget.futureManager.error);
        }
        return suraProvider?.errorWidget?.call(
                widget.futureManager.error, widget.futureManager.refresh) ??
            Center(
              child: Text(
                widget.futureManager.error.toString(),
                textAlign: TextAlign.center,
              ),
            );
      case ManagerViewState.ready:
        return widget.ready(context, widget.futureManager.data!);
    }
  }
}
