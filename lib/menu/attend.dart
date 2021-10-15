import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jahwa_mobile_groupware/util/common.dart';
import 'package:jahwa_mobile_groupware/util/globals.dart';
import 'package:http/http.dart' as http;
import 'package:jahwa_mobile_groupware/util/globals.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:percent_indicator/percent_indicator.dart';

ProgressDialog pr; /// 0. Progress Dialog Declaration

class AttendApp extends StatefulWidget {
  @override
  _AttendWidgetState createState() => _AttendWidgetState();
}

class _AttendWidgetState extends State<AttendApp> {

  var day = DateFormat("yyyy-MM-dd").format(DateTime.now());
  var dayName = DateFormat('EEEE').format(DateTime.now());
  var remark = "";
  var start_time = "";
  var end_time = "";
  var break_time = "";
  var dilig_nm = "";
  var end_time_YN = "N";
  var break_count = 0;
  var work_type = "";
  var work_type_nm = "";
  var dilig_strt_dt = "";
  var dilig_end_dt = "";
  var strt_null = "";
  var end_null = "";
  var real_time = "";
  var app_tot = "";
  var over_time = "";
  var remain_over_time = "";
  var status = "";
  var select_remain_time = "";
  var select_recommend_time = "";

  List<Card> breakList = [];
  List<Card> modifyList = [];

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
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    '  ' + '근태관리',
                                    style: TextStyle(fontSize: 25,color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                SizedBox( width: screenWidth * 0.5, ),
                                Container(
                                    width: screenWidth * 0.18,
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
                SizedBox(height: (screenHeight - statusBarHeight) * 0.025,),
                Container(
                  width: screenWidth,
                  height: (screenHeight - statusBarHeight) * 0.05,
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget> [
                      SizedBox(width: (screenWidth-40) * 0.1,),
                      Container(
                        width: (screenWidth-40) * 0.3,
                        height: (screenHeight - statusBarHeight) * 0.05,
                        alignment: Alignment.center,
                        child: Text(
                          '기준일자 : ',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        width: (screenWidth - 40) * 0.5,
                        height:(screenHeight - statusBarHeight) * 0.05,
                        alignment: Alignment.center,
                        child: ButtonTheme(
                          minWidth: baseWidth,
                          height: (screenHeight - statusBarHeight) * 0.05,
                          child: RaisedButton(
                            child:Text(translateText(context, '${day}'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue,)),
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                            splashColor: Colors.grey,
                            color: Colors.white,
                            onPressed: () {
                              yearMonthDayPicker(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.35,
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
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            ' ' + '나의 근로시간 [${dayName}]',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              if(remark != "") Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Text(
                                  '  ${remark}',
                                  style: TextStyle(fontSize: 20,color: Colors.red, fontWeight: FontWeight.w700),
                                ),
                              ),
                              if(dilig_nm != "") Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Text(
                                  '  ${dilig_nm}',
                                  style: TextStyle(fontSize: 20,color: Colors.blue, fontWeight: FontWeight.w700),
                                ),
                              ),
                              if(dilig_nm == "" && remark == "") Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Text(
                                  '  ${dilig_nm}',
                                  style: TextStyle(fontSize: 20,color: Colors.blue, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: screenWidth,
                          height: (screenHeight - statusBarHeight) * 0.2,
                          alignment: Alignment.topCenter,
                          margin: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: screenWidth * 0.27,
                                height: (screenHeight - statusBarHeight) * 0.2,
                                margin: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(0xFF, 0x59, 0xA0, 0xE2),
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
                                      margin: EdgeInsets.all(6),
                                      child: Text(
                                        '출근시간',
                                        style: TextStyle(fontSize: 20,color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(7),
                                      child: Text(
                                        '${start_time}',
                                        style: TextStyle(fontSize: 35,color: Colors.white, fontWeight: FontWeight.w700, decoration: TextDecoration.underline,),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: screenWidth * 0.27,
                                height: (screenHeight - statusBarHeight) * 0.2,
                                margin: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(0xFF, 0x17, 0xB7, 0x57),
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
                                      margin: EdgeInsets.all(6),
                                      child: Text(
                                        '퇴근시간',
                                        style: TextStyle(fontSize: 20,color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    if(end_time_YN == "N") Container(
                                      margin: EdgeInsets.all(7),
                                      child: Text(
                                        '${end_time}',
                                        style: TextStyle(fontSize: 35,color: Colors.blue, fontWeight: FontWeight.w700, decoration: TextDecoration.underline,),
                                      ),
                                    ),
                                    if(end_time_YN == "Y") Container(
                                      margin: EdgeInsets.all(7),
                                      child: Text(
                                        '${end_time}',
                                        style: TextStyle(fontSize: 35,color: Colors.white, fontWeight: FontWeight.w700, decoration: TextDecoration.underline,),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: screenWidth * 0.27,
                                height: (screenHeight - statusBarHeight) * 0.2,
                                margin: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(0xFF, 0xEA, 0x86, 0x2B),
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
                                      margin: EdgeInsets.all(6),
                                      child: Text(
                                        '휴게시간',
                                        style: TextStyle(fontSize: 20,color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(7),
                                      child: Text(
                                        '${break_time}',
                                        style: TextStyle(fontSize: 35,color: Colors.white, fontWeight: FontWeight.w700, decoration: TextDecoration.underline,),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.03,
                ),
                Container(
                  width: screenWidth,
                  height: (screenHeight - statusBarHeight) * 0.05,
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        //color of shadow
                        spreadRadius: 1,
                        //spread radius
                        blurRadius: 7,
                        // blur radius
                        offset:
                        Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Text(
                    ' ' + '휴게시간',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  // Main Area
                  width: screenWidth,
                  height: (screenHeight - statusBarHeight) * 0.065 * break_count,
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView(
                      primary: false,
                      shrinkWrap: true,
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: breakList,
                      ).toList(),
                    ),
                  ),
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.03,
                ),
                Container(
                  width: screenWidth,
                  height: (screenHeight - statusBarHeight) * 0.05,
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        //color of shadow
                        spreadRadius: 1,
                        //spread radius
                        blurRadius: 7,
                        // blur radius
                        offset:
                        Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Text(
                    ' ' + '출퇴근시간정정',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  // Main Area
                  width: screenWidth,
                  height: (screenHeight - statusBarHeight) * 0.065 * 3,
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView(
                      primary: false,
                      shrinkWrap: true,
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: modifyList,
                      ).toList(),
                    ),
                  ),
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.03,
                ),
                Container(
                  width: (screenWidth-40) * 0.3,
                  height: (screenHeight - statusBarHeight) * 0.05,
                  alignment: Alignment.center,
                  child: Text(
                    '주 단위',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.01,
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          //color of shadow
                          spreadRadius: 1,
                          //spread radius
                          blurRadius: 7,
                          // blur radius
                          offset:
                          Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            '구분',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.5,
                          alignment: Alignment.center,
                          child: Text(
                            '${work_type_nm}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.01,
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          //color of shadow
                          spreadRadius: 1,
                          //spread radius
                          blurRadius: 7,
                          // blur radius
                          offset:
                          Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            '기간',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.5,
                          alignment: Alignment.center,
                          child: Text(
                            '${dilig_strt_dt}${dilig_end_dt}',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.01,
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          //color of shadow
                          spreadRadius: 1,
                          //spread radius
                          blurRadius: 7,
                          // blur radius
                          offset:
                          Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            '출근미체크',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.5,
                          alignment: Alignment.center,
                          child: Text(
                            '${strt_null}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.01,
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          //color of shadow
                          spreadRadius: 1,
                          //spread radius
                          blurRadius: 7,
                          // blur radius
                          offset:
                          Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            '퇴근미체크',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.5,
                          alignment: Alignment.center,
                          child: Text(
                            '${end_null}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.01,
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          //color of shadow
                          spreadRadius: 1,
                          //spread radius
                          blurRadius: 7,
                          // blur radius
                          offset:
                          Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            '실제근로시간',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.5,
                          alignment: Alignment.center,
                          child: Text(
                            '${real_time}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.01,
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          //color of shadow
                          spreadRadius: 1,
                          //spread radius
                          blurRadius: 7,
                          // blur radius
                          offset:
                          Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            '인정근로시간',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.5,
                          alignment: Alignment.center,
                          child: Text(
                            '${app_tot}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.01,
                ),
                if(work_type == "1" || work_type == "9") Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          //color of shadow
                          spreadRadius: 1,
                          //spread radius
                          blurRadius: 7,
                          // blur radius
                          offset:
                          Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            '연장근로시간',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.5,
                          alignment: Alignment.center,
                          child: Text(
                            '${over_time}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                ),
                if(work_type == "7" || work_type == "8") Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          //color of shadow
                          spreadRadius: 1,
                          //spread radius
                          blurRadius: 7,
                          // blur radius
                          offset:
                          Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            '잔여근로시간',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.5,
                          alignment: Alignment.center,
                          child: Text(
                            '${select_remain_time}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.01,
                ),
                if(work_type == "1" || work_type == "9") Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          //color of shadow
                          spreadRadius: 1,
                          //spread radius
                          blurRadius: 7,
                          // blur radius
                          offset:
                          Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            '잔여연장근로시간',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.5,
                          alignment: Alignment.center,
                          child: Text(
                            '${remain_over_time}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                ),
                if(work_type == "7" || work_type == "8") Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          //color of shadow
                          spreadRadius: 1,
                          //spread radius
                          blurRadius: 7,
                          // blur radius
                          offset:
                          Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            '일근무가능시간',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.5,
                          alignment: Alignment.center,
                          child: Text(
                            '${select_recommend_time}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.01,
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          //color of shadow
                          spreadRadius: 1,
                          //spread radius
                          blurRadius: 7,
                          // blur radius
                          offset:
                          Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            '상태',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.1,
                        ),
                        if(status == "Status_04") Padding(
                          padding: EdgeInsets.all(1),
                          child: new LinearPercentIndicator(
                            width: screenWidth * 0.35,
                            animation: true,
                            lineHeight: (screenHeight - statusBarHeight) * 0.03,
                            animationDuration: 2500,
                            percent: 1,
                            center: Text(
                                '보통',
                                style: TextStyle(fontSize: 14,color: Colors.white, fontWeight: FontWeight.w700)
                            ),
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: Colors.green,
                          ),
                        ),
                        if(status == "Status_03") Padding(
                          padding: EdgeInsets.all(1),
                          child: new LinearPercentIndicator(
                            width: screenWidth * 0.35,
                            animation: true,
                            lineHeight: (screenHeight - statusBarHeight) * 0.03,
                            animationDuration: 2500,
                            percent: 0.5,
                            center: Text(
                                '주의',
                                style: TextStyle(fontSize: 14,color: Colors.white, fontWeight: FontWeight.w700)
                            ),
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: Colors.yellow,
                          ),
                        ),
                        if(status == "Status_02") Padding(
                          padding: EdgeInsets.all(1),
                          child: new LinearPercentIndicator(
                            width: screenWidth * 0.35,
                            animation: true,
                            lineHeight: (screenHeight - statusBarHeight) * 0.03,
                            animationDuration: 2500,
                            percent: 0.25,
                            center: Text(
                                '경계',
                                style: TextStyle(fontSize: 14,color: Colors.white, fontWeight: FontWeight.w700)
                            ),
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: Colors.orange,
                          ),
                        ),
                        if(status == "Status_01") Padding(
                          padding: EdgeInsets.all(1),
                          child: new LinearPercentIndicator(
                            width: screenWidth * 0.35,
                            animation: true,
                            lineHeight: (screenHeight - statusBarHeight) * 0.03,
                            animationDuration: 2500,
                            percent: 0.01,
                            center: Text(
                                '위험',
                                style: TextStyle(fontSize: 14,color: Colors.white, fontWeight: FontWeight.w700)
                            ),
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: Colors.red,
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(
                  height: (screenHeight - statusBarHeight) * 0.03,
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
      var url = 'https://jhapi.jahwa.co.kr/WorkTime';
      var count = 0;

      // Send Parameter
      var data = {'EmpCode':'${session['EmpCode']}', 'BaseDate':'${day}'};

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 30)).then<bool>((http.Response response) async {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Server Info. Data Error !!!'); }
        else if(response.statusCode == 200){
          start_time = "";
          end_time = "";
          end_time_YN = "N";
          dilig_nm = "";
          break_time = "";
          work_type = "";

          ///나의 근로시간
          if(jsonDecode(response.body)['Table'].length == 0) {
            ///showMessageBox(context, 'Alert', 'Data does not Exists!!!');
          }
          else {
            await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            jsonDecode(response.body)['Table'].forEach((element) {
              start_time = element["STRT_TIME"].toString();
              if (element["EXP_END_TIME"].toString() != ''){
                end_time = element["EXP_END_TIME"].toString();
                end_time_YN = "N";
              }
              else{
                end_time = element["END_TIME"].toString();
                end_time_YN = "Y";
              }
              break_time = element["BREAK_TIME"].toString();
              dilig_nm = element["DILIG_NM"].toString();
              work_type = element["WORK_TYPE"].toString();
            });
            await pr.hide();
          }

          ///공휴일
          if(jsonDecode(response.body)['Table1'].length == 0) {
            ///showMessageBox(context, 'Alert', 'Data does not Exists!!!');
          }
          else {
            await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            jsonDecode(response.body)['Table1'].forEach((element) {
              remark = element["Remark"].toString();
            });
            await pr.hide();
          }

          break_count = 0;

          ///휴게시간
          if(jsonDecode(response.body)['Table2'].length == 0) {
            ///showMessageBox(context, 'Alert', 'Data does not Exists!!!');
            breakList.clear();
          }
          else {
            await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            breakList.clear();

            Widget card = Card(
              child: Row(
                children: <Widget> [
                  Container(
                    width: screenWidth * 0.2,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      '시작시간',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.2,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      '종료시간',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.2,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      '반영시간',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.3,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      '사유',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
            break_count++;
            breakList.add(card);

            jsonDecode(response.body)['Table2'].forEach((element) {
              Widget card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.2,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["StTime"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.2,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["EdTime"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.2,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["BREAK_TIME"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.3,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["REASON"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
              breakList.add(card);
              break_count++;
            });
            await pr.hide();
          }

          ///출퇴근시간정정
          if(jsonDecode(response.body)['Table3'].length == 0) {
            modifyList.clear();
          }
          else {
            await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            modifyList.clear();

            Widget card = Card(
              child: Row(
                children: <Widget> [
                  Container(
                    width: screenWidth * 0.2,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      '항목',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.2,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      '기존시간',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.2,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      '변경시간',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.3,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      '사유',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
            modifyList.add(card);

            jsonDecode(response.body)['Table3'].forEach((element) {
              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.2,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '출근시간',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.2,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["StTime"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.2,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["StTimeEdit"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.3,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["StTimeReason"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
              modifyList.add(card);

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.2,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '퇴근시간',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.2,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["EdTime"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.2,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["EdTimeEdit"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.3,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["EdTimeReason"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            });

            modifyList.add(card);
            await pr.hide();
          }

          work_type_nm = "";
          dilig_strt_dt = "";
          dilig_end_dt = "";
          strt_null = "";
          end_null = "";
          real_time = "";
          app_tot = "";
          over_time = "";
          remain_over_time = "";
          select_recommend_time = "";
          select_remain_time = "";
          status = "";

          if(work_type == "7" || work_type == "8"){
            if(jsonDecode(response.body)['Table6'].length == 0) {
              ///showMessageBox(context, 'Alert', 'Data does not Exists!!!');
            }
            else {
              await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
              jsonDecode(response.body)['Table6'].forEach((element) {
                work_type_nm = element["WORK_TYPE_NM"].toString();
                dilig_strt_dt = element["DILIG_STRT_DT"].toString()+ "~";
                dilig_end_dt = element["DILIG_END_DT"].toString();
                real_time = element["REAL_TIME"].toString();
                app_tot = element["APP_TOT"].toString();
                over_time = element["OVER_TIME"].toString();
                select_recommend_time = element["SELECT_RECOMMEND_TIME"].toString();
                select_remain_time = element["SELECT_REMAIN_TIME"].toString();
                status = element["Status"].toString();
              });
              await pr.hide();
            }

            if(jsonDecode(response.body)['Table7'].length == 0) {
              ///showMessageBox(context, 'Alert', 'Data does not Exists!!!');
            }
            else {
              await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
              jsonDecode(response.body)['Table7'].forEach((element) {
                strt_null = element["STRT_NULL"].toString();
                end_null = element["END_NULL"].toString();
              });
              await pr.hide();
            }
          }
          else{
            if(jsonDecode(response.body)['Table4'].length == 0) {
              ///showMessageBox(context, 'Alert', 'Data does not Exists!!!');
            }
            else {
              await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
              jsonDecode(response.body)['Table4'].forEach((element) {
                work_type_nm = element["WORK_TYPE_NM"].toString();
                dilig_strt_dt = element["DILIG_STRT_DT"].toString()+ "~";
                dilig_end_dt = element["DILIG_END_DT"].toString();
                real_time = element["REAL_TIME"].toString();
                app_tot = element["APP_TOT"].toString();
                over_time = element["OVER_TIME"].toString();
                remain_over_time = element["REMAIN_OVER_TIME"].toString();
                status = element["Status"].toString();
              });
              await pr.hide();
            }

            if(jsonDecode(response.body)['Table5'].length == 0) {
              ///showMessageBox(context, 'Alert', 'Data does not Exists!!!');
            }
            else {
              await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
              jsonDecode(response.body)['Table5'].forEach((element) {
                strt_null = element["STRT_NULL"].toString();
                end_null = element["END_NULL"].toString();
              });
              await pr.hide();
            }
          }

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

  ///캘린더 일자 검색
  yearMonthDayPicker(BuildContext context) async {
    final year = DateTime.now().year;

    final DateTime dateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(year),
      lastDate: DateTime(year + 10),
    );

    if (dateTime != null) {
      day = dateTime.toString().split(' ')[0];
      dayName = DateFormat('EEEE').format(dateTime);
    }

    getJSONData();
  }
}
