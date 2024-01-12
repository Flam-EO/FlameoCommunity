import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class ArtDescription extends StatelessWidget {
  const ArtDescription({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenSize screensize = ScreenSize(context);
    bool wideScreen = screensize.aspectRatio > 1.2;
    double textFontSize = wideScreen ? 32 : 21;
    return Padding(
      padding: const EdgeInsets.only(left: 45.0, right: 45, top: 25),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: <TextSpan>[
            TextSpan(
                text: 'Con flameo es mucho más fácil:\n\n',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight: FontWeight.normal)
            ),
            TextSpan(
                text: 'Promociona y vende tu arte en ',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight: FontWeight.normal)
            ),
            TextSpan(
                text: 'tu propia página web\n\n',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight: FontWeight.bold)
            ),
            TextSpan(
                text: '¡Ahí fuera hay personas interesadas en adquirir tus obras!\n\n',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight: FontWeight.normal)
            ),
            TextSpan(
                text: '¿A qué esperas?\n\n',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight: FontWeight.normal)
            ),
          ],
        ),
      ),
    );
  }
}
