import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/AppLocalizations.dart';
import 'customer_state.dart';
import '../CustomerList/CustomerListPage.dart';

class CustomerForm extends StatelessWidget {
  final CustomerState customerState;

  CustomerForm(this.customerState);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StreamBuilder<List<String>>(
              stream: customerState._lastNameSuggestionsController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return snapshot.data!.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      customerState._lastnameController.text = selection;
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      customerState._lastnameController = textEditingController;
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate('last_name_input'),
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                  );
                } else {
                  return TextField(
                    controller: customerState._lastnameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('last_name_input'),
                      border: OutlineInputBorder(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<String>>(
              stream: customerState._firstNameSuggestionsController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return snapshot.data!.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      customerState._firstnameController.text = selection;
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      customerState._firstnameController = textEditingController;
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate('first_name_input'),
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                  );
                } else {
                  return TextField(
                    controller: customerState._firstnameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('first_name_input'),
                      border: OutlineInputBorder(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<String>>(
              stream: customerState._addressSuggestionsController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return snapshot.data!.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      customerState._addressController.text = selection;
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      customerState._addressController = textEditingController;
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate('address_input'),
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                  );
                } else {
                  return TextField(
                    controller: customerState._addressController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('address_input'),
                      border: OutlineInputBorder(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text(customerState._birthday == null
                  ? AppLocalizations.of(context).translate('select_birthday')
                  : DateFormat.yMd().format(customerState._birthday!)),
              trailing: Icon(Icons.calendar_today),
              onTap: () => customerState._selectDate(context),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (customerState.isUpdatingCustomer) {
                  customerState.updateCustomer();
                } else {
                  customerState._addCustomer();
                }
              },
              child: Text(customerState.isUpdatingCustomer ? AppLocalizations.of(context).translate('update_customer') : AppLocalizations.of(context).translate('add_customer')),
            ),
          ],
        ),
      ),
    );
  }
}
