import 'package:flutter/material.dart';
import 'package:sura_flutter/sura_flutter.dart';
import 'package:sura_manager/sura_manager.dart';
import 'package:sura_manager_example/test_pagination.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SuraProvider(
      errorWidget: (error, onRefresh) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString()),
              TextButton(
                  onPressed: onRefresh, child: const Icon(Icons.refresh)),
            ],
          ),
        );
      },
      child: MaterialApp(
        title: 'Sura Manager Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(
          dataManager: FutureManager(reloading: true),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final FutureManager<int> dataManager;
  const MyHomePage({Key? key, required this.dataManager}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    widget.dataManager.asyncOperation(() async {
      await Future.delayed(const Duration(milliseconds: 1500));
      return 10;
    });

    widget.dataManager.addListener(() {
      debugPrint(widget.dataManager.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Use with FutureManagerBuilder
    return Scaffold(
      appBar: AppBar(
        title: const Text("FutureManager example"),
      ),
      body: FutureManagerBuilder<int>(
        futureManager: widget.dataManager,
        onRefreshing: () => const RefreshProgressIndicator(),
        loading: const Center(child: CircularProgressIndicator()),
        error: (err) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(err.toString()),
                ElevatedButton(
                  onPressed: () {
                    widget.dataManager.clearError();
                  },
                  child: const Text("Clear error"),
                ),
              ],
            ),
          );
        },
        onError: (err) {
          //debugdebugPrint("We got an error: $err");
        },
        onData: (data) {
          // debugPrint("We got a data: $data");
        },
        ready: (context, data) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$data",
                  key: const ValueKey("data"),
                ),
                const SpaceY(24),
                ElevatedButton(
                  key: const ValueKey("add"),
                  onPressed: () async {
                    await widget.dataManager.modifyData((data) {
                      return data! + 10;
                    });
                  },
                  child: const Text("Add 10"),
                ),
                const SpaceY(24),
                ElevatedButton(
                  key: const ValueKey("refresh"),
                  onPressed: widget.dataManager.refresh,
                  child: const Text("Refresh"),
                ),
                const SpaceY(24),
                ElevatedButton(
                  key: const ValueKey("refresh-no-reload"),
                  onPressed: () => widget.dataManager.refresh(reloading: false),
                  child: const Text("Refresh without reload"),
                ),
                const SpaceY(24),
                ElevatedButton(
                  key: const ValueKey("add-error"),
                  onPressed: () async {
                    widget.dataManager.addError(
                        const FutureManagerError(exception: "exception"));
                  },
                  child: const Text("Add error"),
                ),
                const SpaceY(24),
                ElevatedButton(
                  key: const ValueKey("reset"),
                  onPressed: widget.dataManager.resetData,
                  child: const Text("Reset"),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SuraPageNavigator.push(context, const SuraManagerWithPagination());
        },
        child: const Icon(Icons.assessment),
      ),
    );
  }
}
