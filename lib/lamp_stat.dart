import 'package:flutter/material.dart';
import 'package:Lucerna/carbon_footprint.dart';
import 'package:Lucerna/chat.dart';
import 'package:Lucerna/dashboard.dart';
import 'package:Lucerna/main.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math'; // As of now, there is only 1 ecolight hardware, and flask is not connected, so we import to generate random values
import 'package:http/http.dart' as http;

//server's IP address
const String apiUrl = "http://192.168.153.187:5001/getData";

class ecolight_stat extends StatefulWidget {
  const ecolight_stat({super.key});

  @override
  State<ecolight_stat> createState() => _ecolight_statState();
}

class _ecolight_statState extends State<ecolight_stat> {
  // Initialize the data with default values.
  Map<String, dynamic> latestData = {
    'light': '0',
    'temperature': '0',
    'carbon': '0',
    'algaeBiomass': 'False',
  };

  @override
  void initState() {
    super.initState();
    // Fetch data initially, if there is the hardware.
    generateRandomData();
    // fetchData();

    // Set up a timer to generate data every few seconds
    Timer.periodic(Duration(seconds: 5), (Timer t) => generateRandomData());
    // Timer.periodic(Duration(seconds: 5), (Timer t) => fetchData());
  }

  // Function to generate random data within specified ranges
  void generateRandomData() {
    final random = Random();
    
    setState(() {
      latestData = {
        'light': (290 + random.nextInt(21)).toString(), // 290 to 310 lx
        'temperature': (28 + random.nextInt(3)).toString(), // 28 to 30 °C
        'carbon': (700 + random.nextInt(31)).toString(), // 700 to 730 ppm
        'algaeBiomass': random.nextBool().toString() // Random true/false
      };
    });
  }

  // Function to fetch data from the Rapsberry Pi Flask
  Future<void> fetchData() async {
    try {
      // Make the GET request
      final response = await http.get(Uri.parse(apiUrl));

      // Check if the response status is successful
      if (response.statusCode == 200) {
        // Decode the JSON data from the response
        var data = json.decode(response.body);

        // Update the state with the new data
        setState(() {
          latestData = {
            'light': data['light'].toString(),
            'temperature': data['temperature'].toString(),
            'carbon': data['carbon'].toString(),
            'algaeBiomass': data['algaeBiomass'].toString(),
          };
        });
      } else {
        // Handle any error codes
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      // Catch any exceptions and print an error message
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: EcolightMeasuresScreen(data: latestData),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Color.fromRGBO(173, 191, 127, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              icon: const Icon(
                Icons.pie_chart,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => dashboard()),
                );
              }),
          IconButton(
              icon: const Icon(
                Icons.lightbulb,
                color: Colors.black,
              ),
              onPressed: () {}),
          IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CarbonFootprintTracker()),
                );
              }),
          IconButton(
              icon: Image.asset('assets/chat-w.png'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => chat(carbonFootprint: '10', showAddRecordButton: false)),
                );
              }),
        ],
      ),
    );
  }
}

class EcolightMeasuresScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const EcolightMeasuresScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                child: Text(
                  'Ecolight \nMeasures',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(children: [
                    StatCard(
                      img: 'assets/light.png',
                      title: 'Light Intensity',
                      value: data['light'],
                      color: Theme.of(context).colorScheme.secondary,
                      unit: 'lx',
                    ),
                    SizedBox(height: 30),
                    StatCard(
                      img: 'assets/co2.png',
                      title: 'Carbon Dioxide Level',
                      value: data['carbon'],
                      color: Theme.of(context).colorScheme.tertiary,
                      unit: 'ppm',
                    ),
                    SizedBox(height: 30),
                    StatCard(
                      img: 'assets/temparature.png',
                      title: 'Temperature',
                      value: data['temperature'],
                      color: Theme.of(context).colorScheme.surface,
                      unit: '°C',
                    ),
                    SizedBox(height: 30),
                    StatCard(
                      img: 'assets/algaeBiomass.png',
                      title: 'Algae Bloom Status',
                      value: '50',
                      color: Theme.of(context).colorScheme.primary,
                      unit: '',
                    ),
                  ]),
                ),
                Image.asset('assets/lamp.png', height: 535),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String img;
  final String title;
  final String value;
  final Color color;
  final String unit;

  const StatCard({
    super.key,
    required this.img,
    required this.title,
    required this.value,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: color,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(25, 8, 8, 8),
          minVerticalPadding: 10,
          leading: Image.asset(
            img,
            height: 50,
            width: 50,
          ),
          title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10)
              ]),
          subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$value $unit',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ]),
        ),
      ),
    );
  }
}
