import 'package:flutter/material.dart';

class DashboardTutorial extends StatefulWidget {
  const DashboardTutorial({super.key});

  @override
  State<DashboardTutorial> createState() => _DashboardTutorialState();
}

class _DashboardTutorialState extends State<DashboardTutorial> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tutorial del dashboard', style: TextStyle(color: Colors.white)));
  }
}