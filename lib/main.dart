import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'language_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Hive'ı başlat
  await Hive.openBox('tasks'); // 'tasks' kutusunu aç
  runApp(ToDoList());
}

class ToDoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',


      theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.teal, // buton rengi
    textTheme: ButtonTextTheme.primary, // buton yazı rengi
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.tealAccent, // yüzen buton rengi
    foregroundColor: Colors.white, // yüzen buton yazı rengi
  ),
  scaffoldBackgroundColor: Colors.white, // arka plan rengi
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.teal, // app bar rengi
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
),

      
      
      
      
      home: ToDoHomePage(),
    );
  }
}

class Task {
  String title;
  bool completed;
  DateTime createdAt;

  Task({required this.title, this.completed = false, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      completed: map['completed'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class ToDoHomePage extends StatefulWidget {
  @override
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  final Box _taskBox = Hive.box('tasks');
  final TextEditingController _taskController = TextEditingController();
  String _currentLanguage = 'en';

  List<Task> get _tasks {
    return _taskBox.values
        .map((task) => Task.fromMap(Map<String, dynamic>.from(task)))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _deleteOldTasks(); // 24 saat geçmiş görevleri sil
  }

  void _deleteOldTasks() {
    final now = DateTime.now();
    for (var key in _taskBox.keys) {
      final task = Task.fromMap(Map<String, dynamic>.from(_taskBox.get(key)));
      if (now.difference(task.createdAt).inHours >= 24) {
        _taskBox.delete(key);
      }
    }
    setState(() {});
  }

  void _addTask(String taskTitle) {
    final task = Task(title: taskTitle, createdAt: DateTime.now());
    _taskBox.add(task.toMap());
    setState(() {});
    _taskController.clear();
  }

  void _deleteTask(int index) {
    _taskBox.deleteAt(index);
    setState(() {});
  }

  void _toggleTaskCompletion(int index) {
    final taskMap = _taskBox.getAt(index);
    final task = Task.fromMap(Map<String, dynamic>.from(taskMap));
    task.completed = !task.completed;
    _taskBox.putAt(index, task.toMap());
    setState(() {});
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageHelper.localizedStrings[_currentLanguage]!['add_task']!),
        content: TextField(
          controller: _taskController,
          decoration: InputDecoration(
            hintText: LanguageHelper.localizedStrings[_currentLanguage]!['enter_task']!,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LanguageHelper.localizedStrings[_currentLanguage]!['cancel']!),
          ),
          ElevatedButton(
            onPressed: () {
              if (_taskController.text.isNotEmpty) {
                _addTask(_taskController.text);
                Navigator.of(context).pop();
              }
            },
            child: Text(LanguageHelper.localizedStrings[_currentLanguage]!['add']!),
          ),
        ],
      ),
    );
  }

  void _toggleLanguage() {
    setState(() {
      _currentLanguage = _currentLanguage == 'en' ? 'tr' : 'en';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageHelper.localizedStrings[_currentLanguage]!['title']!),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: _toggleLanguage,
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? Center(
              child: Text(
                LanguageHelper.localizedStrings[_currentLanguage]!['no_tasks']!,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    leading: Checkbox(
                      value: task.completed,
                      onChanged: (value) => _toggleTaskCompletion(index),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(index),
                    ),
                    subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(task.createdAt)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}