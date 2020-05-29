import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_machine/models/machine.dart';
import 'package:image_machine/pages/detail.dart';

class ListMachine extends StatelessWidget {
  final Machine data;
  ListMachine({Key key, @required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))),
      child: ListTile(
        leading: Icon(CupertinoIcons.tag),
        title: Text(data.name),
        trailing: Icon(CupertinoIcons.right_chevron),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Detail(data: data)));
        },
      ),
    );
  }
}
