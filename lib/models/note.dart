class Note {
  int _id;
  int _priority;
  String _title;
  String _description;
  String _date;

  Note(this._priority, this._title, this._date, [this._description]);

  Note.withId(this._id, this._priority, this._title, this._date,
      [this._description]);

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  String get description => _description;

  set description(String value) {
    if (value.length <= 255) {
      _description = value;
    }
  }

  String get title => _title;

  set title(String value) {
    if (value.length <= 255) {
      _title = value;
    }
  }

  int get priority => _priority;

  set priority(int value) {
    if (value > 0 && value < 3) {
      _priority = value;
    }
  }

  int get id => _id;

  // Convert a Note object into a Map object for the DB
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (_id != null) {
      map["id"] = _id;
    }
    map["priority"] = _priority;
    map["title"] = _title;
    map["description"] = _description;
    map["date"] = _date;

    return map;
  }

  //Convert a DB Map object to a Note object
  Note.fromMapObject(Map<String, dynamic> map) {
   this._id=  map["id"];
   this._priority = map["priority"];
   this._title = map["title"];
   this._description = map["description"];
   this._date = map["date"];
  }
}
