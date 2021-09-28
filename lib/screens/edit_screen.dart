import 'dart:io';
import 'package:firebase_flutter_notes/components/form_field.dart';
import 'package:firebase_flutter_notes/networking/database.dart';
import 'package:firebase_flutter_notes/networking/validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_notes/utilities/encryption.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'full_image_screen.dart';
import 'package:firebase_flutter_notes/components/showSnack.dart';
import 'package:firebase_flutter_notes/screens/full_image_screen.dart';
import 'package:firebase_flutter_notes/utilities/capitalization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
class DbEditScreen extends StatefulWidget {
  final String currentTitle;
  final String currentDescription;
  final String documentId;
  final String photoUrl;
  final String photoName;

  DbEditScreen({
    required this.currentTitle,
    required this.currentDescription,
    required this.documentId,
    required this.photoUrl,
    required this.photoName,
  });

  @override
  _DbEditScreenState createState() => _DbEditScreenState();
}

class _DbEditScreenState extends State<DbEditScreen> {
  final FocusNode _titleFocusNode = FocusNode();

  final FocusNode _descriptionFocusNode = FocusNode();
  File? image;
  File? newImage;
  String photoUrl = "";
  final _editItemFormKey = GlobalKey<FormState>();
  Encryption encryption = Encryption();
  bool _isProcessing = false;
  bool isUpload = false;

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
    return GestureDetector(
      onTap: () {
        _titleFocusNode.unfocus();
        _descriptionFocusNode.unfocus();
      },
      child: Scaffold(
        bottomNavigationBar:buildBottomNavigationBar() ,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: IconButton(
                onPressed: () {Navigator.pop(context);},
                icon: Icon(Icons.arrow_back_ios)
            ),
          ),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 20.0,
            ),
            child: SingleChildScrollView(
        child: Form(
          key: _editItemFormKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                  bottom: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFormField(
                      fontSize: 35,
                      isLabelEnabled: false,
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      keyboardType: TextInputType.text,
                      inputAction: TextInputAction.next,
                      validator: (value) =>
                          DbValidator.validateField(
                            value: value,
                          ),
                      label: 'Title',
                      hint: 'Title',
                    ),
                    Center(
                      child: Stack(
                        children: [
                          (image == null)
                              ? (widget.photoUrl != "")
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
                                    Container(
                                      child: Image(image: AssetImage(
                                          'assets/placeholder.png'),),
                                      padding: EdgeInsets.all(0),
                                    ),
                                imageUrl: widget.photoUrl,
                                // width: 160.0,
                                height: 160.0,
                                // fit: BoxFit.fitWidth,
                              ),
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          )
                              : Container(
                          )
                              : Material(
                            color: Colors.transparent,
                            child: Image.file(
                              image!,
                              height: 160.0,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.0),
                    CustomFormField(
                      fontSize: 21,
                      maxLines: 10,
                      isLabelEnabled: false,
                      controller: _descriptionController,
                      focusNode: _descriptionFocusNode,
                      keyboardType: TextInputType.multiline,
                      inputAction: TextInputAction.newline,
                      validator: (value) =>
                          DbValidator.validateField(
                            value: value,
                          ),
                      label: 'Description',
                      hint: 'Type something...',
                    ),
                    SizedBox(height: 3.3,),
                    _isProcessing
                        ? Center(
                          child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                      ),
                    ),
                        ) : Container(),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    newImage = File(xFile!.path);
    if (newImage != null) {
      this.setState(() {
        image = newImage;
        isUpload = true;
      });
    }
  }

  Future uploadImage() async {
    String mFileName = widget.photoName != ''?  widget.photoName : '${DateTime.now().millisecondsSinceEpoch}${Database.userUid.toString()}';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(Database.userUid.toString()).child(
        mFileName);
    UploadTask uploadTask = ref.putFile(image!);
    await uploadTask.then((value) {
      value.ref.getDownloadURL().then((newUrl) async{
        // showSnack('Photo Uploaded!', context);
        await Database.updatePhoto(
          photoUrl:newUrl,
          docId: widget.documentId,
          photoName: mFileName,
        );
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeScreen(user: FirebaseAuth.instance.currentUser,)), (route) => false);
      }, onError: (errorMessage) {
        showSnack(errorMessage.toString(), context);
      });
    }, onError: (errorMessage) {
      showSnack(errorMessage.toString(), context);
    });
  }


  update(final title, final description, final search) async{
    await Database.updateItem(
      docId: widget.documentId,
      title: title,
      description: description.base64,
      search: setSearch(search),
    );
    if(isUpload){
      await uploadImage();
    }else{  Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen(user: FirebaseAuth.instance.currentUser,)), (route) => false);}
  }

  setSearch(String searchValue) {
    late List<String>  caseSearchList = [];
    String temp = "";
    for (int i = 0; i < searchValue.length; i++) {
      temp = temp + searchValue[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      // currentIndex: 1,
      onTap: (value) {
        print(value);
        value == 0 ?
        getImage() :  save();
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.photo), label: "Photo"),
        BottomNavigationBarItem(icon: Icon(Icons.save), label: "Save"),
      ],
    );
  }

  save() async{
    _titleFocusNode.unfocus();
    _descriptionFocusNode.unfocus();

    if (_editItemFormKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });
      final title = _titleController.text;
      final description = encryption.doEncryption(
          _descriptionController.text);
      await update(title, description, title.capitalizeFirstofEach);

      setState(() {
        _isProcessing = false;
      });
    }
  }
}
