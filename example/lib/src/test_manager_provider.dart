import 'package:flutter/material.dart';
import 'package:sura_flutter/sura_flutter.dart';
import 'package:sura_manager/sura_manager.dart';

final provider = ManagerProvider((ref, param) {
  int second = param as int;
  ref.onDispose(() {
    infoLog("Manager is disposing");
  });
  return FutureManager<int>(
    futureFunction: () => Future.delayed(Duration(seconds: second), () => second),
  );
});

class TestManagerProvider extends StatefulWidget {
  const TestManagerProvider({Key? key}) : super(key: key);

  @override
  State<TestManagerProvider> createState() => _TestManagerProviderState();
}

class _TestManagerProviderState extends State<TestManagerProvider> with ManagerProviderMixin {
  late final manager = ref.read(provider, param: 3);

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
