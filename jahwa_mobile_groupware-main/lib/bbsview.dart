import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jahwa_mobile_groupware/util/common.dart';
import 'package:jahwa_mobile_groupware/util/globals.dart';
import 'package:jahwa_mobile_groupware/util/program_list.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:intl/intl.dart';

ProgressDialog pr; /// 0. Progress Dialog Declaration

class BbsViewApp extends StatefulWidget {
  @override
  _BbsViewWidgetState createState() => _BbsViewWidgetState();
}

class _BbsViewWidgetState extends State<BbsViewApp> {

  var Subject = "";
  var Name = "";
  var Insdate = "";
  var ReadCnt = "";
  var Contents = "";
  var Type = "";
  var ImageCnt = 0;

  List<Card> cardList = [];

  void initState() {
    BbsTitle = "";
    super.initState();
    getJSONData();
    print("open Employee Info Page : " + DateTime.now().toString());
  }

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
                                  width: screenWidth * 0.8,
                                  child: Text(
                                    '  ' + BbsTitle,
                                    style: TextStyle(fontSize: 25,color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
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
                  ///height: (screenHeight - statusBarHeight) * 0.85,
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
                  child: Column(
                    children: <Widget>[
                      SizedBox( height: (screenHeight - statusBarHeight) * 0.01, ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(10),
                        child: Text(
                          '${Subject}',
                          style: TextStyle(fontSize: 22 , fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        height:1,
                        width: screenWidth * 0.9,
                        color:Colors.grey
                      ),
                      SizedBox( height: (screenHeight - statusBarHeight) * 0.01, ),
                      Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.all(10),
                        child: Text(
                          '${Name} [${Insdate}], 조회수: ${ReadCnt}',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox( height: (screenHeight - statusBarHeight) * 0.01, ),
                      if(Type != "Image")
                      Html(data: Contents),
                      if(Type == "Image")
                      Container( // Main Area
                        width: screenWidth * 0.9,
                        height: (screenHeight - statusBarHeight) * 0.5 * ImageCnt,
                        alignment: Alignment.topCenter,
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView(
                            children: ListTile.divideTiles(
                              context: context,
                              tiles: cardList,
                            ).toList(),
                          ),
                        ),
                      ),
                    ],
                  )
                ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> getJSONData() async {
    try {
      // Login API Url
      var url = 'https://jhapi.jahwa.co.kr/BbsView';

      // Send Parameter
      var data = {'Num': BbsNum, 'Lang': "ko-KR", 'EmpCode': session['EmpCode']};
      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 15)).then<bool>((http.Response response) async {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Server Info. Data Error !!!'); }
        else if(response.statusCode == 200){
          await pr.show();
          if(jsonDecode(response.body)['Table'].length == 0) {

          }
          else {
            jsonDecode(response.body)['Table'].forEach((element) {
              BbsTitle = element["Title"].toString();
              Subject = element["Subject"].toString();
              Name = element["Name"].toString();
              Insdate = element["InsDate"].toString();
              ReadCnt = element["ReadCnt"].toString();
              Contents = element["Contents"].toString();
            });

          }

          if(jsonDecode(response.body)['Table4'].length == 0) {

          }
          else {
            jsonDecode(response.body)['Table4'].forEach((element) {
              Type = element["Type"].toString();
            });
          }
          await pr.hide();
          ImageCnt = 0;

          await pr.show();
          if(jsonDecode(response.body)['Table3'].length == 0) {
            cardList.clear();
          }
          else {
            /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            cardList.clear();
            jsonDecode(response.body)['Table3'].forEach((element) {
              Widget card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.8,
                      height: (screenHeight - statusBarHeight) * 0.5,
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color:Colors.white, width: 2, style: BorderStyle.solid,),
                        image: DecorationImage(
                            image: NetworkImage('https://gw.jahwa.co.kr/Pics/Board/' + element["Code"].toString() + '/' + element["FileCode"].toString() + '' + element["FileExt"].toString(),)),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ],
                ),
              );
              cardList.add(card);
              ImageCnt++;
            });
          }
          await pr.hide();
          setState(() {
          });
        }
        return true;
      });
    }
    catch (e) {
      showMessageBox(context, 'Alert', 'Preference Setting Error A : ' + e.toString());
    }
  }
}
