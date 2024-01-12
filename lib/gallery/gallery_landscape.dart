import 'package:carousel_slider/carousel_slider.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:html' as html;

class GalleryLandscape extends StatefulWidget {

  final  double expandedAppBarHeight;
  const GalleryLandscape({super.key, required this.expandedAppBarHeight});

  @override
  State<GalleryLandscape> createState() => _GalleryLandscapeState();
}

class _GalleryLandscapeState extends State<GalleryLandscape> {

  
  @override
  Widget build(BuildContext context) {
    double upperBannerHeight = 40;
    
    ScreenSize screenSize = ScreenSize(context);
    
    return Column(children: [
      Container(color: Theme.of(context).colorScheme.primary,height: upperBannerHeight,
      child: Stack(
        children:
        [ if (screenSize.aspectRatio > 1.2 )Padding(
          padding: const EdgeInsets.only(left:10.0),
          child: Align(alignment: Alignment.centerLeft,
            child: Text("FLAMEOART", style: GoogleFonts.lora(//Lo dejo puesto por si algun día nos hace falta.
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    letterSpacing: 3
                  ),
                ),),
          ),
        ),
                  CarouselSlider(
                      items: const  [CarouselText(content: "Somos la galería de artistas independientes"), 
                                    CarouselText(content: "Cada 64 minutos se registra un artista nuevo en FlameoArt"),
                                    CarouselText(content: "Nadie elige al próximo Van Gogh, simplemente emerge",),
                                    CarouselText(content: "Cuando compras un cuadro, transferimos el dinero directamente al artista",),
                                    CarouselText(content: "Si eres artista y quieres aparecer en esta galería, regístrate en flameoart.com de forma gratuita y sube tus obras",),
                                    CarouselText(content: "Si necesitas más información contáctanos en info@flameoapp.com",)],
                      options: CarouselOptions(
                        height:upperBannerHeight,
                        viewportFraction: 1,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 8),
                        autoPlayAnimationDuration: const Duration(seconds: 3),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: false,
                        scrollDirection: Axis.vertical,
                      )
                    )],
      ),),
      Stack(children: [
        Image.asset('imgs/bodegon.png', fit: BoxFit.cover, width: screenSize.width,height: widget.expandedAppBarHeight - upperBannerHeight,filterQuality: FilterQuality.high,),
        Container(color: Colors.black.withOpacity(0.4),width: screenSize.width,height: widget.expandedAppBarHeight - upperBannerHeight,),
         Positioned(
          left: 0,
          child: Padding(
            padding: const EdgeInsets.only(left:15.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("FlameoArt", style: TextStyle(color: Colors.white, fontSize: 70),),
                RichText(text:  TextSpan( style: Theme.of(context).textTheme.bodyMedium,
          
                          children: const [TextSpan(text:"Una galería para artistas",style: TextStyle(color: Colors.white, fontSize: 16)),
                                           TextSpan(text:" emergentes",style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                           ])),
              ],
            ),
          ))
          ,
          Positioned(
            bottom: 10,
            left:10,
            child: SizedBox(
              width: 300,
              child: Row(
                children: [
                  const Text("¿Eres un artista?",
                    style: TextStyle(color: Colors.white, fontSize: 15)
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: mejorar esto. Es para que funcione con subdominio de momento
                      const String url = "https://flameoart.com";
                      html.window.location.href = url;
                    },
                    child: const Text("Regístrate aquí",
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)
                    )
                  )
                ],
              )
            )
          )
        ]
      )
    ],);
  }
}


class CarouselText extends StatefulWidget {
  final String content;
  
  const CarouselText({super.key, required this.content});

  @override
  State<CarouselText> createState() => _CarouselTextState();
}

class _CarouselTextState extends State<CarouselText> {
  @override
  Widget build(BuildContext context) {
    const TextStyle upperBannerTextStyle = TextStyle(color: Colors.white, fontSize: 11);
    return  Align(alignment: Alignment.center,child: Text(widget.content.toUpperCase(), style: upperBannerTextStyle,));
  }
}