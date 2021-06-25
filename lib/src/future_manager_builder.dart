import 'package:flutter/material.dart';
import 'package:sura_flutter/sura_flutter.dart' as SuraFlutter;

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
  }) : super(key: key);
  @override
  _FutureManagerBuilderState createState() => _FutureManagerBuilderState<T>();
}

class _FutureManagerBuilderState<T> extends State<FutureManagerBuilder<T>> {
  //
  SuraFlutter.SuraProvider? suraProvider;
  void listener() {
    if (mounted) {
      setState(() {});
      if (widget.futureManager.hasError) {
        if (suraProvider?.onManagerError != null) {
          suraProvider?.onManagerError
              ?.call(widget.futureManager.error, context);
        }
        widget.onError?.call(widget.futureManager.error);
      }
    }
  }

  @override
  void initState() {
    widget.futureManager.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    widget.futureManager.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    suraProvider = SuraFlutter.SuraProvider.of(context);
    //
    if (widget.futureManager.hasData) {
      return widget.ready(context, widget.futureManager.data!);
    } else if (widget.futureManager.hasError) {
      if (widget.error != null) {
        return widget.error!(widget.futureManager.error);
      }
      return suraProvider?.errorWidget?.call(widget.futureManager.error) ??
          Center(
            child: Text(
              widget.futureManager.error.toString(),
              textAlign: TextAlign.center,
            ),
          );
    } else {
      if (widget.loading != null) {
        return widget.loading!;
      }
      return suraProvider?.loadingWidget ??
          Center(child: CircularProgressIndicator());
    }
  }
}
