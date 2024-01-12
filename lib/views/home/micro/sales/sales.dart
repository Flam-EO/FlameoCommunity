import 'package:flameo/services/config_provider.dart';
import 'package:flameo/views/home/micro/sales/transaction_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flameo/services/database.dart';
import 'package:flameo/models/transaction.dart';
import 'package:flameo/models/client_user.dart';

class Sales extends StatefulWidget {
  final ClientUser user;
  final ConfigProvider config;
  final CompanyPreferences companyPreferences;
  final void Function(bool) setLoading;

  const Sales({super.key, required this.user, required this.companyPreferences, required this.config, required this.setLoading});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<MyTransaction>?>.value(
      initialData: null,
      value: DatabaseService(companyID: widget.user.preferences!.companyID, config: widget.config).getTransactions(),
      child: Container( color: Theme.of(context).colorScheme.secondary,
        child: TransactionDashboard(
          user: widget.user,
          companyPreferences: widget.companyPreferences,
          config: widget.config,
          setLoading: widget.setLoading
        )
      )
    );
  }
}
