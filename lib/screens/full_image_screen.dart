import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
class FullPhoto extends StatelessWidget {
  final String url;
  final String title;
  const FullPhoto({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis,),
        centerTitle: true,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(url),
        ),
      ),
    );
  }
}

