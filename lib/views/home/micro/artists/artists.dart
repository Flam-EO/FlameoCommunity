import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/views/home/micro/artists/artists_list.dart';
import 'package:flameo/views/home/micro/artists/fans_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Artists extends StatefulWidget {

  final CompanyPreferences companyPreferences;
  final ConfigProvider config;

  const Artists({super.key, required this.companyPreferences, required this.config});

  @override
  State<Artists> createState() => _ArtistsState();
}

class _ArtistsState extends State<Artists> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.star),
                text: 'Favoritos'
              ),
              Tab(
                icon: Icon(Icons.search),
                text: 'Explora'
              ),
              Tab(
                icon: Icon(Icons.people),
                text: 'Fans'
              )
            ]
          ),
          Expanded(
            child: TabBarView(
              children: [
                StreamProvider<List<CompanyPreferences>?>.value(
                  initialData: null,
                  value: DatabaseService(config: widget.config, companyID: widget.companyPreferences.companyID).streamFavoritesCompanies,
                  child: ArtistsList(companyPreferences: widget.companyPreferences, config: widget.config)
                ),
                StreamProvider<List<CompanyPreferences>?>.value(
                  initialData: null,
                  value: DatabaseService(config: widget.config).streamArtCompanies,
                  child: ArtistsList(companyPreferences: widget.companyPreferences, config: widget.config)
                ),
                FansList(companyPreferences: widget.companyPreferences, config: widget.config)
              ]
            )
          )
        ]
      )
    );
  }
}