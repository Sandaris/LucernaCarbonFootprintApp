import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Lucerna/carbon_footprint.dart';
import 'package:Lucerna/chat.dart';
import 'package:Lucerna/lamp_stat.dart';
import 'package:Lucerna/main.dart';
import 'history_provider.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  // Variable to track the selected timeframe
  String _footprint_selected = 'Monthly';
  String _offset_selected = 'Monthly';
  double totalCarbonFootprint = 0;
  

  // Image paths or widgets for each timeframe
  final Map<String, String> _footprint_Images = {
    'Daily': 'assets/daily_footprint.png', // Replace with actual asset path
    'Weekly': 'assets/weekly_footprint.png', // Replace with actual asset path
    'Monthly': 'assets/monthly_footprint.png', // Replace with actual asset path
  };

  final Map<String, String> _offset_Images = {
    'Daily': 'assets/daily_offset.png', // Replace with actual asset path
    'Weekly': 'assets/weekly_offset.png', // Replace with actual asset path
    'Monthly': 'assets/monthly_offset.png', // Replace with actual asset path
  };

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }


  void _initializeChat() {
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
      for (var record in historyProvider.history) {
        totalCarbonFootprint += double.tryParse(record['carbonFootprint'] ?? '0') ?? 0;
      }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        bottomNavigationBar: _buildBottomNavigationBar(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Lucerna',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 25),
                  // Emission & Offset stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CarbonStatCard('Total Carbon Emission', '85kg',
                          Theme.of(context).colorScheme.surface, true),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            textAlign: TextAlign.end,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'You have emitted\n',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .copyWith(color: Colors.black),
                                ),
                                TextSpan(
                                  text: '${totalCarbonFootprint.toStringAsFixed(2)}kg CO₂ \n',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary),
                                ),
                                TextSpan(
                                  text: 'so far today.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .copyWith(color: Colors.black),
                                ),
                                TextSpan(text: '- 3% per day'),
                              ],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'And with ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .copyWith(color: Colors.black),
                                ),
                                TextSpan(
                                  text: ' Ecolight ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .copyWith(
                                          color: Colors.white,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                ),
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: ' ...\n',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: '4.17kg CO₂ \n',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                    ),
                                    TextSpan(
                                      text: 'so far today.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(color: Colors.black),
                                    ),
                                    TextSpan(text: '+ 5% per day'),
                                  ],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      CarbonStatCard(
                          'Total Carbon Offset\nwith Ecolight',
                          '50kg',
                          Theme.of(context).colorScheme.secondary,
                          false),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Scrollable Carbon Footprint & Offset section
                  SizedBox(
                    height:
                        350, // Set a fixed height for the scrollable section
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CarbonFootprintSection(context),
                        SizedBox(
                          width: 30,
                        ),
                        CarbonOffsetSection(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom Widget for Emission and Offset Stats
  Widget CarbonStatCard(String label, String value, Color color, bool left) {
    double colourBox, outlineBox, gap;
    if (left) {
      colourBox = 10;
      outlineBox = 0;
      gap = 10;
    } else {
      colourBox = 0;
      outlineBox = 10;
      gap = 0;
    }
    return SizedBox(
      width: (MediaQuery.of(context).size.width * 0.25) + 10,
      height: 110,
      child: Stack(
        children: [
          // Colored Rectangle
          Positioned(
            left: colourBox,
            top: colourBox,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.25,
              height: 100,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ptSerif(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                    SizedBox(height: gap),
                    Text(
                      value,
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: Colors.white,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Outlined Rectangle (Offset)
          Positioned(
            left: outlineBox,
            top: outlineBox,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.25,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Carbon Footprint Section
  Widget CarbonFootprintSection(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        color: Color.fromRGBO(174, 171, 151, 0.5),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Carbon Footprint',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 30),
            Expanded(
              child: Center(
                child: Center(
                  child: Image.asset(
                    _footprint_Images[_footprint_selected]!,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeButton(
                    'Daily', Theme.of(context).colorScheme.primary, true),
                _buildTimeButton(
                    'Weekly', Theme.of(context).colorScheme.surface, true),
                _buildTimeButton(
                    'Monthly', Theme.of(context).colorScheme.tertiary, true),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Carbon Offset Section
  Widget CarbonOffsetSection(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        color: Color.fromRGBO(174, 171, 151, 0.5),
        padding: EdgeInsets.all(20),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Carbon Offset',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              SizedBox(height: 30),
              Expanded(
                child: Center(
                  child: Center(
                    child: Image.asset(
                      _offset_Images[_offset_selected]!,
                      // fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeButton(
                      'Daily', Theme.of(context).colorScheme.primary, false),
                  _buildTimeButton(
                      'Weekly', Theme.of(context).colorScheme.surface, false),
                  _buildTimeButton(
                      'Monthly', Theme.of(context).colorScheme.tertiary, false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(String label, Color color, bool footprint) {
    return SizedBox(
      width: 100,
      height: 25,
      child: ElevatedButton(
          onPressed: () {
            if (footprint) {
              setState(() {
                _footprint_selected = label;
              });
            } else {
              setState(() {
                _offset_selected = label;
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            // padding: const EdgeInsets.symmetric(vertical: 5.0),
          ),
          child: Text(
            label,
            style: GoogleFonts.ptSansCaption(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: Color.fromRGBO(173, 191, 127, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              icon: const Icon(
                Icons.pie_chart,
                color: Colors.black,
              ),
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => dashboard()),);
              }),
          IconButton(
              icon: const Icon(
                Icons.lightbulb,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ecolight_stat()),
                );
              }),
          IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CarbonFootprintTracker()));
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
