import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(const WorkoutTrackerApp());
}

class WorkoutTrackerApp extends StatelessWidget {
  const WorkoutTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Workout Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WorkoutScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WorkoutSet {
  final String machineId;
  final String machineName;
  final DateTime timestamp;
  final int reps;
  final int weight;

  WorkoutSet({
    required this.machineId,
    required this.machineName,
    required this.timestamp,
    required this.reps,
    required this.weight,
  });
}

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String _nfcStatus = 'Tap button to check NFC';
  bool _isLoading = false;
  List<WorkoutSet> _workoutHistory = [];
  
  final Map<String, String> _machineData = {
    'left_chest': 'Chest Press (Left Side)',
    'right_chest': 'Chest Press (Right Side)', 
    'left_shoulder': 'Shoulder Press (Left)',
    'right_shoulder': 'Shoulder Press (Right)',
    'squat_rack': 'Squat Machine',
    'leg_press': 'Leg Press',
  };

  Future<void> _checkNFCAvailability() async {
    setState(() {
      _isLoading = true;
      _nfcStatus = 'Checking NFC...';
    });

    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      setState(() {
        _nfcStatus = isAvailable 
            ? '✅ NFC Ready - Tap to start workout session'
            : '❌ NFC not available (Browser limitation)';
      });
    } catch (e) {
      setState(() {
        _nfcStatus = 'NFC Error: $e\n(This is normal in browser)';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startWorkoutSession() async {
    setState(() {
      _isLoading = true;
      _nfcStatus = '🔍 Simulating workout...';
    });

    // Simulate delay for NFC scanning
    await Future.delayed(const Duration(seconds: 1));

    // Simulate workout data
    final simulatedTagData = _simulateTagReading();
    _handleWorkoutTag(simulatedTagData);
  }

  Map<String, dynamic> _simulateTagReading() {
    final machines = _machineData.keys.toList();
    final randomMachine = machines[_workoutHistory.length % machines.length];
    
    return {
      'machine_id': randomMachine,
      'machine_name': _machineData[randomMachine],
      'timestamp': DateTime.now(),
      'reps': 8 + (_workoutHistory.length % 5),
      'weight': 20 + (_workoutHistory.length * 5),
    };
  }

  void _handleWorkoutTag(Map<String, dynamic> tagData) {
    final workoutSet = WorkoutSet(
      machineId: tagData['machine_id'],
      machineName: tagData['machine_name'],
      timestamp: tagData['timestamp'],
      reps: tagData['reps'],
      weight: tagData['weight'],
    );

    setState(() {
      _workoutHistory.add(workoutSet);
      _isLoading = false;
      _nfcStatus = '✅ ${workoutSet.machineName}\n'
                   '📊 ${workoutSet.reps} reps × ${workoutSet.weight}kg';
    });
  }

  void _clearWorkoutHistory() {
    setState(() {
      _workoutHistory.clear();
      _nfcStatus = 'Workout history cleared';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Workout Tracker'),
        backgroundColor: Colors.blue,
        actions: [
          if (_workoutHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearWorkoutHistory,
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 60,
                    color: _isLoading ? Colors.orange : Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nfcStatus,
                    style: TextStyle(
                      fontSize: 16,
                      color: _isLoading ? Colors.orange : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _checkNFCAvailability,
                        icon: const Icon(Icons.nfc),
                        label: const Text('CHECK NFC'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _startWorkoutSession,
                        icon: const Icon(Icons.fitness_center),
                        label: const Text('ADD WORKOUT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _workoutHistory.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No workouts tracked yet\nTap "ADD WORKOUT" to start!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _workoutHistory.length,
                    itemBuilder: (context, index) {
                      final workout = _workoutHistory.reversed.toList()[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.fitness_center),
                          title: Text(workout.machineName),
                          subtitle: Text(
                            '${workout.reps} reps × ${workout.weight}kg',
                          ),
                          trailing: Text(
                            '${workout.timestamp.hour}:${workout.timestamp.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}