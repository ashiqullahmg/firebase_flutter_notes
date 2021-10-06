import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_notes/constants/colors.dart';
import 'package:firebase_flutter_notes/networking/database.dart';
import 'package:firebase_flutter_notes/screens/home_screen.dart';
import 'package:firebase_flutter_notes/screens/view_screen.dart';
import 'package:firebase_flutter_notes/utilities/encryption.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DbItemGrid extends StatefulWidget {
  final String searchValue;
  const DbItemGrid({Key? key, required this.searchValue,}) : super(key: key);

  @override
  _DbItemGridState createState() => _DbItemGridState();
  static _DbItemGridState? of(BuildContext context) => context.findAncestorStateOfType<_DbItemGridState>();

}

class _DbItemGridState extends State<DbItemGrid>  with SingleTickerProviderStateMixin {
  List<bool>userChecked = [];
  List<String> checkedImage = [];
  List<String> checkedItems = [];

  Encryption encryption = Encryption();

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.searchValue == '' ? Database.readItems() : Database.searchItem(widget.searchValue),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        } else if (snapshot.hasData || snapshot.data != null) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: RefreshIndicator(
              onRefresh: refreshData,
              child:AnimationLimiter(
                child: StaggeredGridView.countBuilder(
                  addAutomaticKeepAlives:false,
                  addRepaintBoundaries: false,
                  staggeredTileBuilder: (index) {
                    return new StaggeredTile.count(index == 2 ? 2 : 1, index == 2 ? 1 : 1);
                  },
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    List itemsList = [];
                    final data = snapshot.data!.docs.reversed;
                    for (var info in data) {
                      itemsList.add(info);
                    }
                    // final titleD = encryption.doDecryption(itemsList[index]['title']);
                    final titleD = itemsList[index]['title'];
                    final descriptionD =
                    encryption.doDecryption(itemsList[index]['description']);
                    String photoUrl = itemsList[index]['photoUrl'];
                    String photoName = itemsList[index]['photoName'];
                    String docID = itemsList[index].id;
                    String title = titleD;
                    String description = descriptionD;
                    userChecked.add(false);
                    final date = (DateFormat.yMMMMd().format(itemsList[index]['timestamp'].toDate()));
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                         Expanded(
                           child: AnimationConfiguration.staggeredGrid(
                             columnCount: index == 2 ? 1 : 2,
                             position: index,
                             duration: const Duration(seconds: 1),
                             child: SlideAnimation(
                                 // verticalOffset: 50.0,
                               horizontalOffset: 100.0,
                               child: FadeInAnimation(
                                 curve: Curves.easeInOut,
                                 child: GestureDetector(
                                   onLongPress: () {
                                     doCheck(index, docID, photoName);
                                   },
                                   onTap: () {

                                    checkedItems.isEmpty ? Navigator.of(context).push(
                                       MaterialPageRoute(

                                         builder: (context) => ViewScreen(
                                           currentTitle: title,
                                           currentDescription: description,
                                           documentId: docID,
                                           photoUrl: photoUrl,
                                           photoName: photoName,
                                           date : date,
                                         ),
                                       ),
                                     )  : doCheck(index, docID, photoName);
                                   },
                                   child: Stack(
                                     children: [
                                       Container(
                                         padding: const EdgeInsets.all(0),
                                         alignment: Alignment.center,
                                         child: Padding(
                                           padding: const EdgeInsets.all(12.0),
                                           child: Column(
                                             children: [
                                               Expanded(flex: 4,
                                                   child: Text(
                                                     title, style: TextStyle(fontSize: index == 2? 25: 20, color: Palette.lightDark),
                                                     overflow: TextOverflow.ellipsis,
                                                     maxLines: index == 2? 3 : 4,)),
                                               SizedBox(height: 5.0,),
                                               // Text(description,overflow: TextOverflow.ellipsis,),
                                               // SizedBox(height: 5.0,),
                                               Expanded(flex: 1, child: Text(date, style: TextStyle(color: Palette.lightDark),)),
                                             ],
                                           ),
                                         ),
                                         // height: 200,
                                         // height: itemAnimation.value  * 200,
                                         // width: index != 2? itemAnimation.value  * 190 : null,
                                         decoration: BoxDecoration(
                                             color: Palette().listColors[Random().nextInt(6)],
                                             borderRadius: BorderRadius.circular(15)),
                                       ),
                                       (checkedItems.isNotEmpty) ? Positioned(
                                          right: -2,
                                          child: Transform.scale(
                                            scale: 1.9,
                                            child: Checkbox(
                                              fillColor: MaterialStateProperty.all(Colors.white),
                                              checkColor: Theme.of(context).brightness == Brightness.dark
                                                  ? Palette.lightDark
                                                  : Colors.indigo,
                                                shape: CircleBorder(),
                                                value: userChecked[index], onChanged: (value){
                                              if(value == true){
                                                setState(() {
                                                  checkedItems.add(docID);
                                                 userChecked[index] = true;
                                                  if(photoName !=''){
                                                    checkedImage.add(photoName);
                                                  }
                                                });

                                              }else{
                                               setState(() {
                                                 checkedItems.remove(docID);
                                                 userChecked[index] = false;
                                                 if(photoName !=''){
                                                   checkedImage.remove(photoName);
                                                 }
                                               });
                                              }
                                              HomeScreen.of(context)!.checkedItems = checkedItems;
                                              HomeScreen.of(context)!.checkedImage = checkedImage;
                                              HomeScreen.of(context)!.setState(() {
                                              });
                                              print(checkedItems);
                                            }),
                                          ),
                                        ) : Container(),
                                     ],
                                   ),
                                 ),
                               ),
                             ),
                           ),),

                      ],
                    );
                  },
                ),
              ),
            ),
          );
        }

        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Palette.orange,
            ),
          ),
        );
      },
    );
  }


  Future refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      checkedItems = [];
      checkedImage = [];
      userChecked =[];
    });
    HomeScreen.of(context)!.setState(() {
      HomeScreen.of(context)!.checkedItems = [];
      HomeScreen.of(context)!.checkedImage = [];
    });

    return null;
  }

  doCheck( int index , String docID, String photoName){
    if(userChecked[index] == true){
      setState(() {
        userChecked[index] = false;
        checkedItems.remove(docID);
        if(photoName !=''){
          checkedImage.remove(photoName);
        }
      });
    }else{
      setState(() {
        userChecked[index] = true;
        checkedItems.add(docID);
        if(photoName !=''){
          checkedImage.add(photoName);
        }
      });}
    HomeScreen.of(context)!.checkedItems = checkedItems;
    HomeScreen.of(context)!.checkedImage = checkedImage;
    HomeScreen.of(context)!.setState(() {
    });
  }
}


