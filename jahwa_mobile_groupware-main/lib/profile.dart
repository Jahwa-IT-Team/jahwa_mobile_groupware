import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jahwa_mobile_groupware/util/common.dart';
import 'package:jahwa_mobile_groupware/util/globals.dart';
import 'package:http/http.dart' as http;

ProgressDialog pr; /// 0. Progress Dialog Declaration

class ProfileApp extends StatefulWidget {
  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileApp> {
  var name = "";
  var eng_name = "";
  var company = "";
  var department = "";
  var roll_pstn = "";
  var em_tel_no = "";
  var hand_tel_no = "";
  var email_addr = "";
  var addr = "";
  var photo = "NONE.jpg";

  bool _isLoading = true;

  void initState() {
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
                    height: (screenHeight - statusBarHeight) * 0.15,
                    color: Colors.blue,
                    child: Column(
                      children: <Widget>[
                        SizedBox( height: (screenHeight - statusBarHeight) * 0.05, ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '  ' + 'Profile',
                            style: TextStyle(fontSize: 25,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    )
                ),
                Container(
                  width: screenWidth,
                  height: (screenHeight - statusBarHeight) * 0.9,
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.topCenter,
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
                        Container(
                          width: screenWidth * 0.3,
                          height: (screenHeight - statusBarHeight) * 0.2,
                          margin: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color:Colors.white, width: 2, style: BorderStyle.solid,),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage('https://gw.jahwa.co.kr/Photo/' + '${photo}')),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        Container(
                          child: Text(
                            '${name}',
                             style: TextStyle(fontSize: 30),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Text(
                            '${eng_name}',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                        SizedBox( height: (screenHeight - statusBarHeight) * 0.01, ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Text(
                            '${company}',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Text(
                            '${department} ${roll_pstn}',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox( height: (screenHeight - statusBarHeight) * 0.03, ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: screenWidth * 0.02,),
                              Icon(Icons.call, color: Colors.blue),
                              SizedBox(width: screenWidth * 0.03,),
                              Container(
                                width: screenWidth * 0.8,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
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
                                child: Text(
                                  ' ${em_tel_no}',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: screenWidth * 0.02,),
                              Icon(Icons.phone_android, color: Colors.blue),
                              SizedBox(width: screenWidth * 0.03,),
                              Container(
                                width: screenWidth * 0.8,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
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
                                child: Text(
                                  ' ${hand_tel_no}',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: screenWidth * 0.02,),
                              Icon(Icons.mail, color: Colors.blue),
                              SizedBox(width: screenWidth * 0.03,),
                              Container(
                                width: screenWidth * 0.8,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
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
                                child: Text(
                                  ' ${email_addr}',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: screenWidth * 0.02,),
                              Icon(Icons.map, color: Colors.blue),
                              SizedBox(width: screenWidth * 0.03,),
                              Container(
                                width: screenWidth * 0.8,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
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
                                child: Text(
                                  '${addr}',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container( /// Search Button
                          width: (screenWidth-40) * 0.3,
                          child: ButtonTheme(
                            minWidth: baseWidth,
                            height: (screenHeight - statusBarHeight) * 0.05,
                            child: RaisedButton(
                              child:Text(translateText(context, 'Logout'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white,)),
                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                              splashColor: Colors.grey,
                              color: Colors.orange,
                              onPressed: () async {
                                removeUserSharedPreferences();
                                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                              },
                            ),
                          ),
                        ),
                      ]
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> getJSONData() async {
    try {
      // Login API Url
      var url = 'https://jhapi.jahwa.co.kr/PersonInformation';

      // Send Parameter
      var data = {'Text': session['EmpCode']};
      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 15)).then<bool>((http.Response response) async {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Server Info. Data Error !!!'); }
        else if(response.statusCode == 200){
          if(jsonDecode(response.body)['Table'].length == 0) {
            showMessageBox(context, 'Alert', 'Data does not Exists!!!');
          }
          else {
            await pr.show();

            jsonDecode(response.body)['Table'].forEach((element) {
              name = element["NAME"].toString();
              eng_name = element["ENG_NAME"].toString();
              company = element["CO_FULL_NM"].toString();
              department = element["DEPT_NM"].toString();
              roll_pstn = element["ROLL_PSTN"].toString();
              em_tel_no = element["EM_TEL_NO"].toString();
              hand_tel_no = element["HAND_TEL_NO"].toString();
              email_addr = element["EMAIL_ADDR"].toString();
              addr = element["ADDR"].toString();
              photo = element["Photo"].toString();
            });
            await pr.hide();

          setState(() {

          });
          }
       }
        return true;
      });
    }
    catch (e) {
      showMessageBox(context, 'Alert', 'Preference Setting Error A : ' + e.toString());
    }
  }
}