import 'package:flameo/models/userproduct.dart';
import 'package:flutter/material.dart';

class PunctuationSelector extends StatefulWidget {

  final UserProduct product;

  const PunctuationSelector({super.key,required this.product});

  @override
  State<PunctuationSelector> createState() => _PunctuationSelectorState();
}

class _PunctuationSelectorState extends State<PunctuationSelector> {

  late TextEditingController punctuationController = TextEditingController(
    text: widget.product.galleryPunctuation == null
    ? '0'
    : '${widget.product.galleryPunctuation}'
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (widget.product.galleryPunctuation == null)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Esta obra no está puntuada.'),
            ),
          if (widget.product.galleryPunctuation != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Puntuación actual de la obra: ${widget.product.galleryPunctuation}'),
            ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Asignar puntuación: '),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.5, style: BorderStyle.none),
                  borderRadius: BorderRadius.all(Radius.circular(15.0))
                ),
              ),
              keyboardType: TextInputType.number,
              controller: punctuationController,
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    widget.product.setGalleryPunctuation(int.parse(punctuationController.text))
                    .then((_) => setState(() {}));
                    Navigator.of(context).pop();
                  },
                  child: const Text('Asignar puntuación')
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    widget.product.removeGalleryPunctuation()
                    .then((_) => setState(() {
                      punctuationController.text = '0';
                    }));
                    Navigator.of(context).pop();
                  },
                  child: const Text('Quitar puntuación')
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}