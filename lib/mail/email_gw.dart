import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jahwa_mobile_groupware/util/common.dart';

import 'package:jahwa_mobile_groupware/util/globals.dart';

class EmailGW extends StatefulWidget {
  @override
  _EmailGWState createState() => _EmailGWState();
}

class _EmailGWState extends State<EmailGW> {

  // Call When Form Init
  @override
  void initState() {
    super.initState();
    print("open GW Mail Page : " + DateTime.now().toString());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // For Keyboard UnFocus
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(0xFF, 0x34, 0x40, 0x4E),
          title: Text(
            'GroupWare Email',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15,),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container( // Main Area
                color: Color.fromARGB(0xFF, 0xFF, 0xFF, 0xFF),
                width: screenWidth,
                alignment: Alignment.center,
                child : Column (
                  children: <Widget> [
                    Container(
                      width: screenWidth - 20,
                      padding: EdgeInsets.all(20.0) ,
                      alignment: Alignment.center,
                      child: Text(
                        'GW Mail Page',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50, fontFamily: 'NanumBrush'),
                      ),
                    ),
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