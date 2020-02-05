
import 'package:flutter/material.dart';

enum ScreenSize {
  small, medium, large 
}

ScreenSize getScreenSizeFrom(BuildContext context) {
    // one issue is four columns
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSize.small;
    } else if (width < 960) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }