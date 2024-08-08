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


/// A page that displays detailed information about a specific customer.
///
/// This page shows the customer's full name, address, and birthday.
/// It includes a button to navigate back to the previous page.
///
/// The `CustomerPage` takes a `Customer` object as a required parameter
/// to display the details of the customer.
class CustomerPage extends StatelessWidget {
  /// The customer whose details are to be displayed on this page.
  final Customer customer;

  /// Creates an instance of [CustomerPage] with the given [customer].
  ///
  /// The [customer] parameter is required and represents the customer
  /// whose details will be shown on this page.
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
            /// Displays the full name of the customer.
            ///
            /// Combines the `firstname` and `lastname` of the customer to
            /// present the full name in a bold font style.

            Text(
              "${AppLocalizations.of(context).translate('name')}: ${customer.firstname} ${customer.lastname}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            /// Displays the address of the customer.
            ///
            /// Shows the `address` of the customer in a standard font style.
            Text(
              "${AppLocalizations.of(context).translate('address')}: ${customer.address}",
              style: const TextStyle(fontSize: 16),
            ),

            /// Displays the birthday of the customer.
            ///
            /// Formats the `birthday` of the customer using the `DateFormat`
            /// to show the date in the 'MM/dd/yyyy' format.
            Text(
              "${AppLocalizations.of(context).translate('birthday')}: ${DateFormat.yMd().format(customer.birthday)}",
              style: const TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            /// A button that navigates back to the previous page.
            ///
            /// When pressed, it pops the current route off the navigation stack,
            /// returning to the previous page.
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
