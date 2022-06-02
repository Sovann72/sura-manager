import 'package:flutter/material.dart';

import '../sura_manager.dart';

mixin ManagerProviderMixin<T extends StatefulWidget> on State<T> {
  ManagerRef ref = ManagerRef();

  @override
  void dispose() {
    ref.dispose();
    super.dispose();
  }
}

class ManagerRef {
  final List<ManagerProvider> _providers = [];
  FutureManager<T> read<T extends Object>(ManagerProvider<T> provider, {Map<String, dynamic>? param}) {
    if (_ManagerStore.store[provider] == null) {
      provider.data = provider._create(param);
    }
    _providers.add(provider);
    _ManagerStore.addListener(provider);
    return provider.data as FutureManager<T>;
  }

  void dispose() {
    for (var provider in _providers) {
      _ManagerStore.removeListener(provider);
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

  static void removeListener<T extends Object>(ManagerProvider<T> provider) {
    if (store[provider] == null) return;
    store[provider] = store[provider]! - 1;
    if (store[provider] == 0) {
      provider.data?.dispose();
      store.remove(provider);
    }
  }
}

class ManagerProvider<T extends Object> {
  FutureManager? data;
  final FutureManager<T> Function(Map<String, dynamic>? param) _create;

  ManagerProvider(this._create);
}

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
