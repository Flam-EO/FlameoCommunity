import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {

  final double size;
  final Widget? child;
  final dynamic evaluate;
  final dynamic chargingValue;

  const Loading({Key? key, this.size=40, this.child, this.evaluate, this.chargingValue}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return child == null || evaluate == chargingValue ? Center(
      child: SpinKitPulse(
      color: Theme.of(context).colorScheme.primary, size: size)
    ) : child ?? const SizedBox();
  }
}
