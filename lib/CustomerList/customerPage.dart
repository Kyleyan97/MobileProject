// customerPage.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:final_project/CustomerList/Customer.dart';
import 'package:final_project/CustomerList/CustomerDAO.dart';
import '../Database.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:final_project/AppLocalizations.dart';
import 'package:final_project/main.dart';
import 'dart:async';

// Additional imports or code related to individual customer details can be added here

class CustomerPage extends StatelessWidget {
  final Customer customer;

  CustomerPage({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('customer_detail_title')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppLocalizations.of(context).translate('name')}: ${customer.firstname} ${customer.lastname}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${AppLocalizations.of(context).translate('address')}: ${customer.address}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "${AppLocalizations.of(context).translate('birthday')}: ${DateFormat.yMd().format(customer.birthday)}",
              style: const TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context).translate('back')),
            ),
          ],
        ),
      ),
    );
  }
}
