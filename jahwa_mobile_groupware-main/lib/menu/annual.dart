import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
import 'package:http/http.dart' as http;
import 'package:jahwa_mobile_groupware/util/globals.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

ProgressDialog pr; /// 0. Progress Dialog Declaration

class AnnualApp extends StatefulWidget {
  @override
  _AnnualWidgetState createState() => _AnnualWidgetState();
}

class _AnnualWidgetState extends State<AnnualApp> {
  List<Card> cardList = [];
  var year_save = 0.0;
  var year_part = 0.0;
  var year_save_tot = 0.0;
  var year_use = 0.0;
  var year_remain = 0.0;

  @override
  void initState() {
    super.initState();
    print("open Employee Info Page : " + DateTime.now().toString());
    getJSONData();
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
                                  child: Text(
                                    '  ' + '연차조회',
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
                SizedBox( height: (screenHeight - statusBarHeight) * 0.03, ),
                Container(
                  width: screenWidth,
                  height: (screenHeight - statusBarHeight) * 0.1,
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
                          '조회년도 : ',
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
                            child:Text(translateText(context, '${year}'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue,)),
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                            splashColor: Colors.grey,
                            color: Colors.white,
                            onPressed: () {
                              yearPicker(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow:[
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), //color of shadow
                          spreadRadius: 5, //spread radius
                          blurRadius: 7, // blur radius
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            ' ' + '연차발생',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ' ${year_save * 8}' + '시간 ' + '(${year_save}' + '개)',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    )
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow:[
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), //color of shadow
                          spreadRadius: 5, //spread radius
                          blurRadius: 7, // blur radius
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            ' ' + '근속가산',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ' ${year_part * 8}' + '시간 ' + '(${year_part}' + '개)',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    )
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow:[
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), //color of shadow
                          spreadRadius: 5, //spread radius
                          blurRadius: 7, // blur radius
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            ' ' + '연차총발생',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ' ${year_save_tot * 8}' + '시간 ' + '(${year_save_tot}' + '개)',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    )
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow:[
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), //color of shadow
                          spreadRadius: 5, //spread radius
                          blurRadius: 7, // blur radius
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            ' ' + '사용',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ' ${year_use}' + '시간 ' + '(${year_use / 8}' + '개)',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    )
                ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10), //border corner radius
                      boxShadow:[
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), //color of shadow
                          spreadRadius: 5, //spread radius
                          blurRadius: 7, // blur radius
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            ),
                          ),
                          child: Text(
                            ' ' + '잔여',
                            style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          height: (screenHeight - statusBarHeight) * 0.05,
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ' ${year_remain * 8}' + '시간 ' + '(${year_remain}' + '개)',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox( height: (screenHeight - statusBarHeight) * 0.03, ),
                Container(
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    margin: EdgeInsets.fromLTRB(10,0,10,0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0)
                      ),
                      boxShadow:[
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), //color of shadow
                          spreadRadius: 5, //spread radius
                          blurRadius: 7, // blur radius
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Text(
                      ' ' + '연차 사용 내역',
                      style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                ),
                Container( // Main Area
                  width: screenWidth,
                  height: (screenHeight - statusBarHeight) * 0.7,
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.fromLTRB(10,0,10,0),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView(
                      primary: false,
                      shrinkWrap: true,
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: cardList,
                      ).toList(),
                    ),
                  ),
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
      var url = 'https://jhapi.jahwa.co.kr/AnnualLeave';

      year_save = 0.0;
      year_part = 0.0;
      year_save_tot = 0.0;
      year_use = 0.0;
      year_remain = 0.0;

      // Send Parameter
      var data = {'Year': '${year.toString()}', 'EmpCode' : '${session['EmpCode']}', 'EntCode' : '${session['EntCode']}'};

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 30)).then<bool>((http.Response response) async {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Server Info. Data Error !!!'); }
        else if(response.statusCode == 200){
          if(jsonDecode(response.body)['Table2'].length == 0) {

            cardList.clear();
          }
          else {
            await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            cardList.clear();
            jsonDecode(response.body)['Table2'].forEach((element) {
              Widget card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.25,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["DILIG_DT"]}',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.2,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                          '${element["DILIG_NM"]}',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.15,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                          '${element["DILIG_HH"]}',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.3,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                          '${element["REMARK"]}',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              );
              cardList.add(card);
              year_use += element["DILIG_HH"];
            });
            await pr.hide();
          }

          if(jsonDecode(response.body)['Table'].length == 0) {

          }
          else {
            await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            jsonDecode(response.body)['Table'].forEach((element) {
              year_save = element["YEAR_SAVE"];
              year_part = element["YEAR_PART"];
              year_save_tot = element["YEAR_SAVE_TOT"];
              year_remain = year_save_tot - year_use / 8;
            });
            await pr.hide();
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
  ///캘린더 년도 검색
  yearPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '해당년도를 입력하세요',
            textAlign: TextAlign.center,
          ),
          content: Container(
            height: MediaQuery.of(context).size.height / 4.0,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: YearPicker(
              selectedDate: DateTime(year),
              firstDate: DateTime(year - 10),
              lastDate: DateTime(year + 10),
              onChanged: (value) {
                year = int.parse(value.toString().substring(0, 4));
                Navigator.of(context).pop();
                getJSONData();
              },
            ),
          ),
        );
      },
    );
  }
}




