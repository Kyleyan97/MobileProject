import 'package:flutter/material.dart';
import 'package:final_project/AppLocalizations.dart';
import 'package:final_project/AirplaneList/Airplane.dart';
import 'package:final_project/AirplaneList/AirplaneDAO.dart';
import 'airplane_list_utils.dart';

Widget airplaneList(
    BuildContext context,
    List<Airplane> airplanes,
    Airplane? selectedAirplane,
    ScrollController _scrollController,
    AirplaneDAO myAirplaneDAO,
    Function loadAirplanes,
    Function(Airplane airplane) onDeleteAirplane, // 新增回调函数参数
    ) {
  return Padding(
    padding: const EdgeInsets.all(1.0),
    child: Scrollbar(
      controller: _scrollController,
      thickness: 8.0,
      radius: Radius.circular(10.0),
      thumbVisibility: false,
      child: airplanes.isEmpty
          ? Center(
        child: Text(AppLocalizations.of(context).translate('no_airplane_selected')),
      )
          : ListView.builder(
        controller: _scrollController,
        itemCount: airplanes.length,
        itemBuilder: (BuildContext context, int index) {
          var airplane = airplanes[index];
          return GestureDetector(
            onTap: () {
              // Update selected airplane
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Delete Airplane"),
                    content: const Text("Are you sure you want to delete this airplane?"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Yes"),
                        onPressed: () {
                          onDeleteAirplane(airplane); // 调用回调函数
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Airplane deleted successfully')),
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
                          "${airplane.type}",
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
                          "${AppLocalizations.of(context).translate('passengers')}: ${airplane.maxNumberOfPassenger}, ${AppLocalizations.of(context).translate('speed')}: ${airplane.maxSpeed}, ${AppLocalizations.of(context).translate('distance')}: ${airplane.maxDistance}",
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

Widget airplaneDetails(
    BuildContext context,
    Airplane? selectedAirplane,
    TextEditingController typeController,
    TextEditingController passengersController,
    TextEditingController speedController,
    TextEditingController distanceController,
    Function updateAirplane,
    int? _airplaneToUpdateId,
    bool isUpdatingAirplane,
    ) {
  if (selectedAirplane == null) {
    return Center(
      child: Text(AppLocalizations.of(context).translate('no_airplane_selected'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  } else {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(AppLocalizations.of(context).translate('airplane_detail'), style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
          Table(
            columnWidths: const {
              0: FixedColumnWidth(150.0),
              1: FlexColumnWidth(),
            },
            children: [
              TableRow(
                children: [
                  Text(AppLocalizations.of(context).translate('airplane_type'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                  Text('${selectedAirplane.type}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                ],
              ),
              TableRow(
                children: [
                  Text(AppLocalizations.of(context).translate('max_passengers'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                  Text('${selectedAirplane.maxNumberOfPassenger}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                ],
              ),
              TableRow(
                children: [
                  Text(AppLocalizations.of(context).translate('max_speed'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                  Text('${selectedAirplane.maxSpeed}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                ],
              ),
              TableRow(
                children: [
                  Text(AppLocalizations.of(context).translate('max_distance'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                  Text('${selectedAirplane.maxDistance}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Update airplane
                },
                child: Text(AppLocalizations.of(context).translate('update_airplane')),
              ),
              ElevatedButton(
                onPressed: () {
                  // Delete airplane
                },
                child: Text(AppLocalizations.of(context).translate('delete_airplane')),
              ),
              ElevatedButton(
                onPressed: () {
                  // Return to list
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

Widget addOrUpdateAirplaneForm(
    BuildContext context,
    TextEditingController typeController,
    TextEditingController passengersController,
    TextEditingController speedController,
    TextEditingController distanceController,
    Function handleSubmit,
    bool isUpdatingAirplane,
    ) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextField(
            controller: typeController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('airplane_type_input'),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: passengersController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('max_passengers_input'),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: speedController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('max_speed_input'),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: distanceController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('max_distance_input'),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              handleSubmit();
            },
            child: Text(isUpdatingAirplane ? AppLocalizations.of(context).translate('update_airplane') : AppLocalizations.of(context).translate('add_airplane')),
          ),
        ],
      ),
    ),
  );
}
