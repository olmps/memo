import 'package:flutter/material.dart';
import 'package:memo/application/constants/images.dart' as images;

const _splashBackgroundColor = Color(0xFF1F1D28); // classic theme - neutralSwatch.shade900

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _splashBackgroundColor,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: Image.asset(images.logoAsset),
        ),
      ),
    );
  }
}
