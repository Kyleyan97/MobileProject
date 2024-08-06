import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/AppLocalizations.dart';

import 'CustomerListPage.dart';

Widget addOrUpdateCustomerForm(CustomerListPageState state) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StreamBuilder<List<String>>(
            stream: state._lastNameSuggestionsController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return snapshot.data!.where((String option) {
                      return option.toLowerCase().contains(
                          textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    state._lastnameController.text = selection;
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    state._lastnameController = textEditingController;
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                            .translate('last_name_input'),
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                );
              } else {
                return TextField(
                  controller: state._lastnameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .translate('last_name_input'),
                    border: OutlineInputBorder(),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<String>>(
            stream: state._firstNameSuggestionsController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return snapshot.data!.where((String option) {
                      return option.toLowerCase().contains(
                          textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    state._firstnameController.text = selection;
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    state._firstnameController = textEditingController;
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                            .translate('first_name_input'),
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                );
              } else {
                return TextField(
                  controller: state._firstnameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .translate('first_name_input'),
                    border: OutlineInputBorder(),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<String>>(
            stream: state._addressSuggestionsController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return snapshot.data!.where((String option) {
                      return option.toLowerCase().contains(
                          textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    state._addressController.text = selection;
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    state._addressController = textEditingController;
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)
                            .translate('address_input'),
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                );
              } else {
                return TextField(
                  controller: state._addressController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)
                        .translate('address_input'),
                    border: OutlineInputBorder(),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            title: Text(state._birthday == null
                ? AppLocalizations.of(context).translate('select_birthday')
                : DateFormat.yMd().format(state._birthday!)),
            trailing: Icon(Icons.calendar_today),
            onTap: state._selectDate,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (state.isUpdatingCustomer) {
                state.updateCustomer();
              } else {
                state._addCustomer();
              }
            },
            child: Text(state.isUpdatingCustomer
                ? AppLocalizations.of(context).translate('update_customer')
                : AppLocalizations.of(context).translate('add_customer')),
          ),
        ],
      ),
    ),
  );
}
