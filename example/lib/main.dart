import 'package:dio/dio.dart';
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
  late FutureManager<int> dataManager = FutureManager(
    reloading: true,
    onError: (err) {},
  );

  @override
  void initState() {
    dataManager.asyncOperation(() async {
      await Future.delayed(Duration(milliseconds: 1500));
      bool error = false;
      //Random().nextBool();
      if (error) throw "Error while getting data";
      print("Get data done");
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
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
              dataManager.modifyData((data) {
                int newData = data ?? 0 + 10;
                return newData;
              });
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
        onReady: (data) {
          print("We got a data: $data");
        },
        ready: (context, data) {
          print("Rebuild");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("My data: $data"),
                const SpaceY(24),
                ElevatedButton(
                    onPressed: () {
                      dataManager.modifyData((data) {
                        return data! + 10;
                      });
                    },
                    child: Text("Update")),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SuraPageNavigator.push(context, SuraManagerWithPagination());
        },
        child: Icon(Icons.assessment),
      ),
    );
  }
}

class SuraManagerWithPagination extends StatefulWidget {
  const SuraManagerWithPagination({Key? key}) : super(key: key);

  @override
  _SuraManagerWithPaginationState createState() =>
      _SuraManagerWithPaginationState();
}

class _SuraManagerWithPaginationState extends State<SuraManagerWithPagination> {
  FutureManager<UserResponse> userController = FutureManager();
  int currentPage = 1;

  Future fetchData([bool reload = false]) async {
    if (reload) {
      currentPage = 1;
    }
    userController.asyncOperation(
      () async {
        final response = await Dio().get(
          "https://express-boilerplate.chunleethong.com/api/user/all",
          queryParameters: {
            "page": currentPage,
            "count": 10,
          },
        );
        return UserResponse.fromJson(response.data);
      },
      onSuccess: (response) {
        if (userController.hasData) {
          response.users = [...userController.data!.users, ...response.users];
        }
        currentPage += 1;
        return response;
      },
      reloading: reload,
    );
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fetch all users with pagination")),
      body: FutureManagerBuilder<UserResponse>(
        futureManager: userController,
        ready: (context, UserResponse response) {
          return SuraPaginatedList(
            itemCount: response.users.length,
            hasMoreData: response.hasMoreData,
            hasError: userController.hasError,
            itemBuilder: (context, index) {
              final user = response.users[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                onTap: () {},
                title: Text("${user.firstName} ${user.lastName}"),
                subtitle: Text(user.email!),
              );
            },
            dataLoader: fetchData,
          );
        },
      ),
    );
  }
}

class UserResponse {
  List<UserModel> users;
  final Pagination? pagination;

  UserResponse({this.pagination, required this.users});

  bool get hasMoreData =>
      pagination != null ? users.length < pagination!.totalItems : false;

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        users: json["data"] == null
            ? []
            : List<UserModel>.from(
                json["data"].map((x) => UserModel.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );
}

class UserModel {
  UserModel({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.avatar,
  });

  String? id;
  String? email;
  String? firstName;
  String? lastName;
  String? avatar;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["_id"] ?? null,
        email: json["email"] ?? null,
        firstName: json["first_name"] ?? null,
        lastName: json["last_name"] ?? null,
        avatar: json["profile_img"] ?? null,
      );
}

class Pagination {
  Pagination({
    required this.page,
    required this.totalItems,
    required this.totalPage,
  });

  num page;
  num totalItems;
  num totalPage;

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json["page"] ?? 0,
        totalItems: json["total_items"] ?? 0,
        totalPage: json["total_page"] ?? 0,
      );
}
