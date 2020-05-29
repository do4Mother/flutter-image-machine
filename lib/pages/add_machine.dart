import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_machine/models/machine.dart';
import 'package:image_machine/provider/machine_provider.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

class AddMachine extends StatelessWidget {
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
      body: AddMachineBody(),
    );
  }
}

class AddMachineBody extends StatefulWidget {
  @override
  _AddMachineBodyState createState() => _AddMachineBodyState();
}

class _AddMachineBodyState extends State<AddMachineBody> {
  String thedate = 'Last Maintenance';
  List<Asset> images = List<Asset>();
  final _form = GlobalKey<FormState>();
  Machine _data = Machine();

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
      await state.insert(data);
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
              'Add Machine',
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
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0), gapPadding: 4.0),
              labelText: 'Name',
            ),
            onSaved: (text) {
              _data.name = text;
            },
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 11)),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0), gapPadding: 4.0),
              labelText: 'Type',
            ),
            onSaved: (text) {
              _data.type = text;
            },
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 11)),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0), gapPadding: 4.0),
              labelText: 'QR Number',
            ),
            keyboardType: TextInputType.number,
            onSaved: (text) {
              _data.qr = int.parse(text);
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
                  Text(thedate)
                ],
              ),
            ),
            onTap: () {
              DatePicker.showDatePicker(context, locale: LocaleType.en,
                  onConfirm: (date) {
                setState(() {
                  thedate = '${date.day} / ${date.month} / ${date.year}';
                });
              });
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
                child: images.length == 0 ? noImages() : gridImages()),
            onTap: () {
              pickImage();
            },
          ),
          if (images.length == 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 18.0),
              child: Text('Tap images to select image'),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 18.0),
              child: Text(
                  'total images ${images.length} - press and hold to remove images'),
            ),
          CupertinoButton.filled(
            child: Text('Save'),
            onPressed: () async {

              // get image path
              List<String> json = await Future.wait(images.map((e) => FlutterAbsolutePath.getAbsolutePath(e.identifier)));
              _data.imagepath = jsonEncode(json);
              
              // get date data
              _data.date = thedate.contains('/') ? thedate : 'No date selected before';

              _form.currentState.save();

              await saveData(_data);

              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('Machine saved! please wait...'),
                )
              );

              Future.delayed(Duration(seconds: 2), (){
                Navigator.pop(context);
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
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            child: AssetThumb(
              asset: images[index],
              width: 150,
              height: 150,
            ),
            onLongPress: () {
              setState(() {
                images.removeAt(index);
              });
            },
          ),
        );
      }),
    );
  }
}
