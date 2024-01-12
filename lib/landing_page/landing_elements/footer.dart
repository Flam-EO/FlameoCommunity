import 'package:flameo/landing_page/policies/privacy.dart';
import 'package:flameo/landing_page/policies/terms.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  static const TextStyle italicStyle = TextStyle(color: Color.fromARGB(200, 255, 255, 255), fontSize: 12, fontStyle: FontStyle.italic);
  static const TextStyle termsStyle = TextStyle(color: Color.fromARGB(200, 255, 255, 255), fontSize: 10, );
  @override
  Widget build(BuildContext context) {
    ScreenSize screensize = ScreenSize(context);
    return Container(
      padding: const EdgeInsets.all(8),
      width: screensize.width,
      height: screensize.height * 0.18,
      color: const Color.fromARGB(255, 64, 67, 70),
      child: Stack(
        
        children: [
         
          Positioned(right: 0,
            child: SizedBox(height: screensize.height*0.15,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Powered by ",
                        style: TextStyle(color: Color.fromARGB(200, 255, 255, 255), fontSize: 12)
                      ),
                      Text(
                        "GPW",
                        style: italicStyle
                      )
                    ]
                  ),
                  Text(
                    "Digitalizing &  Data Science services",
                    style: italicStyle
                  ),
                  SelectableText(
                    "info@flameoapp.com",
                    style: italicStyle
                  )
                ]
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Privacy())
                ),
                child: const Text(
                  'Política de privacidad',
                  style: TextStyle(color: Color.fromARGB(200, 255, 255, 255), fontSize: 10),
                )
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Terms())
                ),
                child: const Text(
                  'Términos y condiciones',
                  style: TextStyle(color: Color.fromARGB(200, 255, 255, 255), fontSize: 10),
                )
              )
            ]
          )
        ]
      )
    );
  }
}
