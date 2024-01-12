import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';

class GalleryOrderer extends StatefulWidget {

  final void Function(GalleryCreationsOrder) orderCreations;

  const GalleryOrderer({
    super.key, required this.orderCreations,
  });

  @override
  State<GalleryOrderer> createState() => _GalleryOrdererState();
}

class _GalleryOrdererState extends State<GalleryOrderer> {

  bool isOpen = false;
  double maxPanelWidth = 500;
  String orderName = 'Relevancia';

  @override
  Widget build(BuildContext context) {

    ScreenSize screenSize = ScreenSize(context);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: screenSize.width < maxPanelWidth ? screenSize.width - 40 : maxPanelWidth,
            child: ExpansionPanelList(
              expandIconColor: Colors.black,
              children: [
                ExpansionPanel(
                  headerBuilder: (context, isExpanded) {
                    return Center(child: Text('ORDENADO POR: $orderName'));
                  },
                  body: Column(
                    children: [
                      Card(
                        color: Theme.of(context).colorScheme.onSecondary,
                        child: ListTile(
                          title: const Text('Relevancia'),
                          onTap: () {
                            widget.orderCreations(GalleryCreationsOrder.relevance);
                            setState(() {
                              orderName = 'Relevancia';
                              isOpen = false;
                            });
                          }
                        ),
                      ),
                      Card(
                        color: Theme.of(context).colorScheme.onSecondary,
                        child: ListTile(
                          title: const Text('Precio Ascendente'),
                          onTap: () {
                            widget.orderCreations(GalleryCreationsOrder.priceAscending);
                            setState(() {
                              orderName = 'Precio Ascendente';
                              isOpen = false;
                            });
                          }
                        ),
                      ),
                      Card(
                        color: Theme.of(context).colorScheme.onSecondary,
                        child: ListTile(
                          title: const Text('Precio Descendente'),
                          onTap: () {
                            widget.orderCreations(GalleryCreationsOrder.priceDescending);
                            setState(() {
                              orderName = 'Precio Descendente';
                              isOpen = false;
                            });
                          }
                        ),
                      ),
                      Card(
                        color: Theme.of(context).colorScheme.onSecondary,
                        child: ListTile(
                          title: const Text('Más modernas'),
                          onTap: () {
                            widget.orderCreations(GalleryCreationsOrder.newer);
                            setState(() {
                              orderName = 'Más modernas';
                              isOpen = false;
                            });
                          }
                        ),
                      ),
                      Card(
                        color: Theme.of(context).colorScheme.onSecondary,
                        child: ListTile(
                          title: const Text('Más antiguas'),
                          onTap: () {
                            widget.orderCreations(GalleryCreationsOrder.older);
                            setState(() {
                              orderName = 'Más antiguas';
                              isOpen = false;
                            });
                          }
                        ),
                      )
                    ],
                  ),
                  isExpanded: isOpen
                )
              ],
              expansionCallback: (panelIndex, isExpanded) => setState(() {isOpen = isExpanded;}),
            ),
          ),
        ],
      ),
    );
  }
}
