import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/auth.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:flutter/material.dart';

class DeletedAccount extends StatefulWidget {

  final CompanyPreferences companyPreferences;
  final ConfigProvider configProvider;

  const DeletedAccount({super.key, required this.companyPreferences, required this.configProvider});

  @override
  State<DeletedAccount> createState() => _DeletedAccountState();
}

class _DeletedAccountState extends State<DeletedAccount> {
  @override
  Widget build(BuildContext context) {
    
    bool deleting = widget.companyPreferences.deletionDate!.seconds > Timestamp.now().seconds;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            deleting ? 'Esta cuenta está siendo eliminada, se eliminará definitivamente el ${widget.companyPreferences.deletionDate!.toDate()}'
            : 'Esta cuenta ha sido eliminada.'  
          ),
          const SizedBox(height: 20),
          if(!deleting) ElevatedButton(
            onPressed: () => AuthService(config: widget.configProvider).signOut(),
            child: const Text('Salir')
          ),
          if(deleting) ElevatedButton(
            onPressed: () => widget.companyPreferences.updateFields({
              'is_deleted': false,
              'deletion_date': FieldValue.delete()
            }, widget.configProvider),
            child: const Text('Reactivar cuenta')
          )
        ]
      ),
    );
  }
}