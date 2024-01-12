import 'package:flameo/models/client_contact.dart';

import 'package:flutter/material.dart';

class MyAddress extends StatelessWidget {
  final Address address;
  const MyAddress({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, fontWeight: FontWeight.bold);
    TextStyle title2Style = const TextStyle(fontStyle: FontStyle.italic, fontSize: 11, fontWeight: FontWeight.bold);
    TextStyle generalStyle = const TextStyle(fontStyle: FontStyle.italic, fontSize: 11);
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child:  Text("Dirección de Envío:", style: titleStyle)
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text("Calle ${address.street}, número ${address.number}\nPiso ${address.floor} puerta ${address.door}", style: generalStyle)
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text("Provincia: ${address.province}, Ciudad: ${address.city}\nCódigo postal: ${address.zipCode}", style: generalStyle)
          ),
          Text("Detalles adicionales:", style: title2Style),
          Text(address.details ?? "", style: generalStyle)
        ]
      )
    );
  }
}