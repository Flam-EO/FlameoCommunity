import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/auth.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flameo/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class MasterEye extends StatefulWidget {

  final ConfigProvider config;

  const MasterEye({super.key, required this.config});

  @override
  State<MasterEye> createState() => _MasterEyeState();
}

class _MasterEyeState extends State<MasterEye> {

  final _log = Logger('Sauron');

  TextEditingController searcherController = TextEditingController(text: '');

  Widget companyCard(CompanyPreferences companyPreferences) {
    return InkWell(
      onTap: () {
        // Uri panelUrl = Uri.parse('${widget.config.get('base_link')}/panel?name=${companyPreferences.panel.panelLink}');
        // openUrl(panelUrl, _log);
        Navigator.of(context).pushNamed('/panel?name=${companyPreferences.panel.panelLink}');
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${companyPreferences.companyName} (/${companyPreferences.panel.panelLink})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
            ),
            Text('${companyPreferences.companyID} (Ext: ${companyPreferences.flameoExtension.name})'),
            Text(companyPreferences.creationTimestamp.toDate().toString()),
            Row(
              children: [
                Text(companyPreferences.email ?? ''),
                if(companyPreferences.email != null) IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                      text: companyPreferences.email!
                    ));
                  },
                  icon: const Icon(Icons.copy, color: Colors.black)
                )
              ]
            ),
            Row(
              children: [
                Text(companyPreferences.phone ?? ''),
                if(companyPreferences.phone != null) IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                      text: companyPreferences.phone!
                    ));
                  },
                  icon: const Icon(Icons.copy, color: Colors.black)
                )
              ]
            ),
            InkWell(
              child: Text('Media: ${companyPreferences.media}'),
              onTap: () => openUrl(Uri.parse('https://www.instagram.com/${companyPreferences.instagram}'), _log)
            ),
            Text('Productos: ${companyPreferences.nProducts}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Theme(
                      data: ThemeData.from(useMaterial3: false, colorScheme: Theme.of(context).colorScheme),
                      child: Switch(
                        value: companyPreferences.panel.mastersApprove ?? false,
                        onChanged: (value) => companyPreferences.updateFields({'mastersApprove': value}, widget.config),
                        activeColor: Theme.of(context).colorScheme.primary
                      )
                    ),
                    const Text('Masters Approve')
                  ]
                ),
                ElevatedButton(
                  onPressed: () {
                    Environment environment = widget.config.environment ?? Environment.dev;
                    if ([Environment.art, Environment.dev].contains(environment)) {
                      openUrl(Uri.parse('https://console.firebase.google.com/u/1/project/flameoapp-pyme/hosting/sites/flameoapp-pyme-${environment.name}/domains'), _log);
                    }
                    if (environment == Environment.pro) {
                      openUrl(Uri.parse('https://console.firebase.google.com/u/1/project/flameoapp-pyme/hosting/sites/flameoapp-pyme/domains'), _log);
                    }
                    if (environment == Environment.devart) {
                      openUrl(Uri.parse('https://console.firebase.google.com/u/1/project/flameoapp-pyme/hosting/sites/flameoapp-pyme-art-dev/domains'), _log);
                    }
                    if ([Environment.pro, Environment.dev].contains(environment)) {
                      openUrl(Uri.parse('https://domains.google.com/registrar/flameoapp.com/dns'), _log);
                    }
                    if ([Environment.devart, Environment.art].contains(environment)) {
                      openUrl(Uri.parse('https://domains.google.com/registrar/flameoart.com/dns'), _log);
                    }
                  },
                  child: const Text('Crear subdominio')
                ),
                Column(
                  children: [
                    Theme(
                      data: ThemeData.from(useMaterial3: false, colorScheme: Theme.of(context).colorScheme),
                      child: Switch(
                        value: companyPreferences.isPublic,
                        onChanged: (value) => companyPreferences.updateFields({'isPublic': value}, widget.config),
                        activeColor: Theme.of(context).colorScheme.primary
                      )
                    ),
                    const Text('Public Company')
                  ]
                )
              ]
            )
          ]
        )
      )
    );
  }

  Widget companyListView(List<CompanyPreferences> companiesSection) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: companiesSection.length,
      itemBuilder: (_, int index) => companyCard(companiesSection[index]),
      separatorBuilder: (_, __) => const Divider(color: Colors.grey)
    );
  }

  Widget sectionOpener(String text, VoidCallback updater) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blue[50],
      height: 50,
      width: double.infinity,
      child: InkWell(
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
        ),
        onTap: () => setState(updater)
      )
    );
  }

  bool notApprovedOpen = false;
  bool notTriedStripeOpen = false;
  bool stripeDisabledOpen = false;
  bool goldenClientsOpen = false;
  bool trashOrCreatingOpen = false;
  bool subdomainRequestedOpen = false;
  @override
  Widget build(BuildContext context) {

    List<CompanyPreferences> companies =  Provider.of<List<CompanyPreferences>>(context);

    companies = companies.where((company) => (company.panel.panelLink?.toLowerCase() ?? '').contains(searcherController.text.toLowerCase())).toList();

    int totalCompanies = companies.length;

    List<CompanyPreferences> notApprovedCompanies = companies.where((company) => !company.mastersApprove).toList();
    notApprovedCompanies.sort((a, b) => b.creationTimestamp.compareTo(a.creationTimestamp));
    companies = companies.where((company) => company.mastersApprove).toList();
    List<CompanyPreferences> trashOrCreatingCompanies = companies.where((company) => !company.dataCompleted).toList();
    trashOrCreatingCompanies.sort((a, b) => b.creationTimestamp.compareTo(a.creationTimestamp));
    companies = companies.where((company) => company.dataCompleted).toList();
    List<CompanyPreferences> notTriedStripeCompanies = companies.where((company) => !company.triedStripe).toList();
    notTriedStripeCompanies.sort((a, b) => b.creationTimestamp.compareTo(a.creationTimestamp));
    companies = companies.where((company) => company.triedStripe).toList();
    List<CompanyPreferences> stripeDisabledCompanies = companies.where((company) => !company.stripeEnabled).toList();
    stripeDisabledCompanies.sort((a, b) => b.creationTimestamp.compareTo(a.creationTimestamp));
    companies = companies.where((company) => company.stripeEnabled).toList();
    notApprovedCompanies.sort((a, b) => b.nProducts.compareTo(a.nProducts));

    List<CompanyPreferences> subdomainRequestedCompanies = companies.where((company) => company.subdomainRequested).toList();
    notApprovedCompanies.sort((a, b) => b.creationTimestamp.compareTo(a.creationTimestamp));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sauron Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => AuthService(config: widget.config).signOut(),
            icon: const Icon(Icons.exit_to_app)
          )
        ]
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
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
            ),
            sectionOpener('Sin aprobar (${notApprovedCompanies.length}/$totalCompanies)', () => notApprovedOpen = !notApprovedOpen),
            if (notApprovedOpen) companyListView(notApprovedCompanies),
            const Divider(),
            sectionOpener('Quieren subdominio (${subdomainRequestedCompanies.length})', () => subdomainRequestedOpen = !subdomainRequestedOpen),
            if (subdomainRequestedOpen) companyListView(subdomainRequestedCompanies),
            const Divider(),
            sectionOpener('Pros (${companies.length}/$totalCompanies)', () => goldenClientsOpen = !goldenClientsOpen),
            if (goldenClientsOpen) companyListView(companies),
            const Divider(),
            sectionOpener('Sin intentos en Stripe (${notTriedStripeCompanies.length}/$totalCompanies)', () => notTriedStripeOpen = !notTriedStripeOpen),
            if (notTriedStripeOpen) companyListView(notTriedStripeCompanies),
            const Divider(),
            sectionOpener('Sin Stripe (${stripeDisabledCompanies.length}/$totalCompanies)', () => stripeDisabledOpen = !stripeDisabledOpen),
            if (stripeDisabledOpen) companyListView(stripeDisabledCompanies),
            const Divider(),
            sectionOpener('Basura o registrándose (${trashOrCreatingCompanies.length}/$totalCompanies)', () => trashOrCreatingOpen = !trashOrCreatingOpen),
            if (trashOrCreatingOpen) companyListView(trashOrCreatingCompanies)
          ]
        ),
      )
    );
  }
}