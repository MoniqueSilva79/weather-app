import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiKey = String.fromEnvironment('OWM_API_KEY');
const baseUrl = 'https://api.openweathermap.org/data/2.5';

void main() => runApp(const WeatherApp());

class Weather {
  final String city, description, icon;
  final double temp, feelsLike, wind;
  final int humidity;

  Weather.fromJson(Map<String, dynamic> j)
      : city = j['name'],
        description = j['weather'][0]['description'],
        icon = j['weather'][0]['icon'],
        temp = (j['main']['temp'] as num).toDouble(),
        feelsLike = (j['main']['feels_like'] as num).toDouble(),
        humidity = j['main']['humidity'],
        wind = (j['wind']['speed'] as num).toDouble();
}

class Forecast {
  final DateTime time;
  final double temp;
  final String icon;

  Forecast.fromJson(Map<String, dynamic> j)
      : time = DateTime.fromMillisecondsSinceEpoch(j['dt'] * 1000),
        temp = (j['main']['temp'] as num).toDouble(),
        icon = j['weather'][0]['icon'];
}

Future<Map<String, dynamic>> _get(String path, String city) async {
  final uri = Uri.parse('$baseUrl/$path?q=${Uri.encodeComponent(city)}&appid=$apiKey&units=metric&lang=pt_br');
  final res = await http.get(uri);
  if (res.statusCode == 404) throw Exception('Cidade não encontrada');
  if (res.statusCode != 200) throw Exception('Erro ${res.statusCode} ao consultar o clima');
  return jsonDecode(res.body);
}

Future<(Weather, List<Forecast>)> fetchAll(String city) async {
  final now = Weather.fromJson(await _get('weather', city));
  final fc = await _get('forecast', city);
  final list = (fc['list'] as List).take(8).map((e) => Forecast.fromJson(e)).toList();
  return (now, list);
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Clima',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.lightBlue, useMaterial3: true),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = TextEditingController(text: 'São Paulo');
  late Future<(Weather, List<Forecast>)> future = fetchAll(controller.text);

  void _search() => setState(() => future = fetchAll(controller.text.trim()));

  Widget _icon(String code, double size) =>
      Image.network('https://openweathermap.org/img/wn/$code@2x.png', width: size, height: size);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🌦️ Clima')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (apiKey.isEmpty)
            const Text('⚠️ Rode com --dart-define=OWM_API_KEY=sua_chave', style: TextStyle(color: Colors.red)),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Digite uma cidade',
              suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<(Weather, List<Forecast>)>(
              future: future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text(snap.error.toString().replaceFirst('Exception: ', '')));
                }
                final (w, forecast) = snap.data!;
                return ListView(children: [
                  Center(child: Text(w.city, style: Theme.of(context).textTheme.headlineMedium)),
                  Center(child: _icon(w.icon, 120)),
                  Center(
                    child: Text('${w.temp.round()}°C',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  Center(child: Text(w.description, style: const TextStyle(fontSize: 18))),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    Text('🌡️ Sensação ${w.feelsLike.round()}°'),
                    Text('💧 ${w.humidity}%'),
                    Text('💨 ${(w.wind * 3.6).round()} km/h'),
                  ]),
                  const SizedBox(height: 24),
                  const Text('Próximas 24 horas', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: forecast
                          .map((f) => Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(children: [
                                    Text('${f.time.hour.toString().padLeft(2, '0')}h'),
                                    _icon(f.icon, 40),
                                    Text('${f.temp.round()}°'),
                                  ]),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ]),
      ),
    );
  }
}
