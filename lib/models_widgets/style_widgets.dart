// This file contains style related widgets

import 'package:flutter/material.dart';

/// Flameo white button style
ButtonStyle whiteButtonStyle(BuildContext context) => ButtonStyle(
  elevation: MaterialStateProperty.all(0.0),
  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onSecondary),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0)
    )
  )
);

/// Rounded corner box decoration for containers
BoxDecoration containerDecoration(Color color, double borderRadius) => BoxDecoration(
  color: color,
  borderRadius:  BorderRadius.all(Radius.circular(borderRadius))
);