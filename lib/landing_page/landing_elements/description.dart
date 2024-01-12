import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class Description extends StatelessWidget {
  const Description({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenSize screensize = ScreenSize(context);
    bool wideScreen = screensize.aspectRatio > 1.2;
    double textFontSize = wideScreen ? 32 : 21;
    return Padding(
      padding: const EdgeInsets.only(left: 45.0, right: 45, top: 25.0, bottom: 25.0),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: <TextSpan>[

            TextSpan(
                text:
                    'Cualquier persona, empresa ',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight: FontWeight.bold)),
            TextSpan(
                text:
                    'con un proyecto puede llevarlo a internet. \n\n ',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize)),
               
              
                TextSpan(
                text:
                    'Comparte tu código QR, dale ',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize)),
                TextSpan(
                text:
                    'otra dimensión a tu proyecto',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
