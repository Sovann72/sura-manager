import 'package:flutter/material.dart';
import 'package:sura_manager/sura_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sura Manager Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FutureManager<int> dataManager = FutureManager(reloading: false);

  @override
  void initState() {
    dataManager.asyncOperation(() async {
      await Future.delayed(Duration(seconds: 2));
      //Add 10 into our dataManager
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
              dataManager.refresh();
            },
          ),
        ],
      ),
      body: FutureManagerBuilder<int>(
        futureManager: dataManager,
        showProgressIndicatorWhenLoading: true,
        error: (error) => Text(error.toString()),
        loading: Center(child: CircularProgressIndicator()),
        ready: (context, data) {
          print("Rebuild");
          //result: My data: 10
          return Center(child: Text("My data: $data"));
        },
      ),
    );
  }
}
