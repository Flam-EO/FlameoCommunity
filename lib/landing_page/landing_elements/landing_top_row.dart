import 'package:flameo/landing_page/landing_elements/company_title.dart';
import 'package:flutter/material.dart';

class LandingTopRow extends StatelessWidget {

  final bool isArtEnv;
  final bool layoutIsWide;

  const LandingTopRow({super.key, required this.isArtEnv, required this.layoutIsWide});

  @override
  Widget build(BuildContext context) {
    return layoutIsWide
    ? Padding(
        padding: const EdgeInsets.only(top: 20, left: 60, right: 60),
        child: Row(
          children: [
            CompanyTitle(isArtEnv: isArtEnv),
            const Expanded(child: SizedBox()),
            ElevatedButton(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(0.0),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  )
                )
              ),
              onPressed: () { Navigator.pushNamed(context, '/acceso'); },
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black
                  )
                )
              )
            ),
            const SizedBox(width: 20),
            ElevatedButton(
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
          ],
        ),
      )
    : Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          children: [
            CompanyTitle(isArtEnv: isArtEnv),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0.0),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)
                        )
                      )
                    ),
                    onPressed: () { Navigator.pushNamed(context, '/acceso'); },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black
                        )
                      )
                    )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
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
              ],
            )
          ]
        )
      );
  }
}
