import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:final_project/CustomerList/Customer.dart';
import 'package:final_project/CustomerList/CustomerDAO.dart';
import '../Database.dart';
import 'customer_widgets.dart';
import 'customer_form.dart';
import 'customer_utils.dart';
import 'package:final_project/AppLocalizations.dart';
import 'package:final_project/main.dart';
import 'dart:async';

class CustomerListPage extends StatefulWidget {

  //State<StatefulWidget> createState() {
    //return CustomerListPageState();
 // }
  @override
  CustomerListPageState createState() => CustomerListPageState();


}

class CustomerListPageState extends State<CustomerListPage> {
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
  final StreamController<List<String>> _firstNameSuggestionsController = StreamController<List<String>>();
  final StreamController<List<String>> _lastNameSuggestionsController = StreamController<List<String>>();
  final StreamController<List<String>> _addressSuggestionsController = StreamController<List<String>>();

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
     //showSnackBar(content, Text('welcome_to_customer_list'));
   // showSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome to Customer List')),
      );


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
    final database = await $FloorAppDatabase.databaseBuilder('app_database2.db').build();
    _customerDAO = database.customerDAO;
    _loadCustomers();
  }

  Future<void> initEncryptedSharedPreferences() async {
    savedData = EncryptedSharedPreferences();
  }

  Future<void> _loadCustomers() async {
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

  Future<void> _addCustomer() async {
    if (_lastnameController.text.isNotEmpty &&
        _firstnameController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _birthday != null) {
      final newCustomer = Customer(
        Customer.ID++, // This should be managed properly, consider using UUIDs or auto-incremented IDs from the database.
        _lastnameController.text,
        _firstnameController.text,
        _addressController.text,
        _birthday!,
      );
      try {
        await _customerDAO.insertCustomer(newCustomer);
        _loadCustomers();
        clearInputFields();
        setState(() {
          isAddingNewCustomer = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer added successfully')),
        );
      }catch (e) {
        print("Error adding customer: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add customer: $e')),
        );
      }
    } else {
      showAlertDialog(context, "Error", "All fields are required.");
    }
  }

  void clearInputFields() {
    _lastnameController.clear();
    _firstnameController.clear();
    _addressController.clear();
    _birthday = null;
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
      showAlertDialog(context, "Error", "All fields are required.");
    }
  }

  void _removeCustomer(Customer customer) async {
    await _customerDAO.deleteCustomer(customer);
    _loadCustomers();
    setState(() {
      selectedCustomer = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer deleted successfully')),
    );
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

  void pressAddCustomer() {
    setState(() {
      isAddingNewCustomer = true;
      isUpdatingCustomer = false;
    });
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('welcome_to_customer_list')),
      ),
    );
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customerDetails(context, this),
                ),
                //child: customerList(context, this),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customerDetails(context, this),
                ),
              )
            ],
          );
        } else {
          if (selectedCustomer == null) {
            return customerList(context, this);
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: customerDetails(context, this),
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
                child: customerList(context, this),
              ),
              Expanded(
                flex: 1,
                child: addOrUpdateCustomerForm(this),
              )
            ],
          );
        } else {
          return addOrUpdateCustomerForm(this);
        }
      } else if (!isAddingNewCustomer && isUpdatingCustomer) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: customerList(context, this),
              ),
              Expanded(
                flex: 1,
                child: addOrUpdateCustomerForm(this),
              )
            ],
          );
        } else {
          if (selectedCustomer == null) {
            return Text(AppLocalizations.of(context).translate('no_customer_selected'));
          } else {
            return addOrUpdateCustomerForm(this);
          }
        }
      } else {
        return const Text("");
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
              showUsageDialog(context);
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
}
