import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

void main() {
  runApp(FrenchLearningApp());
}

class FrenchLearningApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'French Learning App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learn French Verbs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Text(
              'Verbs A-Z',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildLetterRangeButton(context, 'A-C'),
                _buildLetterRangeButton(context, 'D-F'),
                _buildLetterRangeButton(context, 'G-I'),
                _buildLetterRangeButton(context, 'J-L'),
                _buildLetterRangeButton(context, 'M-O'),
                _buildLetterRangeButton(context, 'P-R'),
                _buildLetterRangeButton(context, 'S-U'),
                _buildLetterRangeButton(context, 'V-Z'),
              ],
            ),
            SizedBox(height: 40),
            Text(
              'Enable Notifications',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationResultPage(enabled: true)),
                    );
                  },
                  child: Text('Yes'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationResultPage(enabled: false)),
                    );
                  },
                  child: Text('No'),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                try {
                  SystemNavigator.pop(); // Attempt to exit the app
                } catch (e) {
                  Navigator.of(context).pop(); // Fallback if the system method fails
                }
              },
              child: Text('Quit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterRangeButton(BuildContext context, String range) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerbListScreen(letterRange: range),
          ),
        );
      },
      child: Text(range),
    );
  }
}

class VerbListScreen extends StatefulWidget {
  final String letterRange;

  VerbListScreen({required this.letterRange});

  @override
  _VerbListScreenState createState() => _VerbListScreenState();
}

class _VerbListScreenState extends State<VerbListScreen> {
  List<Map<String, String>> verbs = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVerbsFromFile(widget.letterRange);
  }

  void _loadVerbsFromFile(String range) async {
    try {
      final data = await rootBundle.loadString('assets/Verbs.csv');
      final fields = const CsvToListConverter(fieldDelimiter: '|').convert(data);

      setState(() {
        verbs = fields.map((row) {
          return {
            'verb': row[0].toString(),
            'definition': row[1].toString(),
            'je': row[2].toString(),
            'tu': row[3].toString(),
            'il/elle': row[4].toString(),
            'nous': row[5].toString(),
            'vous': row[6].toString(),
            'ils/elles': row[7].toString(),
            'past_participle': row[8].toString(),
          };
        }).where((verb) {
          final firstLetter = verb['verb']![0].toUpperCase();
          return range.contains(firstLetter);
        }).toList();

        verbs.sort((a, b) => a['verb']!.compareTo(b['verb']!));
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error loading file: $e";
        print(errorMessage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verbs ${widget.letterRange}'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pop(context);  // Return to the landing page
          },
        ),
      ),
      body: errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
        itemCount: verbs.length,
        itemBuilder: (context, index) {
          final verb = verbs[index];
          return ListTile(
            title: Text(verb['verb']!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Definition: ${verb['definition']}'),
                Text('Je: ${verb['je']}'),
                Text('Tu: ${verb['tu']}'),
                Text('Il/Elle: ${verb['il/elle']}'),
                Text('Nous: ${verb['nous']}'),
                Text('Vous: ${verb['vous']}'),
                Text('Ils/Elles: ${verb['ils/elles']}'),
                Text('Past Participle: ${verb['past_participle']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NotificationResultPage extends StatelessWidget {
  final bool enabled;

  NotificationResultPage({required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Center(
        child: Text(
          enabled ? 'Notifications Enabled' : 'Notifications Disabled',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
