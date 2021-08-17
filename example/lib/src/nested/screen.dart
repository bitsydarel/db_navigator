import 'package:db_navigator/db_navigator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
class Screen extends StatelessWidget {
  ///
  final int index;

  ///
  const Screen({required this.index, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DBRouterDelegate delegate = DBRouterDelegate.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () {
          DBRouterDelegate.of(context, root: true).close();
        }),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              'Screen $index',
              style: const TextStyle(fontSize: 35),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: index > 0 ? delegate.close : null,
                child: const Text('Previous'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => delegate.navigateTo(
                  location: '/screen',
                  arguments: delegate.pages.length,
                ),
                child: const Text('Next'),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<int>('index', index));
  }
}
