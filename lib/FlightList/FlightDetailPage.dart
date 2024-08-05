import 'package:flutter/material.dart';
import '../AppLocalizations.dart';
import '../FlightList/Flight.dart';

/// This class represents the flight detail page.
class FlightDetailPage extends StatelessWidget {
  final Flight flight;
  final Function(Flight) onUpdateFlight;
  final Function(Flight) onDeleteFlight;
  final VoidCallback onReturnToList;

  const FlightDetailPage(
      {required this.flight,
        required this.onUpdateFlight,
        required this.onDeleteFlight,
        required this.onReturnToList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(AppLocalizations.of(context).translate('flight_detail'), style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                Table(
                  columnWidths: const {
                    0: FixedColumnWidth(150.0),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        Text(AppLocalizations.of(context).translate('flight_number'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                        Text('${flight.flightNumber}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(AppLocalizations.of(context).translate('departure_city'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                        Text('${flight.departureCity}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(AppLocalizations.of(context).translate('destination_city'), style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                        Text('${flight.destinationCity}', style: const TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.left),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          AppLocalizations.of(context).translate('departure_time'),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          '${TimeOfDay.fromDateTime(flight.departureTime).format(context)}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          AppLocalizations.of(context).translate('arrival_time'),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          '${TimeOfDay.fromDateTime(flight.arrivalTime).format(context)}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onUpdateFlight(flight);
                  },
                  child: Text(AppLocalizations.of(context).translate('update_flight')),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    onDeleteFlight(flight);
                  },
                  child: Text(AppLocalizations.of(context).translate('delete_flight')),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onReturnToList,
                  child: Text(AppLocalizations.of(context).translate('return_to_list')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
