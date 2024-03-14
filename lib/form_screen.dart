import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'DatabaseHelper.dart'; // Ensure this import is correct

class FormScreen extends StatefulWidget {
  final String appId;
  final String formId;

  FormScreen({required this.appId, required this.formId});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  List<dynamic> formFields = [];
  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    loadForm();
    executeJoin();
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> loadForm() async {
    try {
      final String response =
          await rootBundle.loadString('assets/app_config.json');
      final data = json.decode(response);
      setState(() {
        var selectedApp = data['apps'].firstWhere(
            (app) => app['appId'] == widget.appId,
            orElse: () => null);
        if (selectedApp != null) {
          List<dynamic> screens = selectedApp['screens'];
          for (var screen in screens) {
            var forms = screen['forms'];
            for (var form in forms) {
              if (form['formId'] == widget.formId) {
                formFields = form['fields'];
                // Initialize a TextEditingController for each field
                formFields.forEach((field) {
                  controllers[field['dbMapper']] = TextEditingController();
                });
                return; // Exit once the correct form is found
              }
            }
          }
        }
      });
    } catch (e) {
      print('Error loading form: $e');
    }
  }

  void executeJoin() async {
    List<Map<String, dynamic>> joinData = await DatabaseHelper.instance
        .executeJoinOperation(widget.appId, "getMemberDetailsWithJoin");
    // Handle the joinData here, e.g., by setting it to a state variable and displaying it in the widget tree
    print(joinData); // For debugging purposes
  }

  Widget buildField(dynamic field) {
    var controller = controllers[field['dbMapper']];
    switch (field['type']) {
      case 'text':
      case 'number':
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: field['placeholder']),
          keyboardType: field['type'] == 'number'
              ? TextInputType.number
              : TextInputType.text,
        );
      case 'dropdown':
        // Dropdowns need to be handled differently because they don't use controllers directly
        return DropdownButtonFormField<String>(
          value: controller!.text.isNotEmpty ? controller.text : null,
          items: field['options'].map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(value: option, child: Text(option));
          }).toList(),
          onChanged: (selected) {
            setState(() {
              controller.text = selected!;
            });
          },
          decoration: InputDecoration(labelText: field['placeholder']),
        );
      default:
        return SizedBox.shrink(); // For unsupported field types
    }
  }

  void saveFormData() {
    Map<String, dynamic> formData = {};
    controllers.forEach((key, controller) {
      formData[key] = controller.text;
    });
    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    // Assuming you have a table that matches the formId or another way to determine the target table
    databaseHelper.insert(widget.appId, widget.formId, formData).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Data saved successfully')));
    }).catchError((error) {
      print("Error saving form data: $error");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save data')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Form'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ...formFields.isNotEmpty
                  ? formFields.map((field) => buildField(field)).toList()
                  : [Text("Loading form...")],
              ElevatedButton(
                onPressed: saveFormData,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
