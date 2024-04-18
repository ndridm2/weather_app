import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/bloc/weather_bloc_bloc.dart';
import 'package:weather_app/pages/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(future: _determinePosition(), builder: (context, snap) {
        if (snap.hasData) {
          return BlocProvider<WeatherBlocBloc>(
            create: (context) =>  WeatherBlocBloc()..add(FetchWeather(snap.data as Position)),
            child: const HomeScreen(),
            );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
      ),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnable;
  LocationPermission permission;

  serviceEnable = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnable) {
    return Future.error('Location service is disabled');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permission is denied');
    }
  }
  if (permission == LocationPermission.deniedForever){
    return Future.error('Location permission is permanently denied, we cannot request permission.');
  }
  return await Geolocator.getCurrentPosition();
}
