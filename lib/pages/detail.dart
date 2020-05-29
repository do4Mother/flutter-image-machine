import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_machine/models/machine.dart';
import 'package:image_machine/pages/edit_machine.dart';
import 'package:image_machine/pages/image_detail.dart';
import 'package:image_machine/provider/machine_provider.dart';
import 'package:provider/provider.dart';

class Detail extends StatelessWidget {
  final Machine data;
  Detail({Key key, @required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text('Machine Details', style: TextStyle(
          color: Colors.black
        ),),
      ),
      body: DetailBody(data: data),
    );
  }
}

class DetailBody extends StatelessWidget {
  final Machine data;
  DetailBody({Key key, @required this.data}) : super(key: key);

  Future<void> deleteMachine(BuildContext context, Machine data) async{
    var state = Provider.of<MachineProvider>(context, listen: false);
    await state.open();
    await state.delete(data);
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  showAlert(BuildContext context, Machine data){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return CupertinoAlertDialog(
          title: Text('Delete'),
          content: Text('Are you sure want to delete this item?'),
          actions: <Widget>[
            CupertinoButton(
              child: Text('No'),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            CupertinoButton(
              child: Text('Yes'),
              onPressed: (){
                deleteMachine(context, data);
              },
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                data.name,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            metaData('ID', data.id.toString()),
            metaData('Type', data.type),
            metaData('QR Number', data.qr.toString()),
            metaData('Last Maintenance', data.date),
            listPhotos(context, data),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  color: Colors.green,
                  child: Text('Edit', style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => EditMachine(data: data)
                    ));
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(right: 18.0),
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  color: Colors.red,
                  child: Text('Remove', style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                  onPressed: (){
                    showAlert(context, data);
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget metaData(String text, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0)
          )
        ),
        child: ListTile(
          title: Text(text),
          subtitle: Text(subtitle),
        )
      ),
    );
  }

  Widget listPhotos(BuildContext context, Machine data) {
    final List<String> _getgallery = jsonDecode(data.imagepath).cast<String>();
    final List<File> _gallery = _getgallery.map((e) => File(e)).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
          elevation: 10.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          child: ListTile(
            title: Text('Gallery'),
            subtitle: _gallery.length == 0
                ? Text('No Images')
                : GridView.count(
                    padding: EdgeInsets.all(10.0),
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(
                        _gallery.length,
                        (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                  child: Hero(
                                      tag: index.toString(),
                                      child: Image.file(_gallery[index])),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ImageDetail(
                                                index: index.toString(),
                                                image: _gallery[index])
                                        )
                                    );
                                  }
                                ),
                              )
                            )
                        ),
          )
        ),
    );
  }
}
