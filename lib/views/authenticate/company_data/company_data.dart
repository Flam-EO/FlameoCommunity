import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/registration_values_setter.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flameo/views/authenticate/company_data/description_data.dart';
import 'package:flutter/material.dart';

class CompanyData extends StatefulWidget {
  final ConfigProvider config;
  final CompanyPreferences companyPreferences;

  const CompanyData({super.key, required this.companyPreferences, required this.config});

  @override
  State<CompanyData> createState() => _CompanyDataState();
}

class _CompanyDataState extends State<CompanyData> {

   
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () {
        widget.config.log(LoggerAction.companyDataPanelLink);
        return rightSlideTransition(
          context, 
          DescriptionData(
            config: widget.config,
            values: RegistrationValuesSetter(companyPreferences: widget.companyPreferences, config: widget.config)
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Loading();
  }
}
