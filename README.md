# Sura Manager

ValueNotifier and ValueListenableBuilder but for asynchronous value.

[![pub package](https://img.shields.io/badge/pub-0.2.1-blueviolet.svg)](https://pub.dev/packages/sura_manager) ![Latest commit](https://badgen.net/github/last-commit/asurraa/sura_manager)

# Installation

Add this to pubspec.yaml

```dart
dependencies:
  sura_manager: ^0.2.1
```

### Use case and motivation:

Now imagine that you're fetching data from an API or working with a Future function that reflects the change to UI. Traditionally you could use **setState** or **FutureBuilder** to handle this case. But both of them create a boilerplate code and lack some functionality like refresh, event callback ..etc.

FutureManager provides you a solution with mainly focus on 3 main state of Future value: **Loading**,**Error** and **Done** where you can handle the UI with those states with FutureManagerBuilder.

#### Short example:

```dart
//Create a manager
FutureManager<int> dataManager = FutureManager();

//define a Future function
dataManager.asyncOperation(() => doingSomeAsyncWorkAndReturnValueAsInt());

//Handle the value
@override
Widget(BuildContext context){
  return FutureManagerBuilder<int>(
      futureManager: dataManager,
      error: (error) => YourErrorWidget(error), //optional
      loading: YourLoadingWidget(), //optional
      ready: (context, data){
        return ElevatedButton(
          child: Text("My data: ${data}"),
          onPressed: (){
            //Call the future function again
            dataManager.refresh();
          },
        ),
      }
  );
}
```

# FutureManager

| Property | description | default |
| --- | --- | --- |
| futureFunction | a function to run and return data | null |
| reloading | Reset a state to loading or not when you call refresh or asyncOperation | true |
| onSuccess | a callback function called after operation is success | null |
| onDone | a callback function called after operation is completely done, similar to finally in try-catch | null |
| onError | a callback function called after operation has an error | null |

| field    | description                                |
| -------- | ------------------------------------------ |
| data     | current data in the Manager                |
| error    | error in the Manager                       |
| hasData  | check if our Manager has a data            |
| hasError | check if our Manager has an error          |
| future   | future field of the current futureFunction |

| Method | description |
| --- | --- |
| when | A method similar to FutureManagerBuilder |
| asyncOperation | run futureFunction that will return a data to our Manager |
| refresh | call the asyncOperation again. we have to assign futureFunction from the constructor or call asyncOperation once to run this method, otherwise it will log an error |
| updateData | a method to update data in our Manager |
| modifyData | a method to update data in our Manager with data callback, prefer using this method to update data. |
| resetData | reset eveything to loading or null state |
| addError | add error into our manager |

# FutureManagerBuilder

## Example

```dart
class _HomePageState extends State<NewPage> {

  FutureManager<int> dataManager = FutureManager();
  @override
  void initState() {
    dataManager.asyncOperation(()async{
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
    );
  }
}
```

## Documentation

| Property | description | default |
| --- | --- | --- |
| futureManager | our FutureManager object | required |
| ready | A widget builder show when [FutureManager] has a data | required |
| loading | A widget show when [FutureManager] state is loading | CircularProgressIndicator |
| error | A widget show when [FutureManager] state is error | Text(error.toString()) |
| onError | A callback function that call when [FutureManager] state is error | null |
| onData | A callback function that call when [FutureManager] state has a data or data is updated | null |
| onRefreshing | A widget to show on top of this widget when refreshing | null |
