import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';
import 'package:seo/seo.dart';

class TitleArt extends StatelessWidget {

  const TitleArt({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenSize screenSize = ScreenSize(context);
    double fontSize = screenSize.aspectRatio > 1.2 ? 80 : 50;
    double logoSize = screenSize.aspectRatio > 1.2 ? 90 : 60;
    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: <InlineSpan>[
          WidgetSpan(
            child: Image.asset('imgs/logo.png', width: logoSize)
          ),
            TextSpan(
            text: '\nCrea ',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'tu propia \ngalería ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary, fontSize: fontSize),
          ),
            TextSpan(
            text: 'online',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '\n',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 40.0, fontWeight: FontWeight.normal),
          ),
          WidgetSpan(child:
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0.0),
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                    )
                  )
                ),
                onPressed: () { Navigator.pushNamed(context, '/registro'); },
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Registrarse',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                    )
                  )
                )
              ),
            ),
          ),
          TextSpan(
            text: '\n¡Visita nuestra galería!\n',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 40.0, fontWeight: FontWeight.normal),
          ),
          WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/gallery");
                },
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0.0),
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onBackground),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                    )
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Seo.text(
                    text: 'Galeria online, compra tu arte online. Obras de arte de artistas emergentes. Online Gallery',
                    child:  Text("Visita las obras de nuestros artistas",
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.tertiary
                      )
                    )
                  )
                )
              )
            )
          )
        ]
      )
    );
  }
}
