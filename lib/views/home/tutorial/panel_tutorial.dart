import 'package:flutter/material.dart';

class PanelTutorial extends StatefulWidget {

  final VoidCallback finish;

  const PanelTutorial({super.key, required this.finish});

  @override
  State<PanelTutorial> createState() => _PanelTutorialState();
}

class _PanelTutorialState extends State<PanelTutorial> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(child: Text('Tutorial del panel', style: TextStyle(color: Colors.white))),
        ElevatedButton(onPressed: widget.finish, child: const Text('Comenzar a vender'))
      ],
    );
  }
}