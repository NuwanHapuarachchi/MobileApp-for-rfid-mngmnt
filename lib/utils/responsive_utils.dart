import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isTabletLandscape(BuildContext context) {
    return isTablet(context) && isLandscape(context);
  }

  static bool isMobileLandscape(BuildContext context) {
    return isMobile(context) && isLandscape(context);
  }

  // Get appropriate cross axis count for grid layouts
  static int getGridCrossAxisCount(
    BuildContext context, {
    int mobileCount = 1,
    int tabletPortraitCount = 2,
    int tabletLandscapeCount = 3,
    int desktopCount = 4,
  }) {
    if (isDesktop(context)) return desktopCount;
    if (isTabletLandscape(context)) return tabletLandscapeCount;
    if (isTablet(context)) return tabletPortraitCount;
    return mobileCount;
  }

  // Get appropriate padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(24.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  // Get appropriate card width for different screen sizes
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isDesktop(context)) {
      return screenWidth * 0.25; // 25% of screen width
    } else if (isTabletLandscape(context)) {
      return screenWidth * 0.3; // 30% of screen width
    } else if (isTablet(context)) {
      return screenWidth * 0.45; // 45% of screen width
    } else {
      return screenWidth * 0.9; // 90% of screen width for mobile
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) {
      return baseSize * 1.2;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize;
    }
  }

  // Get appropriate spacing based on screen size
  static double getSpacing(
    BuildContext context, {
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  // Check if we should use single column layout
  static bool shouldUseSingleColumn(BuildContext context) {
    return isMobile(context) || (isTablet(context) && isPortrait(context));
  }

  // Get appropriate height for containers
  static double getContainerHeight(
    BuildContext context, {
    double mobile = 120.0,
    double tablet = 140.0,
    double desktop = 160.0,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  // Get layout direction for responsive layouts
  static Axis getLayoutDirection(BuildContext context) {
    if (isTabletLandscape(context) || isDesktop(context)) {
      return Axis.horizontal;
    }
    return Axis.vertical;
  }

  // Get appropriate sidebar width
  static double getSidebarWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isDesktop(context)) {
      return 280.0;
    } else if (isTabletLandscape(context)) {
      return screenWidth * 0.25;
    } else {
      return screenWidth * 0.8; // Full width drawer for mobile/tablet portrait
    }
  }

  // Check if we should show sidebar as drawer or permanent
  static bool shouldUseDrawer(BuildContext context) {
    return !isDesktop(context);
  }

  // Get appropriate app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isTablet(context) || isDesktop(context)) {
      return 70.0;
    }
    return 56.0; // Default height for mobile
  }
}
