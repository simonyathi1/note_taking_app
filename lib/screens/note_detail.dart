import 'package:flutter/material.dart';
import 'package:note_taking_app/models/note.dart';
import 'package:note_taking_app/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class NoteDetail extends StatefulWidget {
  String appBarTitle;

  NoteDetail(this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  final _minimumPadding = 8.0;
  var _priorities = ["High", "Low"];
  var _currentSelectedPriority = "";
  TextStyle appliedTextStyle;
  BuildContext _buildContext;
  String appBarTitle;
  var _formKey = GlobalKey<FormState>();

  NoteDetailState(this.appBarTitle);

  void initState() {
    super.initState();
    _currentSelectedPriority = _priorities[0];
  }

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _buildContext = context;
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                moveToPreviousScreen();
              }),
        ),
        body: getDetailsScreen(),
      ),
      onWillPop: () {
        moveToPreviousScreen();
      },
    );
  }

  Widget getDetailsScreen() {
    return ListView(
      children: <Widget>[
        getDropDownWidget(),
        getTextFieldWidget("Title", "Enter note title", _titleController),
        getTextFieldWidget(
            "Description", "Enter note description", _descriptionController),
        getButtonRow()
      ],
    );
  }

  Widget getTextFieldWidget(
      String label, String hint, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(_minimumPadding),
      child: TextFormField(
        //style: appliedTextStyle,
        controller: controller,
        validator: (String value) {
          if (value.isEmpty) {
            return "Please enter $label value";
          }
        },
        decoration: InputDecoration(
            labelText: label,
            //labelStyle: appliedTextStyle,
            errorStyle: TextStyle(fontSize: 15),
            hintText: hint,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
      ),
    );
  }

  Widget getDropDownWidget() {
    return ListTile(
        title: DropdownButton<String>(
      items: _priorities.map((String dropdownStringItem) {
        return DropdownMenuItem<String>(
          value: dropdownStringItem,
          child: Text(dropdownStringItem),
        );
      }).toList(),
      onChanged: (String newValueSelected) {
        _onDropDownItemSelected(newValueSelected);
      },
      value: _currentSelectedPriority,
    ));
  }

  void _onDropDownItemSelected(String newValueSelected) {
    setState(() {
      this._currentSelectedPriority = newValueSelected;
    });
  }

  Widget getButtonRow() {
    return Padding(
      padding: EdgeInsets.all(_minimumPadding),
      child: Row(
        children: <Widget>[
          Expanded(
            child: RaisedButton(
                color: Theme.of(_buildContext).accentColor,
                textColor: Theme.of(_buildContext).primaryColorDark,
                child: Text(
                  "Save",
                  textScaleFactor: 1.5,
                ),
                onPressed: () {
                  setState(() {
                    if (_formKey.currentState.validate()) {}
                  });
                }),
          ),
          Expanded(
            child: RaisedButton(
                color: Theme.of(_buildContext).accentColor,
                textColor: Theme.of(_buildContext).primaryColorDark,
                child: Text(
                  "Delete",
                  textScaleFactor: 1.5,
                ),
                onPressed: () {
                  setState(() {
                    _delete();
                  });
                }),
          ),
        ],
      ),
    );
  }

  void moveToPreviousScreen() {
    Navigator.pop(context);
  }

  void _delete() {}
}
