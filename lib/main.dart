import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'AirplaneList/airplane_list_page.dart';
import 'AppLocalizations.dart';
import 'CustomerList/CustomerListPage.dart';
import 'FlightList/FlightPage.dart';
import 'Reservation/ReservationPage.dart';


void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() {
    return _MyAppState();
  }

  /// Provides a static method to access the [MyAppState].
  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }
}

class _MyAppState extends State<MyApp>{
  /// The current locale of the app, initialized to English (Canada).
  var _locale = Locale("en","CA");

  /// Changes the current language of the app.
  void changeLanguage(Locale newLocale){
    setState(() {
      _locale = newLocale;
    });
  }

  /// Builds the MaterialApp with defined routes for navigation.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) => MyHomePage(title: AppLocalizations.of(context).translate('project_title')),
        '/CustomerListPage': (context) { return CustomerListPage(); },
        '/AirplaneListPage': (context) { return AirplaneListPage(); },
        '/FlightPage': (context) { return FlightPage(); },
        '/ReservationPage': (context) { return ReservationPage(); },
      },
      debugShowCheckedModeBanner: false,
      title: 'Final Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      supportedLocales: [
        const Locale('en', 'CA'),
        const Locale('zh', 'hans'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      initialRoute: '/home',
    );
  }
}

/// The home page widget of the application.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  /// The title of the home page.
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  /// Builds the UI of the home page including the AppBar and buttons for navigation.
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

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
        ],
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: customerListButtonClicked,
              child:Text(
                AppLocalizations.of(context).translate('customer_list'),
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: airplaneListButtonClicked,
              child:Text(
                AppLocalizations.of(context).translate('airplane_list'),
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: flightListButtonClicked,
              child:Text(
                AppLocalizations.of(context).translate('flight_list'),
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: reservationButtonClicked,
              child:Text(
                AppLocalizations.of(context).translate('reservation_list'),
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// Navigates to the Customer List Page.
  void customerListButtonClicked(){
    Navigator.pushNamed(context, "/CustomerListPage");
  }

  /// Navigates to the Airplane List Page.
  void airplaneListButtonClicked(){
    Navigator.pushNamed(context, "/AirplaneListPage");
  }

  /// Navigates to the Flight List Page.
  void flightListButtonClicked(){
    Navigator.pushNamed(context, "/FlightPage");
  }

  /// Navigates to the Reservation Page.
  void reservationButtonClicked(){
    Navigator.pushNamed(context, "/ReservationPage");
  }
}
