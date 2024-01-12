import 'package:flutter/material.dart';

class ProductTitlesRow extends StatelessWidget {

  final bool layoutIsWide;

  const ProductTitlesRow({super.key,
                          required this.layoutIsWide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    width: 1,
                  ),
                ),
                color: Theme.of(context).colorScheme.secondary
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: layoutIsWide
                ? Row(
                  children: [
                    Text('Imagen', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(width: 40),
                    Text('Nombre del producto', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(width: 180),
                    Text('Cantidad', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(width: 27),
                    Text('Precio/ud', style: Theme.of(context).textTheme.labelMedium),
                    const Expanded(child: SizedBox()),
                    Text('Total', style: Theme.of(context).textTheme.labelMedium),
                  ],
                )
                : Row(
                  children: [
                    Text('Producto', style: Theme.of(context).textTheme.labelMedium),
                    const Expanded(child: SizedBox()),
                    Text('Total', style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
            ),
    );
  }
}