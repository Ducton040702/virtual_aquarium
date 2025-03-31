import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class Fish {
  Color color;
  double speed;
  Offset position;
  Offset direction;

  Fish({required this.color, required this.speed})
      : position = Offset(Random().nextDouble() * 250, Random().nextDouble() * 250),
        direction = Offset(
          (Random().nextDouble() * 2 - 1),
          (Random().nextDouble() * 2 - 1),
        );

  void move(Size size) {
    position += direction * speed;
    if (position.dx <= 0 || position.dx >= size.width - 20) {
      direction = Offset(-direction.dx, direction.dy);
    }
    if (position.dy <= 0 || position.dy >= size.height - 20) {
      direction = Offset(direction.dx, -direction.dy);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium',
      home: const AquariumPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AquariumPage extends StatefulWidget {
  const AquariumPage({super.key});
  @override
  State<AquariumPage> createState() => _AquariumPageState();
}

class _AquariumPageState extends State<AquariumPage> {
  final List<Fish> _fishList = [];
  double _speed = 1.0;
  Color _selectedColor = Colors.orange;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _startSwimming();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startSwimming() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() {
        for (var fish in _fishList) {
          fish.move(const Size(300, 300));
        }
      });
    });
  }

  void _addFish() {
    if (_fishList.length < 10) {
      setState(() {
        _fishList.add(Fish(color: _selectedColor, speed: _speed));
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speed', _speed);
    await prefs.setInt('color', _selectedColor.value);
    await prefs.setInt('fishCount', _fishList.length);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings saved!")),
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _speed = prefs.getDouble('speed') ?? 1.0;
      _selectedColor = Color(prefs.getInt('color') ?? Colors.orange.value);
      int count = prefs.getInt('fishCount') ?? 0;
      for (int i = 0; i < count; i++) {
        _fishList.add(Fish(color: _selectedColor, speed: _speed));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Virtual Aquarium")),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 300,
              height: 300,
              color: Colors.lightBlueAccent,
              child: Stack(
                children: _fishList.map((fish) {
                  return Positioned(
                    left: fish.position.dx,
                    top: fish.position.dy,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: fish.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _addFish, child: const Text("Add Fish")),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _saveSettings, child: const Text("Save Settings")),
            ],
          ),
          const SizedBox(height: 20),
          Text("Speed: ${_speed.toStringAsFixed(1)}"),
          Slider(
            value: _speed,
            min: 0.5,
            max: 5.0,
            divisions: 9,
            label: _speed.toStringAsFixed(1),
            onChanged: (val) {
              setState(() {
                _speed = val;
              });
            },
          ),
          const SizedBox(height: 10),
          DropdownButton<Color>(
            value: _selectedColor,
            items: [
              Colors.orange,
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.purple
            ].map((color) {
              return DropdownMenuItem<Color>(
                value: color,
                child: Container(width: 100, height: 20, color: color),
              );
            }).toList(),
            onChanged: (newColor) {
              if (newColor != null) {
                setState(() {
                  _selectedColor = newColor;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
