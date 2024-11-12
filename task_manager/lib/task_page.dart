import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskListWidget extends StatefulWidget {
  TaskListWidget({Key? key}) : super(key: key);

  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _toggleTaskCompletion(
      BuildContext context, String taskId, bool currentStatus) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'isCompleted': !currentStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task status updated!')),
      );
    } catch (e) {
      print('Error toggling task completion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task. Please try again.')),
      );
    }
  }

  Future<void> _deleteTask(BuildContext context, String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task. Please try again.')),
      );
    }
  }

  Future<void> _addSubTask(BuildContext context, String taskId) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AddSubTaskDialog(taskId: taskId),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subtask added successfully!')),
      );
    }
  }

  Future<void> _deleteSubTask(BuildContext context, String taskId,
      int subTaskIndex, int detailIndex) async {
    try {
      DocumentSnapshot taskSnapshot =
          await _firestore.collection('tasks').doc(taskId).get();
      List<dynamic> currentSubTasks = taskSnapshot.get('subTasks') ?? [];

      if (subTaskIndex >= 0 && subTaskIndex < currentSubTasks.length) {
        List<dynamic> details = currentSubTasks[subTaskIndex]['details'] ?? [];

        if (detailIndex >= 0 && detailIndex < details.length) {
          details.removeAt(detailIndex);

          if (details.isEmpty) {
            currentSubTasks.removeAt(subTaskIndex);
          } else {
            currentSubTasks[subTaskIndex]['details'] = details;
          }

          await _firestore.collection('tasks').doc(taskId).update({
            'subTasks': currentSubTasks,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subtask deleted successfully!')),
          );
        }
      }
    } catch (e) {
      print('Error deleting subtask: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete subtask. Please try again.')),
      );
    }
  }

  Future<void> _toggleSubTaskCompletion(BuildContext context, String taskId,
      int subTaskIndex, int detailIndex, bool isCompleted) async {
    try {
      DocumentSnapshot taskSnapshot =
          await _firestore.collection('tasks').doc(taskId).get();
      List<dynamic> currentSubTasks = taskSnapshot.get('subTasks') ?? [];

      if (subTaskIndex >= 0 && subTaskIndex < currentSubTasks.length) {
        List<dynamic> details = currentSubTasks[subTaskIndex]['details'] ?? [];

        if (detailIndex >= 0 && detailIndex < details.length) {
          details[detailIndex]['isCompleted'] = !isCompleted;

          currentSubTasks[subTaskIndex]['details'] = details;

          await _firestore.collection('tasks').doc(taskId).update({
            'subTasks': currentSubTasks,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subtask status updated!')),
          );
        }
      }
    } catch (e) {
      print('Error toggling subtask completion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update subtask. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Center(
        child: Text('No user logged in'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Snapshot Error: ${snapshot.error}');
          return Center(
            child: Text(
              'Error loading tasks: ${snapshot.error}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!.docs;

        if (tasks.isEmpty) {
          return Center(child: Text('No tasks added yet'));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            var task = tasks[index];
            String taskId = task.id;
            String taskName = task['taskName'] ?? 'Unnamed Task';
            bool isCompleted = task['isCompleted'] ?? false;
            List<dynamic> subTasks = task['subTasks'] ?? [];

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Checkbox(
                      value: isCompleted,
                      onChanged: (val) {
                        _toggleTaskCompletion(context, taskId, isCompleted);
                      },
                    ),
                    Expanded(
                      child: Text(
                        taskName,
                        style: TextStyle(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteTask(context, taskId);
                      },
                    ),
                  ],
                ),
                children: [
                  if (subTasks.isNotEmpty)
                    Padding(
                      padding:
                          EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                      child: Column(
                        children: List.generate(subTasks.length, (subIndex) {
                          var subTask = subTasks[subIndex];
                          String timeFrame =
                              subTask['timeFrame'] ?? 'No Time Frame';
                          List<dynamic> details = subTask['details'] ?? [];

                          return ExpansionTile(
                            title: Text(timeFrame),
                            children:
                                List.generate(details.length, (detailIndex) {
                              String detail =
                                  details[detailIndex]['detail'] ?? 'No Detail';
                              bool isDetailCompleted =
                                  details[detailIndex]['isCompleted'] ?? false;

                              return ListTile(
                                leading: Checkbox(
                                  value: isDetailCompleted,
                                  onChanged: (val) {
                                    _toggleSubTaskCompletion(
                                        context,
                                        taskId,
                                        subIndex,
                                        detailIndex,
                                        isDetailCompleted);
                                  },
                                ),
                                title: Text(
                                  detail,
                                  style: TextStyle(
                                    decoration: isDetailCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _deleteSubTask(
                                        context, taskId, subIndex, detailIndex);
                                  },
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                      _addSubTask(context, taskId);
                    },
                    child: Text('Add Subtask'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AddSubTaskDialog extends StatefulWidget {
  final String taskId;

  AddSubTaskDialog({required this.taskId});

  @override
  _AddSubTaskDialogState createState() => _AddSubTaskDialogState();
}

class _AddSubTaskDialogState extends State<AddSubTaskDialog> {
  final TextEditingController _subTaskController = TextEditingController();
  final TextEditingController _timeFrameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSubmitting = false;
  @override
  void dispose() {
    _subTaskController.dispose();
    _timeFrameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    String timeFrame = _timeFrameController.text.trim();
    String detail = _subTaskController.text.trim();

    if (timeFrame.isEmpty || detail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both fields.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      DocumentSnapshot taskSnapshot =
          await _firestore.collection('tasks').doc(widget.taskId).get();
      List<dynamic> currentSubTasks = taskSnapshot.get('subTasks') ?? [];

      int existingIndex = currentSubTasks.indexWhere(
        (subTask) => subTask['timeFrame'] == timeFrame,
      );

      if (existingIndex != -1) {
        currentSubTasks[existingIndex]['details'].add({
          'detail': detail,
          'isCompleted': false,
        });
      } else {
        currentSubTasks.add({
          'timeFrame': timeFrame,
          'details': [
            {
              'detail': detail,
              'isCompleted': false,
            }
          ],
        });
      }

      await _firestore.collection('tasks').doc(widget.taskId).update({
        'subTasks': currentSubTasks,
      });

      Navigator.pop(context, true);
    } catch (e) {
      print('Error adding subtask: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add subtask. Please try again.')),
      );
      Navigator.pop(context, false);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Subtask'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _timeFrameController,
              decoration:
                  InputDecoration(labelText: 'Time Frame (e.g., 9 AM - 10 AM)'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _subTaskController,
              decoration: InputDecoration(labelText: 'Task Details'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.pop(context, false);
                },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text('Add'),
        ),
      ],
    );
  }
}
