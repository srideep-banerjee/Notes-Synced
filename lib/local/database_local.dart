import 'package:flutter/foundation.dart';
import 'package:notes_flutter/local/note_model.dart';
import 'package:notes_flutter/models/notes_item.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  late Future<Database> _futureDatabase;
  String DATABASE_NAME = "notes_database.db";

  DatabaseHelper() {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      _futureDatabase = _getDatabaseFuture(DATABASE_NAME);
      return;
    }
    _futureDatabase = getDatabasesPath().then(
      (databasePath) => _getDatabaseFuture(join(databasePath, DATABASE_NAME))
    );
  }

  Future<Database> _getDatabaseFuture(String path) {
    return openDatabase(
      DATABASE_NAME,

      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE notes(`index` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT NOT NULL, content TEXT NOT NULL, time TEXT NOT NULL)",
        );
      },

      onUpgrade: (Database db, int oldVersion, int newVersion) {
        print("Upgrading database");
        Future<void>? upgradeFuture;

        chainFuture(Future<void> future) {
          //Initialize upgradeFuture to future if upgradeFuture is null else chain future
          upgradeFuture = upgradeFuture?.then((_) => future) ?? future;
        }

        if (oldVersion < 2 && newVersion >= 2) {
          String currentTime = DateTime.timestamp().toString();
          chainFuture(
            db.execute("ALTER TABLE notes ADD COLUMN time TEXT DEFAULT \"$currentTime\" NOT NULL")
                .then((_) => db.rawUpdate("UPDATE notes SET time = ?", [currentTime])),
          );
        }

        return upgradeFuture;
      },
      version: 2,
    );
  }

  Future<List<NoteModel>> getNoteList() async {
    Database database = await _futureDatabase;

    List<Map<String, Object?>> noteMapList = await database.query("notes");

    return List<NoteModel>.from(noteMapList.map((it) => NoteModel(
          index: it["index"] as int,
          title: it["title"] as String,
          content: it["content"] as String,
          time: it["time"] as String,
        )));
  }

  Future<int> addNote(NotesItem notesItem, String time) async {
    Database database = await _futureDatabase;
    Map<String, Object?> notesItemMap = notesItem.toMap();
    notesItemMap["time"] = time;

    int index = await database.insert(
      "notes",
      notesItemMap,
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );

    return index;
  }

  Future<void> updateNote(NoteModel noteModel) async {
    Database database = await _futureDatabase;

    int count = await database.update(
      "notes",
      noteModel.toMap(),
      where: "`index` = ?",
      whereArgs: [noteModel.index],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    print("$count rows affected");
  }

  Future<void> deleteMultipleNotes(Iterable<int> indices) async {
    Database database = await _futureDatabase;
    print(indices.toString());

    await database.delete(
      "notes",
      where: "`index` IN (${List.filled(indices.length, "?").join(",")})",
      whereArgs: List.of(indices),
    );
  }

  Future<void> deleteNote(NoteModel noteModel) async {
    Database database = await _futureDatabase;

    await database.delete(
      "notes",
      where: "`index` = ?",
      whereArgs: [noteModel.index],
    );
  }

  void dispose() {
    _futureDatabase.then((database) => database.close());
  }
}
