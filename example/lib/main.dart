import 'package:flutter/material.dart';
import 'package:sura_flutter/sura_flutter.dart';
import 'package:sura_manager/sura_manager.dart';
import 'package:sura_manager_example/src/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SuraManagerProvider(
      errorBuilder: (error, onRefresh) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString()),
              SuraAsyncButton(
                fullWidth: false,
                onPressed: onRefresh,
                child: const Icon(Icons.refresh),
              ),
              // AnimatedBuilder(animation: animation, builder: builder)
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
          dataManager: () => FutureManager(
            reloading: true,
            cacheOption: const ManagerCacheOption.non(),
          ),
        ),
      ),
    );
  }
}
