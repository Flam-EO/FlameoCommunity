import 'package:flutter/material.dart';

class TheConceptOfArt extends StatefulWidget {
  const TheConceptOfArt({super.key});

  @override
  State<TheConceptOfArt> createState() => _TheConceptOfArtState();
}

class _TheConceptOfArtState extends State<TheConceptOfArt> {
  @override
  Widget build(BuildContext context) {

    double textFontSize = 13;
    return RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: <TextSpan>[
            TextSpan(
                text: 'Se equivocan aquellos que piensan en el arte con un motivo meramente estético. Indudablemente lo es, desde que el ser humano '
                      'toma consciencia de si mismo  ha intentado transcender, ir más allá.\n\n'
                      'Es en ese viaje hacia lo desconocido donde nace el sentido de apreciación estética. Lo bonito frente a lo feo, lo elegante frente a vulgar, '
                      'lo sublime frente a lo mundano.\n\n'
                      'Pero el arte trasciende lo meramente "bonito". Se subestima su capacidad de cambiar la realidad que le rodea reflejando la realidad vivida del artista. El arte puede y debe ser un ente transformador como el ser humano lo es.\n\n'
                      ,
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight: FontWeight.normal)
            ),
            TextSpan(
                text: 'En Flameoart creemos que la mejor manera de conseguir potenciar el arte a su máxima expresión en este siglo es proveerlo de una plataforma que sea'
                      ' un sitio de reunión de artistas independientes. Queremos ofrecer a cualquier artista un sitio en internet donde expresarse, '
                      ' enseñar sus obras y poder venderlas. Esta galería es la prueba de que realizar ese proyecto es posible.\n\n'
                      'Nadie elige al próximo Van Gogh, simplemente',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight: FontWeight.normal)
            ),
            TextSpan(
                text: ' aparece.\n\n',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight: FontWeight.bold)
            ),
            TextSpan(
                text: 'Atentamente, a tí que creas\n\n',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight: FontWeight.normal, )
            ),

             TextSpan(
                text: 'FLAMEOART',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize, fontWeight: FontWeight.bold, letterSpacing: 3, )
            )
          ],
        ),
      );
  }
}