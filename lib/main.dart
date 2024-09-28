import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Расчет рабочего времени',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Shift> shifts = [];

  final DateFormat timeFormat = DateFormat("HH:mm");

  void _addNewShift() {
    setState(() {
      shifts.add(Shift());
    });
  }

  Duration _calculateTotalHours() {
    Duration totalDuration = const Duration();
    for (var shift in shifts) {
      if (shift.start != null && shift.end != null) {
        totalDuration += shift.end!.difference(shift.start!);
      }
    }
    return totalDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расчет рабочего времени'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: shifts.length,
                itemBuilder: (context, index) {
                  return ShiftRow(
                    shift: shifts[index],
                    onShiftChanged: () {
                      setState(() {});
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addNewShift,
              child: const Text('Добавить смену'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final totalDuration = _calculateTotalHours();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Общая продолжительность'),
                      content: Text(
                        'Всего отработано: ${totalDuration.inHours} часов ${totalDuration.inMinutes % 60} минут',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('ОК'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Посчитать общее время'),
            ),
          ],
        ),
      ),
    );
  }
}

class Shift {
  DateTime? start;
  DateTime? end;

  Duration get duration {
    if (start != null && end != null) {
      return end!.difference(start!);
    }
    return const Duration();
  }
}

class ShiftRow extends StatelessWidget {
  final Shift shift;
  final VoidCallback onShiftChanged;

  ShiftRow({required this.shift, required this.onShiftChanged});

  final DateFormat timeFormat = DateFormat("HH:mm");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('Начало смены'),
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        shift.start = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          time.hour,
                          time.minute,
                        );
                        onShiftChanged();
                      }
                    },
                    child: Text(shift.start == null
                        ? 'Выбрать время'
                        : timeFormat.format(shift.start!)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  const Text('Конец смены'),
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        shift.end = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          time.hour,
                          time.minute,
                        );
                        onShiftChanged();
                      }
                    },
                    child: Text(shift.end == null
                        ? 'Выбрать время'
                        : timeFormat.format(shift.end!)),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (shift.start != null && shift.end != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Продолжительность: ${shift.duration.inHours} часов ${shift.duration.inMinutes % 60} минут',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        const Divider(),
      ],
    );
  }
}
