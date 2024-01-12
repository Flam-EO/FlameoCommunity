import 'dart:math';

import 'package:flameo/gallery/author_gallery/author_gallery.dart';
import 'package:flameo/gallery/creation_gallery/creation_gallery.dart';
import 'package:flameo/gallery/gallery_landscape.dart';
import 'package:flameo/gallery/the_concept_of_art/the_concept_of_art.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Gallery extends StatefulWidget {

  final ConfigProvider config;
  final String? scrollPosition;
  
  const Gallery({super.key, required this.config, required this.scrollPosition});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {

  late ScreenSize screenSize = ScreenSize(context);

  static const double tabBarHeight = 50;

  @override
  Widget build(BuildContext context) {

    ScreenSize screenSize = ScreenSize(context);
    
    List<CompanyPreferences> companies =  Provider.of<List<CompanyPreferences>>(context);
    
    double expandedAppBarHeight = max(screenSize.aspectRatio > 0.9
                                  ? screenSize.width * 0.2 - tabBarHeight
                                  : 350 - tabBarHeight,200
                                  );
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: ((context, innerBoxIsScrolled) {
            return <Widget> [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: expandedAppBarHeight,
                collapsedHeight: kToolbarHeight,
                backgroundColor: Theme.of(context).colorScheme.onSecondary,
                centerTitle: true,
                elevation: 0,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: GalleryLandscape(expandedAppBarHeight: expandedAppBarHeight)
                ),
              ),
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                expandedHeight: tabBarHeight,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: TabBar(
                    isScrollable: screenSize.aspectRatio > 0.9 ? false : true,
                    tabs: const [
                      Tab(text: 'OBRAS DESTACADAS'),
                      Tab(text: 'ARTISTAS'),
                      Tab(text: 'EL CONCEPTO DEL ARTE'),
                    ],
                  ),
                ),
              )
            ];
          }),
          body: TabBarView(
              children: [
                StreamProvider<List<UserProduct>?>.value(
                  initialData: null,
                  value: DatabaseService(config: widget.config).gallerySelectedProducts,
                  child: CreationGallery(screenSize: screenSize, config: widget.config, scrollPosition: widget.scrollPosition),
                ),
                AuthorGallery(screenSize: screenSize, companies: companies, config: widget.config,),
                Padding(
                  padding: EdgeInsets.only(top:50.0, right: screenSize.aspectRatio >1.2 ? screenSize.width*0.2 : 10,
                                                     left: screenSize.aspectRatio >1.2 ? screenSize.width*0.2 : 10),
                  child: const TheConceptOfArt(),
                ) // TODO
              ]
          ),
        ),
      )
    );
  }
}
