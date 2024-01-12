import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class SizeSelector extends StatefulWidget {

  final bool enabled;
  final TextEditingController widthController;
  final TextEditingController heightController;

  const SizeSelector({super.key, required this.enabled, required this.widthController, required this.heightController});

  @override
  State<SizeSelector> createState() => _SizeSelectorState();
}

enum Options {
  square,
  other
}

class _SizeSelectorState extends State<SizeSelector> {

  Options _selectedOption = Options.square;

  @override
  Widget build(BuildContext context) {
    
    if (widget.widthController.text.isNotEmpty && widget.heightController.text.isEmpty) {
      _selectedOption = Options.other;
    }

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text(
                          'Formato cuadrado',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                        leading: Radio<Options>(
                          value: Options.square,
                          groupValue: _selectedOption,
                          onChanged: (Options? value) {
                            setState(() {
                              widget.widthController.clear();
                              widget.heightController.clear();
                              _selectedOption = value!;
                            });
                          }
                        )
                      )
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text(
                          'Otro',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                        leading: Radio<Options>(
                          value: Options.other,
                          groupValue: _selectedOption,
                          onChanged: (Options? value) {
                            setState(() {
                              widget.widthController.clear();
                              widget.heightController.clear();
                              _selectedOption = value!;
                            });
                          }
                        )
                      )
                    )
                  ]
                ),
                Padding(
                  padding:  const EdgeInsets.all(10),
                  child: _selectedOption == Options.square ? Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextFormField(
                            enabled: widget.enabled,
                            controller: widget.widthController,
                            decoration: inputDecoration("Ancho"),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        )
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextFormField(
                            enabled: widget.enabled,
                            controller: widget.heightController,
                            decoration: inputDecoration("Alto"),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        )
                      )
                    ]
                  )
                  : TextFormField(
                    enabled: widget.enabled,
                    controller: widget.widthController,
                    decoration: inputDecoration("Tamaño")
                  )
                )
              ]
            )
          )
        ),
        Positioned(
          top: -5,
          left: 10,
          child: Container(
            color: Theme.of(context).colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Text('Tamaño en centímetros (opcional)')
          )
        )
      ]
    );
  }
}