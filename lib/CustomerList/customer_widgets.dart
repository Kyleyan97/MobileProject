import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/AppLocalizations.dart';
import 'package:MobileProject/CustomerList/CustomerListPage.dart';

import 'CustomerListPage.dart';

/// Builds the customer list widget
Widget customerList(BuildContext context, CustomerListPageState state) {
  return Padding(
    padding: const EdgeInsets.all(1.0),
    child: Scrollbar(
      controller: state._scrollController,
      thickness: 8.0,
      radius: const Radius.circular(10.0),
      thumbVisibility: false,
      child: state._customers.isEmpty
          ? Center(
        child: Text(
          AppLocalizations.of(context).translate('no_customers_yet'),
        ),
      )
          : ListView.builder(
        controller: state._scrollController,
        itemCount: state._customers.length,
        itemBuilder: (BuildContext context, int index) {
          var customer = state._customers[index];
          return GestureDetector(
            onTap: () {
              state.setState(() {
                state._selectedCustomer = customer;
              });
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Delete Customer"),
                    content: const Text("Are you sure you want to delete this customer?"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Yes"),
                        onPressed: () async {
                          await state.customerDAO.deleteCustomer(customer);
                          state.loadCustomers();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Customer deleted successfully')),
                          );
                        },
                      ),
                      TextButton(
                        child: const Text("No"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: index.isEven
                      ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text("${index + 1}"),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${customer.firstname} ${customer.lastname}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 50),
                        Text(
                          "${AppLocalizations.of(context).translate('address')}: ${customer.address}, "
                              "${AppLocalizations.of(context).translate('date_birth')}: ${DateFormat.yMd().format(customer.birthday)}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class CustomerListPageState {
}

/// Builds the customer details widget
Widget customerDetails(BuildContext context, CustomerListPageState state) {
  final selectedCustomer = state._selectedCustomer;

  if (selectedCustomer == null) {
    return Center(
      child: Text(
        AppLocalizations.of(context).translate('no_customer_selected'),
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  } else {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate('customer_detail'),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Table(
            columnWidths: const {
              0: FixedColumnWidth(150.0),
              1: FlexColumnWidth(),
            },
            children: [
              _buildTableRow(
                context,
                AppLocalizations.of(context).translate('last_name'),
                selectedCustomer.lastname,
              ),
              _buildTableRow(
                context,
                AppLocalizations.of(context).translate('first_name'),
                selectedCustomer.firstname,
              ),
              _buildTableRow(
                context,
                AppLocalizations.of(context).translate('address'),
                selectedCustomer.address,
              ),
              _buildTableRow(
                context,
                AppLocalizations.of(context).translate('birthday'),
                DateFormat.yMd().format(selectedCustomer.birthday),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  state.setState(() {
                    state.isUpdatingCustomer = true;
                    state.customerToUpdateId = selectedCustomer.id;
                    state.lastnameController.text = selectedCustomer.lastname;
                    state.firstnameController.text = selectedCustomer.firstname;
                    state.addressController.text = selectedCustomer.address;
                    state.birthday = selectedCustomer.birthday;
                  });
                },
                child: Text(AppLocalizations.of(context).translate('update_customer')),
              ),
              ElevatedButton(
                onPressed: () => state.removeCustomer(selectedCustomer),
                child: Text(AppLocalizations.of(context).translate('delete_customer')),
              ),
              ElevatedButton(
                onPressed: () {
                  state.setState(() {
                    state.selectedCustomer = null;
                  });
                },
                child: Text(AppLocalizations.of(context).translate('return_to_list')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper method to build a table row widget
TableRow _buildTableRow(BuildContext context, String label, String value) {
  return TableRow(
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.left,
      ),
      Text(
        value,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        textAlign: TextAlign.left,
      ),
    ],
  );
}
