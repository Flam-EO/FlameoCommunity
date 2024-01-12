import 'package:flameo/models/client_user.dart';
import 'package:flameo/models/panel.dart';
import 'package:flameo/models/userproduct.dart';
import 'package:flameo/models_widgets/share_qr_dialog.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/shared/platform.dart';
import 'package:flameo/views/home/micro/price_panel/internal/new_product.dart';
import 'package:flameo/views/home/micro/price_panel/internal/price_panel_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PricePanel extends StatefulWidget {

  final ClientUser user;
  final ConfigProvider config;
  final CompanyPreferences companyPreferences;
  
  const PricePanel({super.key, required this.user, required this.config, required this.companyPreferences});

  @override
  State<PricePanel> createState() => _PricePanelState();
}

class _PricePanelState extends State<PricePanel> {

  void pauseQR(bool pause, Panel panel) {
    if (widget.user.preferences != null) {
      if (pause) {
        panel.pause();
      } else {
        panel.resume();
      }
    }
  }

  void pressQRShow() => showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return ShareQrDialog(
        dialogContext: dialogContext,
        config: widget.config,
        companyPreferences: widget.companyPreferences,
        context: context
      );
    }
  );

  @override
  Widget build(BuildContext context) {

    ScreenSize screensize = ScreenSize(context);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    !(widget.companyPreferences.panel.isPaused ?? false)
                    ? 'Panel Público activado'
                    : 'Panel Público desactivado'
                  ),
                  Theme(
                    data: ThemeData.from(useMaterial3: false, colorScheme: Theme.of(context).colorScheme),
                    child: Switch(
                      value: !(widget.companyPreferences.panel.isPaused ?? false),
                      onChanged: (value) => pauseQR(!value, widget.companyPreferences.panel),
                      activeColor: Theme.of(context).colorScheme.primary,
                    )
                  ),
                  ElevatedButton.icon(
                    onPressed: pressQRShow,
                    label: const Text(
                      'Ver código QR',
                      style: TextStyle(color: Colors.white)
                    ),
                    icon: const Icon(
                      Icons.qr_code,
                      color: Colors.white
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimaryContainer),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                      ),
                    ),
                  )
                ]
              )
            ),
            Expanded(
              child: SizedBox(
                child: StreamProvider<List<UserProduct>?>.value(
                  initialData: null,
                  value: DatabaseService(companyID: widget.user.preferences!.companyID, config: widget.config).userProducts,
                  child: PricePanelDashboard(
                    companyPreferences: widget.companyPreferences
                  )
                )
              )
            )
          ]
        ),
        Positioned(
          bottom: screensize.height * 0.05,
          right: screensize.width * 0.05,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              padding: const EdgeInsets.all(0.0),
              backgroundColor: Colors.transparent
            ),
            child: Stack(
              children: [
                const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 60
                ),
                Icon(
                  Icons.add_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 60
                )
              ]
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewProduct(
                    config: widget.config, widget.companyPreferences
                  )
                )
              );
            }
          )
        )
      ]
    );
  }
}
