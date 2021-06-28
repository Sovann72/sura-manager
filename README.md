# Sura Manager

An class implementation to handle async value with Flutter widget

[![pub package](https://img.shields.io/badge/pub-0.0.2-blueviolet.svg)](https://pub.dev/packages/sura_manager) ![Latest commit](https://badgen.net/github/last-commit/asurraa/sura_manager)

# Installation

Add this to pubspec.yaml

```dart
dependencies:
  sura_manager: ^0.0.2
```

# Manager

### FutureManager

Handle async value with change notifier

```dart
class _HomePageState extends State<NewPage> {

  FutureManager<int> dataManager = FutureManager();
  @override
  void initState() {
    dataManager.asyncOperation(()async{
      await Future.delayed(Duration(seconds: 2));
      //Add 10 into our dataManager
      return 10;
    })
  }

  @override
  Widget build(BuildContext context) {
    //Use with FutureManagerBuilder
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon:Icon(Icons.refresh),
            onPressed:(){
              //call our asyncOperation again
              dataManager.refresh();
            },
          )
        ]
      ),
      body: FutureManagerBuilder<int>(
        futureManager: dataManager,
        error: (error) => YourErrorWidget(),
        loading: YourLoadingWidget(),
        ready: (context, data){
          //result: My data: 10
          return Text("My data: ${data}"),
        }
      ),
    ),
  }
}
```
