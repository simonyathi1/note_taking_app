import 'dart:async';

import 'package:note_taking_app/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = "note_table";
  String colId = "id";
  String colPriority = "priority";
  String colTitle = "title";
  String colDescription = "description";
  String colDate = "date";

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    //Get directory path to the Android and IOS databases
//    Directory directory = await getApplicationDocumentsDirectory();
//    String path = directory.path + "note.db";

    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'note.db');
    //Open/ create database at given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDB);
    return notesDatabase;
  }

  void _createDB(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT,"
        "$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)");
  }

  //fetch All notes
  Future<List<Map<String, dynamic>>> getNotesMapList() async {
    Database database = await this.database;
    return await database.query(noteTable, orderBy: "$colPriority ASC");
  }

  //Insert note to db
  Future<int> insertNote(Note note) async {
    Database database = await this.database;
    return await database.insert(noteTable, note.toMap());
  }

  //Update note in db
  Future<int> updateNote(Note note) async {
    Database database = await this.database;
    return await database.update(noteTable, note.toMap(),
        where: "$colId = ?", whereArgs: [note.id]);
  }

  //delete note from db
  Future<int> deleteNote(int id) async {
    Database database = await this.database;
    return database.rawDelete("DELETE FROM $noteTable WHERE $colId = $id");
  }
//get number of notes in db
  Future<int> getCount() async{
    Database database = await this.database;
    List<Map<String, dynamic>> notes = await database.rawQuery("SELECT COUNT (*) from $noteTable");
    return Sqflite.firstIntValue(notes);
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNotesMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
