import 'package:flutter/material.dart';

import '../sura_manager.dart';

typedef DisposeFunction = void Function(VoidCallback);

///Mixin on StatefulWidget's state class to access [ManagerRef]
mixin ManagerProviderMixin<T extends StatefulWidget> on State<T> {
  final ManagerRef ref = ManagerRef();

  @override
  void dispose() {
    ref._dispose();
    super.dispose();
  }
}

///
abstract class _ManagerDisposable {
  void onDispose(void Function() cb);
}

class ManagerRef extends _ManagerDisposable {
  // ignore: prefer_function_declarations_over_variables
  VoidCallback disposeCallBack = () {};
  @override
  void onDispose(void Function() cb) {
    disposeCallBack = cb;
  }

  final List<ManagerProvider> _providers = [];
  FutureManager<T> read<T extends Object>(ManagerProvider<T> provider, {Object? param}) {
    if (_ManagerStore.store[provider] == null) {
      provider._manager = provider._create(this, param);
    }
    _providers.add(provider);
    _ManagerStore.addListener(provider);
    return provider._manager as FutureManager<T>;
  }

  void _dispose() {
    for (var provider in _providers) {
      _ManagerStore.removeListener(provider, disposeCallBack);
    }
    _providers.clear();
  }
}

class _ManagerStore {
  static final Map<ManagerProvider, int> store = {};

  static void addListener<T extends Object>(ManagerProvider<T> provider) {
    store[provider] ??= 0;
    store[provider] = store[provider]! + 1;
  }

  static void removeListener<T extends Object>(ManagerProvider<T> provider, VoidCallback onDispose) {
    if (store[provider] == null) return;
    store[provider] = store[provider]! - 1;
    if (store[provider] == 0) {
      onDispose.call();
      provider._manager?.dispose();
      store.remove(provider);
    }
  }
}

///Create a provider for [FutureManager]
class ManagerProvider<T extends Object> {
  FutureManager? _manager;
  final FutureManager<T> Function(ManagerRef, Object?) _create;
  ManagerProvider(this._create);
}

///Extends this class instead of Stateless widget to access [ManagerRef]
abstract class ManagerConsumer extends StatefulWidget {
  const ManagerConsumer({Key? key}) : super(key: key);

  Widget build(BuildContext context, ManagerRef ref);

  @override
  State<ManagerConsumer> createState() => _ManagerConsumerState();
}

class _ManagerConsumerState extends State<ManagerConsumer> with ManagerProviderMixin {
  @override
  Widget build(BuildContext context) {
    return widget.build(context, ref);
  }
}
