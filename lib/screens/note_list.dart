import 'dart:async';

import 'package:flutter/material.dart';
import 'package:note_taking_app/models/note.dart';
import 'package:note_taking_app/screens/note_detail.dart';
import 'package:note_taking_app/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(new Note(2, "", ""), "Add Note");
        },
        tooltip: "Add Note",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    updateListView();
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
        itemCount: noteList.length,
        itemBuilder: (BuildContext context, int position) {
          if (noteList.isNotEmpty)
            return Card(
              color: Colors.white,
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                  getPriorityColor(this.noteList[position].priority),
                  child: getPriorityIcon(this.noteList[position].priority),
                ),
                title: Text(
                  this.noteList[position].title,
                  style: titleStyle,
                ),
                subtitle: Text(this.noteList[position].date),
                trailing: GestureDetector(
                    child: Icon(
                      Icons.delete,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      _delete(context, this.noteList[position]);
                    }),
                onTap: () {
                  navigateToDetail(noteList[position], "Edit Note");
                },
              ),
            );
        });
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;

      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
        break;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;

      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
        break;
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, "Note deleted");
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String appBarTitle) async {
    bool hasAddedOrDeletedNote =
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, appBarTitle);
    }));

    if (hasAddedOrDeletedNote) {
      updateListView();
    }
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await databaseHelper.getNotesMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
