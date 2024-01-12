import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/models/role.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/loading.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flameo/models/client_user.dart';

bool isMaster(ClientUser user) {
  return user.uid == 'sauronID';//'sauronID';
}

class CompanyOption {

  final String companyName;
  final String companyID;
  final bool flameoManagement;

  CompanyOption({ required this.companyID, required this.companyName, required this.flameoManagement });

  static CompanyOption fromDict(Map<String, dynamic> data, String companyId) => CompanyOption(
    companyID: companyId,
    companyName: data['companyName'],
    flameoManagement: data['flameoManagement'] ?? false
  );

  factory CompanyOption.fromFirestore(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = downloadDocSnapshot(doc);
    return fromDict(data, doc.id);
  }

}

Future<List<CompanyOption>> getCompanies(ConfigProvider configProvider) {
    return FirebaseFirestore.instance.collection(configProvider.get('companies'))
      .get().then((querySnapshot) => 
        querySnapshot.docs.map(CompanyOption.fromFirestore).toList()
      );
  }

Future<Preferences> masterPreferences(BuildContext context, ConfigProvider configProvider) async {
  return await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MasterScreen(configProvider: configProvider))
  );
}

class MasterScreen extends StatefulWidget {

  final ConfigProvider configProvider;

  const MasterScreen({super.key, required this.configProvider});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {

  List<CompanyOption>? companies;
  @override
  void initState() {
    getCompanies(widget.configProvider).then((value) => setState(() => companies = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (companies != null) {
      List<CompanyOption> authorized = companies!.where((element) => element.flameoManagement).toList();
      List<CompanyOption> unAuthorized = companies!.where((element) => !element.flameoManagement).toList();
      authorized.sort((a, b) => a.companyName.compareTo(b.companyName));
      unAuthorized.sort((a, b) => a.companyName.compareTo(b.companyName));
      companies = authorized + unAuthorized;
    }

    return Scaffold(
      body: companies == null ? const Loading() : ListView.builder(
        itemCount: companies!.length,
        itemBuilder: (BuildContext context, int index) => InkWell(
          onTap: () => companies![index].flameoManagement ? Navigator.pop(context, Preferences(
            email: 'info@flameoapp.com',
            companyID: companies![index].companyID,
            role: Role(permissionsDict: null, role: RoleTag.admin),
            name: 'Master User',
            tutorialCompleted: true
          )) : null,
          child: ListTile(
            title: Text(companies![index].companyName),
            subtitle: Text(companies![index].companyID),
            trailing: companies![index].flameoManagement ? const SizedBox() : const Text('No autorizado')
          )
        )
      )
    );
  }
}