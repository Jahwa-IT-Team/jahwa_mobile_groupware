import 'dart:io';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jahwa_mobile_groupware/util/globals.dart';

class Update extends StatefulWidget {
  @override
  _UpdateState createState() => _UpdateState();
}

class _UpdateState extends State<Update> {

  // Call When Form Init
  @override
  void initState() {
    super.initState();
    print("open Update Page : " + DateTime.now().toString());
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width; // Screen Width
    screenHeight = MediaQuery.of(context).size.height; // Screen Height
    statusBarHeight = MediaQuery.of(context).padding.top;

    return GestureDetector( // For Keyboard UnFocus
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container( // Top Area
                height: statusBarHeight,
                width: screenWidth,
                color: Color.fromARGB(0xFF, 0x34, 0x40, 0x4E),
              ),
              Container( // Menu Area - Menu List Button + Menu Name + Close Button -> Index has not Close Button
                height: 50,
                alignment: Alignment.centerLeft,
                width: screenWidth,
                color: Color.fromARGB(0xFF, 0x34, 0x40, 0x4E),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 50,
                      alignment: Alignment.center,
                      child : IconButton(
                          icon: FaIcon(FontAwesomeIcons.times),
                          color: Colors.white,
                          onPressed: ()=> exit(0),
                      ),
                    ),
                    Container(
                      width: screenWidth - 100, // Index : 50, Exclude Index : 100
                      padding: EdgeInsets.all(10.0) ,
                      child: Text(
                        'Jahwa Mobile - Android Update',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15,),
                      ),
                    ),
                    Container(
                      width: 50,
                      alignment: Alignment.center,
                    ),
                  ],
                ),
              ),
              Container( // Main Area
                color: Color.fromARGB(0xFF, 0xFF, 0xFF, 0xFF),
                height: screenHeight - 50,
                width: screenWidth,
                alignment: Alignment.center,
                child : Column (
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget> [
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.download),
                      iconSize: 50,
                      color: Colors.blueAccent,
                      onPressed: () {
                        var url = "https://jims.jahwa.co.kr/File/JHMobile.apk";
                        launch(url);
                      },
                    ),
                    Text('Download', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16,),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}