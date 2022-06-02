import 'package:flutter/material.dart';
import 'package:sura_manager/src/type.dart';

class SuraManagerProvider extends InheritedWidget {
  const SuraManagerProvider({
    Key? key,
    required Widget child,
    this.managerLoadingBuilder,
    this.errorBuilder,
    this.onFutureManagerError,
  }) : super(child: child, key: key);

  ///Loading widget use in [Manager] class
  final Widget? managerLoadingBuilder;

  ///Error widget use in [Manager] class
  final ManagerErrorBuilder? errorBuilder;

  ///A callback function that run if FutureManagerBuilder has an error
  final OnManagerError? onFutureManagerError;

  static SuraManagerProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SuraManagerProvider>();
  }

  @override
  bool updateShouldNotify(SuraManagerProvider oldWidget) => true;
}
