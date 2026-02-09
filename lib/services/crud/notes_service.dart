import 'package:flutter/material.dart';
import 'package:mynote/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;
  
  Future<DatabaseNotes> updateNote({required DatabaseNotes note, required String text}) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updateCount = await db.update(notesTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    }
    return await getNote(id: note.id);
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      notesTable
    );
    return notes.map((noteRow) => DatabaseNotes.fromRow(noteRow)).toList();
  }

  // this function will return a note from the database based on the id.
  Future<DatabaseNotes> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id]
    );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNotes.fromRow(notes.first);
    }
  }

  Future<int> deleteAllNotes() async {
    final  db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(notesTable);
    return deleteCount;
  }

  // this function will delete a note from the database based on the id 
  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id]
    );
    // if deleteCount is 0, it means that either the note was not found or there was an error during deletion.
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    }
  }  // this function will create a new note in the database for the given user.
  Future<DatabaseNotes> createNotes({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email: owner.email);
    // if the user is not found in the database, we throw a CouldNotFindUser exception.
    // This is to ensure that we can only create notes for existing users in the database.
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';
    final noteId = await db.insert(
      notesTable,
      {
        userIdColumn: owner.id,
        textColumn: text,
        isSyncedWithCloudColumn: 1
      }
    );
    final note = DatabaseNotes(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true
    );
    return note;
  }

  // this function will return a user from the database based on the email, it takes the email as a parameter and return a Future that completes with the DatabaseUser object when the user is found successfully or throws an exception if there is an error or if the user is not found
  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    // we query the database to find a user with the given email, we use limit 1 to optimize the query and only get one result
    // query return a list of maps, where each map represents a row in the database, and the keys of the map are the column names and the values are the corresponding values for that row
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()]
    );
    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      // if the result is not empty, it means we found a user with the given email, we take the first row from the result and convert it to a DatabaseUser object using the fromRow constructor.
      return DatabaseUser.fromRow(result.first);
    }
  } 

  // this function will create a new user in the database with the given email, it takes the email as a parameter and returns a Future that completes with the created DatabaseUser object when the user is created successfully or throws an exception if there is an error
  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    // we query the database to check if a user with the given email already exists, we use limit 1 to optimize the query and only get one result.
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()]
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }
    // id will hold the id of the newly created user, we use the insert method of the datbase to insert a new row into the user table with the given email
    // the insert method returns the id of the newly created row, which we can use to create a DatabaseUser object to return from this function
    final id = await db.insert(userTable, {
      emailColumn: email.toLowerCase()
    });
    // we return a new DatabaseUser object with the id and email of the created user, this will be the result of the Future returned by this function when it completes successfully
    return DatabaseUser(id: id, email: email);
  }

  // this function will delete a user from the database based on the email, it takes the email as a parameter and returns a Future that completes when the user is deleted successfully or throws an exception if there is an error
  Future<void> deleteUser({required String email}) async {
    // we get the reference to the opened database using the _getDatabaseOrThrow function, which will throw an exception if the database is not open, this ensures that we can only perform database operations when the database is open
    final db = _getDatabaseOrThrow();
    // we specify the where clause and where arguments to delete the user with the given email, we use whereArgs to prevent SQL injection attacks by separating the SQL command from the user input, this is a best practice when working with databases to ensure the security of our application
    // deleteCount will hold the number of rows that were deleted, we expect it to be 1 because we want to delete only one user with the given email, if it is not 1, it means that either the user was not found or there was an error during deletion
    // 'email = ?' is the where cluase that specifies the condition for deleting the user, the ? is a placeholder for the value that will be provided in the whereArgs list, this allow us to safely pass the email value without risking SQL injection, the database engine will replace the ? with the actual value from whereArgs when executing the delete command
    // SQL injection attak is a type of security vulnerability that allows an attacker to execute arbitrary SQL code on the database by manipulating the user input, by using parameterized queries with placeholders and separate arguements, we can prevent SQL injection attacks and ensure that the user input is treated as data rather than executable code
    // for example, if we directly concatenate the email into the SQL command like 'email = $email', an attacker could input something like ' OR 1=1 --' which would result in a SQL command that deletes all users in the database, but by using 'email = ?' and providing the email as a separate argument in whereArgs, we ensure that the email is treated as a string value and not as part of the SQL command.
    final deleteCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()]
    );
    // if deleteCount is not 1, it means that either the user was not found or there was an error during deletion, so we throw a CouldNotDeleteUser exception to indicate that we could not delete the user with the given email
    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    }
  }
  // this function will return the reference to the opened database if it is open, otherwise it will throw an exception
  // short answer: this function is a helper function that we use to get the reference to the opened database and ensure that it is open before we try to use it in other functions that perfrom database operations
  Database _getDatabaseOrThrow() {
    // Because _db is a class field, Dart can't guarantee it won't change between checking it and using it
    // By copying it to a local variable, Dart knows for sure it's not null after the if check.
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpend();
    } else {
      return db;
    }
  }

  // async function to open the database, it returns a Future that completes when the database is opened successfully or throws an exception if there is an error
  // we use async and await because opening the database is an asynchronous operation that can take some time, especially if the database file needs to be created or if there are many tables to create
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      // Get the path to the documents directory and create the full path for the database file
      // getApplicationDocumentasDirectory is a function from the path_provider package that returns the directory where we can store application data
      final docsPath = await getApplicationDocumentsDirectory();
      // join is a function from the path package that joins multiple path segments into a single path
      // we join the documents directory path with the database name to get the full path to the database file
      // we will use this path to open the database
      final dbPath = join(docsPath.path, dbName);
      // openDatabase is a function from the sqflite package that opens the database at the given path
      // if the database does not exist, it will be created
      // we await the result of openDatabase because it is an asynchronous operation
      // the result of openDatabase is a Database object that we can use to interact with the database
      final db = await openDatabase(dbPath);
      // assign the opened database to the _db variable
      _db = db;
        db.execute(createUserTable);
        db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpend();
    } else {
      await db.close();
      // we don't want to set db to null after closing the database because if there is an error while closing the database,
      // we want to keep the reference to the opened database in order to handle the error properly
      _db = null;
    }
  }
}

// this class is responsible for managing the SQLite database for user notes
@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  // Convert a DatabaseUser into a Map.
  // This map is used to insert the user into the database.
  // The keys must correspond the names of the columns in the database.
  // the map will be used
  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      email = map[emailColumn] as String;

  @override
  // toString method for easy debugging and logging
  String toString() => 'Person, ID = $id, email = $email';

  @override
  // Equality operator and hashCode override for comparing instances
  // We compare DatabaseUser instances based on their id
  // covariant is used to ensure the other object is of type DatabaseUser, for type safety
  // covariant allows us to specify a more specific type for the parameter
  // we want to compare DatabaseUser instances only, so we use covariant here
  // we don't want to compare DatabaseUser with other types like String or int...
  bool operator ==(covariant DatabaseUser other) => id == other.id;
  
  @override
  // Generate hashCode based on id
  // We use the id of the note to generate the hashCode, because the id is unique for each note and it is the primary key in the database, so it is a good candidate for generating the hashCode
  // By using the id for hashCode, we ensure that each note has a unique hashCode, which is important for collections like sets or maps that rely on hash codes for storing and retrieving objects efficiently
  // we use id instead of other propreties like text or userId because those propreties can be the same for different notes, but the id will always be unique for each note
  int get hashCode => id.hashCode;
  
}

// This class represents a note in the database
class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  // Constructor for creating a new DatabaseNotes instance
  DatabaseNotes({required this.id, required this.userId, required this.text, required this.isSyncedWithCloud});

  DatabaseNotes.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      text = map[textColumn] as String,
      isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

    // toString method for easy debugging and logging
    @override
    String toString() => 'DatabaseNotes, ID = $id, User ID = $userId, Text = $text, Is Synced = $isSyncedWithCloud';


    @override
    bool operator ==(covariant DatabaseNotes other) => id == other.id;
    
      @override
      int get hashCode => id.hashCode;
  }

// Constants for database configuration and table/column names
const dbName = 'notes.db';
const notesTable = 'notes';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

// Create the user and notes tables if they do not exist
const String createUserTable = '''
  CREATE TABLE IF NOT EXISTS "user" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "email" TEXT NOT NULL UNIQUE,
  PRIMARY KEY("id" AUTOINCREMENT)
  ); ''';

// The notes table has an id column that is the primary key, a user_id column that is a foreign key referencing the user table, a text column for the note content,
// and an is_synced_with_cloud column that indicates whether the note is synced with the cloud or not
// We also set the default value of is_synced_with_cloud to 0 (false) when a new note is created
// The foreign key constraint ensures that each note is associated with a valid user in the user table
const String createNoteTable = '''
  CREATE TABLE IF NOT EXISTS "notes" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "user_id" INTEGER NOT NULL,
  "text" TEXT,
  "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY("user_id") REFERENCES "user"("id"),
  PRIMARY KEY("id" AUTOINCREMENT)
  );''';