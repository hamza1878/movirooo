import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

Widget darkModeTileBuilder(
  BuildContext context,
  Widget tileWidget,
  TileImage tile,
) {
  return ColorFiltered(
    colorFilter:const ColorFilter.matrix([
  0.10, 0.00, 0.20, 0.00, 0, // Red
  0.00, 0.10, 0.30, 0.00, 0, // Green
  0.10, 0.10, 0.80, 0.00, 0, // Blue 🔥
  0.00, 0.00, 0.00, 1.00, 0, // Alpha
]),
    
    child: tileWidget,
  );
}