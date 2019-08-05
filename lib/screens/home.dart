import 'package:flutter/material.dart';
import 'package:note_taking_app/models/note.dart';
import 'note_detail.dart';
import 'note_list.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {

  static int _selectedPage = 0;
  static var _note = new Note(2, "", "", "");
  final _pages = [
    NoteList(),
    NoteDetail(_note, "Add Note"),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPage],
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.view_list), title: Text("Notes")),
        BottomNavigationBarItem(icon: Icon(Icons.playlist_add), title: Text("Add Notes"))
      ], onTap: (int index){
        setState(() {
          _selectedPage = index;
        });
      },
        currentIndex: _selectedPage,),
    );
  }
}
