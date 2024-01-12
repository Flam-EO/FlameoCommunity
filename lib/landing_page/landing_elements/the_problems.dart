import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class TheProblems extends StatelessWidget {
  const TheProblems({super.key});

  @override
  Widget build(BuildContext context) {
     ScreenSize screensize = ScreenSize(context);
    bool wideScreen = screensize.aspectRatio > 1.2;
     double textFontSize = wideScreen ? 32: 21;
    return Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 45.0, right: 45),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Me gustaría tener mi propia web ',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize)),
                         TextSpan(
                        text: 'sin depender de nadie.\n\n ',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight:FontWeight.bold )),
                    TextSpan(
                        text: 'No sé ',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize)),
                          TextSpan(
                        text: 'nada ',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight:FontWeight.bold)),
                          TextSpan(
                        text: 'de informática.\n\n ',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize)),
                    TextSpan(
                        text: 'No tengo tiempo ',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize,  fontWeight:FontWeight.bold)),
                         TextSpan(
                        text: 'ni capacidad para vender por internet.\n\n ',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize)),
                    TextSpan(
                        text: '1000 euros ',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight:FontWeight.bold)),
                        TextSpan(
                        text: 'por una web es inasumible. \n\n',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize)),
                    TextSpan(
                        text: 'No quiero una ',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize)),
                                  TextSpan(
                        text: 'cuota de mantenimiento. \n\n',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight:FontWeight.bold)),
                    TextSpan(
                        text: 'Montar un e-commerce con una ',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize)),
                        TextSpan(
                        text: 'pasarela de pagos ',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize,  fontWeight:FontWeight.bold)),
                        TextSpan(
                        text: 'es un laberinto \n\n',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize)),
                         TextSpan(
                        text: '...',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize)),
                  ],
                ),
              ),
            );
  }
}