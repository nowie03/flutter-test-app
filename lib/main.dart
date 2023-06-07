import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

dynamic getWeather(var lat, var long) async {
  var url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${long}&appid=7bad00f2e703564969a401a2d81059a1&units=metric');

  var response = await http.get(url);
  if (response.statusCode == 200) {
    print(response.body);
    var res = response.body;

    return res;
  } else {
    return {};
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic temperature = null;
  var city;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchData(var lat, var long) async {
    var weather = await getWeather(lat, long);
    var weatherData = jsonDecode(weather);

    if (weatherData['main'] != null && weatherData['main']['temp'] != null) {
      temperature = weatherData['main']['temp'].toString();
      city = weatherData['name'];
    } else {
      temperature = 'N/A';
    }

    print(weather);
    setState(() {});
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      return;
    }
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      fetchData(_currentPosition?.latitude, _currentPosition?.longitude);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('LAT: ${_currentPosition?.latitude ?? ""}'),
            Text('LNG: ${_currentPosition?.longitude ?? ""}'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: getCurrentLocation,
              child: const Text("Get Current Location"),
            ),
            Text('Weather in ${city}'),
            if (temperature != null)
              Text(
                '${temperature} F',
                style: Theme.of(context).textTheme.headline6,
              ),
            if (temperature == null) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
