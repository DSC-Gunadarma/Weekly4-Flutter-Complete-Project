import 'dart:io';

import 'package:flutter/material.dart';
import 'const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';

class AddUpdateItemPage extends StatefulWidget {
  final id;
  final String name;
  final String desc;
  final String photo;

  AddUpdateItemPage(this.id, {this.name, this.desc, this.photo});
  @override
  _AddUpdateItemPageState createState() => _AddUpdateItemPageState();
}

File _image;
var firestore = FirebaseFirestore.instance;

class _AddUpdateItemPageState extends State<AddUpdateItemPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.id != null) {
      nameController.text = widget.name;
      descController.text = widget.desc;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            _image = null;
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
                            backgroundImage: FileImage(_image),
                          ),
                        )
                      : GestureDetector(
                          onTap: () async {
                            _image = await chooseImage();
                            setState(() {});
                          },
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: widget.id != null
                                ? NetworkImage(widget.photo)
                                : AssetImage("images/empty_pic.png"),
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
                      widget.id == null ? "Add Data" : "Update Data",
                      style: kWhiteTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onPressed: () {
                    try {
                      uploadImage(_image, context, widget.id,
                          nameController.text, descController.text);
                      _image = null;
                      Navigator.pop(context);
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

Future<String> uploadImage(File image, BuildContext context, String id,
    String singerName, String singerDesc) async {
  StorageReference storageReference = FirebaseStorage.instance
      .ref()
      .child('singers/${Path.basename(image.path)}}');
  StorageUploadTask uploadTask = storageReference.putFile(image);
  await uploadTask.onComplete;
  storageReference.getDownloadURL().then((fileURL) {
    if (id == null) {
      addDatabase(context, singerName, singerDesc, fileURL);
    } else {
      updateDatabase(context, id, singerName, singerDesc, fileURL);
    }
  });
}

Future addDatabase(BuildContext context, String singerName, String singerDesc,
    String singerPhoto) async {
  CollectionReference singers = firestore.collection('singers');

  try {
    DocumentReference result = await singers.add(<String, String>{
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

Future updateDatabase(BuildContext context, String id, String singerName,
    String singerDesc, String singerPhoto) async {
  DocumentReference currentSinger = firestore.collection('singers').doc(id);
  await currentSinger.update(<String, String>{
    'name': singerName,
    'desc': singerDesc,
    'photo': singerPhoto,
  });
}
