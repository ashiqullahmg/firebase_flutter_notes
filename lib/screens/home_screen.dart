import 'package:firebase_flutter_notes/components/item_grid.dart';
import 'package:firebase_flutter_notes/components/more_drawer.dart';
import 'package:firebase_flutter_notes/constants/colors.dart';
import 'package:firebase_flutter_notes/networking/database.dart';
import 'package:firebase_flutter_notes/utilities/capitalization.dart';
import 'package:firebase_flutter_notes/utilities/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_screen.dart';



class HomeScreen extends StatefulWidget {
  final User? user;
  const HomeScreen({Key? key, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
  static
  _HomeScreenState? of(BuildContext context) => context.findAncestorStateOfType<_HomeScreenState>();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDelete = false;
  List<String> checkedImage = [];
  List<String> checkedItems = [];
  final FocusNode _searchBarFocusNode = FocusNode();
  ThemeNotifier themeNotifier = ThemeNotifier();
  bool isSearch = false;
  String searchValue = '';
  TextEditingController searchBarController = TextEditingController();
  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Database.userUid = user.uid;
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        _searchBarFocusNode.unfocus();
        setState(() {
          isSearch = false;
          searchValue = '';
          searchBarController.text = '';
        });
      },
      child: Scaffold(
        drawer: MoreDrawer(user: widget.user),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: isSearch ? TextField(
            textCapitalization: TextCapitalization.words,
            controller: searchBarController,
            onChanged: (value) {
              setState(() {
                searchValue = value.capitalizeFirstofEach;
              });
            },
            onSubmitted: (String str){
              setState(() {
                isSearch = false;
              });
            },
            cursorColor: Theme
                .of(context)
                .brightness == Brightness.dark
                ? Palette.grey
                : Colors.white,
            autofocus: true,
            focusNode: _searchBarFocusNode,
            decoration: InputDecoration(
              hintText: "Search note...",
              border: InputBorder.none,
              hintStyle: TextStyle(color: Theme
                  .of(context)
                  .brightness == Brightness.dark
                  ? Palette.grey
                  : Colors.white,),
            ),
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ) : Text('My Notes',),
          actions: [
            !isSearch ?   IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  isSearch = true;
                });
              },
            ) : Container(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 5,
          onPressed: () async {
            if(checkedItems.length== 0) {
              // print(checkedItems);
              Navigator.of(context).push(
                MaterialPageRoute(
                  // builder: (context) => DbAddScreen(),
                  builder: (context) => DbAddScreen(),
                ),
              );
            } else{
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String str = checkedItems.length > 1 ? 'notes?' : 'note?';
                    return AlertDialog(
                      title: new Text("Do you want to delete ${checkedItems.length} "+ str ),
                      actions: <Widget>[
                        TextButton(
                          child: new Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: new Text("Delete", style: TextStyle(color: Colors.redAccent),),
                          onPressed: () async {
                            await Database.deleteItems(items: checkedItems, photos:checkedImage, context: context);;
                             // Navigator.of(context).pop();
                          },

                        ),
                      ],
                    );
                  });
              // Navigator.of(context).pop();
            }
          },
          backgroundColor: checkedItems.length == 0? null : Colors.red,
          child: Icon(
            checkedItems.length == 0 ?
            Icons.add : Icons.delete,
            // color: checkedItems.length == 0? null : Colors.red,
            size: 32,
          ),
        ),
        body:
            Column(
              children: [
                Expanded(
                  child: DbItemGrid(searchValue: searchValue,),
                ),
              ],
            ),
      ),
    );
  }
}

