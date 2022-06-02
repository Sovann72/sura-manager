import 'package:flutter/material.dart';
import 'package:sura_manager/sura_manager.dart';

final provider = ManagerProvider((param) {
  return FutureManager<int>(
    futureFunction: () => Future.delayed(const Duration(seconds: 1), () => 1),
  );
});

class TestManagerStore extends StatefulWidget {
  const TestManagerStore({Key? key}) : super(key: key);

  @override
  State<TestManagerStore> createState() => _TestManagerStoreState();
}

class _TestManagerStoreState extends State<TestManagerStore>
    with ManagerProviderMixin {
  late final manager = ref.read(provider);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manager Store test")),
      body: manager.when(
        ready: (data) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$data"),
                const StatelessManagerStore(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StatelessManagerStore extends ManagerConsumer {
  const StatelessManagerStore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: ref.read(provider).when(
        ready: (data) {
          return ElevatedButton(
            child: Text("$data"),
            onPressed: () {
              ref.read(provider).modifyData((data) => data! + 10);
            },
          );
        },
      ),
    );
  }
}
