import 'package:flutter/material.dart';

class SalesTutorial extends StatefulWidget {
  const SalesTutorial({super.key});

  @override
  State<SalesTutorial> createState() => _SalesTutorialState();
}

class _SalesTutorialState extends State<SalesTutorial> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tutorial de ventas', style: TextStyle(color: Colors.white)));
  }
}