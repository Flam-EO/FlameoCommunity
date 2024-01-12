import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class CompanyTitle extends StatelessWidget {

  final bool isArtEnv;

  const CompanyTitle({super.key, required this.isArtEnv});


  @override
  Widget build(BuildContext context) {
    ScreenSize screensize = ScreenSize(context);
    bool wideScreen = screensize.aspectRatio > 1.2;
    return  RichText(
      textAlign: TextAlign.right,
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: <TextSpan>[
          TextSpan(
            text: 'Flameo', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: wideScreen? 45: 25)
          ),
          TextSpan(
            text: isArtEnv ? 'Art' : 'App',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontStyle: FontStyle.italic, fontSize: wideScreen? 45: 25)
          ),
        ],
      ),
    );
  }
}