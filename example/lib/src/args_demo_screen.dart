import 'package:db_navigator/db_navigator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Result demo screen.
class ArgsDemoScreen extends StatefulWidget {
  /// [ArgsDemoScreen]'s path.
  static const String path = '/result';

  /// Create a new [ArgsDemoScreen].
  const ArgsDemoScreen({this.argument, Key? key}) : super(key: key);

  /// The argument received.
  final String? argument;

  @override
  State<ArgsDemoScreen> createState() => _ArgsDemoScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('argument', argument));
  }
}

class _ArgsDemoScreenState extends State<ArgsDemoScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final List<Widget> content;

    final String? argument = widget.argument;

    if (argument != null) {
      content = <Widget>[
        Center(child: Text('Argument received: $argument')),
      ];
    } else {
      content = <Widget>[
        TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Enter an argument'),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (BuildContext builderContext, TextEditingValue value, _) {
            final String enteredText = value.text;

            return ElevatedButton(
              onPressed: enteredText.isEmpty
                  ? null
                  : () {
                      DBRouterDelegate.of(builderContext).navigateTo(
                        location: ArgsDemoScreen.path + enteredText,
                        arguments: enteredText,
                      );
                    },
              child: const Text('Send'),
            );
          },
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Argument Screen'),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 64),
          ...content,
        ],
      ),
    );
  }
}
