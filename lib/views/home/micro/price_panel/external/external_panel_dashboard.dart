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

  TextEditingController searcherController = TextEditingController(text: '');

  List<UserProduct> productsCascade = [];
  FocusNode searchfieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.config.anonymousLog(LoggerAction.acessExternalPanelDashboard, {'companyID': widget.companyID});
  }

  bool searchFilter(String? productContent) {
    if (productContent == null) return false;
    return removeDiacritics(productContent.toLowerCase()).contains(
      removeDiacritics(searcherController.text.toLowerCase())
    );
  }

  UserProduct? showingProduct;
  void productSwitcher(UserProduct? newProduct, [bool previous = false]) => Future.delayed(Duration.zero, () {
    if (mounted) {
      setState(() {
        showingProduct = newProduct;
        if (showingProduct != null) {
          productsCascade.add(showingProduct!);
        } else if (productsCascade.isNotEmpty && previous) {
          productsCascade.removeLast();
          if (productsCascade.isNotEmpty) {
            showingProduct = productsCascade.last;
          }
        } else {
          productsCascade = [];
        }
      });
    }
  });

  String selectedCategory = 'Todo';
  bool isSearchFieldOpen = false;
  bool requestSearchFieldFocus = false;

  @override
  Widget build(BuildContext context) {
    ScreenSize screensize = ScreenSize(context);
    int rowSize;

    Logger logger = Logger('ExternalPanelHead');

    CompanyPreferences? companyPreferences = Provider.of<CompanyPreferences?>(context);
    List<UserProduct>? products = Provider.of<List<UserProduct>?>(context);

    if (products != null) {
      products = products.where((product) => product.active).toList();
    }

    if (!searchfieldFocusNode.hasFocus && !requestSearchFieldFocus && searcherController.text.isEmpty) {
      isSearchFieldOpen = false;
    } else if (requestSearchFieldFocus) {
      requestSearchFieldFocus = false;
      Future.delayed(Duration.zero, () => searchfieldFocusNode.requestFocus());
    }

    if(companyPreferences != null && cart == null) {
      Future.delayed(Duration.zero, () =>
        Cart.cache(companyPreferences, widget.config).then((value) => setState(() => cart = value))
      );
    }

    if (products != null && widget.linkOpener.productID != null) {
      widget.config.anonymousLog(LoggerAction.accessProductFromLink,{
        'companyID': widget.companyID,
        'productID': widget.linkOpener.productID
      });
      showingProduct = products.where((product) => product.id == widget.linkOpener.productID).firstOrNull;
      if (showingProduct != null) productsCascade.add(showingProduct!);
      widget.linkOpener.productID = null;
    }

    if (companyPreferences != null) {
      if (companyPreferences.subdomain == null) {
        Future.delayed(Duration.zero,() => window.history.pushState(
          null,
          showingProduct?.name ?? 'panel',
          'panel?name=${companyPreferences.panel.panelLink ?? ''}${showingProduct != null ? '&product=${showingProduct!.id}' : ''}'
        ));
      } else if (showingProduct != null) {
        Future.delayed(Duration.zero,() => window.history.pushState(
          null,
          showingProduct?.name ?? 'panel',
          '?product=${showingProduct!.id}'
        ));
      }
    }

    if (screensize.aspectRatio > 1.2) {
      rowSize = 5;
    } else if (screensize.aspectRatio < 0.8) {
      rowSize = 3;
    } else {
      rowSize = 3;
    }

    List<UserProduct>? filteredProducts = products?.where((element) => searchFilter(element.name)).toList();
    List<UserProduct>? descriptionFilteredProducts = products?.where((element) => 
      searchFilter(element.description) && !(filteredProducts?.contains(element) ?? false)
      ).toList();
    if (filteredProducts != null) filteredProducts = sortProducts(filteredProducts);
    if (descriptionFilteredProducts != null) descriptionFilteredProducts = sortProducts(descriptionFilteredProducts);
    filteredProducts?.addAll(descriptionFilteredProducts ?? []);

    List<String> availableCategories = filteredProducts?.where((e) => e.category != null).map((e) => e.category!).toSet().toList() ?? [];
    availableCategories.sort((a, b) => a.compareTo(b));
    availableCategories.insert(0, 'Todo');
    if (selectedCategory != 'Todo') {
      filteredProducts = filteredProducts?.where((element) => element.category == selectedCategory).toList();
    }

    late List<PanelProductElement> panelList = filteredProducts!.map((e) => PanelProductElement(
      key: UniqueKey(),
      product: e,
      isExternal: widget.isExternal,
      openFromPanelHome: true,
      cart: cart!,
      companyPreferences: companyPreferences!,
      productSwitcher: productSwitcher,
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

    return companyPreferences == null || cart == null ? const Loading()
      : showingProduct != null ? 
        filteredProducts == null? const Loading()
        : ProductPage(
          key: UniqueKey(),
          config: widget.config,
          mainProduct: showingProduct,
          cart: cart!,
          companyPreferences: companyPreferences,
          products: filteredProducts,
          productSwitcher: productSwitcher,
          scrollPosition: widget.scrollPosition
        )
      : PopScope(
        onPopInvoked: (bool willPop) async {
          if (AuthService(config: widget.config).isUserLoggedin && willPop) Navigator.pushNamed(context, '/artistas');
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          body: Padding(
            padding: EdgeInsets.only(
              left: screensize.aspectRatio > 1.2? screensize.width * 0.0 : 0,
              right: screensize.aspectRatio > 1.2 ? screensize.width * 0.0 : 0
            ),
            child: CustomScrollView(
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
                            Padding(
                              padding: EdgeInsets.only(left: AuthService(config:widget.config).isUserLoggedin ? 25.0 : 0),
                              child: SizedBox(
                                width: screensize.width * 0.66 * 0.8,
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
                              )
                            ),
                            if(companyPreferences.isCommercial) Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: CartAccess(
                                cart: cart!,
                                config: widget.config,
                                companyPreferences: companyPreferences,
                                productSwitcher: productSwitcher,
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
                                String encodedAddress = Uri.encodeComponent(companyPreferences.address ?? '');
                                if (encodedAddress != '') {
                                  final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
                                  openUrl(url, logger);
                                }
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
                      controller: searcherController,
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
        )
      );
    }
}