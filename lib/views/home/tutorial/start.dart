import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class StartTutorial extends StatefulWidget {

  final VoidCallback startFunction;

  const StartTutorial({super.key, required this.startFunction});

  @override
  State<StartTutorial> createState() => _StartTutorialState();
}

class _StartTutorialState extends State<StartTutorial> {

  void safeSetState(f) {
    if (mounted) setState(f);
  }

  bool secondText = false;
  bool showStart = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () => safeSetState(() => secondText = true));
    Future.delayed(const Duration(milliseconds: 8000), () => safeSetState(() => showStart = true));
  }

  @override
  Widget build(BuildContext context) {
    
    Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        SizedBox(
          height: size.height * 0.2,
          child: Center(
            child: AnimatedTextKit(
              animatedTexts: [
                RotateAnimatedText(
                  'Bienvenido a FlameoAPP',
                  textStyle: const TextStyle(
                    fontSize: 42.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                  duration: const Duration(milliseconds: 1000),
                  rotateOut: false
                )
              ],
              totalRepeatCount: 1,
              pause: const Duration(milliseconds: 500),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            )
          )
        ),
        secondText ? SizedBox(
          height: size.height * 0.3,
          width: size.width * 0.7,
          child: Center(
            child: AnimatedTextKit(
              animatedTexts: [
                FadeAnimatedText(
                  'En este tutorial aprenderás las funcionalidades básicas de la aplicación. '
                  'Puedes saltar este tutorial en cualquier momento o ir a la siguiente pantalla'
                  ' usando los botones de la parte inferior.',
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                  fadeInEnd: 0.001,
                  fadeOutBegin: 0.99,
                  duration: const Duration(seconds: 1000)
                )
              ],
              totalRepeatCount: 1,
              pause: const Duration(milliseconds: 500),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            )
          )
        ) : const SizedBox(),
        showStart ? ElevatedButton(
          onPressed: widget.startFunction,
          child: const Text('Comenzar')
        ) : const SizedBox()
      ]
    );
  }
}