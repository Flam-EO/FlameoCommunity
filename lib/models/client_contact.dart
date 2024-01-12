
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientContact {

  // Object to store the needed information of a buyer

  String name;
  String surname;
  String email;
  String phoneNumber;
  Address? address;

  ClientContact({
    required this.name, 
    required this.surname, 
    required this.email, 
    required this.phoneNumber, 
    this.address
  });

  // Cache constructor
  static Future<ClientContact?> get cache async {
    return await SharedPreferences.getInstance().then((SharedPreferences prefs) {
      String? clientContactCache = prefs.getString('clientContact');
      if (clientContactCache != null) {
        Map<String, dynamic> clientContactCacheData = jsonDecode(clientContactCache) as Map<String, dynamic>;
        if (Timestamp.now().seconds - clientContactCacheData['timestamp'] <  365 * 24 * 3600) {
          return ClientContact.fromDict(clientContactCacheData['data']);
        }
      }
      return null;
    });
  }

  // Cache methods
  void saveToCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Address? cachedAddress = (await ClientContact.cache)?.address;
    Map<String, dynamic> clientContactCacheData = {
      'timestamp': Timestamp.now().seconds,
      'data': this.toDict()..['address'] = this.address?.toDict() ?? cachedAddress?.toDict()
    };
    prefs.setString('clientContact', jsonEncode(clientContactCacheData));
  }

  void clearCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('clientContact');
  }

  // Useful methods
  void setAddress(Address address) {
    this.address = address;
    saveToCache();
  }

  // Conversion methods
  Map<String, dynamic> toDict() => {
    'name': name,
    'surname': surname,
    'email': email,
    'phoneNumber': phoneNumber,
    'address': address?.toDict(),
  };

  static ClientContact fromDict(Map<String, dynamic> data) => ClientContact(
    name: data['name'],
    surname: data['surname'],
    email: data['email'],
    phoneNumber: data['phoneNumber'],
    address: data['address'] == null ? null : Address.fromDict(data['address'])
  );

  @override
  String toString() {
    return '$name $surname, $email, $phoneNumber';
  }
  String toStringStack() {
    return '$name $surname\n$email\n$phoneNumber';
  }

}

class Address {

  // Object to store generic address information

  String province;
  String city;
  String zipCode;
  String street;
  String number;
  String? floor;
  String? door;
  String? details;

  Address({
    required this.province,
    required this.city,
    required this.zipCode,
    required this.street,
    required this.number,
    this.floor,
    this.door,
    this.details
  });

  // Address string representation
  @override
  String toString() {
    String address = '$street $number';
    if (floor != null) {
      address += ', $floor';
      if (door != null) {
        address += ' $door';
      }
    }
    address += ', $zipCode $city ($province)';
    if (details != null) {
      address += '\n$details';
    }
    return address;
  }

  // Conversion methods
  Map<String, dynamic> toDict() => {
    'province': province,
    'city': city,
    'zipCode': zipCode,
    'street': street,
    'number': number,
    'floor': floor,
    'door': door,
    'details': details,
  };

  static Address fromDict(Map<String, dynamic> data) => Address(
    province: data['province'],
    city: data['city'],
    zipCode: data['zipCode'],
    street: data['street'],
    number: data['number'],
    floor: data['floor'],
    door: data['door'],
    details: data['details']
  );

}

// ClientContact validation enums
enum ClientContactError {
  emptyName,
  enmptySurname,
  bothContactEmpty
}
