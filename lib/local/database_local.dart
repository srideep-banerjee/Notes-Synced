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
      _futureDatabase = openDatabase(
        DATABASE_NAME,
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE notes(`index` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT NOT NULL, content TEXT NOT NULL)",
          );
        },
        version: 1,
      );
      return;
    }
    _futureDatabase = getDatabasesPath().then(
      (databasePath) => openDatabase(
        join(databasePath, DATABASE_NAME),
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE notes(`index` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT NOT NULL, content TEXT NOT NULL)",
          );
        },
        version: 1,
      ),
    );
  }

  Future<List<NoteModel>> getNoteList() async {
    Database database = await _futureDatabase;

    List<Map<String, Object?>> noteMapList = await database.query("notes");

    return List<NoteModel>.from(noteMapList.map((it) => NoteModel(
          index: it["index"] as int,
          title: it["title"] as String,
          content: it["content"] as String,
        )));
  }

  Future<int> addNote(NotesItem notesItem) async {
    Database database = await _futureDatabase;

    int index = await database.insert(
      "notes",
      notesItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
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
