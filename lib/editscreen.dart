// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:my_app/main.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class Task {
  final String name;
  final String details;
  final String assignedTo;

  Task(this.name, this.details, this.assignedTo);
}

class EditTaskScreen extends StatefulWidget {
  // Define properties to pass the task details
  final String name;
  final String details;
  final String assignedTo;

  EditTaskScreen({super.key, 
    required this.name,
    required this.details,
    required this.assignedTo,
  });

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  // Define controllers for editing task details
  List<Task> taskEdit = [];
  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskDetailsController = TextEditingController();
  TextEditingController assignedToController = TextEditingController();

  Future<void> updateTaskInBack4App(Task task) async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Jobs'));
    final response = await queryBuilder.query();
    if (response.success) {
      final tasksFromServer = response.results;
      if (tasksFromServer != null && tasksFromServer.isNotEmpty) {
        final taskToUpdate = tasksFromServer.first;
        taskToUpdate.set<String>('TaskName', task.name);
        taskToUpdate.set<String>('TaskDetails', task.details);
        taskToUpdate.set<String>('AssignedTo', task.assignedTo);

        final updateResponse = await taskToUpdate.save();
        if (updateResponse.success) {
          print('Task updated in Back4App');
        } else {
          print('Failed to update task: ${response.error?.message}');
        }
      }
    }
    else {
      print('Failed to fetch task for update: ${response.error?.message}');
    }
  }

  Future<void> deleteTaskFromBack4App(String taskName) async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Jobs'))
      ..whereEqualTo('TaskName', taskName)
      ..setLimit(1);

    final response = await queryBuilder.query();

    if (response.success) {
      final deleteFromServer = response.results;
      if (deleteFromServer != null && deleteFromServer.isNotEmpty) {
        final taskToDelete = deleteFromServer.first;

        final deleteResponse = await taskToDelete.delete();
        if (deleteResponse.success) {
          print('Task deleted from Back4App');
          //return true;
        } else {
          print('Failed to delete task: ${response.error?.message}');
          //return false;
        }
      }
    }
    else {
      print('Failed to fetch task for delete: ${response.error?.message}');
      //return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the existing task details
    taskNameController.text = widget.name;
    taskDetailsController.text = widget.details;
    assignedToController.text = widget.assignedTo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Name'),
            TextField(controller: taskNameController),
            SizedBox(height: 16.0),
            Text('Task Details'),
            TextField(controller: taskDetailsController),
            SizedBox(height: 16.0),
            Text('Assigned To'),
            TextField(controller: assignedToController),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    final updatedTaskName = taskNameController.text;
                    final updatedTaskDetails = taskDetailsController.text;
                    final updatedAssignedTo = assignedToController.text;
                    if (updatedTaskName.isNotEmpty && updatedTaskDetails.isNotEmpty) {
                      final newTask = Task(updatedTaskName, updatedTaskDetails, updatedAssignedTo);
                      taskEdit.add(newTask);
                      updateTaskInBack4App(newTask);

                      //Show a custom dialogue box after successful update
                      showDialog(
                        context: context, 
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Task Updated Successfully!!'),
                            content: Text('What would you like to do next?'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                }, 
                                child: Text('Edit Again'),
                              ),
                              ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              }, 
                              child: Text('Go Back'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },                    
                  child: Text('Save Changes'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                  },
                  child: Text('Back'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context, 
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text('Are you sure you want to delete this task'),
                          actions: [
                            ElevatedButton(onPressed: () async {
                              await deleteTaskFromBack4App(widget.name);
                              showDialog(
                                context: context, 
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Task Deleted'),
                                    content: Text('Your task has been successfully deleted.'),
                                    actions: [
                                      ElevatedButton(onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => MyApp()),
                                        );
                                      }, child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }, 
                            child: Text('Confirm'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the confirmation dialog
                              },
                              child: Text('Cancel'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}