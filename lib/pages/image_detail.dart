import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageDetail extends StatelessWidget {
  final String index;
  final File image;

  ImageDetail({Key key, @required this.index, @required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          child: PhotoView(
            imageProvider: FileImage(image),
            heroAttributes: PhotoViewHeroAttributes(
              tag: index,
              transitionOnUserGestures: true,
            ),
          ),
        ),
      ),
    );
  }
}
