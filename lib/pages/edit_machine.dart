import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_machine/models/machine.dart';
import 'package:image_machine/provider/machine_provider.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

class EditMachine extends StatelessWidget {
  final Machine data;
  EditMachine({Key key, @required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        elevation: 0.0,
      ),
      body: EditMachineBody(data: data),
    );
  }
}

class EditMachineBody extends StatefulWidget {
  final Machine data;
  EditMachineBody({Key key, @required this.data});

  @override
  _EditMachineBodyState createState() => _EditMachineBodyState();
}

class _EditMachineBodyState extends State<EditMachineBody> {
  List<Asset> images = List<Asset>();
  final _form = GlobalKey<FormState>();

  Future<void> pickImage() async {
    try {
      List<Asset> imgs = await MultiImagePicker.pickImages(maxImages: 10);
      setState(() {
        images = imgs;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> saveData(Machine data) async {
    var state = Provider.of<MachineProvider>(context, listen: false);
    try {
      await state.open();
      await state.update(data);
    } catch (e) {
      print('Failed DB, ' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Edit Machine',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 18.0),
            ),
            formInput(context),
          ],
        ),
      ),
    );
  }

  Widget formInput(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: widget.data.name,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0), gapPadding: 4.0),
              labelText: 'Name',
            ),
            onSaved: (text) {
              widget.data.name = text;
            },
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 11)),
          TextFormField(
            initialValue: widget.data.type,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0), gapPadding: 4.0),
              labelText: 'Type',
            ),
            onSaved: (text) {
              widget.data.type = text;
            },
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 11)),
          TextFormField(
            initialValue: widget.data.qr.toString(),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0), gapPadding: 4.0),
              labelText: 'QR Number',
            ),
            keyboardType: TextInputType.number,
            onSaved: (text) {
              widget.data.qr = int.parse(text);
            },
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 11)),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.calendar_today),
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                  ),
                  Text(widget.data.date)
                ],
              ),
            ),
            onTap: () {
              DatePicker.showDatePicker(context, locale: LocaleType.en,
                  onConfirm: (date) {
                setState(() {
                  widget.data.date = '${date.day} / ${date.month} / ${date.year}';
                });
              });
            },
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 11)),
          CupertinoButton.filled(
            child: Text('Save'),
            onPressed: () async {

              // get date data
              widget.data.date = widget.data.date.contains('/') ? widget.data.date : 'No date selected before';

              _form.currentState.save();

              await saveData(widget.data);

              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Machine saved! please wait...'),
                )
              );

              Future.delayed(Duration(seconds: 2), (){
                Navigator.popUntil(context, ModalRoute.withName('/'));
              });
            },
          )
        ],
      ),
    );
  }

  Widget noImages() => Row(
        children: <Widget>[
          Icon(Icons.photo_library),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          Text('No Images')
        ],
      );

  Widget gridImages() {
    List<String> _getgallery = jsonDecode(widget.data.imagepath).cast<String>();
    List<File> _gallery = _getgallery.map((e) => File(e)).toList();
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: List.generate(_gallery.length, (index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            child: Image.file(_gallery[index], width: 150, height: 150,),
            onLongPress: () {
              setState(() {
                _gallery.removeAt(index);
              });
            },
          ),
        );
      }),
    );
  }
}
