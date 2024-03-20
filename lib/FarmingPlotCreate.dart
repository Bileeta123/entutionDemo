// ignore_for_file: avoid_print

import 'package:entutiondemoapp/DynamicFuntionHandler.dart';
import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
// import 'DynamicFuntionHandler.dart';

class AddFarmingPlotScreen extends StatefulWidget {
  const AddFarmingPlotScreen({super.key});

  @override
  State<AddFarmingPlotScreen> createState() => _AddFarmingPlotScreenState();
}

class _AddFarmingPlotScreenState extends State<AddFarmingPlotScreen> {
  final _form = GlobalKey<FormState>();
  DynamicFunctionHandler handler = DynamicFunctionHandler();

  // Placeholder for form fields from JSON
  List<Map<String, dynamic>> fields = [];

  final Map<String, dynamic> formConfig = {
    "appId": "farmer",
    "appName": "Farmer",
    "screens": [
      {
        "screenId": "addNewMember",
        "screenName": "Add New Plot",
        "forms": [
          {
            "formId": "addNewPlot",
            "formName": "Add New Plot",
            "fields": [
              {
                "fieldName": "Plot Name",
                "fieldId": "100",
                "dbMapper": "plotName",
                "type": "text",
                "placeholder": "Plot Name",
                "isRequired": true,
                "sequence": 1
              },
              {
                "fieldName": "Plot Code",
                "dbMapper": "plotCode",
                "fieldId": "200",
                "type": "text",
                "placeholder": "Plot Code",
                "isRequired": true,
                "sequence": 2
              },
              {
                "fieldName": "UOM Group",
                "dbMapper": "uomGroup",
                "type": "dropdown",
                "fieldId": "300",
                "options": [],
                "placeholder": "Select UOM Group",
                "dbQuery": {
                  "query": "SELECT * FROM UOMGroup",
                  "queryValue": "UOMGroupId",
                  "onChangeFunc": {
                    "functionName": "getUOMGroupDetails",
                    "functionQuery":
                        "SELECT UOMGroupDetail.GroupId, UOMGroupDetail.LineId, UOMGroupDetail.FromUOMId, UOMGroupDetail.ToUOMId, UOMGroupDetail.ConversionRate, ListValues.ListValueId, ListValues.ListValue FROM UOMGroupDetail INNER JOIN ListValues ON UOMGroupDetail.FromUOMId = ListValues.ListValueId where ListValues.ListCategoryId = 88 AND UOMGroupDetail.GroupId = ",
                    "queryValue": "ListValue",
                  }
                },
                "sequence": 3
              },
              {
                "fieldName": "Capacity Group",
                "dbMapper": "capacityGroup",
                "type": "dropdown",
                "options": [],
                "fieldId": "400",
                "dbQuery": {
                  "query": '',
                },
                "dependable": {"parentId": "300"},
                "placeholder": "Select Capacity Group",
                "sequence": 4
              }
            ]
          }
        ]
      },
    ]
  };

  @override
  void initState() {
    super.initState();
    // Assuming 'formConfig' is your JSON configuration for forms
    fields = formConfig['screens'][0]['forms'][0]['fields'];
    fetchDropdownOptions();
  }

  // Function to fetch dropdown options for each dropdown field
  void fetchDropdownOptions() async {
    for (int i = 0; i < fields.length; i++) {
      if (fields[i]['type'] == 'dropdown' &&
          fields[i]['dbQuery'] != '' &&
          fields[i]['dbQuery']['query'] != '') {
        String query = fields[i]['dbQuery']['query'];
        String queryValue = fields[i]['dbQuery']['queryValue'];
        try {
          List<String> options = await DatabaseHelper.instance
              .fetchDropdownOptions(query, queryValue);
          setState(() {
            fields[i]['options'] = options;
          });
        } catch (error) {
          print('Error fetching dropdown options: $error');
        }
      }
    }
  }

  // void updateDependentDropdowns(
  //     String parentId, String? selectedValue, rows) async {
  //   var dependentFields = fields
  //       .where((field) => field['dependable']?['parentId'] == parentId)
  //       .toList();
  //   for (var field in dependentFields) {
  //     List<String> newOptions = rows;
  //     setState(() {
  //       field['options'] = field['options'] =
  //           newOptions.map((option) => option.toString()).toList();
  //     });
  //     print('sfdf - $dependentFields');
  //   }
  // }

  void updateDependentDropdowns(String parentId, String? selectedValue) async {
    // Find the dependent fields.
    var dependentFields = fields
        .where((field) => field['dependable']?['parentId'] == parentId)
        .toList();

    // Iterate through all dependent fields to update their options.
    for (var field in dependentFields) {
      if (field['dbQuery'] != '' && field['dbQuery']['onChangeFunc'] != '') {
        String functionName = field['dbQuery']['onChangeFunc']['functionName'];
        String functionQuery =
            field['dbQuery']['onChangeFunc']['functionQuery'] + selectedValue!;
        print('khhihihih- $functionQuery');
        try {
          List<String> newOptions = await handler.callFunctionByName(
              functionName, functionQuery, field['dbQuery']['queryValue']);

          setState(() {
            field['options'] =
                newOptions.map((option) => option.toString()).toList();
          });

          print('ss - $dependentFields');
        } catch (e) {
          print('Error updating dependent dropdowns: $e');
        }
      } else {
        // print('innn');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Form'),
      ),
      body: ListView(
        children: [
          Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fields.map((field) => buildFormField(field)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormField(Map<String, dynamic> field) {
    switch (field['type']) {
      case 'text':
        return TextFormField(
          decoration: InputDecoration(labelText: field['placeholder']),
        );
      case 'dropdown':
        return DropdownButtonFormField<String>(
          value: null,
          items: field['options'].map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) async {
            if (value != null && field['dbQuery'].containsKey('onChangeFunc')) {
              String functionName =
                  field['dbQuery']['onChangeFunc']['functionName'];
              String functionQuery = field['dbQuery']['onChangeFunc']
                      ['functionQuery'] +
                  value; // Append selected value to query if needed
              String functionQueryValue =
                  field['dbQuery']['onChangeFunc']['queryValue'];
              Future<void> rows = handler.callFunctionByName(
                  functionName, functionQuery, functionQueryValue);
              // print('dddd - $rows');
              updateDependentDropdowns(field['fieldId'], value);
            }
          },
          decoration: InputDecoration(
            labelText: field['placeholder'],
          ),
        );
      default:
        return const SizedBox.shrink(); // Fallback for unknown field type
    }
  }
}
