
import 'package:firebase_flutter_notes/constants/colors.dart';
import 'package:firebase_flutter_notes/screens/full_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';


class View extends StatefulWidget {

  final FocusNode titleFocusNode;
  final FocusNode descriptionFocusNode;
  final String currentTitle;
  final String currentDescription;
  final String documentId;
  final String photoUrl;
  final String photoName;
  final String date;

  const View({
    required this.titleFocusNode,
    required this.descriptionFocusNode,
    required this.currentTitle,
    required this.currentDescription,
    required this.documentId,
    required this.photoUrl,
    required this.photoName,
    required this.date,
  });

  @override
  _ViewState createState() => _ViewState();
}

class _ViewState extends State<View> {

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    _titleController = TextEditingController(
      text: widget.currentTitle,
    );

    _descriptionController = TextEditingController(
      text: widget.currentDescription,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 10.0,
              top: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.currentTitle, style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),),
                SizedBox(height: 7.0,),
                Text(widget.date, style: TextStyle(
                  fontSize: 21,
                  color: Theme
                      .of(context)
                      .brightness == Brightness.dark
                      ? Palette.grey.withOpacity(0.7)
                      : Palette.lightDark.withOpacity(0.7),
                  fontWeight: FontWeight.normal,
                ),),
                SizedBox(height: 5.0,),

                Column(
                  children: [
                    Center(
                      child:(widget.photoUrl != "")
                          ? Material(
                        // show uploaded image file
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) =>
                                    FullPhoto(url: widget.photoUrl,
                                        title: widget.currentTitle)));
                          },
                          child: CachedNetworkImage(
                            placeholder: (context, url) =>
                                Center(
                                  child: Container(
                                    child: CircularProgressIndicator(
                                    ),
                                  ),
                                ),
                            imageUrl: widget.photoUrl,
                            // width: double.infinity,
                            height: 160.0,
                            // fit: BoxFit.cover,
                          ),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                          : Container(
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.photoUrl != '' ? 15.0 : 0.0),
                Text(
                  widget.currentDescription,
                  style: TextStyle(
                    color: Theme
                        .of(context)
                        .brightness == Brightness.dark
                        ? Palette.grey
                        : Palette.lightDark,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),

        ],
      ),
    );
  }

}