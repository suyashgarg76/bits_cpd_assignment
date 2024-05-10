import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:my_app/login.dart';
import 'package:my_app/editscreen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const keyApplicationId = 'bHM1hygta0gmmfROudWAwL0UtvbVMbOjthyJZPNa';
  const keyClientKey = 'LjsFayjfjpYJAkSRG3hLMf5B0cLnDhqhrRElOFUV';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl, clientKey: keyClientKey, autoSendSessionId: true, debug: true);

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserState(),
      child: MaterialApp(
        initialRoute: 'login',
        routes: {
          'login': (context) => LoginScreen(),
          'main': (context) => MyApp(),
          'editscreen':(context) => EditTaskScreen(name: '', details: '', assignedTo: ''),
        },
      ),
    ),
  );
}

class Task {
  final String name;
  final String details;
  final String assignedTo;

  //Task(this.name, this.details, this.assignedTo, this.assignedBy);
  Task(this.name, this.details, this.assignedTo);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Task> tasks = [];
  final taskNameController = TextEditingController();
  final taskDetailsController = TextEditingController();
  final assignedToController = TextEditingController();
  //final currentUser = ParseUser.currentUser;
  
  Future<void> saveTaskToBack4App(Task task) async {
    final parseObject = ParseObject('Jobs')
      ..set('TaskName', task.name)
      ..set('TaskDetails', task.details)
      ..set('AssignedTo', task.assignedTo);
    final response = await parseObject.save();
  }

  Future<void> fetchTasksFromBack4App() async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Jobs'))
      ..orderByAscending('createdAt');
    final response = await queryBuilder.query();
    if (response.success) {
      final tasksFromServer = response.results;
      tasks.clear();
      if (tasksFromServer != null)
      {
        for (var taskObject in tasksFromServer) {
          tasks.add(Task(
            taskObject.get('TaskName'),
            taskObject.get('TaskDetails'),
            taskObject.get('AssignedTo'),
          ));
        }
      }
      print('Fetched ${tasks.length} tasks from Back4App');
      setState(() {
        tasks = tasks;
      });
    } else {
      print('Failed to fetch tasks: ${response.error?.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70.0,
          title: Text(
            "Task App",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blue,
          elevation: 4.0, 
          centerTitle: true, 
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: taskNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Task Name'),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: taskDetailsController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Task Details'),
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: assignedToController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Assigned To'),
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    final taskName = taskNameController.text;
                    final taskDetails = taskDetailsController.text;
                    final assignedTo = assignedToController.text;

                    if (taskName.isNotEmpty && taskDetails.isNotEmpty && assignedTo.isNotEmpty) {
                      final newTask = Task(taskName, taskDetails, assignedTo);
                      tasks.add(newTask);
                      saveTaskToBack4App(newTask);
                      taskNameController.clear();
                      taskDetailsController.clear();
                      assignedToController.clear();

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Task Saved'),
                            content: Text('What would you like to do next?'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Add More Task'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => MyApp()),
                                  );
                                  fetchTasksFromBack4App();
                                },
                                child: Text('Back'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Close the dialog and navigate back to the login screen
                                  Navigator.pop(context);
                                  // Navigate to the login screen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginScreen()),
                                  );
                                },
                                child: Text('Logout'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    else {
                      // Show a validation message if any field is empty
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('OOPS!! Cannot Save.'),
                            content: Text('Please fill in all the required fields.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  // Close the validation dialog
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('Save'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    fetchTasksFromBack4App();
                  },
                  child: Text('Refresh'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to the login screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Recent Tasks:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(name: tasks[index].name, details: tasks[index].details, assignedTo: tasks[index].assignedTo),
                          ),
                      );
                    },
                    child: Card (
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(tasks[index].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                        subtitle: Text('Assigned to: ${tasks[index].assignedTo}\nDetails: ${tasks[index].details}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontStyle: FontStyle.normal,
                            letterSpacing: 0.5,
                            wordSpacing: 2.0,
                            height: 1.8,
                            backgroundColor: Colors.transparent,
                            decoration: TextDecoration.none,
                            decorationColor: Colors.red,
                            decorationStyle: TextDecorationStyle.solid
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }
}