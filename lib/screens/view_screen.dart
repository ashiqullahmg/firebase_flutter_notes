import 'package:firebase_flutter_notes/components/showSnack.dart';
import 'package:firebase_flutter_notes/components/view.dart';
import 'package:firebase_flutter_notes/networking/database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import '../main.dart';
import 'edit_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewScreen extends StatefulWidget {
  final String currentTitle;
  final String currentDescription;
  final String documentId;
  final String photoUrl;
  final String photoName;
  final String date;

  ViewScreen({
    required this.currentTitle,
    required this.currentDescription,
    required this.documentId,
    required this.photoUrl,
    required this.photoName,
    required this.date,
  });

  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  final FocusNode _titleFocusNode = FocusNode();
  List<String> imagePaths = [];
  final FocusNode _descriptionFocusNode = FocusNode();

  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _titleFocusNode.unfocus();
        _descriptionFocusNode.unfocus();
      },
      child: Scaffold(
        bottomNavigationBar: buildBottomNavigationBar(),
        appBar: AppBar(
          // leadingWidth: 50,
          leading: Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: IconButton(
              onPressed: () {Navigator.pop(context);},
              icon: Icon(Icons.arrow_back_ios)
            ),
          ),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                // Icons.edit_road_sharp,
                FontAwesomeIcons.edit,
                // color: Colors.redAccent,
                size: 25,
              ),
              onPressed: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    //TODO: Goes to Edit Screen
                    builder: (context) => DbEditScreen(
                      currentTitle: widget.currentTitle,
                      currentDescription: widget.currentDescription,
                      documentId: widget.documentId,
                      photoUrl: widget.photoUrl,
                      photoName: widget.photoName,

                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 20.0,
            ),
            child: View(
              documentId: widget.documentId,
              titleFocusNode: _titleFocusNode,
              descriptionFocusNode: _descriptionFocusNode,
              currentTitle: widget.currentTitle,
              currentDescription: widget.currentDescription,
              photoUrl: widget.photoUrl,
              photoName: widget.photoName,
              date: widget.date,
            ),
          ),
        ),
      ),
    );
  }
  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      // currentIndex: 1,
      onTap: (value) {
        print(value);
        value == 0 ?
        delete() : value == 1 ? copy() : shareNote() ;
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.delete), label: "Delete"),
        BottomNavigationBarItem(icon: Icon(Icons.copy), label: "Copy"),
        BottomNavigationBarItem(icon: Icon(Icons.share), label: "Share"),
      ],
    );
  }

  Future<Null> shareNote() async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    if (Platform.isAndroid) {
      if(widget.photoUrl != '') {
        var url = widget.photoUrl;
        var response = await get(Uri.parse(url));
        final documentDirectory = (await getExternalStorageDirectory())!.path;
        File imgFile = new File('$documentDirectory/flutter.png');
        imagePaths.add(imgFile.path);
        imgFile.writeAsBytesSync(response.bodyBytes);
        Share.shareFiles(imagePaths,
            subject: widget.currentTitle,
            text: widget.currentDescription,
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
      } else{
        Share.share(widget.currentDescription,
            subject: widget.currentTitle,
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
      }
    } else {
      Share.share(widget.currentDescription,
          subject: widget.currentTitle,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }
  delete(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Do you want to delete?"),
            actions: <Widget>[
              TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: new Text("Delete"),
                onPressed: () async {
                  await Database.deleteItem(
                    photoName: widget.photoName,
                    docId: widget.documentId,
                  );
                  // Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => HomeScreen(user: FirebaseAuth.instance.currentUser,)), (route) => false);
                },
              ),
            ],
          );
        });
  }
  copy(){
    Clipboard.setData(ClipboardData(text: '${widget.photoUrl}\n${widget.currentTitle}\n${widget.currentDescription}'));
    showSnack('Copied', context);
  }
}
