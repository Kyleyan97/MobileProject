import 'package:flutter/material.dart';
import 'package:final_project/AppLocalizations.dart';
import 'package:final_project/main.dart';
import 'customer_form.dart';
import 'customer_state.dart';
import 'customer_widgets.dart';

class CustomerListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CustomerListPageState();
  }
}

class CustomerListPageState extends State<CustomerListPage> {
  final CustomerState customerState = CustomerState();

  @override
  void initState() {
    super.initState();
    customerState.initializeState(context);
  }

  @override
  void dispose() {
    customerState.disposeState();
    super.dispose();
  }

  void pressAddCustomer() {
    setState(() {
      customerState.isAddingNewCustomer = true;
      customerState.isUpdatingCustomer = false;
    });
  }

  Widget responsiveLayout(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if (!customerState.isAddingNewCustomer && !customerState.isUpdatingCustomer) {
      if ((width > height) && (width > 720)) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: CustomerList(customerState),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomerDetails(customerState),
              ),
            )
          ],
        );
      } else {
        if (customerState.selectedCustomer == null) {
          return CustomerList(customerState);
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomerDetails(customerState),
          );
        }
      }
    } else if (customerState.isAddingNewCustomer && !customerState.isUpdatingCustomer) {
      if ((width > height) && (width > 720)) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: CustomerList(customerState),
            ),
            Expanded(
              flex: 1,
              child: CustomerForm(customerState),
            )
          ],
        );
      } else {
        return CustomerForm(customerState);
      }
    } else if (!customerState.isAddingNewCustomer && customerState.isUpdatingCustomer) {
      if ((width > height) && (width > 720)) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: CustomerList(customerState),
            ),
            Expanded(
              flex: 1,
              child: CustomerForm(customerState),
            )
          ],
        );
      } else {
        if (customerState.selectedCustomer == null) {
          return Text(AppLocalizations.of(context).translate('no_customer_selected'));
        } else {
          return CustomerForm(customerState);
        }
      }
    } else {
      return const Text("");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('customer_list_title')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: <Widget>[
          PopupMenuButton<Locale>(
            onSelected: (Locale locale) {
              MyApp.of(context)!.changeLanguage(locale);
            },
            icon: const Icon(Icons.language_sharp),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              const PopupMenuItem<Locale>(
                value: Locale('en', 'CA'),
                child: Text('English'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('zh', 'Hans'),
                child: Text('中文'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              customerState.showUsageDialog(context);
            },
          ),
        ],
      ),
      body: responsiveLayout(context),
      floatingActionButton: ((width > height) && (width > 720) ||
          (width <= height && customerState.selectedCustomer == null)) &&
          !customerState.isAddingNewCustomer &&
          !customerState.isUpdatingCustomer
          ? FloatingActionButton(
        onPressed: pressAddCustomer,
        tooltip: AppLocalizations.of(context).translate('add_customer'),
        child: const Icon(Icons.add),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
