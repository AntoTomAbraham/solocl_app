import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../models/feed.dart';

class Homepage extends StatefulWidget {
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final query =
      FirebaseFirestore.instance.collection("feeds").withConverter<feed>(
            fromFirestore: (snapshot, _) => feed.fromJson(snapshot.data()!),
            toFirestore: (feed, _) => feed.toJson(),
          );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff4f4f4),
      appBar: AppBar(
        backgroundColor: Color(0xfff4f4f4),
        elevation: 0.0,
        title: Text(
          "Solocl",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Color(0xffFECD45),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height * 1,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 1 - 60,
                child: FirestoreListView<feed>(
                  query: query,
                  pageSize: 5,
                  itemBuilder: (context, snapshot) {
                    final feed = snapshot.data();
                    print(feed.image);
                    return showFeed(context, feed.image, feed.placeholder);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showFeed(BuildContext context, String image, String placeholder) {
    return Padding(
      padding: const EdgeInsets.only(left: 21.0, right: 21.0, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 25.0,
              spreadRadius: 5.0,
              offset: Offset(
                15.0,
                15.0,
              ),
            )
          ],
          color: Color(0xffffffff),
        ),
        height: MediaQuery.of(context).size.height * .66,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 15),
              Container(
                child: Image.network(image),
              ),
              SizedBox(height: 15),
              SizedBox(
                height: MediaQuery.of(context).size.height * .3,
                child: Text(
                  placeholder,
                  textAlign: TextAlign.justify,
                  style: GoogleFonts.lato(fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final controller = ScreenshotController();
                          final bytes = await controller.captureFromWidget(
                              Material(
                                  child:
                                      showFeed(context, image, placeholder)));
                          print(bytes.toString());
                          saveImage(bytes).whenComplete(() {
                            var snackBar = SnackBar(
                                content: Text('Successfully Saved to gallery'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          });
                        },
                        child: Icon(
                          Icons.file_download_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          await Share.share(
                              'Hi, I found this interesting News and Updates post on Solocl, which is an app to know all that is happening in our city\nSolocl says : $placeholder\nhttps://solocl.com/');
                        },
                        child: Icon(
                          Icons.share,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    String time = DateTime.now().toString();
    final result =
        await ImageGallerySaver.saveImage(bytes, name: 'Solocl_$time');
    return result['filePath'];
  }

  // void createSnackBar(String message) {
  //   final GlobalKey<ScaffoldState> _scaffoldKey =
  //       new GlobalKey<ScaffoldState>();
  //   _scaffoldKey.currentState
  //       .showSnackBar(new SnackBar(content: new Text(value)));
  // }
}
