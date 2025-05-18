import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ultrakey_ui/models/utils.dart';

// styling constants

class WidgetRatios {
  static late double defaultTrackThumbSize;
  static late double defaultTrackBorderSize;
  static late double horizontalPadding;
  static late double verticalPadding;

  static late EdgeInsets screenPadding;

  static late double smallIconSize;
  static late double defaultIconSize;
  static late double mediumIconSize;
  static late double largeIconSize;

  static late double fontSize6;
  static late double fontSize8;
  static late double fontSize10;
  static late double fontSize12;
  static late double fontSize14;
  static late double fontSize16;
  static late double fontSize18;
  static late double fontSize20;
  static late double fontSize22;
  static late double fontSize24;

  static const double screenReferenceWidth = 800;
  static const double screenReferenceHeight = 600;

  static void readScreenRatios(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double xRatio = screenWidth / screenReferenceWidth;
    double yRatio = screenHeight / screenReferenceHeight;

    loadWidgetScale(
      xRatio: clampDouble(xRatio, 0.9, 1.7),
      yRatio: clampDouble(yRatio, 1.0, 2.5),
    );
  }

  static EdgeInsets widgetPadding({double scale = 1}) {
    return EdgeInsets.fromLTRB(
      horizontalPadding * scale,
      verticalPadding * scale,
      horizontalPadding * scale,
      verticalPadding * scale,
    );
  }

  static void loadWidgetScale({double xRatio = 1.0, double yRatio = 1.0}) {
    defaultTrackThumbSize = 24;
    defaultTrackBorderSize = 1.2;
    horizontalPadding = 12;
    verticalPadding = 12;

    screenPadding = EdgeInsets.fromLTRB(
      horizontalPadding,
      verticalPadding,
      horizontalPadding,
      verticalPadding,
    );

    smallIconSize = 24;
    defaultIconSize = 28;
    mediumIconSize = 44;
    largeIconSize = 66;

    fontSize6 = 6;
    fontSize8 = 8;
    fontSize10 = 10;
    fontSize12 = 12;
    fontSize14 = 14;
    fontSize16 = 16;
    fontSize18 = 18;
    fontSize20 = 20;
    fontSize22 = 22;
    fontSize24 = 24;
  }
}

class CustomColor {
  static const Color pink = Color.fromARGB(255, 184, 0, 185);
  static const Color purple = Color.fromARGB(255, 132, 0, 185);
}

TextTheme buildTextTheme() {
  TextStyle templateTextStyle = TextStyle(
    letterSpacing: 0,
    overflow: TextOverflow.fade,
    // fontFamily: "NotoSans"
  );

  return TextTheme(
    // body
    titleLarge: templateTextStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: WidgetRatios.fontSize20,
    ),
    titleMedium: templateTextStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: WidgetRatios.fontSize18,
    ),
    titleSmall: templateTextStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: WidgetRatios.fontSize16,
    ),

    // headline
    headlineLarge: templateTextStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: WidgetRatios.fontSize18,
    ),
    headlineMedium: templateTextStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: WidgetRatios.fontSize16,
    ),
    headlineSmall: templateTextStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: WidgetRatios.fontSize14,
    ),

    // body
    bodyLarge: templateTextStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: WidgetRatios.fontSize16,
    ),
    bodyMedium: templateTextStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: WidgetRatios.fontSize14,
    ),
    bodySmall: templateTextStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: WidgetRatios.fontSize12,
    ),

    // label
    labelLarge: templateTextStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: WidgetRatios.fontSize16,
    ),
    labelMedium: templateTextStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: WidgetRatios.fontSize14,
    ),
    labelSmall: templateTextStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: WidgetRatios.fontSize12,
    ),
  );
}

ColorScheme buildDarkScheme() {
  return ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 76, 0, 255),
    brightness: Brightness.dark,
  ).copyWith(
    tertiary: const Color.fromARGB(255, 42, 42, 42),
    primary: Colors.white,
    onPrimary: const Color.fromARGB(255, 15, 15, 15),
    secondary: const Color.fromARGB(255, 56, 198, 243),
    onSecondary: const Color.fromARGB(255, 41, 86, 56),
    errorContainer: const Color.fromARGB(255, 254, 211, 124),
    onErrorContainer: const Color.fromARGB(255, 167, 76, 38),
    primaryContainer: const Color.fromARGB(255, 81, 133, 255),
    error: const Color.fromARGB(255, 241, 91, 34),
    onError: const Color.fromARGB(255, 70, 27, 27),
    onSurface: const Color.fromARGB(255, 194, 194, 194),
    onTertiary: const Color.fromARGB(255, 83, 83, 83),
    surface: const Color.fromARGB(255, 15, 15, 15),
    inverseSurface: Colors.white,
    surfaceTint: const Color.fromARGB(255, 15, 15, 15),
  );
}

ThemeData buildTheme(BuildContext context) {
  WidgetRatios.readScreenRatios(context);

  TextTheme textTheme = buildTextTheme();
  ColorScheme colorsTheme = buildDarkScheme();

  return ThemeData(
    useMaterial3: true,
    splashColor: Colors.transparent,
    fontFamily: "WixFont",

    // colorScheme: colorTheme,
    textTheme: textTheme,
    colorScheme: colorsTheme,

    sliderTheme: SliderThemeData(
      trackHeight: (WidgetRatios.defaultTrackThumbSize / 2),
      thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: WidgetRatios.defaultTrackThumbSize / 2,
          disabledThumbRadius: WidgetRatios.defaultTrackThumbSize / 2,
          elevation: 0,
          pressedElevation: 0),
      overlayShape: const RoundSliderOverlayShape(
        overlayRadius: 30,
      ),
      overlayColor: Colors.transparent,
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, WidgetRatios.defaultIconSize),
        textStyle: textTheme.bodyMedium,
        padding: WidgetRatios.widgetPadding(),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: Size(0, WidgetRatios.defaultIconSize),
        textStyle: textTheme.bodyMedium,
        padding: WidgetRatios.widgetPadding(),
        backgroundColor: colorsTheme.secondary
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        iconSize: WidgetRatios.defaultIconSize
      ),
    ),

    tabBarTheme: TabBarTheme(
      labelColor: colorsTheme.primary,
      labelStyle: textTheme.bodySmall,
      unselectedLabelStyle: textTheme.labelSmall,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      unselectedIconTheme: IconThemeData(
        weight: 100,
        color: colorsTheme.inverseSurface,
        size: WidgetRatios.defaultIconSize,
      ),
      selectedIconTheme: IconThemeData(
        weight: 200,
        color: colorsTheme.primary,
        size: WidgetRatios.defaultIconSize,
      ),
    ),

    iconTheme: IconThemeData(
      weight: 300,
      color: colorsTheme.inverseSurface,
      size: WidgetRatios.defaultIconSize,
    ),

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 10.0),
      isDense: true,
      floatingLabelAlignment: FloatingLabelAlignment.start,
      suffixStyle: textTheme.bodySmall,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(huge),
      ),
    ),

    // Define the default brightness and colors.
  );
}
