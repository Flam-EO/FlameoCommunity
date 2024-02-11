import 'package:flameo/models/client_user.dart';
import 'package:flameo/services/config_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManagementDatabaseService {

  // Database service for app management

  String? companyID;
  String? uid;
  final ConfigProvider config;

  ManagementDatabaseService({this.companyID, this.uid, required this.config});

  late CollectionReference contact = FirebaseFirestore.instance.collection(config.get('contact'));
  late CollectionReference logs = FirebaseFirestore.instance.collection(config.get('logs'));
  late CollectionReference companies = FirebaseFirestore.instance.collection(config.get('companies'));
  late CollectionReference users = FirebaseFirestore.instance.collection(config.get('users'));

  // Send a message to contact collection
  Future<bool> sendMessage(String sender, String content, String? ip) async {
    try {
      await contact.add({'sender': sender, 'content': content, 'ip': ip, 'timestamp': Timestamp.now()});
    } on Exception catch (_) {
      return false;
    }
    return true;
  }

  // Save ip information to database
  void saveIP(String ip) {
    logs.doc('00000000').collection('ips').doc(ip).get().then((DocumentSnapshot doc) {
      if (!doc.exists) {
        logs.doc('00000000').collection('ips').doc(ip).set({'saveTimestamp': Timestamp.now()});
      }
    });
  }

  // Log to logs collection
  void log(Map<String, dynamic> content, String visitor) {
    content['timestamp'] = Timestamp.now();
    logs.doc(DateFormat('yyyyMMdd').format(DateTime.now()))
      .collection('visitors').doc(visitor)
      .collection('actions').add(content);
  }

    // Get companies list
    Stream<List<CompanyPreferences>> get streamCompanies {
      return companies.orderBy('creationTimestamp', descending: true)
        .snapshots().map((querySnapshot) => querySnapshot.docs.map((doc) => 
          CompanyPreferences.fromFirestore(doc, config)
        ).toList());
    }

    // Register gallery interested email
    void galleryInterestedEmail(String email) {
      users.doc('sauronID').collection('galleryInterestedEmails').add({
        'email': email,
        'timestamp': Timestamp.now()
      });
    }
}
