import 'dart:async';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:final_project/AppLocalizations.dart';
import 'package:final_project/CustomerList/Customer.dart';
import '../Database.dart';
import 'CustomerDAO.dart';
import 'customer_utils.dart';

class CustomerState {
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

  final StreamController<List<String>> _firstNameSuggestionsController =
  StreamController<List<String>>();
  final StreamController<List<String>> _lastNameSuggestionsController =
  StreamController<List<String>>();
  final StreamController<List<String>> _addressSuggestionsController =
  StreamController<List<String>>();

  void initializeState(BuildContext context) {
    _scrollController = ScrollController();
    _lastnameController = TextEditingController();
    _firstnameController = TextEditingController();
    _addressController = TextEditingController();
    initDatabase();
    initEncryptedSharedPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSnackBar(context,);
    });
  }

  void disposeState() {
    _scrollController.dispose();
    _lastnameController.dispose();
    _firstnameController.dispose();
    _addressController.dispose();
    _firstNameSuggestionsController.close();
    _lastNameSuggestionsController.close();
    _addressSuggestionsController.close();
  }

  Future<void> initDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _customerDAO = database.customerDAO;
    _loadCustomers();
  }

  Future<void> initEncryptedSharedPreferences() async {
    savedData = EncryptedSharedPreferences();
  }

  Future<void> _loadCustomers() async {
    _customers = await _customerDAO.getAllCustomers();
    _updateNameSuggestions();
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
        Customer.ID++,
        _lastnameController.text,
        _firstnameController.text,
        _addressController.text,
        _birthday!,
      );
      await _customerDAO.insertCustomer(newCustomer);
      _loadCustomers();
      clearInputFields();
      isAddingNewCustomer = false;
      showSnackBar(context, message: 'Customer added successfully');
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

  Future<void> _removeCustomer(Customer customer) async {
    await _customerDAO.deleteCustomer(customer);
    _loadCustomers();
    selectedCustomer = null;
    showSnackBar(context, message: 'Customer deleted successfully');
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _birthday) {
      _birthday = picked;
    }
  }

  Future<void> updateCustomer() async {
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
      isUpdatingCustomer = false;
      selectedCustomer = null;
      showSnackBar(context, message: 'Customer updated successfully');
    } else {
      showAlertDialog(context, "Error", "All fields are required.");
    }
  }

  void showSnackBar(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content);
  }