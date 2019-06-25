import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_taking_app/models/note.dart';
import 'package:note_taking_app/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(note, appBarTitle);
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
  Note note;

  NoteDetailState(this.note, this.appBarTitle);

  DatabaseHelper databaseHelper = DatabaseHelper();

  void initState() {
    super.initState();
    if (note != null) {
      _currentSelectedPriority = getPriorityAsString(note.priority);
    } else {
      _currentSelectedPriority = _priorities[0];
    }
  }

  var _titleController = new TextEditingController();
  var _descriptionController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    if(note != null) {
      _titleController.text = note.title;
      _descriptionController.text = note.description;
    }
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
        body: Form(child: getDetailsScreen()),
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
      child: Form(
        child: new TextFormField(
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
        updatePriorityAsInteger(newValueSelected);
      },
          value: getPriorityAsString(note.priority),
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
                textColor: Colors.white,
                child: Text(
                  "Save",
                  textScaleFactor: 1.5,
                ),
                onPressed: () {
                  setState(() {
                    if (_titleController.toString() != "" && _descriptionController.toString() != "") {
                      _save();
                      debugPrint("save");
                    }
                  });
                }),
          ),
          Expanded(
            child: RaisedButton(
                color: Theme.of(_buildContext).accentColor,
                textColor: Colors.white,
                child: Text(
                  "Delete",
                  textScaleFactor: 1.5,
                ),
                onPressed: () {
                  setState(() {
                    _delete();
                    debugPrint("del");
                  });
                }),
          ),
        ],
      ),
    );
  }

  void moveToPreviousScreen() {
    Navigator.pop(context, true);
  }

  void updatePriorityAsInteger(String value) {
    switch (value) {
      case "High":
        note.priority = 1;
        break;
      case "Low":
        note.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    switch (value) {
      case 1:
        return _priorities[0]; //high
        break;
      case 2:
        return _priorities[1]; //low
        break;
    }
    return "";
  }

  void updateTitle() {
    note.title = this._titleController.text;
  }

  void updateDescription() {
    note.description = this._descriptionController.text;
  }

  void setNoteCreationDate() {
    note.date = DateFormat.yMMMMd().format(DateTime.now());
  }

  void _save() async {
    moveToPreviousScreen();
    updateTitle();
    updateDescription();
    setNoteCreationDate();
    int result;
    if (note.id != null) {
      // update
      result = await databaseHelper.updateNote(note);
    } else {
      //create
      result = await databaseHelper.insertNote(note);
    }

    if (result != 0) {
      // success
      _showAlertDialog("Status", "Note Saved Successfully");
    } else {
      //failure
      _showAlertDialog("Status", "Problem Saving Note");
    }
  }

  void _delete() async {
    int result;
    moveToPreviousScreen();
    if (note.id == null) {
      // delete new note
      _showAlertDialog("Status", "No note to delete");
      return;
    }

    result = await databaseHelper.deleteNote(note.id);

    if (result != 0) {
      // success
      _showAlertDialog("Status", "Note Deleted Successfully");
    } else {
      //failure
      _showAlertDialog("Status", "Problem Deleting Note");
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
