import 'package:db_navigator/db_navigator.dart';
import 'package:example/src/example_app.dart';
import 'package:example/src/home_page_builder.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    ExampleApp(
      initialPage: HomePageBuilder.initialPage,
      pageBuilders: <DBPageBuilder>[HomePageBuilder()],
    ),
  );
}
