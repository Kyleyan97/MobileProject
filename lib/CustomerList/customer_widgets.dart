import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/CustomerList/Customer.dart';
import 'customer_state.dart';
import 'package:final_project/AppLocalizations.dart';

class CustomerList extends StatelessWidget {
  final CustomerState customerState;

  CustomerList(this.customerState);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Scrollbar(
        controller: customerState._scrollController,
        thickness: 8.0,
        radius: Radius.circular(10.0),
        thumbVisibility: false,
        child: customerState._customers.isEmpty
            ? Center(
          child: Text(AppLocalizations.of(context).translate('no_customers_yet')),
        )
            : ListView.builder(
          controller: customerState._scrollController,
          itemCount: customerState._customers.length,
          itemBuilder: (BuildContext context, int index) {
            var customer = customerState._customers[index];
            return GestureDetector(
              onTap: () {
                customerState.selectedCustomer = customer;
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
                          onPressed: () {
                            customerState._removeCustomer(customer);
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text("No"),
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
                    color: index % 2 == 0
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
                            "${AppLocalizations.of(context).translate('address')}: ${customer.address}, ${AppLocalizations.of(context).translate('date_birth')}: ${DateFormat.yMd().format(customer.birthday)}",
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
}

class CustomerDetails extends StatelessWidget {
  final CustomerState customerState;

  CustomerDetails(this.customerState);

  @override
  Widget build(BuildContext context) {
    if (customerState.selectedCustomer == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_customer_selected'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
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
              style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(150.0),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('last_name'),
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      '${customerState.selectedCustomer!.lastname}',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('first_name'),
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      '${customerState.selectedCustomer!.firstname}',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('address'),
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      '${customerState.selectedCustomer!.address}',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('birthday'),
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      '${DateFormat.yMd().format(customerState.selectedCustomer!.birthday)}',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    customerState.isUpdatingCustomer = true;
                    customerState._customerToUpdateId = customerState.selectedCustomer!.id;
                    customerState._lastnameController.text = customerState.selectedCustomer!.lastname;
                    customerState._firstnameController.text = customerState.selectedCustomer!.firstname;
                    customerState._addressController.text = customerState.selectedCustomer!.address;
                    customerState._birthday = customerState.selectedCustomer!.birthday;
                  },
                  child: Text(AppLocalizations.of(context).translate('update_customer')),
                ),
                ElevatedButton(
                  onPressed: () => customerState._removeCustomer(customerState.selectedCustomer!),
                  child: Text(AppLocalizations.of(context).translate('delete_customer')),
                ),
                ElevatedButton(
                  onPressed: () {
                    customerState.selectedCustomer = null;
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
}
