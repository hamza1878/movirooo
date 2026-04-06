import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

Widget darkModeTileBuilder(
  BuildContext context,
  Widget tileWidget,
  TileImage tile,
) {
  return ColorFiltered(
    colorFilter: const ColorFilter.matrix(<double>[
      0.15,
      0.00,
      0.25,
      0.00,
      0,
      0.05,
      0.05,
      0.20,
      0.00,
      0,
      0.20,
      0.05,
      0.45,
      0.00,
      0,
      0.00,
      0.00,
      0.00,
      1.00,
      0,
    ]),
    child: tileWidget,
  );
}
