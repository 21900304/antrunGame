import 'package:flutter/material.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Image.asset(
        'assets/images/ant_cute.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
