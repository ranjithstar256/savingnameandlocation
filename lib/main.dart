import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'Person.dart'; // Import the Person entity
import 'objectbox.g.dart'; // Import the generated code



import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> deleteDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final objectBoxDir = Directory('${dir.path}/objectbox');
  if (await objectBoxDir.exists()) {
    await objectBoxDir.delete(recursive: true);
    print("Database deleted successfully");
  } else {
    print("Database directory not found");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await deleteDatabase(); // Delete existing database files
  final store = await openStore(); // Initialize ObjectBox
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store store;

  const MyApp({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ObjectBox Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(store: store),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Store store;

  const HomeScreen({Key? key, required this.store}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Box<Person> personBox;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _retrievedLocation;

  @override
  void initState() {
    super.initState();
    personBox = widget.store.box<Person>();
  }

  void _savePerson() {
    final name = _nameController.text;
    final location = _locationController.text;

    if (name.isNotEmpty && location.isNotEmpty) {
      final person = Person(name: name, location: location);
      personBox.put(person); // Save to ObjectBox
      _nameController.clear();
      _locationController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both name and location')),
      );
    }
  }

  void _retrieveLocation() {
    final name = _nameController.text;

    if (name.isNotEmpty) {
      final query = personBox.query(Person_.name.equals(name)).build();
      final person = query.findFirst();
      setState(() {
        _retrievedLocation = person?.location ?? 'Not found';
      });
      query.close();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name to search')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ObjectBox Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter name'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(hintText: 'Enter location'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePerson,
              child: const Text('Save Person'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retrieveLocation,
              child: const Text('Retrieve Location by Name'),
            ),
            const SizedBox(height: 20),
            if (_retrievedLocation != null)
              Text('Location: $_retrievedLocation'),
          ],
        ),
      ),
    );
  }
}
