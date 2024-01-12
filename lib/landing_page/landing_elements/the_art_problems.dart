import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class TheArtProblems extends StatelessWidget {
  const TheArtProblems({super.key});

  @override
  Widget build(BuildContext context) {
     ScreenSize screensize = ScreenSize(context);
    bool wideScreen = screensize.aspectRatio > 1.2;
     double textFontSize = wideScreen? 32: 21;
    return Padding(
              padding: const EdgeInsets.only(left: 45.0, right: 45, top: 15),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Ganarse la vida como artista es muy difícil:\n\n',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize)
                    ),
                    TextSpan(
                      text: 'Tú ',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight:FontWeight.bold)
                    ),
                    TextSpan(
                      text: 'pones la creatividad y el esfuerzo.\n\n',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight:FontWeight.normal)
                    ),
                    TextSpan(
                      text: 'Pero no puedes encontrar una galería que acceda a exponer tu arte;\n\n',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight:FontWeight.normal)
                    ),
                    TextSpan(
                      text: 'y si tienes la suerte de hacerlo, ésta te cobra comisiones de hasta el 50%\n\n',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight:FontWeight.normal)
                    ),
                  ],
                ),
              ),
            );
  }
}