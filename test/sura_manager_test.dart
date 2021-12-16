import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sura_manager/src/future_manager.dart';

void main() {
  FutureManager<int> futureManager = FutureManager();

  test("Test future manger with value", () async {
    late int value;
    await futureManager.asyncOperation(() async {
      await Future.delayed(const Duration(seconds: 2));
      return 10;
    }, onSuccess: (data) {
      value = data;
      return value;
    });
    expect(value, 10);
  });

  test("Test future manger with error", () async {
    int? value;
    await futureManager.asyncOperation(() async {
      await Future.delayed(const Duration(seconds: 2));
      throw const HttpException("Unable to process");
    }, onSuccess: (data) {
      value = data;
      return value!;
    });
    expect(value, null);
    expect(futureManager.error.runtimeType, HttpException);
  });

  // test("Test future manger with loading", () async {
  //   int? value;
  //   await futureManager.asyncOperation(() async {
  //     await Future.delayed(Duration(seconds: 2));
  //     return 10;
  //   }, onSuccess: (data) {
  //     value = data;
  //     return value!;
  //   });
  //   expect(value, 10);
  //   futureManager.refresh(reloading: false).then((value) {
  //     expect(futureManager.isLoading, false);
  //     futureManager.refresh(reloading: true);
  //     expect(futureManager.isLoading, true);
  //   });
  //   expect(futureManager.isLoading, false);
  // });
}
