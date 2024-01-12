import 'package:flameo/landing_page/landing_elements/photos_grid/element.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class PhotosGrid extends StatelessWidget {
  const PhotosGrid({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenSize screensize = ScreenSize(context);
    bool wideScreen = screensize.aspectRatio > 1.2;

    double textFontSize = wideScreen ? 17 : 13;
    final List photos = [
      'imgs/marketing/external.PNG',
      'imgs/marketing/products.PNG',
      'imgs/marketing/payments.PNG',
      'imgs/marketing/qr.PNG',
      'imgs/marketing/tickets.PNG',
      'imgs/marketing/transactions.PNG'
    ];
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.only(top: 30, left: 10, right: 50, bottom: 30),
        child: Column(
          children: [
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: wideScreen ? 3 : 1,
              children: photos.map((e) => ElementLanding(imagePath: e)).toList(),
            ),
            Row(
              children: [
                Text("Te hacemos una demo:",
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: textFontSize)),
              ],
            ),
            Row(
              children: [
                SelectableText(
                  "info@flameoapp.com",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: textFontSize + 6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
