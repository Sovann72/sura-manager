import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sura_flutter/sura_flutter.dart';
import 'package:sura_manager/sura_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SuraProvider(
      errorWidget: (error, onRefresh) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString()),
              TextButton(onPressed: onRefresh, child: Icon(Icons.refresh)),
            ],
          ),
        );
      },
      child: MaterialApp(
        title: 'Sura Manager Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int count = 0;
  late final FutureManager<int> dataManager;

  @override
  void initState() {
    dataManager = FutureManager(
      reloading: true,
      onError: (err) {
        print("error");
        count = 0;
      },
    );
    dataManager.asyncOperation(() async {
      count += 1;
      print("Count: $count");
      await Future.delayed(Duration(milliseconds: 1200));
      bool error = Random().nextBool();
      print("Is error? $error");
      if (error) throw "Error while getting data";
      return 10;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Use with FutureManagerBuilder
    return Scaffold(
      appBar: AppBar(
        title: Text("FutureManager example"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              //call our asyncOperation again
              dataManager.refresh(
                reloading: false,
              );
            },
          ),
        ],
      ),
      body: FutureManagerBuilder<int>(
        futureManager: dataManager,
        onRefreshing: const RefreshProgressIndicator(),
        loading: Center(child: CircularProgressIndicator()),
        onError: (err) {
          print("We got an error: $err");
        },
        ready: (context, data) {
          print("Rebuild");
          //result: My data: 10
          return Center(child: Text("My data: $data"));
        },
      ),
    );
  }
}
