import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/models_widgets/editable_panel_element.dart';
import 'package:flameo/models_widgets/photo_fit_contains.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

/// PanelElement: This widget renders each of the cards in the panel
class PanelElement extends StatefulWidget {

  final UserProduct product;
  final CompanyPreferences? companyPreferences;
  final bool pinnable;

  const PanelElement({super.key, required this.product, required this.companyPreferences, required this.pinnable});

  @override
  State<PanelElement> createState() => _PanelElementState();
}

class _PanelElementState extends State<PanelElement> {

  @override
  void initState() {
    super.initState();
    widget.product.downloadPhotoLinks().then((_) => Future.delayed(Duration.zero, () {
      if (mounted) setState(() {});
    }));
  }

  DateTime _lastSnackbarTimestamp = DateTime.now();

  late RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(0),
      bottomLeft: Radius.circular(8),
      bottomRight: Radius.circular(8)
    ),
    side: BorderSide(
      width: 0.7,
      color: Theme.of(context).colorScheme.outline
    )
  );

  late RoundedRectangleBorder miniCardShape = RoundedRectangleBorder(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(8),
      bottomLeft: Radius.circular(0),
      bottomRight: Radius.circular(0)
    ),
    side: BorderSide(
      width: 0.7,
      color: Theme.of(context).colorScheme.outline
    )
  );

  @override
  Widget build(BuildContext context) {
    ScreenSize screenSize = ScreenSize(context);
    Widget image = PhotoFitContains(photo: widget.product.photos!.first, boxFit: BoxFit.contain, thumbnail: true);

    Widget availabilityInfo = Positioned(
      left: -10,
      bottom: 1,
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        shape: miniCardShape,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "${widget.product.stock} ${widget.product.measureStr} disponibles",
            style: const TextStyle(color: Colors.white)
          )
        )
      )
    );

    Widget activeButton = Positioned(
      right: 10,
      bottom: 5,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(1)
          ),
          child: Column(
            children: [
              Theme(
                data: ThemeData.from(useMaterial3: false, colorScheme: Theme.of(context).colorScheme),
                child: Switch(
                  value: widget.product.active,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    widget.product.changeActive(value);
                    widget.product.setGalleryPunctuation(value ? 1 : 0);
                    if (elapsedTimeChecker(_lastSnackbarTimestamp, 2000) && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          content: Text(value ? 'Producto reactivado' : 'Producto desactivado', textAlign: TextAlign.center),
                          duration: const Duration(seconds: 2),
                        )
                      );
                    }
                    _lastSnackbarTimestamp = DateTime.now();
                  }
                ),
              ),
              Text(widget.product.active ? 'Producto activo' : 'Producto desactivado')
            ]
          )
        )
      )
    );

    Widget deleteButton = Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(1)
        ),
        child: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return StatefulBuilder(builder: (builderContext, setDialogState) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Radio de esquina personalizado
                    ),
                    title: const Text('¿Seguro que quieres borrar el producto?',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: SizedBox(
                            height: screenSize.height * 0.5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: image
                            )
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(widget.product.name)
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(builderContext).pop(),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondary),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                          )
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(fontSize: 12)
                          )
                        )
                      ),
                      TextButton(
                        onPressed: () {
                          widget.product.deleteProduct(widget.companyPreferences);
                          widget.product.setGalleryPunctuation(0);
                          Navigator.of(builderContext).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondary),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
                          )
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Borrar',
                            style: TextStyle(fontSize: 12)
                          )
                        )
                      )
                    ],
                  );
                });
              }
            );
          },
          icon: const Icon(
            Icons.delete,
            color: Color.fromARGB(255, 167, 47, 38)
          )
        )
      )
    );

    Widget pinnedButton = Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(1)
        ),
        child: IconButton(
          icon: Icon(widget.product.pinnedTimestamp != null ? Icons.push_pin : Icons.push_pin_outlined),
          onPressed: () {
            if (widget.product.pinnedTimestamp != null) {
              widget.product.unPin();
            } else if (widget.pinnable) {
              widget.product.pin();
            } else {
              if (elapsedTimeChecker(_lastSnackbarTimestamp, 2000) && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    content: const Text('Solo puedes fijar 3 productos, quita un producto fijado primero', textAlign: TextAlign.center),
                    duration: const Duration(seconds: 2),
                  )
                );
              }
              _lastSnackbarTimestamp = DateTime.now();
            }
          }
        )
      )
    );

    Widget editButton = Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(1)
        ),
        child: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditablePanelElement(
                product: widget.product,
                companyPreferences: widget.companyPreferences!,
              )
            )
          ),
          icon: const Icon(Icons.edit)
        )
      )
    );

    Widget addOneButton = Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(1),
        ),
        child: IconButton(
          onPressed: () => widget.product.addOneToStock(),
          icon: const Icon(
            Icons.plus_one,
            color: Colors.green,
          )
        )
      )
    );

    Widget removeOneButton = Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(1)
        ),
        child: IconButton(
          onPressed: () {
            if (widget.product.stock > 0) {
              widget.product.removeOneFromStock();
            } else {
              if (elapsedTimeChecker(_lastSnackbarTimestamp, 2000) && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    content: const Text('¡No queda stock de ese producto!', textAlign: TextAlign.center),
                    duration: const Duration(seconds: 2),
                  )
                );
              }
              _lastSnackbarTimestamp = DateTime.now();
            }
          },
          icon: const Icon(
            Icons.exposure_minus_1,
            color: Color.fromARGB(255, 172, 76, 175)
          )
        )
      )
    );

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.onSecondary,
      shape: cardShape,
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: AspectRatio(aspectRatio: 1, child: image)
              ),
              if (!widget.product.active) Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.75)
                ),
              ),
              availabilityInfo,
              activeButton,
              Visibility(
                visible: widget.companyPreferences != null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        deleteButton,
                        pinnedButton,
                        editButton
                      ]
                    ),
                    addOneButton,
                    removeOneButton
                  ]
                )
              )
            ]
          ),
          Text(
            widget.product.name,
            style: const TextStyle(fontSize: 15),
            softWrap: true,
            textAlign: TextAlign.center
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.product.priceEuro,
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.center
              )
            ]
          ),
          if (widget.product.description?.isNotEmpty ?? false) Center(
            child: Text(
              widget.product.description!,
              textAlign: TextAlign.center
            )
          ),
          if (widget.product.size?.isNotEmpty ?? false) Center(
            child: Text(
              widget.product.size!,
              textAlign: TextAlign.center
            )
          )
        ]
      )
    );
  }
}
