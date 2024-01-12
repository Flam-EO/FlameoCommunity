import 'package:flameo/landing_page/landing_elements/feature.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class FeatureCarrousel extends StatelessWidget {
  const FeatureCarrousel({super.key});

  @override
  Widget build(BuildContext context) {

    ScreenSize screensize = ScreenSize(context);

    String imageFolderName = screensize.aspectRatio > 1.2
    ? 'carrousel_art_computer'
    : 'carrousel_art_phone';

    List<String> paths = [
      'imgs/$imageFolderName/1.png',
      'imgs/$imageFolderName/2.png',
      'imgs/$imageFolderName/3.png',
      'imgs/$imageFolderName/4.png',
      'imgs/$imageFolderName/5.png',
      'imgs/$imageFolderName/6.png',
      'imgs/$imageFolderName/7.png'
    ];

    return Container(
      color: const Color.fromARGB(255, 31, 32, 35),
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Text('Tú pones la creatividad y el esfuerzo', style: TextStyle(fontSize: 35, color: Colors.white),),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 50.0),
              child: Text('Nosotros ponemos los medios', style: TextStyle(fontSize: 35, color: Colors.white),),
            ),
            CarouselSlider(
              items: paths.map((path) => Feature(path: path)).toList(),
              options: CarouselOptions(
                height: 500,
                viewportFraction: screensize.aspectRatio > 1.2 ? 0.5 : 1,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(seconds: 5),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                scrollDirection: Axis.horizontal,
              )
            ),
          ],
        ),
      ),
    );
  }
}