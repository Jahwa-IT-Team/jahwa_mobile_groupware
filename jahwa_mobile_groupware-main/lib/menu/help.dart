import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jahwa_mobile_groupware/util/common.dart';
import 'package:jahwa_mobile_groupware/util/globals.dart';

ProgressDialog pr; /// 0. Progress Dialog Declaration

class HelpApp extends StatefulWidget {
  @override
  _HelpWidgetState createState() => _HelpWidgetState();
}

class _HelpWidgetState extends State<HelpApp> {
  @override
  Widget build(BuildContext context) {

    pr = ProgressDialog( /// 1. Progress Dialog Setting
      context,
      type: ProgressDialogType.Normal,
      isDismissible: true,
    );

    pr.style( /// 2. Progress Dialog Style
      message: translateText(context, 'Wait a Moment...'),
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      progressWidgetAlignment: Alignment.center,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w600),
    );

    screenWidth = MediaQuery.of(context).size.width; /// Screen Width
    screenHeight = MediaQuery.of(context).size.height; /// Screen Height
    statusBarHeight = MediaQuery.of(context).padding.top; /// Status Bar Height

    var baseWidth = screenWidth * 0.65;
    if(baseWidth > 280) baseWidth = 280;

    return GestureDetector(
      /// Keyboard UnFocus시를 위해 onTap에 GestureDetector를 위치시킴
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            ///height: screenHeight,
            width: screenWidth,
            color: Color.fromARGB(0xFF, 0xFF, 0xFF, 0xFF),
            child: Column(
              children: <Widget>[
                SizedBox( height: statusBarHeight, ), /// Status Bar
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.13,
                    alignment: Alignment.centerLeft,
                    color: Colors.blue,
                    child: Column(
                      children: <Widget>[
                        SizedBox( height: (screenHeight - statusBarHeight) * 0.05, ),
                        Container(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    '  ' + '도움말 시스템',
                                    style: TextStyle(fontSize: 25,color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                SizedBox( width: screenWidth * 0.4, ),
                                Container(
                                    width: screenWidth * 0.1,
                                    child:GestureDetector(
                                      child: Icon(Icons.arrow_back, color: Colors.white, size: 30,),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                ),
                              ],
                            )
                        ),
                      ],
                    )
                ),
                Container(
                  width: screenWidth,
                  height: (screenHeight - statusBarHeight) * 0.85,
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10), //border corner radius
                    boxShadow:[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2), //color of shadow
                        spreadRadius: 5, //spread radius
                        blurRadius: 7, // blur radius
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
