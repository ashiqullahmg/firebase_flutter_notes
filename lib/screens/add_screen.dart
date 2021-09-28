import 'package:firebase_flutter_notes/components/form_field.dart';
import 'package:firebase_flutter_notes/components/showSnack.dart';
import 'package:firebase_flutter_notes/constants/colors.dart';
import 'package:firebase_flutter_notes/networking/database.dart';
import 'package:firebase_flutter_notes/utilities/encryption.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_flutter_notes/networking/validator.dart';
import 'package:firebase_flutter_notes/utilities/capitalization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DbAddScreen extends StatefulWidget {


  const DbAddScreen({Key? key}) : super(key: key);

  @override
  _DbAddScreenState createState() => _DbAddScreenState();
}

class _DbAddScreenState extends State<DbAddScreen> {
  String photoUrl = "";
  File? image;
  File? newImage;
  String photoName = "";
  bool isImageSelected = false;
  final _addItemFormKey = GlobalKey<FormState>();
  Encryption encryption = Encryption();
  bool _isProcessing = false;
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        titleFocusNode.unfocus();
        descriptionFocusNode.unfocus();
      },
      child: Scaffold(
        bottomNavigationBar:buildBottomNavigationBar() ,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: IconButton(
                onPressed: () {Navigator.pop(context);},
                icon: Icon(Icons.arrow_back_ios)
            ),
          ),
          elevation: 0,
          centerTitle: true,
          title: Text('Notes'),
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
                key: _addItemFormKey,
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
                          SizedBox(height: 30.0),
                          CustomFormField(
                            fontSize: 35,
                            isLabelEnabled: false,
                            controller: _titleController,
                            focusNode: titleFocusNode,
                            keyboardType: TextInputType.multiline,
                            inputAction: TextInputAction.next,
                            validator: (value) => DbValidator.validateField(
                              value: value,
                            ),
                            label: 'Title',
                            hint: 'Title',
                          ),
                          Center(
                            child: Stack(
                              children: [
                                (image == null)
                                    ? (photoUrl != '')
                                    ? Material(
                                  // show uploaded image file
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) =>
                                        Container(
                                          child: Image(image: AssetImage(
                                              'assets/placeholder.png'),),
                                        ),
                                    imageUrl: photoUrl,

                                  ),
                                )
                                    : Container(
                                )
                                    : Material(
                                  color: Colors.transparent,
                                  child: Image.file(
                                    image!,
                                    height: 160,
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
                            focusNode: descriptionFocusNode,
                            keyboardType: TextInputType.multiline,
                            inputAction: TextInputAction.newline,
                            validator: (value) => DbValidator.validateField(
                              value: value,
                            ),
                            label: 'Description',
                            hint: 'Type something...',
                          ),
                        ],
                      ),
                    ),
                    _isProcessing
                        ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Palette.orange,
                        ),
                      ),
                    )
                        : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                        ),
                        isImageSelected
                            ? CircularProgressIndicator()
                            : Container(),
                      ],
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

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
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

  Future getImage() async {
    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    newImage = File(xFile!.path);
    if (newImage != null) {
      this.setState(() {
        image = newImage;
        isImageSelected = true;
      });
      uploadImage();
    }
  }

  Future uploadImage() async {
    String mFileName =
        '${DateTime.now().millisecondsSinceEpoch}${Database.userUid.toString()}';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref =
    storage.ref().child(Database.userUid.toString()).child(mFileName);
    UploadTask uploadTask = ref.putFile(image!);
    await uploadTask.then((value) {
      value.ref.getDownloadURL().then((newUrl) {
        setState(() {
          photoUrl = newUrl;
          showSnack('Photo Uploaded!', context);
          photoName = mFileName;
          isImageSelected = false;
        });
      }, onError: (errorMessage) {
        showSnack(errorMessage.toString(), context);
      });
    }, onError: (errorMessage) {
      showSnack(errorMessage.toString(), context);
    });
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

  save() async{
    titleFocusNode.unfocus();
    descriptionFocusNode.unfocus();

    if (_addItemFormKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });
      final title = _titleController.text;
      final description = encryption
          .doEncryption(_descriptionController.text);
      !isImageSelected
          ? await Database.addItem(
        //TODO
        photoName: photoName,
        photoUrl: photoUrl,
        // title: title.base64,
        title: title,
        search: setSearch(title.capitalizeFirstofEach),

        description: description.base64,
      )
          : showSnack('Please wait...', context);

      setState(() {
        _isProcessing = false;
      });
      if (!isImageSelected) {
        Navigator.of(context).pop();
      }
    }
  }
}
