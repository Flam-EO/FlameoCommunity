import 'package:collection/collection.dart';
import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/models_widgets/panel_product_element.dart';
import 'package:flameo/models_widgets/my_cart/cart_fab.dart';
import 'package:flameo/models_widgets/panel_main_element.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {

  final UserProduct? mainProduct;
  final CompanyPreferences companyPreferences;
  final Cart cart;
  final List<UserProduct> products;
  final ConfigProvider config;
  final Function(UserProduct?, [bool]) productSwitcher;
  final String? scrollPosition;

  const ProductPage({
    super.key,
    required this.mainProduct,
    required this.config,
    required this.cart,
    required this.companyPreferences,
    required this.products,
    required this.productSwitcher,
    required this.scrollPosition
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {

  @override
  Widget build(BuildContext context) {

    ScreenSize screensize = ScreenSize(context);

    UserProduct? streamProduct = widget.products.firstWhereOrNull((product) => product.id == widget.mainProduct!.id);

    if (widget.mainProduct == null || streamProduct == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Este producto ya no está disponible'),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => widget.productSwitcher(null),
                child: const Text('Volver')
              )
            ]
          ),
        )
      );
    }

    late List<PanelProductElement> panelList = widget.products.where((product) => 
      product.id != widget.mainProduct!.id
    ).map((product) => PanelProductElement(
      product: product,
      isExternal: true,
      openFromPanelHome: false,
      cart: widget.cart,
      companyPreferences: widget.companyPreferences,
      productSwitcher: widget.productSwitcher,
      config: widget.config
    )).toList();

    int elementsPerRow = screensize.aspectRatio > 1.2 ? 4 : 2;
    double margin =  screensize.aspectRatio > 1.2 ? screensize.width*0.3 : 0;
    late Widget panelMainElement = Padding(
      padding:  EdgeInsets.only(left: margin, right: margin),
      child: PanelMainElement(
        product: streamProduct,
        cart: widget.cart,
        updateParent: () => setState(() {}),
        companyPreferences: widget.companyPreferences,
        config: widget.config
      )
    );

    Widget productsGrid = SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: elementsPerRow, mainAxisSpacing: 1, crossAxisSpacing: 1
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => panelList[index],
        childCount: panelList.length
      )
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 0,
            actions: [
              if (widget.companyPreferences.isCommercial) Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: CartAccess(
                  cart: widget.cart,
                  config: widget.config,
                  companyPreferences: widget.companyPreferences,
                  productSwitcher: widget.productSwitcher
                )
              )
            ],
            floating: true,
            title: TextButton(
              onPressed: () => widget.productSwitcher(null),
              child: Text(
                widget.companyPreferences.companyName,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                overflow: TextOverflow.ellipsis
              )
            ),
            leading: IconButton(
              onPressed: () {
                if (widget.scrollPosition != null) {
                  Navigator.pushNamed(context, '/gallery?scrollPosition=${widget.scrollPosition}');
                }
                widget.productSwitcher(null, false);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )
            )
          ),
          SliverToBoxAdapter(
            child: panelMainElement
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).colorScheme.secondary,
              height: 50,
              width: screensize.width
            )
          ),
          productsGrid
        ]
      )
    );
  }
}
