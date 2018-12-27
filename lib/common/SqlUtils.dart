import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

 String tableName = "t_user";
 String columnId = "userId";
 String columnName = "name";
 String columnPwd = "pwd";
 String columnFlag = "flag";
 String dbName = "marine.db";

 String sql_createTable =
      'create table IF NOT EXISTS $tableName ('+
        '$columnId integer primary key autoincrement, '+
        '$columnName text not null, '+
        '$columnPwd text not null,'+
        '$columnFlag text not null)';

class MarineUser {
  int id;
  String name;
  String pwd;
  String flag;

  Map toMap() {
    Map<String, dynamic> map = 
    {columnName: name, columnPwd: pwd, columnFlag:flag};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  MarineUser();

  MarineUser.fromMap(Map map) {
    id = map[columnId];
    name = map[columnName];
    pwd = map[columnPwd];
    flag = map[columnFlag];
  }
}

class MarineUserProvider {
  Future<String> createNewDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    if (await new Directory(dirname(path)).exists()) {
    } else {
      try {
        await new Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        print(e);
      }
    }
    return path;
  }

  createTable(dbPath) async {
    Database db = await openDatabase(dbPath);
    await db.execute(sql_createTable);
    await db.close();
  }

  Future<Map> insert(Map _user, String dbPath) async {
    print(_user);
    Database db = await openDatabase(dbPath);
    int id = await db.insert(tableName, _user);
    await db.close();
    _user[columnId] = id;
    return _user;
  }

  Future<Map> getDataByUserName(String userName, String dbPath) async {
    Database db = await openDatabase(dbPath);
    List<Map> maps = await db.query(tableName,
        columns: [columnId, columnName, columnPwd, columnPwd],
        where: "$columnName = ?",
        whereArgs: [userName]);
    await db.close();
    if (maps.length > 0) {
      return maps.first;
    }
    return null;
  }

  Future<Map> getDataById(int id, String dbPath) async {
    Database db = await openDatabase(dbPath);
    List<Map> maps = await db.query(tableName,
        columns: [columnId, columnName, columnPwd, columnPwd],
        where: "$columnId = ?",
        whereArgs: [id]);
    await db.close();
    if (maps.length > 0) {
      return maps.first;
    }
    return null;
  }

  Future<Map> getFirstData(String dbPath) async {
    Database db = await openDatabase(dbPath);
    List<Map> maps = await db.query(tableName,
        columns: [columnId, columnName, columnPwd, columnFlag]);
    await db.close();
    if (maps.length > 0) {
      return maps.first;
    }
    return null;
  }


  Future<Map> getData(int id, String dbPath) async {
    Database db = await openDatabase(dbPath);
    List<Map> maps = await db.query(tableName,
        columns: [columnId, columnName, columnPwd, columnPwd],
        where: "$columnId = ?",
        whereArgs: [id]);
    await db.close();
    if (maps.length > 0) {
      return maps.first;
    }
    return null;
  }

  Future<int> delete(int id, String dbPath) async {
    Database db = await openDatabase(dbPath);
    int _count =  await db.delete(tableName, where: "$columnId = ?", whereArgs: [id]);
    await db.close();
    return _count;
    
  }

  Future<int> update(Map todo, String dbPath) async {
    print(todo);
    Database db = await openDatabase(dbPath);
    int _count =  await db.update(tableName, todo,
        where: "$columnId = ?", whereArgs: [todo[columnId]]);
    await db.close();
    return _count;
  }
}
