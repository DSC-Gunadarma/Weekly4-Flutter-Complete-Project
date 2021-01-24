import 'dart:io';

import 'package:flutter/material.dart';
import 'const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

File _image;
var firestore = FirebaseFirestore.instance;

class _AddItemPageState extends State<AddItemPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Add Item Page",
          style: kWhiteTextStyle.copyWith(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
        shadowColor: Colors.grey.shade300,
      ),
      body: Container(
          margin: EdgeInsets.all(kHorizontalMargin),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: _image != null
                      ? GestureDetector(
                          onTap: () async {
                            _image = await chooseImage();
                            setState(() {});
                          },
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: AssetImage(_image.path),
                          ),
                        )
                      : GestureDetector(
                          onTap: () async {
                            _image = await chooseImage();
                            setState(() {});
                          },
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: AssetImage("images/empty_pic.png"),
                          ),
                        ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Nama Penyanyi",
                      hintText: "Nama Penyanyi"),
                ),
                SizedBox(
                  height: 25,
                ),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Tentang Penyanyi",
                    hintText: "Tentang Penyanyi",
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: kAccentColor1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Add Data",
                      style: kWhiteTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onPressed: () {
                    try {
                      uploadImage(_image, context, nameController.text,
                          descController.text);
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
              ],
            ),
          )),
    );
  }
}

Future<File> chooseImage() async {
  File currentImage;
  try {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      currentImage = image;
    });
  } catch (e) {
    print(e);
  }
  return currentImage;
}

Future<String> uploadImage(File image, BuildContext context, String singerName,
    String singerDesc) async {
  StorageReference storageReference = FirebaseStorage.instance
      .ref()
      .child('singers/${Path.basename(image.path)}}');
  StorageUploadTask uploadTask = storageReference.putFile(image);
  await uploadTask.onComplete;
  storageReference.getDownloadURL().then((fileURL) {
    addDatabase(context, singerName, singerDesc, fileURL);
  });
}

Future addDatabase(BuildContext context, String singerName, String singerDesc,
    String singerPhoto) async {
  CollectionReference books = firestore.collection('singers');

  try {
    DocumentReference result = await books.add(<String, String>{
      'name': singerName,
      'desc': singerDesc,
      'photo': singerPhoto,
    });
    if (result.id != null) {
      _image = null;
      Navigator.pop(context);
    }
  } catch (e) {
    print(e);
  }
}
