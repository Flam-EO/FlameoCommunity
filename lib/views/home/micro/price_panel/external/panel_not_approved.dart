import 'package:flutter/material.dart';

class PanelNotApproved extends StatelessWidget {

  final String companyName;
  const PanelNotApproved({super.key, required this.companyName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Próxima apertura",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  color: Theme.of(context).colorScheme.onTertiary,
                )
              ),
              Text(
                "En breve podrás ver aquí la tienda online de",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.onTertiary,
                )
              ),
              Text(
                companyName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 58,
                  color: Theme.of(context).colorScheme.secondary,
                )
              ),
              Text(
                "Te esperamos muy pronto!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.onTertiary,
                )
              )
            ]
          )
        )
      )
    );
  }
}