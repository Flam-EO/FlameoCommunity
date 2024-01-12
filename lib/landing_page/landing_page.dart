import 'package:flameo/landing_page/landing_elements/company_title.dart';
import 'package:flameo/landing_page/landing_elements/description.dart';
import 'package:flameo/landing_page/landing_elements/footer.dart';
import 'package:flameo/landing_page/landing_elements/landing_top_row.dart';
import 'package:flameo/landing_page/landing_elements/photos_grid/photos_grid.dart';
import 'package:flameo/landing_page/landing_elements/the_problems.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  final ConfigProvider config;
  const LandingPage({super.key, required this.config});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    ScreenSize screenSize = ScreenSize(context);
    widget.config.anonymousLog(LoggerAction.landingPage);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Column(
            children: [
              screenSize.aspectRatio > 1.2
              ? const LandingTopRow(isArtEnv: false, layoutIsWide: true)
              : const LandingTopRow(isArtEnv: false, layoutIsWide: false),
              const TheProblems(),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 15),
                child: Image.asset(
                  'imgs/logo.png',
                  width: 50,
                ),
              ),
              const CompanyTitle(isArtEnv: false),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
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
                        fontSize: 17,
                        color: Colors.white
                      )
                    )
                  )
                ),
              ),
              const Description(),
              const PhotosGrid(),
              const SizedBox(height: 100),
            const Footer()],
          ),
        ),
      ),
    );
  }
}
