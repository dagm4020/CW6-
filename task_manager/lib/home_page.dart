import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? 'No Email';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Welcome, $email!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            AddTaskInput(),
            SizedBox(height: 20),
            Expanded(
              child: TaskListWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskInput extends StatefulWidget {
  const AddTaskInput({Key? key}) : super(key: key);

  @override
  _AddTaskInputState createState() => _AddTaskInputState();
}

class _AddTaskInputState extends State<AddTaskInput> {
  final TextEditingController _taskController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addTask() async {
    String taskName = _taskController.text.trim();
    if (taskName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task name cannot be empty.')),
      );
      return;
    }

    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user is currently signed in.')),
      );
      return;
    }

    try {
      await _firestore.collection('tasks').add({
        'userId': user.uid,
        'taskName': taskName,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'subTasks': [],
      });

      _taskController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task added successfully!')),
      );
    } catch (e) {
      print('Error adding task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add task. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _taskController,
            decoration: InputDecoration(
              labelText: 'Enter Task Name',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: _addTask,
          child: Text('Add'),
        ),
      ],
    );
  }
}
