import 'package:flutter/material.dart';
import 'package:image_machine/models/machine.dart';
import 'package:sqflite/sqflite.dart';

class MachineProvider extends ChangeNotifier {
  Database db;

  Future<void> open() async {
    db = await openDatabase(
      'my_db.db', 
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE ImageMachine (id INTEGER PRIMARY KEY, name TEXT, type TEXT, qr INTEGER, date TEXT, imagepath TEXT)');
      },
    );
  }

  Future<List<Machine>> read() async {
    List<Map> getData;
    try {
      await open();

      getData = await db.query('ImageMachine', 
        columns: ['id', 'name' ,'type', 'qr', 'date', 'imagepath'],
      );

      db.close();
    } catch (e) {
      print('Failed DB, ' + e.toString());
    }

    if(getData.isNotEmpty) {
      return getData.map((e) => Machine.fromJson(e)).toList();
    }

    return List<Machine>();
  }

  Future<List<Machine>> readBarcode(String number) async {
    List<Map> getData;
    try {
      await open();

      getData = await db.query('ImageMachine', 
        columns: ['id', 'name' ,'type', 'qr', 'date', 'imagepath'],
        where: 'qr = ?',
        whereArgs: [number]
      );

      db.close();
    } catch (e) {
      print('Failed DB, ' + e.toString());
    }

    if(getData.isNotEmpty) {
      return getData.map((e) => Machine.fromJson(e)).toList();
    }

    return List<Machine>();
  }

  Future<void> insert(Machine data) async {
    try {
      await db.insert('ImageMachine', data.toJson());
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<int> update(Machine data) async {
    int res;
    try {
      res = await db.update('ImageMachine', data.toJson(),
        where: 'id = ?', whereArgs: [data.id]
      );
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
    return res;
  }

  Future<int> delete(Machine data) async {
    int number;
    try {
      number = await db.delete('ImageMachine', where: 'id = ?', whereArgs: [data.id]);
      notifyListeners();
    } catch (e) {
      number = 0;
      print(e.toString());
    }
    return number;
  }
}