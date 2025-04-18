import 'package:flutter/material.dart';

class AppColors {
  static final dark = Colors.red;
  static final light = Colors.green;
  static final darkCard = Colors.amberAccent;
  static final lightCard = Colors.cyanAccent;
}

class AppThemes {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.light,
    brightness: Brightness.light,
     pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          },
        ),
  );

  static final darkTheme = ThemeData(
    primaryColor: AppColors.dark,
    brightness: Brightness.dark,
     pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          },
        ),
  );
}


