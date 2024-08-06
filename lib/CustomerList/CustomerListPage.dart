// CustomerListPage.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:final_project/CustomerList/Customer.dart';
import 'package:final_project/CustomerList/CustomerDAO.dart';
import '../Database.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:final_project/AppLocalizations.dart';
import 'package:final_project/main.dart';
import 'dart:async';

class CustomerListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CustomerListPageState();
  }
}

class _CustomerListPageState extends State<CustomerListPage> {
  late EncryptedSharedPreferences savedData;
  late CustomerDAO _customerDAO;
  List<Customer> _customers = [];
  late ScrollController _scrollController;
  Customer? selectedCustomer;
  bool isAddingNewCustomer = false;
  bool isUpdatingCustomer = false;
  late TextEditingController _lastnameController;
  late TextEditingController _firstnameController;
  late TextEditingController _addressController;
  DateTime? _birthday;
  int? _customerToUpdateId;

  // Add separate StreamControllers for first name, last name, and address suggestions
  StreamController<List<String>> _firstNameSuggestionsController = StreamController<List<String>>();
  StreamController<List<String>> _lastNameSuggestionsController = StreamController<List<String>>();
  StreamController<List<String>> _addressSuggestionsController = StreamController<List<String>>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _lastnameController = TextEditingController();
    _firstnameController = TextEditingController();
    _addressController = TextEditingController();
    initDatabase();
    initEncryptedSharedPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSnackBar();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _lastnameController.dispose();
    _firstnameController.dispose();
    _addressController.dispose();
    _firstNameSuggestionsController.close();
    _lastNameSuggestionsController.close();
    _addressSuggestionsController.close();
    super.dispose();
  }

  void initDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _customerDAO = database.customerDAO;
    _loadCustomers();
  }

  void initEncryptedSharedPreferences() async {
    savedData = EncryptedSharedPreferences();
  }

  void _loadCustomers() async {
    _customers = await _customerDAO.getAllCustomers();
    _updateNameSuggestions();
    setState(() {});
  }

  void _updateNameSuggestions() {
    List<String> firstNames = _customers.map((customer) => customer.firstname).toList();
    List<String> lastNames = _customers.map((customer) => customer.lastname).toList();
    List<String> addresses = _customers.map((customer) => customer.address).toList();
    _firstNameSuggestionsController.add(firstNames);
    _lastNameSuggestionsController.add(lastNames);
    _addressSuggestionsController.add(addresses);
  }

  void _addCustomer() async {
    if (_lastnameController.text.isNotEmpty &&
        _firstnameController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _birthday != null) {
      //final uuid= build();

    // Check if customer ID already exists
    final existingCustomer = await _customerDAO.findCustomer(Customer.ID);
    if (existingCustomer != null) {
    showAlertDialog("Error", "Customer ID already exists.");
    return;
    }

      final newCustomer = Customer(
        Customer.ID++,
        _lastnameController.text,
        _firstnameController.text,
        _addressController.text,
        _birthday!,
      );
      await _customerDAO.insertCustomer(newCustomer);
      _loadCustomers();
      clearInputFields();
      setState(() {
        isAddingNewCustomer = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer added successfully')),
      );
    } else {
      showAlertDialog("Error", "All fields are required.");
    }
  }

  void clearInputFields() {
    _lastnameController.clear();
    _firstnameController.clear();
    _addressController.clear();
    _birthday = null;
  }

  void showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('welcome_to_customer_list')),
      ),
    );
  }

  Widget customerList() {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Scrollbar(
        controller: _scrollController,
        thickness: 8.0,
        radius: Radius.circular(10.0),
        thumbVisibility: false,
        child: _customers.isEmpty
            ? Center(
          child: Text(AppLocalizations.of(context).translate('no_customers_yet')),
        )
            : ListView.builder(
          controller: _scrollController,
          itemCount: _customers.length,
          itemBuilder: (BuildContext context, int index) {
            var customer = _customers[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCustomer = customer;
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
                          onPressed: () {
                            _customerDAO.deleteCustomer(customer);
                            _loadCustomers();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Customer deleted successfully')),
                            );
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

  Widget addOrUpdateCustomerForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StreamBuilder<List<String>>(
              stream: _lastNameSuggestionsController.stream,
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
                      _lastnameController.text = selection;
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      _lastnameController = textEditingController;
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
                    controller: _lastnameController,
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
              stream: _firstNameSuggestionsController.stream,
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
                      _firstnameController.text = selection;
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      _firstnameController = textEditingController;
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
                    controller: _firstnameController,
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
              stream: _addressSuggestionsController.stream,
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
                      _addressController.text = selection;
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      _addressController = textEditingController;
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
                    controller: _addressController,
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
              title: Text(_birthday == null
                  ? AppLocalizations.of(context).translate('select_birthday')
                  : DateFormat.yMd().format(_birthday!)),
              trailing: Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (isUpdatingCustomer) {
                  updateCustomer();
                } else {
                  _addCustomer();
                }
              },
              child: Text(isUpdatingCustomer ? AppLocalizations.of(context).translate('update_customer') : AppLocalizations.of(context).translate('add_customer')),
            ),
          ],
        ),
      ),
    );
  }

  void updateCustomer() async {
    if (_lastnameController.text.isNotEmpty &&
        _firstnameController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _birthday != null &&
        _customerToUpdateId != null) {
      final customer = Customer(
        _customerToUpdateId!,
        _lastnameController.text,
        _firstnameController.text,
        _addressController.text,
        _birthday!,
      );
      await _customerDAO.updateCustomer(customer);
      _loadCustomers();
      clearInputFields();
      setState(() {
        isUpdatingCustomer = false;
        selectedCustomer = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer updated successfully')),
      );
    } else {
      showAlertDialog("Error", "All fields are required.");
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _birthday) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    Widget responsiveLayout() {
      if (!isAddingNewCustomer && !isUpdatingCustomer) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: customerList(),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customerDetails(),
                ),
              )
            ],
          );
        } else {
          if (selectedCustomer == null) {
            return customerList();
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: customerDetails(),
            );
          }
        }
      } else if (isAddingNewCustomer && !isUpdatingCustomer) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: customerList(),
              ),
              Expanded(
                flex: 1,
                child: addOrUpdateCustomerForm(),
              )
            ],
          );
        } else {
          return addOrUpdateCustomerForm();
        }
      } else if (!isAddingNewCustomer && isUpdatingCustomer) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: customerList(),
              ),
              Expanded(
                flex: 1,
                child: addOrUpdateCustomerForm(),
              )
            ],
          );
        } else {
          if (selectedCustomer == null) {
            return Text(AppLocalizations.of(context).translate('no_customer_selected'));
          } else {
            return addOrUpdateCustomerForm();
          }
        }
      } else {
        return Text("");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('customer_list_title')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: <Widget>[

          PopupMenuButton<Locale>(
            onSelected: (Locale locale) {
              MyApp.of(context)!.changeLanguage(locale); // Replace with your language change logic
            },
            icon: Icon(Icons.language_sharp),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              PopupMenuItem<Locale>(
                value: const Locale('en', 'CA'),
                child: Text('English'),
              ),
              PopupMenuItem<Locale>(
                value: const Locale('zh', 'Hans'),
                child: Text('中文'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showUsageDialog(context);
            },
          ),
        ],
      ),
      body: responsiveLayout(),
      floatingActionButton: ((width > height) && (width > 720) ||
          (width <= height && selectedCustomer == null)) &&
          !isAddingNewCustomer &&
          !isUpdatingCustomer
          ? FloatingActionButton(
        onPressed: pressAddCustomer,
        tooltip: AppLocalizations.of(context).translate('add_customer'),
        child: const Icon(Icons.add),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void pressAddCustomer() {
    setState(() {
      isAddingNewCustomer = true;
      isUpdatingCustomer = false;
    });
  }

  void _showUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('instructions')),
          content: Text(AppLocalizations.of(context).translate('instructions_detail')),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).translate('close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget customerDetails() {
    if (selectedCustomer == null) {
      return Center(
        child: Text(AppLocalizations.of(context).translate('no_customer_selected'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context).translate('customer_detail'), style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(150.0),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('last_name'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                    Text('${selectedCustomer!.lastname}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                  ],
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('first_name'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                    Text('${selectedCustomer!.firstname}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                  ],
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('address'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                    Text('${selectedCustomer!.address}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                  ],
                ),
                TableRow(
                  children: [
                    Text(AppLocalizations.of(context).translate('birthday'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                    Text('${DateFormat.yMd().format(selectedCustomer!.birthday)}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isUpdatingCustomer = true;
                      _customerToUpdateId = selectedCustomer!.id;
                      _lastnameController.text = selectedCustomer!.lastname;
                      _firstnameController.text = selectedCustomer!.firstname;
                      _addressController.text = selectedCustomer!.address;
                      _birthday = selectedCustomer!.birthday;
                    });
                  },
                  child: Text(AppLocalizations.of(context).translate('update_customer')),
                ),
                ElevatedButton(
                  onPressed: () => _removeCustomer(selectedCustomer!),
                  child: Text(AppLocalizations.of(context).translate('delete_customer')),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCustomer = null;
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

  void _removeCustomer(Customer customer) async {
    await _customerDAO.deleteCustomer(customer);
    _loadCustomers();
    setState(() {
      selectedCustomer = null;
    });
  }
}
