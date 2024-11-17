import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:Lucerna/carbon_footprint.dart';
import 'package:Lucerna/dashboard.dart';
import 'package:Lucerna/history_provider.dart';
import 'package:Lucerna/lamp_stat.dart';
import 'package:Lucerna/main.dart';
import 'API_KEY_Config.dart';

class chat extends StatefulWidget {
  final String? carbonFootprint; 
  final String? title;
  final String? category;
  final String? suggestion;
  final String? vehicleType;
  final String? distance;
  final String? energyUsed;
  final bool showAddRecordButton;

  const chat({
    Key? key,
    this.carbonFootprint,
    this.title,
    this.category,
    this.suggestion,
    this.vehicleType,
    this.distance,
    this.energyUsed,
    this.showAddRecordButton = false,
  }) : super(key: key);

  @override
  State<chat> createState() => _ChatState();
}



class _ChatState extends State<chat> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  double totalCarbonFootprint = 0;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);

    if (!widget.showAddRecordButton) {
      // Calculate cumulative carbon footprint from history
      for (var record in historyProvider.history) {
        totalCarbonFootprint += double.tryParse(record['carbonFootprint'] ?? '0') ?? 0;
      }
      messages.add({
        'text': 'Hello! I am a carbon footprint expert. Your cumulative carbon footprint based on your history is ${totalCarbonFootprint.toStringAsFixed(2)} kg CO₂. How can I assist you today?',
        'type': 'bot',
      });
    } else {
      messages.add({
        'text': 'Hello! I am a carbon footprint expert. '
                'Your current carbon footprint is ${widget.carbonFootprint} kg CO₂, derived from your ${widget.category}. '
                'How can I assist you today?',
        'type': 'bot',
      });
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add({'text': _controller.text, 'type': 'user'});
      });

      String userMessage = _controller.text;
      _controller.clear();

      String botResponse = await _getGeminiResponse(userMessage);
      setState(() {
        messages.add({'text': botResponse, 'type': 'bot'});
      });
    }
  }

  Future<String> _getGeminiResponse(String userMessage) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: ApiKeyConfig.geminiApiKey,
    );

    String chatHistory = messages.map((msg) {
      return '${msg['type'] == 'user' ? 'User' : 'Bot'}: ${msg['text']}';
    }).join('\n');

  String prompt;
    if (widget.showAddRecordButton) {
      prompt = '''
        You are a carbon footprint expert. The user's carbon footprint is ${widget.carbonFootprint} kg CO₂, derived from their ${widget.category}, other parameters are (if journey, the distance they travelled is ${widget.distance}, and vehicle type is ${widget.vehicleType}), (if energy, energy used is${widget.energyUsed}).
        Here is the chat history:
        $chatHistory
        User said: "$userMessage". 
        If the user wants to update their carbon footprint by adding or changing meals, journey options, or energy used, let them know how it will affect their footprint.
        Respond in a concise manner, limiting your response to 60 words.
        This chat should focus on ${widget.category}, and only allow modification of carbon footprint about the ${widget.category}.
        If the user updated their record, dont give an in between but a single estiamte. tell the user to click the "add record" button below if they want to add record. if the user wants to create new record, ask them to click the 3rd icon below to go add record page.
      ''';
    } else {
      // Use cumulative carbon footprint prompt when add record button is false
      prompt = '''
        You are a carbon footprint expert. The user's cumulative carbon footprint based on historical data is ${totalCarbonFootprint.toStringAsFixed(2)} kg CO₂.
        Here is the chat history:
        $chatHistory
        User said: "$userMessage". 
        Guide the user on how their historical footprint reflects on their lifestyle, and offer suggestions on how they can improve.
        Respond in a concise manner, limiting your response to 60 words.
      ''';
    }

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? 'No response from Gemini.';
      final words = responseText.split(' ');
      return words.take(60).join(' ');
    } catch (e) {
      print('Error calling Gemini API: $e');
      return 'Sorry, there was an error getting a response.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                Text(
                  'Chat with AI',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB7C49D), // Green box
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: messages.map((message) {
                                return _buildChatBubble(message);
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10), // Add space above the text field
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 20.0,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.black),
                              onPressed: _sendMessage,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (widget.showAddRecordButton)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRecordButton(
                        context,
                        'Return',
                        Theme.of(context).colorScheme.tertiary,
                      ),
                      _buildRecordButton(
                        context,
                        'Add Record',
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ],
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
          onPressed: () async {
            if (label == 'Return') {
              Navigator.pop(context);  // Goes back to previous screen
            } else if (label == 'Add Record') {
              // Check if there are any changes in the carbon footprint based on chat history
              String latestCarbonFootprint = await _checkForUpdatedCarbonFootprint();

              // If a new value is retrieved, update the footprint in HistoryProvider
              final carbonFootprintValue = latestCarbonFootprint.isNotEmpty
                  ? latestCarbonFootprint
                  : widget.carbonFootprint ?? '';

              Provider.of<HistoryProvider>(context, listen: false).addRecord(
                widget.title ?? '',
                widget.category ?? '',
                carbonFootprintValue,
                widget.suggestion ?? '',
                widget.vehicleType ?? '',
                widget.distance ?? '',
                widget.energyUsed ?? '',
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarbonFootprintTracker(),
                ),
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

  Future<String> _checkForUpdatedCarbonFootprint() async {
    // Extract the latest user message from the chat history
    String chatHistory = messages.map((msg) {
      return '${msg['type'] == 'user' ? 'User' : 'Bot'}: ${msg['text']}';
    }).join('\n');

    String prompt = '''
      You are a carbon footprint expert. The user has been updating their records in the chat.
      Here is the chat history:
      $chatHistory
      Check if the user has made any changes to the carbon footprint value in the latest messages.
      If the user has updated the footprint, provide the final updated carbon footprint value in kilograms (kg CO₂) only.
    ''';

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: ApiKeyConfig.geminiApiKey,
      );

      final response = await model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      // Attempt to extract the numeric footprint value from the response
      RegExp regex = RegExp(r'(\d+(\.\d+)?)');
      final match = regex.firstMatch(responseText);

      if (match != null) {
        return match.group(0) ?? '';
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
    }
    
    // Return an empty string if no new value is found
    return '';
  }



  Widget _buildChatBubble(Map<String, String> message) {
    bool isUserMessage = message['type'] == 'user';
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blue[100] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isUserMessage ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          message['text']!,
          style: TextStyle(
            color: isUserMessage ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromRGBO(173, 191, 127, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              icon: const Icon(Icons.pie_chart, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => dashboard()),
                );
              }),
          IconButton(
              icon: const Icon(Icons.lightbulb, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ecolight_stat()),
                );
              }),
          IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CarbonFootprintTracker()));
              }),
          IconButton(
              icon: Image.asset('assets/chat-b.png'), onPressed: () {}),
        ],
      ),
    );
  }
}