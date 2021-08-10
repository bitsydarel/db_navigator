import 'package:flutter/material.dart';

/// Regular demo screen.
class RegularDemo extends StatelessWidget {
  /// Navigation path of the [RegularDemo].
  static const String path = '/regular';

  /// Create a [RegularDemo] in a const expression.
  const RegularDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: const Placeholder(),
    );
  }
}
