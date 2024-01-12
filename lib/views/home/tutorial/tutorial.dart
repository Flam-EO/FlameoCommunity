import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/views/home/tutorial/dashboard_tutorial.dart';
import 'package:flameo/views/home/tutorial/panel_tutorial.dart';
import 'package:flameo/views/home/tutorial/sales_tutorial.dart';
import 'package:flameo/views/home/tutorial/start.dart';
import 'package:flutter/material.dart';

class Tutorial extends StatefulWidget {

  final ClientUser user;
  final ConfigProvider config;
  final Function(String) goToDrawer;

  const Tutorial({super.key, required this.user, required this.goToDrawer, required this.config});

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {

  bool showButtons = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () => setState(() => showButtons = true));
  }
  int currentStep = 0;
  void next() => setState(() {
    currentStep++;
    switch (currentStep) {
      case 1:
        widget.goToDrawer('resumen');
        break;
      case 2:
        widget.goToDrawer('ventas');
        break;
      case 3:
        widget.goToDrawer('panel');
        break;
      default:
    }
  });

  @override
  Widget build(BuildContext context) {

    List<Widget> steps = [
      StartTutorial(startFunction: next),
      const DashboardTutorial(),
      const SalesTutorial(),
      PanelTutorial(finish: () => widget.user.finishTutorial(widget.config))
    ];

    return Stack(
      children: [
        Container(
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(150)
        ),
        steps[currentStep],
        showButtons ? Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () => widget.user.finishTutorial(widget.config),
              child: const Text(
                'Saltar',
                style: TextStyle(color: Colors.white, fontSize: 15)
              )
            )
          )
        ) : const SizedBox(),
        showButtons && currentStep < steps.length - 1 ? Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: next,
              child: const Text(
                'Siguiente',
                style: TextStyle(color: Colors.white, fontSize: 15)
              )
            )
          )
        ) : const SizedBox()
      ]
    );
  }
}