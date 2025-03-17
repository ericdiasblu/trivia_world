import 'package:flutter/material.dart';

class BuildTheme extends StatelessWidget {
  final AssetImage image;
  final String themeName;

  const BuildTheme({super.key, required this.image, required this.themeName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadiusDirectional.all(Radius.circular(10)),
        ),
        width: 120,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: image, height: 50, width: 50),
            Text(
              themeName,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
