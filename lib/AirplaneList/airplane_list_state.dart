import 'package:flutter/material.dart';
import 'package:final_project/AppLocalizations.dart';
import 'package:final_project/AirplaneList/Airplane.dart';
import 'package:final_project/AirplaneList/AirplaneDAO.dart';
import 'package:final_project/Database.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../main.dart';
import 'airplane_list_page.dart';
import 'airplane_list_utils.dart';
import 'package:final_project/AirplaneList/airplane_list_ui.dart';


class AirplaneListState extends State<AirplaneListPage> {
  late EncryptedSharedPreferences savedData;
  late AirplaneDAO myAirplaneDAO;
  List<Airplane> airplanes = [];
  late ScrollController _scrollController;
  Airplane? selectedAirplane;
  bool isAddingNewAirplane = false;
  bool isUpdatingAirplane = false;
  late TextEditingController typeController;
  late TextEditingController passengersController;
  late TextEditingController speedController;
  late TextEditingController distanceController;
  int? _airplaneToUpdateId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    typeController = TextEditingController();
    passengersController = TextEditingController();
    speedController = TextEditingController();
    distanceController = TextEditingController();
    initDb();
    initEncryptedSharedPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSnackBar(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    typeController.dispose();
    passengersController.dispose();
    speedController.dispose();
    distanceController.dispose();
    super.dispose();
  }

  void initDb() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    myAirplaneDAO = database.airplaneDAO;
    loadAirplanes();
  }

  void loadAirplanes() async {
    airplanes = await myAirplaneDAO.findAllAirplanes();
    setState(() {});
  }

  void initEncryptedSharedPreferences() async {
    savedData = EncryptedSharedPreferences();
  }

  void addAirplane() async {
    if (typeController.text.isNotEmpty &&
        passengersController.text.isNotEmpty &&
        speedController.text.isNotEmpty &&
        distanceController.text.isNotEmpty) {
      final airplane = Airplane(
        Airplane.ID++,
        typeController.text,
        int.parse(passengersController.text),
        int.parse(speedController.text),
        int.parse(distanceController.text),
      );
      await myAirplaneDAO.insertAirplane(airplane);
      loadAirplanes();
      clearInputFields();
      setState(() {
        isAddingNewAirplane = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Airplane added successfully')),
      );
    } else {
      showAlertDialog(context, "Error", "All fields are required.");
    }
  }

  void clearInputFields() {
    typeController.clear();
    passengersController.clear();
    speedController.clear();
    distanceController.clear();
  }

  void updateAirplane() async {
    if (typeController.text.isNotEmpty &&
        passengersController.text.isNotEmpty &&
        speedController.text.isNotEmpty &&
        distanceController.text.isNotEmpty &&
        _airplaneToUpdateId != null) {
      final airplane = Airplane(
        _airplaneToUpdateId!,
        typeController.text,
        int.parse(passengersController.text),
        int.parse(speedController.text),
        int.parse(distanceController.text),
      );
      await myAirplaneDAO.updateAirplane(airplane);
      loadAirplanes();
      clearInputFields();
      setState(() {
        isUpdatingAirplane = false;
        selectedAirplane = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Airplane updated successfully')),
      );
    } else {
      showAlertDialog(context, "Error", "All fields are required.");
    }
  }

  void _removeAirplane(Airplane airplane) async {
    await myAirplaneDAO.deleteAirplane(airplane);
    loadAirplanes();
    setState(() {
      selectedAirplane = null;
    });
  }

  void pressAddAirplane() {
    setState(() {
      isAddingNewAirplane = true;
      isUpdatingAirplane = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    Widget responsiveLayout() {
      if (!isAddingNewAirplane && !isUpdatingAirplane) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: airplaneList(context, airplanes, selectedAirplane, _scrollController, myAirplaneDAO, loadAirplanes, _removeAirplane),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: airplaneDetails(context, selectedAirplane, typeController, passengersController, speedController, distanceController, updateAirplane, _airplaneToUpdateId, isUpdatingAirplane),
                ),
              )
            ],
          );
        } else {
          if (selectedAirplane == null) {
            return airplaneList(context, airplanes, selectedAirplane, _scrollController, myAirplaneDAO, loadAirplanes, _removeAirplane);
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: airplaneDetails(context, selectedAirplane, typeController, passengersController, speedController, distanceController, updateAirplane, _airplaneToUpdateId, isUpdatingAirplane),
            );
          }
        }
      } else if (isAddingNewAirplane && !isUpdatingAirplane) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: airplaneList(context, airplanes, selectedAirplane, _scrollController, myAirplaneDAO, loadAirplanes, _removeAirplane),
              ),
              Expanded(
                flex: 1,
                child: addOrUpdateAirplaneForm(context, typeController, passengersController, speedController, distanceController, addAirplane, isUpdatingAirplane),
              )
            ],
          );
        } else {
          return addOrUpdateAirplaneForm(context, typeController, passengersController, speedController, distanceController, addAirplane, isUpdatingAirplane);
        }
      } else if (!isAddingNewAirplane && isUpdatingAirplane) {
        if ((width > height) && (width > 720)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: airplaneList(context, airplanes, selectedAirplane, _scrollController, myAirplaneDAO, loadAirplanes, _removeAirplane),
              ),
              Expanded(
                flex: 1,
                child: addOrUpdateAirplaneForm(context, typeController, passengersController, speedController, distanceController, updateAirplane, isUpdatingAirplane),
              )
            ],
          );
        } else {
          if (selectedAirplane == null) {
            return Text(AppLocalizations.of(context).translate('no_airplane_selected'));
          } else {
            return addOrUpdateAirplaneForm(context, typeController, passengersController, speedController, distanceController, updateAirplane, isUpdatingAirplane);
          }
        }
      } else {
        return Text("");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('airplane_list_title')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: <Widget>[
          PopupMenuButton<Locale>(
            onSelected: (Locale locale) {
              MyApp.of(context)!.changeLanguage(locale);
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
          (width <= height && selectedAirplane == null)) &&
          !isAddingNewAirplane &&
          !isUpdatingAirplane
          ? FloatingActionButton(
        onPressed: pressAddAirplane,
        tooltip: AppLocalizations.of(context).translate('add_airplane'),
        child: const Icon(Icons.add),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
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
}
