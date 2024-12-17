import 'package:flutter/material.dart';

import 'language_helper.dart';

void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: ToDoHomePage(),
    );
  }
}

class ToDoHomePage extends StatefulWidget {
  @override
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
   final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  String _currentLanguage = 'en';
  

  void _addTask(String task) {
   
    setState(() {
      _tasks.add({'title': task, 'completed': false});
    });
    _taskController.clear();
  }

  void _deleteTask(int index) {
    setState(() {
   _tasks.removeAt(index);
    });
  }

  void _toggleTaskCompletion(int index) {
    
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
      });
    
}

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LanguageHelper.localizedStrings[_currentLanguage]!['add_task']!),
        content: TextField(
          controller: _taskController,
          decoration: InputDecoration(
              hintText: LanguageHelper.localizedStrings[_currentLanguage]!['enter_task']!),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
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
              itemBuilder: (context, index) => Card(
          

        
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(
                  _tasks[index]['title'],
                    style: TextStyle(
                    decoration: _tasks[index]['completed']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  leading: Checkbox(
                   value: _tasks[index]['completed'],
                    onChanged: (value) => _toggleTaskCompletion(index),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(index),
                  ),
                ),
              ),),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
