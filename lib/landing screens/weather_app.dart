// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// class WeatherApp extends StatefulWidget {
//   const WeatherApp({super.key});

//   @override
//   _WeatherAppState createState() => _WeatherAppState();
// }

// class _WeatherAppState extends State<WeatherApp> {
//   dynamic _currentWeather;
//   List<dynamic> _dailyForecast = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchWeatherData();
//   }

//   Future<void> fetchWeatherData() async {
//     final url = Uri.parse(
//         'https://weatherbit-v1-mashape.p.rapidapi.com/forecast/daily?lat=30.357807763581793&lon=73.38100730062037');
//     final headers = {
//       'X-RapidAPI-Key': 'd3851e3d38msh99ccc288c90e548p11565ajsn161f174ccd34',
//       'X-RapidAPI-Host': 'weatherbit-v1-mashape.p.rapidapi.com'
//     };

//     try {
//       final response = await http.get(url, headers: headers);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _currentWeather = data['data'][0];
//           _dailyForecast = data['data'].sublist(1);
//         });
//       } else {
//         setState(() {
//           _currentWeather = null;
//           _dailyForecast = [];
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _currentWeather = null;
//         _dailyForecast = [];
//       });
//     }
//   }

//  Widget _buildCurrentWeatherCard() {
//     final iconCode = _currentWeather['weather']['icon'];
//     final temperature = _currentWeather['temp'];
//     final description = _currentWeather['weather']['description'];

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               'Current Weather',
//               style: TextStyle(
//                 fontSize: 20.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 10.0),
//             Image.network(
//               'https://www.weatherbit.io/static/img/icons/$iconCode.png',
//               width: 100,
//               height: 100,
//             ),
//             SizedBox(height: 10.0),
//             Text(
//               'Temperature: $temperature°C',
//               style: TextStyle(fontSize: 18.0),
//             ),
//             SizedBox(height: 5.0),
//             Text(
//               'Description: $description',
//               style: TextStyle(fontSize: 18.0),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWeatherCard(dynamic weather) {
//   final date = DateTime.parse(weather['datetime']);
//   final dayOfWeek = DateFormat('EEEE').format(date);
//   final iconCode = weather['weather']['icon'];
//   final minTemp = weather['min_temp'];
//   final maxTemp = weather['max_temp'];
//   final description = weather['weather']['description'];

//   return Card(
//     child: ListTile(
//       leading: Image.network(
//         'https://www.weatherbit.io/static/img/icons/$iconCode.png',
//         width: 50,
//         height: 50,
//       ),
//       title: Text(dayOfWeek),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Min: $minTemp°C | Max: $maxTemp°C'),
//           Text('Description: $description'),
//         ],
//       ),
//     ),
//   );
// }


// @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Weather App'),
//         ),
//         body: _currentWeather != null
//             ? ListView(
//                 children: [
//                   _buildCurrentWeatherCard(),
//                   Divider(),
//                   ..._dailyForecast
//                       .map((weather) => _buildWeatherCard(weather))
//                       .toList(),
//                 ],
//               )
//             : Center(
//                 child: Text(
//                   _currentWeather == null
//                       ? 'Failed to fetch weather data'
//                       : 'No data available',
//                   style: TextStyle(fontSize: 18.0),
//                 ),
//               ),
//       );
//   }
// }

