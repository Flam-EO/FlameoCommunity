import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HostPlatform {

  // All the information about the platform

  bool isMobile = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;
  bool isComputer = defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows;
  late bool isWeb;

  HostPlatform() {
    isWeb = !isMobile && !isComputer;
  }

}

class ScreenSize {

  // Screen size utils

  final BuildContext context;

  ScreenSize(this.context);

  // The App Bar height needs to be considered
  final appBarHeight = AppBar().preferredSize.height;
  double get height => MediaQuery.of(context).size.height - appBarHeight;
  double get width => MediaQuery.of(context).size.width;
  EdgeInsets get padding => MediaQuery.of(context).padding;
  double get aspectRatio => MediaQuery.of(context).size.aspectRatio;
}

