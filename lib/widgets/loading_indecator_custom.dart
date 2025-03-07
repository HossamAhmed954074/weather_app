import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingIndecatorCustom extends StatelessWidget {
  const LoadingIndecatorCustom({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: LoadingIndicator(
          indicatorType: Indicator.ballSpinFadeLoader,
        
          /// Required, The loading type of the widget
          colors: const [
            Color.fromARGB(255, 230, 117, 117),
            Color.fromARGB(255, 117, 230, 126),
            Color.fromARGB(255, 151, 66, 113),
            Color.fromARGB(255, 108, 159, 252),
          ],
        
          /// Optional, The color collections
          strokeWidth: 2,
        
          /// Optional, The stroke of the line, only applicable to widget which contains line
        ),
      ),
    );
  }
}
