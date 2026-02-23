import 'package:flutter/material.dart';

typedef LibraryLoader = Future<void> Function();
typedef DeferredWidgetBuilder = Widget Function();

/// A widget that loads a library asynchronously and then builds a widget
/// that depends on that library.
///
/// This is used for "Deferred Loading" to reduce initial bundle size.
class DeferredWidget extends StatefulWidget {
  final LibraryLoader loader;
  final DeferredWidgetBuilder builder;
  final Widget? placeholder;

  const DeferredWidget({
    super.key,
    required this.loader,
    required this.builder,
    this.placeholder,
  });

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  Future<void>? _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading page: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _future = widget.loader();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return widget.builder();
        }
        return widget.placeholder ??
            const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
