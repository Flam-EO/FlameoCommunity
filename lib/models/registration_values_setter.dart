import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/stripe.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/shared/utils.dart';

class RegistrationValuesSetter {
  double defaultFee = 0.05;
  double defaultMinimumTransactionAmount = 5.0;
  final CompanyPreferences companyPreferences;
  final ConfigProvider config;

  RegistrationValuesSetter({required this.companyPreferences, required this.config});

  late String panelLink;
  void setValue(String key, dynamic value) {
    if (key == 'panelLink') panelLink = value;
    companyPreferences.updateFields({key: value}, config);
  }

  void saveData(ScreenSize screenSize) {
    Map<String, dynamic> values = {};
    values['dataCompleted'] = true;
    values['feeRate'] = defaultFee;
    values['minimumTransactionAmount'] = defaultMinimumTransactionAmount;
    values['flameoExtension'] = isArtEnvironment(config) ?
      FlameoExtension.art.name
      : FlameoExtension.main.name;
    values['deviceData'] = {
      'aspectRatio': screenSize.aspectRatio,
      'width': screenSize.width,
      'height': screenSize.height
    };
    companyPreferences.updateFields(values, config);
  }

  Future<String?> registerConnectedAccount() async {
    return await StripeService(companyPreferences: companyPreferences, config: config).registerConnectedAccount(panelLink);
  }
}
