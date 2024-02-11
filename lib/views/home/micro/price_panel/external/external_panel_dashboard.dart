import 'dart:html';
import 'package:diacritic/diacritic.dart';
import 'package:flameo/models/cart_models/cart.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/models_widgets/panel_product_element.dart';
import 'package:flameo/models_widgets/my_cart/cart_fab.dart';
import 'package:flameo/services/auth.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/home/micro/price_panel/external/panel_head.dart';
import 'package:flameo/views/home/micro/price_panel/external/product_page.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ExternalPanelDashboard extends StatefulWidget {

  final String companyID;
  final bool isExternal;
  final LinkOpener linkOpener;
  final ConfigProvider config;
  final String? scrollPosition;

  const ExternalPanelDashboard({
    super.key, required this.companyID, required this.isExternal, required this.linkOpener, required this.config, this.scrollPosition
  });

  @override
  State<ExternalPanelDashboard> createState() => _ExternalPanelDashboardState();
}

class _ExternalPanelDashboardState extends State<ExternalPanelDashboard> {

  Cart? cart;
  UserProduct? displayedProduct;
  bool isSearchFieldOpen = false;
  String selectedCategory = 'Todo';
  Logger logger = Logger('MapLogger');
  bool requestSearchFieldFocus = false;
  List<UserProduct> productsCascade = [];
  FocusNode searchfieldFocusNode = FocusNode();
  TextEditingController searchController = TextEditingController(text: '');

  // -----------------------------------------------------------------------------------------------
  //  Helper methods
  // -----------------------------------------------------------------------------------------------

  Future<void> switchProduct(UserProduct? newProduct, [bool previous = false]) async {
    if (!mounted) return;
    await Future.delayed(Duration.zero, () {
      setState(() {
        if (newProduct != null) {
          displayedProduct = newProduct;
          productsCascade.add(displayedProduct!);
        } else if (productsCascade.isNotEmpty && previous) {
          productsCascade.removeLast();
          displayedProduct = productsCascade.isNotEmpty ? productsCascade.last : null;
        } else {
          productsCascade.clear();
          displayedProduct = null;
        }
      });
    });
  }

  /// Initializes the product cart only if needed
  void initCart(CompanyPreferences? companyPreferences) {
     if (companyPreferences != null && cart == null) {
      Future.delayed(Duration.zero, () =>
        Cart.cache(companyPreferences, widget.config).then((value) => setState(() => cart = value))
      );
    }
  }

  List<UserProduct>? getActiveProducts(BuildContext context) {
    // retrieving and filtering products only if they exist
    var products = Provider.of<List<UserProduct>?>(context);
    return products?.where((product) => product.active).toList();
  }

  void handleSearchFieldFocus() {
    if (!searchfieldFocusNode.hasFocus && !requestSearchFieldFocus && searchController.text.isEmpty) {
      isSearchFieldOpen = false;
    } else if (requestSearchFieldFocus) {
      requestSearchFieldFocus = false;
      Future.delayed(Duration.zero, () => searchfieldFocusNode.requestFocus());
    }
  }

  /// Handles opening a product from  a link
  void handleLinkOpen(List<UserProduct>? products) {
    if (products != null && widget.linkOpener.productID != null) {
      widget.config.anonymousLog(LoggerAction.accessProductFromLink,{
        'companyID': widget.companyID,
        'productID': widget.linkOpener.productID
      });
      displayedProduct = products.where((product) => product.id == widget.linkOpener.productID).firstOrNull;
      if (displayedProduct != null) productsCascade.add(displayedProduct!);
      widget.linkOpener.productID = null;
    }
  }

  int getRowSize(double aspectRatio) {
  if (aspectRatio > 1.2) {
    return 5;
  } else {
    return 3;
  }
}

  List<String> getAvailableCategories(List<UserProduct>? products) {
    return (products?.where((e) => e.category != null).map((e) => e.category!).toSet().toList()?..sort()..insert(0, 'Todo')) ?? [];
  }

  List<UserProduct>? filterProducts(List<UserProduct>? products, String? selectedCategory) {
    products = products?.where((element) => searchString(searchController.text, element.name) || 
        searchString(searchController.text ,element.description)).toList();
    if (products != null) products = sortProducts(products);
    if (selectedCategory == null || selectedCategory == 'Todo') return products;
    return products?.where((element) => element.category == selectedCategory).toList();
  }

  void pushLink(CompanyPreferences companyPreferences) {
    if (!hasSubdomain(window.location.href)) {
      Future.delayed(Duration.zero,() => window.history.pushState(
        null,
        displayedProduct?.name ?? 'panel',
        'panel?name=${companyPreferences.panel.panelLink ?? ''}${displayedProduct != null ? '&product=${displayedProduct!.id}' : ''}'
      ));
    } else if (displayedProduct != null) {
      Future.delayed(Duration.zero,() => window.history.pushState(
        null,
        displayedProduct?.name ?? 'panel',
        '?product=${displayedProduct!.id}'
      ));
    }
  }

    @override
  void initState() {
    super.initState();
    widget.config.anonymousLog(LoggerAction.acessExternalPanelDashboard, {'companyID': widget.companyID});
  }

  @override
  Widget build(BuildContext context) {

    ScreenSize screensize = ScreenSize(context);
    CompanyPreferences? companyPreferences = Provider.of<CompanyPreferences?>(context);

    initCart(companyPreferences);

    // early return for loading state
    if (companyPreferences == null || cart == null) return const Loading();

    List<UserProduct>? products = getActiveProducts(context);
    var availableCategories = getAvailableCategories(products);
    var filteredProducts = filterProducts(products, selectedCategory);
    handleSearchFieldFocus();
    handleLinkOpen(products);
    final int rowSize = getRowSize(screensize.aspectRatio);
    pushLink(companyPreferences);

    late List<PanelProductElement> panelList = filteredProducts!.map((e) => PanelProductElement(
      key: UniqueKey(),
      product: e,
      isExternal: widget.isExternal,
      openFromPanelHome: true,
      cart: cart!,
      companyPreferences: companyPreferences,
      productSwitcher: switchProduct,
      config: widget.config
    )).toList();

    late Widget productsGrid = SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: rowSize,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => panelList[index],
        childCount: panelList.length
      )
    );

    return displayedProduct != null ? 
        filteredProducts == null? const Loading()
        : ProductPage(
          key: UniqueKey(),
          config: widget.config,
          mainProduct: displayedProduct,
          cart: cart!,
          companyPreferences: companyPreferences,
          products: filteredProducts,
          productSwitcher: switchProduct,
          scrollPosition: widget.scrollPosition
        )
        // TODO: preguntar a Anthony por qué puso lo del Pop scope
      : PopScope(
        onPopInvoked: (bool willPop) async {
          if (AuthService(config: widget.config).isUserLoggedin && willPop) Navigator.pushNamed(context, '/artistas');
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: AuthService(config:widget.config).isUserLoggedin,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_sharp),
                  onPressed: () {
                    if (widget.scrollPosition != null) {
                      Navigator.pushNamed(context, '/gallery?scrollPosition=${widget.scrollPosition}');
                    } else {
                      Navigator.pushNamed(context, '/artistas');
                    }
                  },
                  color: Colors.black
                ),
                expandedHeight: 300,
                collapsedHeight: kToolbarHeight,
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(bottom: 0.0),
                  centerTitle: true,
                  collapseMode: CollapseMode.parallax,
                  background: PanelHead(companyPreferences: companyPreferences),
                  title: Transform.translate(
                    offset: const Offset(0, 2), // Flutter fail: a tiny line showing between appbar and down
                    child: Container(
                      color: Theme.of(context).colorScheme.secondary,
                      height: kToolbarHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: screensize.width * 0.53,
                            child: Padding(
                              padding: const EdgeInsets.only(left:20.0),
                              child: Text(
                                companyPreferences.companyName,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            )
                          ),
                          if(companyPreferences.isCommercial) Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: CartAccess(
                              cart: cart!,
                              config: widget.config,
                              companyPreferences: companyPreferences,
                              productSwitcher: switchProduct,
                              linkOpener: widget.linkOpener
                            )
                          )
                        ]
                      )
                    )
                  ),
                  expandedTitleScale: 1.2
                ),
                floating: false
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20, top: 10, left: 25),
                        child: Text(
                          companyPreferences.description ?? "",
                          style: TextStyle(color: Colors.black.withOpacity(0.7))
                        )
                      )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 2),
                          child: TextButton.icon(
                            onPressed: () {
                              findOnMaps(companyPreferences.address, logger);
                            },
                            icon: const Icon(
                              Icons.map,
                              color: Colors.blue,
                              size: 15
                            ),
                            label: Text(
                              companyPreferences.address ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue,
                                color: Colors.blue,
                              )
                            )
                          )
                        ),
                        if (!isSearchFieldOpen) IconButton(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onPressed: () => setState(() {
                            isSearchFieldOpen = true;
                            requestSearchFieldFocus = true;
                          }),
                          icon: const Icon(Icons.search)
                        )
                      ]
                    )
                  ]
                )
              ),
              if (products != null && isSearchFieldOpen) SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    focusNode: searchfieldFocusNode,
                    controller: searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5, style: BorderStyle.none),
                        borderRadius: BorderRadius.all(Radius.circular(15.0))
                      ),
                      labelText: "Buscar"
                    ),
                    onChanged: (_) => setState(() {})
                  )
                )
              ),
              if (availableCategories.length > 1) SliverToBoxAdapter(
                // TODO: Mirar como separar estos tabs y que pasa cuando las available categories son iguales y estan en mayúsculas
                child: SizedBox(
                  width: screensize.width,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ScrollConfiguration(
                      behavior: MyCustomScrollBehavior(),
                      child: ListView.builder(
                        itemCount: availableCategories.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, int index) => InkWell(
                          onTap: () => setState(() => selectedCategory = availableCategories[index]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: IntrinsicWidth(
                              child: Column(
                                children: [
                                  Text(availableCategories[index]),
                                  Container(
                                    height: 4,
                                    color: Theme.of(context).colorScheme.onTertiary.withOpacity(
                                      availableCategories[index] == selectedCategory ? 1 : 0
                                    )
                                  )
                                ]
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              ),
              products == null ? const SliverToBoxAdapter(child: Loading())
              : panelList.isEmpty ? SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                    child: Text(
                      products.isEmpty
                        ? companyPreferences.flameoExtension == FlameoExtension.art ? "Todavía no hay obras registradas" : "No hay productos registrados en este panel"
                        : companyPreferences.flameoExtension == FlameoExtension.art ? "No se encuentran obras, ¡prueba con otras palabras!" : "No se encuentran productos, ¡prueba con otras palabras!",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 30)
                    )
                  )
                )
              )
              : productsGrid
            ]
          )
        )
      );
    }
}