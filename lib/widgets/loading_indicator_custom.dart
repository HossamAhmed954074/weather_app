import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingIndicatorCustom extends StatelessWidget {
  const LoadingIndicatorCustom({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: LoadingIndicator(
          indicatorType: Indicator.ballClipRotatePulse,
          colors: [Colors.redAccent, Colors.cyanAccent],
        ),
      ),
    );
  }
}