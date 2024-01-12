import 'package:flameo/models/client_user.dart';
import 'package:flameo/views/home/micro/price_panel/external/landscape.dart';
import 'package:flutter/material.dart';

class PanelHead extends StatelessWidget {
  final CompanyPreferences companyPreferences;

  const PanelHead({super.key, required this.companyPreferences});

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Landscape(companyPreferences: companyPreferences)
    );
  }
}
