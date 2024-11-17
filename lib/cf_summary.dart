import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lucerna/carbon_footprint.dart';
import 'package:Lucerna/chat.dart';
import 'package:Lucerna/dashboard.dart';
import 'package:Lucerna/history_provider.dart';
import 'package:Lucerna/lamp_stat.dart';
import 'package:Lucerna/main.dart';

class CFSummaryPage extends StatelessWidget {
  final String title;
  final String category;
  final String carbon_footprint;
  final String suggestion;
  final String? vehicleType;
  final String? distance;
  final String? energyUsed;

  // Constructor to receive the data
  CFSummaryPage({
    required this.title,
    required this.category,
    required this.carbon_footprint,
    required this.suggestion,
    required this.vehicleType,
    required this.distance,
    required this.energyUsed,
  });

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        backgroundColor: Color(0xFFB7C49D), // Light green background color
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Review\nCarbon Footprint',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(20.0),
                                margin: EdgeInsets.symmetric(horizontal: 30),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildRecordButton(
                                            context,
                                            'Cancel',
                                            Theme.of(context)
                                                .colorScheme
                                                .tertiary),
                                        _buildRecordButton(
                                            context,
                                            'Add Record',
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    Text(
                                      'Carbon Footprint',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(color: Colors.black),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      child: Text(
                                        '$carbon_footprint kg',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                      ),
                                    ),
                                    _buildCategoryLabel(context, category),
                                    Divider(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      thickness: 1.0,
                                      height: 41.0,
                                      indent: MediaQuery.of(context).size.width *
                                          0.05,
                                      endIndent: MediaQuery.of(context).size.width *
                                          0.05,
                                    ),
                                    Text(
                                      suggestion,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(color: Colors.black),
                                    ),
                                    // New button to redirect to chat
                                    // New button to redirect to chat
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => chat(
                                              carbonFootprint: carbon_footprint,
                                              title: title,
                                              category: category,
                                              vehicleType: vehicleType,
                                              suggestion: suggestion,
                                              distance: distance,
                                              energyUsed: energyUsed,
                                              showAddRecordButton: true,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary, // Button color
                                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Larger padding
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8), // Rounded corners
                                        ),
                                      ),
                                      child: Text(
                                        'Discuss with AI Chat',
                                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                          color: Colors.white,
                                          fontSize: 20, // Larger font size
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildRecordButton(
    BuildContext context,
    String label,
    Color color,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 35),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: ElevatedButton(
          onPressed: () {
            if (label == 'Cancel') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CarbonFootprintTracker()));
            }
            if (label == 'Add Record') {
              Provider.of<HistoryProvider>(context, listen: false).addRecord(
                  title,
                  category,
                  carbon_footprint,
                  suggestion,
                  vehicleType,
                  distance,
                  energyUsed);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CarbonFootprintTracker()),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displayLarge!
                .copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryLabel(BuildContext context, String label) {
    Color color;
    switch (label) {
      case ('Food'):
        color = Theme.of(context).colorScheme.tertiary;
        break;

      case ('Journey'):
        color = Theme.of(context).colorScheme.surface;
        break;

      case ('Energy'):
        color = Theme.of(context).colorScheme.surfaceBright;
        break;

      default:
        color = Colors.black;
        break;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 100,
        color: color,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .displayLarge!
              .copyWith(color: Colors.white),
        ),
      ),
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
                // Pass carbon_footprint to chat
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => chat(
                      carbonFootprint: carbon_footprint,
                      title: title,
                      category: category,
                      vehicleType: vehicleType,
                      suggestion: suggestion,
                      distance: distance,
                      energyUsed: energyUsed,
                      showAddRecordButton: true,
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

}
