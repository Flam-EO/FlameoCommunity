import 'package:flameo/landing_page/landing_elements/art_conversation.dart';
import 'package:flameo/landing_page/landing_elements/feature_carousel.dart';
import 'package:flameo/landing_page/landing_elements/footer.dart';
import 'package:flameo/landing_page/landing_elements/landing_top_row.dart';
import 'package:flameo/landing_page/landing_elements/title_art.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class LandingPageArt extends StatefulWidget {
  final ConfigProvider config;
  const LandingPageArt({super.key, required this.config});

  @override
  State<LandingPageArt> createState() => _LandingPageArtState();
}

class _LandingPageArtState extends State<LandingPageArt> {

  @override
  Widget build(BuildContext context) {

    ScreenSize screenSize = ScreenSize(context);

    widget.config.anonymousLog(LoggerAction.landingPage);

    return Scaffold(
      body: SingleChildScrollView(
        child: screenSize.aspectRatio > 1.2
        ? WideLayoutArt(widget: widget)
        : ThinLayoutArt(widget: widget),
      ),
     
    );
  }
}

class WideLayoutArt extends StatelessWidget {

  final LandingPageArt widget;

  const WideLayoutArt({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: const Column(
          children: [
            LandingTopRow(isArtEnv: true, layoutIsWide: true),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 80.0, left: 100.0),
                  child: TitleArt(),
                ),
                Expanded(child: SizedBox()),
                Padding(
                  padding: EdgeInsets.only(top: 100.0),
                  child: ArtConversation(),
                ),
                Expanded(child: SizedBox()),
              ],
            ),
            SizedBox(height: 50),
            FeatureCarrousel(),
            SizedBox(height: 100),
            Footer()
          ]
        ),
    );
  }
}

class ThinLayoutArt extends StatelessWidget {

  final LandingPageArt widget;

  const ThinLayoutArt({super.key, required this.widget});


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: const Column(
          children: [
            LandingTopRow(isArtEnv: true, layoutIsWide: false),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 80.0, left: 20.0),
                  child: TitleArt(),
                ),
                SizedBox(height: 50),
                SizedBox(
                  height: 500,
                  child: ArtConversation()
                ),
              ],
            ),
            SizedBox(height: 50),
            FeatureCarrousel(),
            SizedBox(height: 100),
            Footer()
          ]
        ),
    );
  }
}
