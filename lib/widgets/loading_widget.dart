import 'package:flutter/material.dart';

/// A tiny widget to display a loading spinner.  Two variants are
/// supported: `loop` and `search`, corresponding to the original
/// React component.  The spinners are animated GIFs bundled in the
/// `assets` folder via the pubspec.  When the assets cannot be loaded
/// (for example, during development) a `CircularProgressIndicator`
/// fallback is shown.
class LoadingWidget extends StatelessWidget {
  final String variant;

  const LoadingWidget({Key? key, required this.variant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String asset;
    switch (variant) {
      case 'loop':
        asset = 'assets/loopLoadingSpinner.gif';
        break;
      case 'search':
        asset = 'assets/searchLoadingSpinner.gif';
        break;
      default:
        asset = 'assets/loopLoadingSpinner.gif';
        break;
    }
    return SizedBox(
      width: 80,
      height: 80,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to a generic spinner if the GIF fails to load.
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}