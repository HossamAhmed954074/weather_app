import 'package:flutter/material.dart';

class NoWeatherBody extends StatelessWidget {
  const NoWeatherBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
      Text(
        'There Is No Weather 🙁',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      Text(
        'Start Searching Now 🔍',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
              ],
            ),
    );
  }
}
