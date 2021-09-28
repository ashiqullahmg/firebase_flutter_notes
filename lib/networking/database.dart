import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_notes/screens/home_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _mainCollection = _firestore.collection('notes');

class Database {
  static String? userUid;

  // to add new note in Firebase
  static Future<void> addItem({
    required String title,
    required String description,
    required String photoUrl,
    required String photoName,
    required List search,
  }) async {
    DocumentReference documentReferencer =
    _mainCollection.doc(userUid).collection('items').doc();

    Map<String, dynamic> data = <String, dynamic>{
      "title": title,
      "description": description,
      "timestamp": Timestamp.now(),
      "photoUrl" : photoUrl,
      "photoName" : photoName,
      "search" : search,
    };

    await documentReferencer
        .set(data)
        .whenComplete(() => print("Note item added to the database"))
        .catchError((e) => print(e));
  }

  //to update the current note in Firebase
  static Future<void> updateItem({
    required String title,
    required String description,
    required String docId,
    required List search,
    // required String photoUrl,
  }) async {
    DocumentReference documentReferencer =
    _mainCollection.doc(userUid).collection('items').doc(docId);

    Map<String, dynamic> data = <String, dynamic>{
      "title": title,
      "description": description,
      'timestamp': Timestamp.now(),
      'search': search,
    };

    await documentReferencer
        .update(data)
        .whenComplete(() => print("Note item updated in the database"))
        .catchError((e) => print(e));
  }


  //update the photo in Firebase
  static Future<void> updatePhoto({
    required String docId,
    required String photoUrl,
    required String photoName,
  }) async {
    DocumentReference documentReferencer =
    _mainCollection.doc(userUid).collection('items').doc(docId);

    Map<String, dynamic> data = <String, dynamic>{
      "photoUrl" : photoUrl,
      "photoName" : photoName,
    };

    await documentReferencer
        .update(data)
        .whenComplete(() => print("Note photo updated in the database"))
        .catchError((e) => print(e));
  }


  //read each note from firebase as a snapshot
  static Stream<QuerySnapshot> readItems() {
    CollectionReference notesItemCollection =
    _mainCollection.doc(userUid).collection('items');

    return notesItemCollection.orderBy('timestamp').snapshots();
  }

  //Search note in Firebase
  static Stream<QuerySnapshot> searchItem(String searchValue) {
    return FirebaseFirestore.instance.collection('notes')
        .doc(userUid)
        .collection('items')
        .where('search',  arrayContains: searchValue).snapshots();
  }

  //Delete a single note
  static Future<void> deleteItem({
    required String docId,
    required String photoName,
  }) async {
    DocumentReference documentReferencer =
    _mainCollection.doc(userUid).collection('items').doc(docId);

    if(photoName != ''){
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(Database.userUid.toString()).child(photoName);
      await ref.delete();
    }

    await documentReferencer
        .delete()
        .whenComplete(() => print('Note item deleted from the database'))
        .catchError((e) => print(e));
  }


  //Deleting multiple notes at a time
  static Future<void> deleteItems({
    required List items,
    required List photos,
    required context,
  }) async {

    if(photos.length != 0){
      for( int i = 0; i<photos.length; i++){
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child(Database.userUid.toString()).child(photos[i]);
        await ref.delete();
      }
    }
    for(int i = 0; i< items.length; i++) {
      DocumentReference documentReferencer =
      _mainCollection.doc(userUid).collection('items').doc(items[i]);
      await documentReferencer
          .delete()
          .whenComplete(() => print('Note items deleted from the database'))
          .catchError((e) => print(e));
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen(user: FirebaseAuth.instance.currentUser,)), (route) => false);
  }

}
