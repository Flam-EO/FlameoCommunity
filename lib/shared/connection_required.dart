import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectionRequired extends StatefulWidget {

  final Widget child;
  const ConnectionRequired({super.key, required this.child});

  @override
  State<ConnectionRequired> createState() => _ConnectionRequiredState();
}

class _ConnectionRequiredState extends State<ConnectionRequired> {

  bool thereIsInternet = true;
  late StreamSubscription subscription;
  @override
  void initState() {
    Connectivity().checkConnectivity().then((ConnectivityResult result) {
      if (result == ConnectivityResult.none) setState(() => thereIsInternet = false);
    });
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() => thereIsInternet = false);
      } else if (!thereIsInternet) {
        setState(() => thereIsInternet = true);
      }
    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return thereIsInternet ? widget.child : const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 100),
            Text('No tienes conexión a internet'),
          ]
        )
      )
    );
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }
}