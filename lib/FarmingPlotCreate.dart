import 'dart:math';

import 'package:entutiondemoapp/DynamicFuntionHandler.dart';
import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

class AddFarmingPlotScreen extends StatefulWidget {
  const AddFarmingPlotScreen({Key? key}) : super(key: key);

  @override
  _AddFarmingPlotScreenState createState() => _AddFarmingPlotScreenState();
}

class _AddFarmingPlotScreenState extends State<AddFarmingPlotScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DynamicFunctionHandler _handler = DynamicFunctionHandler();
  List<Map<String, dynamic>> _fields = [];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    // Assuming _formConfig is your JSON configuration.
    // This should be replaced by your actual configuration loaded dynamically or statically defined.
    final Map<String, dynamic> _formConfig = {
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
                  "selectedValue": null,
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
                  "selectedValue": null,
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
    setState(() {
      _fields = _formConfig['screens'][0]['forms'][0]['fields'];
    });
    _fetchInitialDropdownOptions();
  }

  Future<void> _fetchInitialDropdownOptions() async {
    for (var field in _fields.where((field) =>
        field['type'] == 'dropdown' && field['dependable'] == null)) {
      var query = field['dbQuery']['query'];
      var options = await DatabaseHelper.instance.fetchDropdownOptions(query);
      setState(() {
        field['options'] = options
            .map((option) => {
                  'value': option[field['dbQuery']['queryValue']],
                  'display':
                      option['UOMGroupCode'], // Adjusted for UOMGroup dropdown
                })
            .toList();
      });
    }
  }

  Future<void> _updateDependableDropdowns(
      String parentId, dynamic selectedValue) async {
    // Find the parent field based on parentId
    var parentFieldIndex = _fields.indexWhere(
      (field) => field['fieldId'].toString() == parentId,
    );

    if (parentFieldIndex != -1) {
      // Get the parent field's onChangeFunc
      var parentField = _fields[parentFieldIndex];
      var onChangeFunc = parentField['dbQuery']['onChangeFunc'];

      if (onChangeFunc != null) {
        try {
          // Use the parent's onChangeFunc to fetch new options for the child dropdown
          var newOptions = await _handler.callFunctionByName(
            onChangeFunc['functionName'],
            onChangeFunc['functionQuery'] + selectedValue.toString(),
          );
          print("newOptions: $newOptions");
          // Find all dependent fields and update their options
          var dependentFields = _fields
              .where((field) =>
                  field['dependable']?['parentId'].toString() == parentId)
              .toList();
          print('depfields: $dependentFields');
          for (var dependentField in dependentFields) {
            print('depfield: $dependentField');
            setState(() {
              dependentField['options'] = newOptions.map((option) {
                print('option: $option');
                // Ensure you're using the correct keys and providing default values if necessary.
                var value = option['ListValueId'].toString();
                var display = option['ListValue'];
                return {'value': value, 'display': display};
              }).toList();
              print('dependent filed list: $dependentField');
              // Optionally, reset the selected value for the dependent dropdowns
              dependentField['selectedValue'] = null;
            });
          }
        } catch (e) {
          print("Error fetching new options for dependent dropdown: $e");
        }
      }
    }
  }

  Widget _buildFormField(Map<String, dynamic> field) {
    switch (field['type']) {
      case 'text':
        return TextFormField(
          decoration: InputDecoration(labelText: field['placeholder']),
        );
      case 'dropdown':
        return DropdownButtonFormField<dynamic>(
          value: field['selectedValue'],
          items: field['options'].map<DropdownMenuItem<dynamic>>((option) {
            print(option);
            return DropdownMenuItem<dynamic>(
              value: option['value'],
              child: Text(option['display']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              field['selectedValue'] = value;
            });
            // Call _updateDependableDropdowns if this is the UOM Group dropdown
            //if (field['fieldId'] == "300") {
            // Assuming '300' is the fieldId for UOM Group
            _updateDependableDropdowns(field['fieldId'], value);
            //}
          },
          decoration: InputDecoration(
            labelText: field['placeholder'],
          ),
        );
      default:
        return const SizedBox.shrink();
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
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _fields.map((field) => _buildFormField(field)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
