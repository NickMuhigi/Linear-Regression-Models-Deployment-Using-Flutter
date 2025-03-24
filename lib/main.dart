import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prediction App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InputPage(),
    );
  }
}

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _nameController = TextEditingController();
  final _jobController = TextEditingController();
  final _experienceController = TextEditingController();

  void _navigateToPredictionPage(BuildContext context) {
    final name = _nameController.text;
    final job = _jobController.text;
    final experience = _experienceController.text;

    if (name.isNotEmpty && job.isNotEmpty && experience.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  PredictionPage(name: name, job: job, experience: experience),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Please fill in all fields.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Input Page')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _jobController,
              decoration: InputDecoration(
                labelText: 'Enter your job title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _experienceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter years of experience',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToPredictionPage(context),
              child: Text('Predict'),
            ),
          ],
        ),
      ),
    );
  }
}

class PredictionPage extends StatefulWidget {
  final String name;
  final String job;
  final String experience;

  PredictionPage({
    required this.name,
    required this.job,
    required this.experience,
  });

  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  String _prediction = '';
  String _error = '';

  Future<void> _makePrediction() async {
    // Update the API URL based on the platform
    final url =
        'http://192.168.1.82:8000/predict'; // Use correct local IP for device

    try {
      print("🔍 Sending request to API...");
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'feature': double.tryParse(widget.experience) ?? 0.0,
        }),
      );

      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          setState(() {
            _prediction = '';
            _error = data['error'];
          });
        } else {
          setState(() {
            _prediction = data['prediction'].toString();
            _error = '';
          });
        }
      } else {
        setState(() {
          _error = 'Failed to get a response from the API.';
          _prediction = '';
        });
      }
    } catch (e) {
      print('🚨 Error: $e');
      setState(() {
        _error = 'Could not connect to the API.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _testApiConnection();
  }

  void _testApiConnection() async {
    final url = '192.168.1.82:8000/docs'; // Test API connection

    try {
      final response = await http.get(Uri.parse(url));
      print('🟢 API Test Response: ${response.statusCode}');
    } catch (e) {
      print('🚨 API Connection Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prediction Page')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Hello, ${widget.name}!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Job: ${widget.job}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text(
              'Years of Experience: ${widget.experience}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _makePrediction,
              child: Text('Predict Salary'),
            ),
            SizedBox(height: 20),
            if (_prediction.isNotEmpty)
              Text(
                'Predicted Salary: $_prediction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            if (_error.isNotEmpty)
              Text(
                'Error: $_error',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
