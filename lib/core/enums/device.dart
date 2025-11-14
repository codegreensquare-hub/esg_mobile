// Enhanced enum with an intrinsic breakpoint value per device size.
import 'package:esg_mobile/core/config/breakpoints.dart';

enum Device {
  smallMobile,
  largeMobile,
  smallTablet,
  largeTablet,
  smallDesktop,
  largeDesktop;

  double get breakpoint => breakpoints[this]!;
}
