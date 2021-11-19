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

ProgressDialog pr; /// 0. Progress Dialog Declaration

class PayApp extends StatefulWidget {
  @override
  _PayWidgetState createState() => _PayWidgetState();
}

class _PayWidgetState extends State<PayApp> {

  final List<KeyValueModel> _valueList = [
    KeyValueModel(key: "", value: ""),
  ];

  var money = NumberFormat('###,###,###,###'); ///화폐단위 콤마
  var _selectedKey = '';   ///급여구분 선택된 값
  var _selectedText = '';   ///급여구분 선택된 텍스트
  var dispatch_YN = 'N'; ///파견자구분
  var pay_YN = 'N';    ///급여지급구분
  var bonus_YN = 'N';  ///상여지급구분
  var salary_day = ''; ///지급일
  var pay_tot = ''; ///지급총액
  var sub_tot = ''; ///공제총액
  var real_tot = ''; ///실지급액
  var to_company = '';
  var fr_dt = '';
  var to_dt = '';
  var crnc_rate = '';
  var crnc_unit = '';
  var foreign_pay_tot = '';
  var foreign_sub_tot = '';
  var foreign_real_tot = '';
  var foreign_local_tot = '';
  var foreign_kr_tot = '';
  var foreign_salary_day = '';

  var year_month = DateTime.now().month < 11
  ? DateTime.now().year.toString() + '-0' + (DateTime.now().month-1).toString()
  : DateTime.now().year.toString() + '-' + (DateTime.now().month-1).toString();

  var year = DateTime.now().year;
  var month = DateTime.now().month -1 ;

  var pay_count = 0;
  var sub_count = 0;
  var foreign_pay_count = 0;
  var foreign_sub_count = 0;

  List<Card> payList = [];
  List<Card> subList = [];
  List<Card> foreign_payList = [];
  List<Card> foreign_subList = [];

  @override
  void initState() {
    super.initState();
    print("open Employee Info Page : " + DateTime.now().toString());
    getProvData().then((value) => getJSONData());
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
                                    '  ' + '급여조회',
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
                          '급여년월 : ',
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
                            child:Text(translateText(context, '${year_month}'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue,)),
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                            splashColor: Colors.grey,
                            color: Colors.white,
                            onPressed: () async {
                              showMonthPicker(
                                context: context,
                                firstDate: DateTime(year - 20, 5),
                                lastDate: DateTime(year + 20, 9),
                                initialDate: DateTime(year, month),
                                locale: Locale("en"),
                              ).then((date) {
                                if (date != null) {
                                  year_month = date.toString().substring(0, 7);
                                  year = date.year;
                                  month = date.month;
                                  getProvData().then((value) => getJSONData());
                                }
                              });
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
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget> [
                      SizedBox(width: (screenWidth-40) * 0.1,),
                      Container(
                        width: (screenWidth-40) * 0.3,
                        height: (screenHeight - statusBarHeight) * 0.05,
                        alignment: Alignment.center,
                        child: Text(
                          '급여구분 : ',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        height: (screenHeight - statusBarHeight) * 0.05,
                        width: (screenWidth - 40) * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          //border corner radius
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              //color of shadow
                              spreadRadius: 1,
                              //spread radius
                              blurRadius: 0,
                              // blur radius
                              offset:
                                  Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: DropdownButton<String>(
                          value: _selectedKey,
                          items: _valueList
                              .map((data) => DropdownMenuItem<String>(
                                    child: Text(data.value),
                                    value: data.key,
                                  ))
                              .toList(),
                          isExpanded: true,
                          onChanged: (String value) {
                            _selectedKey = value;
                            setState(() {
                            });
                            getJSONData();
                          },
                          hint: Text(''),
                        ),
                      ),
                    ],
                  ),
                ),
                ///급여명세서
                if(_selectedKey=="1") Container(
                  width: screenWidth,
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
                        SizedBox(
                          height: (screenHeight - statusBarHeight) * 0.03,
                        ),
                        Container(
                          width: screenWidth,
                          height: (screenHeight - statusBarHeight) * 0.05,
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.center,
                          child: Text(
                            '${year}년 ${month}월 ${_selectedText}명세서',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: (screenHeight - statusBarHeight) * 0.02,
                        ),
                        Container(
                          width: screenWidth,
                          height: (screenHeight - statusBarHeight) * 0.05,
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.centerRight,
                          child: Text(
                            '지급일 : ${salary_day}',
                            style: TextStyle(
                            fontSize: 15,
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
                          alignment: Alignment.center,
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
                            '지급내역',
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          // Main Area
                          width: screenWidth,
                          height: (screenHeight - statusBarHeight) * 0.065 * pay_count,
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
                                tiles: payList,
                              ).toList(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: (screenHeight - statusBarHeight) * 0.01,
                        ),
                        Container(
                          width: screenWidth,
                          height: (screenHeight - statusBarHeight) * 0.05,
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.center,
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
                            '공제내역',
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          // Main Area
                          width: screenWidth,
                          height: (screenHeight - statusBarHeight) * 0.065 * sub_count,
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
                                tiles: subList,
                              ).toList(),
                            ),
                          ),
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
                                    ' ' + '지급총액',
                                    style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  height: (screenHeight - statusBarHeight) * 0.05,
                                  width: screenWidth * 0.4,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${pay_tot}원',
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
                                    ' ' + '공제총액',
                                    style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  height: (screenHeight - statusBarHeight) * 0.05,
                                  width: screenWidth * 0.4,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${sub_tot}원',
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
                                    ' ' + '실지급액',
                                    style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  height: (screenHeight - statusBarHeight) * 0.05,
                                  width: screenWidth * 0.4,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${real_tot}원',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            )
                        ),
                        SizedBox(
                          height: (screenHeight - statusBarHeight) * 0.02,
                        ),
                      ],
                    ),
                  ),
                ///상여명세서
                if(_selectedKey != "1") Container(
                  width: screenWidth,
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
                      SizedBox(
                        height: (screenHeight - statusBarHeight) * 0.03,
                      ),
                      Container(
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.05,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        alignment: Alignment.center,
                        child: Text(
                          '${year}년 ${month}월 ${_selectedText}명세서',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: (screenHeight - statusBarHeight) * 0.02,
                      ),
                      Container(
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.05,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        alignment: Alignment.centerRight,
                        child: Text(
                          '지급일 : ${salary_day}',
                          style: TextStyle(
                            fontSize: 15,
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
                        alignment: Alignment.center,
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
                          '지급내역',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        // Main Area
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.065 * pay_count,
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
                              tiles: payList,
                            ).toList(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: (screenHeight - statusBarHeight) * 0.01,
                      ),
                      Container(
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.05,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        alignment: Alignment.center,
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
                          '공제내역',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        // Main Area
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.065 * sub_count,
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
                              tiles: subList,
                            ).toList(),
                          ),
                        ),
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
                                  ' ' + '지급총액',
                                  style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                height: (screenHeight - statusBarHeight) * 0.05,
                                width: screenWidth * 0.4,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${pay_tot}원',
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
                                  ' ' + '공제총액',
                                  style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                height: (screenHeight - statusBarHeight) * 0.05,
                                width: screenWidth * 0.4,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${sub_tot}원',
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
                                  ' ' + '실지급액',
                                  style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                height: (screenHeight - statusBarHeight) * 0.05,
                                width: screenWidth * 0.4,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${real_tot}원',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          )
                      ),
                      SizedBox(
                        height: (screenHeight - statusBarHeight) * 0.02,
                      ),
                    ],
                  ),
                ),
                ///파견급여명세서
                if(dispatch_YN == "Y") Container(
                  width: screenWidth,
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
                      SizedBox(
                        height: (screenHeight - statusBarHeight) * 0.03,
                      ),
                      Container(
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.05,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        alignment: Alignment.center,
                        child: Text(
                          '${year}년 ${month}월 ${_selectedText}명세서',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: (screenHeight - statusBarHeight) * 0.02,
                      ),
                      Container(
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.05,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        alignment: Alignment.centerRight,
                        child: Text(
                          '지급일 : ${foreign_salary_day}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.05,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '파견법인 : ${to_company}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.05,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '파견기간 : ${fr_dt} ~ ${to_dt}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.05,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '환율 : ${crnc_rate} ${crnc_unit}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.05,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        alignment: Alignment.center,
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
                          '지급내역',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        // Main Area
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.065 * foreign_pay_count,
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
                              tiles: foreign_payList,
                            ).toList(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: (screenHeight - statusBarHeight) * 0.01,
                      ),
                      Container(
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.05,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        alignment: Alignment.center,
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
                          '공제내역',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        // Main Area
                        width: screenWidth,
                        height: (screenHeight - statusBarHeight) * 0.065 * foreign_sub_count,
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
                              tiles: foreign_subList,
                            ).toList(),
                          ),
                        ),
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
                                  ' ' + '지급총액',
                                  style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                height: (screenHeight - statusBarHeight) * 0.05,
                                width: screenWidth * 0.4,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${foreign_pay_tot}원',
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
                                  ' ' + '공제총액',
                                  style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                height: (screenHeight - statusBarHeight) * 0.05,
                                width: screenWidth * 0.4,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${foreign_sub_tot}원',
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
                                  ' ' + '실지급액',
                                  style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                height: (screenHeight - statusBarHeight) * 0.05,
                                width: screenWidth * 0.4,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${foreign_real_tot}원',
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
                                  ' ' + '현지지급',
                                  style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                height: (screenHeight - statusBarHeight) * 0.05,
                                width: screenWidth * 0.4,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${foreign_local_tot}원',
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
                                  ' ' + '본사지급',
                                  style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ),
                              Container(
                                height: (screenHeight - statusBarHeight) * 0.05,
                                width: screenWidth * 0.4,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${foreign_kr_tot}원',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          )
                      ),
                      SizedBox(
                        height: (screenHeight - statusBarHeight) * 0.02,
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

  Future<void> getProvData() async {
    try {
      // Login API Url
      var url = 'https://jhapi.jahwa.co.kr/ProvList';

      // Send Parameter
      var data = {'EntCode': '${session['EntCode']}', 'EmpCode' : '${session['EmpCode']}', 'PAY_YYMM' : '${year_month.replaceAll('-', '')}'};

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 30)).then<bool>((http.Response response) async {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Server Info. Data Error !!!'); }
        else if(response.statusCode == 200){
          _valueList.clear();
          if(jsonDecode(response.body)['Table'].length == 0) {

          }
          else {
            await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            _valueList.clear();
            jsonDecode(response.body)['Table'].forEach((element) {
              _valueList.add(KeyValueModel(key: element["PROV_TYPE"], value: element["PROV_NAME"]));
            });
            _selectedKey = _valueList.first.key;
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

  Future<void> getJSONData() async {
    try {
      // Login API Url
      var url = 'https://jhapi.jahwa.co.kr/SalaryInfo';

      // Send Parameter
      var data = {'EntCode': '${session['EntCode']}', 'EmpCode' : '${session['EmpCode']}', 'PAY_YYMM' : '${year_month.replaceAll('-', '')}', 'Type' : '${_selectedKey}'};

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 30)).then<bool>((http.Response response) async {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Server Info. Data Error !!!'); }
        else if(response.statusCode == 200){
          await pr.show();
          if(jsonDecode(response.body)['Table'].length == 0) {

            payList.clear();
          }
          else {
            /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            payList.clear();
            jsonDecode(response.body)['Table'].forEach((element) {
              _selectedText = element["PROV_NAME"];
            });
          }

           pay_count = 0;
          ///지급내역
          if(jsonDecode(response.body)['Table1'].length == 0) {

            payList.clear();
          }
          else {
            /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            payList.clear();

            Widget card = Card(
              child: Row(
                children: <Widget> [
                  Container(
                    width: screenWidth * 0.4,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      '지급항목',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.4,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '금액',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
            pay_count++;
            payList.add(card);

            jsonDecode(response.body)['Table1'].forEach((element) {
              Widget card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["ALLOW_NM"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["ALLOW"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
              payList.add(card);
              pay_count++;
            });

          }

          sub_count = 0;
          ///공제내역
          if(jsonDecode(response.body)['Table2'].length == 0) {

            subList.clear();
          }
          else {
            /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            subList.clear();

            Widget card = Card(
              child: Row(
                children: <Widget> [
                  Container(
                    width: screenWidth * 0.4,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      '공제항목',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.4,
                    height: (screenHeight - statusBarHeight) * 0.05,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '금액',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );

            subList.add(card);
            sub_count++;

            jsonDecode(response.body)['Table2'].forEach((element) {
              Widget card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '${element["SUB_NM"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["SUB_AMT"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
              subList.add(card);
              sub_count++;
            });

          }

          ///총 계산내역
          if(jsonDecode(response.body)['Table3'].length == 0) {

          }
          else {
            /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            jsonDecode(response.body)['Table3'].forEach((element) {
              salary_day = element["PROV_DT"].substring(0, 10);
              pay_tot = money.format(element["PROV_TOT_AMT"]).toString();
              sub_tot = money.format(element["SUB_TOT_AMT"]).toString();
              real_tot = money.format(element["REAL_PROV_AMT"]).toString();
            });

          }

          ///파견인원 계산
          if(jsonDecode(response.body)['Table4'].length == 0) {
            dispatch_YN = 'N';
            foreign_payList.clear();
            foreign_subList.clear();
          }
          else {
            /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            foreign_payList.clear();
            foreign_subList.clear();
            dispatch_YN = 'Y';
            jsonDecode(response.body)['Table4'].forEach((element) {
              to_company = element["TO_COMPANY_NM"];
              fr_dt = element["FR_DT"].substring(0, 10);
              to_dt = element["TO_DT"].substring(0, 10);
              crnc_rate = element["CRNC_RATE"].toString();
              crnc_unit = element["CRNC_UNIT"].toString();
              foreign_salary_day = element["PROV_DT"].substring(0, 10);
              foreign_pay_tot = money.format(element["KO_SUM_ALLOW_AMT"]).toString();
              foreign_sub_tot = money.format(element["SUM_SUB_AMT"]).toString();
              foreign_real_tot = money.format(element["REAL_PROV_AMT"]).toString();
              foreign_local_tot = money.format(element["LOCAL_AMT"]).toString();
              foreign_kr_tot = money.format(element["REAL_TOT_KO_AMT_WON"]).toString();

              foreign_pay_count = 0;

              Widget card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '지급항목',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '금액',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              );

              foreign_payList.add(card);
              foreign_pay_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '기본급',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["BAS_AMT_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_payList.add(card);
              foreign_pay_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '상여금',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["BONUS_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_payList.add(card);
              foreign_pay_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '연근수당',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["BUSINESS_ALLOW_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_payList.add(card);
              foreign_pay_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '기타수당',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["ETC_ALLOW_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_payList.add(card);
              foreign_pay_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '파견수당',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["DISPATCH_ALLOW_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_payList.add(card);
              foreign_pay_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '특근수당',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["EXTRA_WORK_ALLOW_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_payList.add(card);
              foreign_pay_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '추가수당',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["ADD_ALLOW_CRNC"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_payList.add(card);
              foreign_pay_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '성과연봉',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["PERFORM_ALLOW_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_payList.add(card);
              foreign_pay_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '팀장수당',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["LEADER_ALLOW_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_payList.add(card);
              foreign_pay_count++;

              foreign_sub_count = 0;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '공제항목',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '금액',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              );

              foreign_subList.add(card);
              foreign_sub_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '가불금',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["ADV_AMT_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_subList.add(card);
              foreign_sub_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '복리기금이자',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["INTEREST_AMT_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_subList.add(card);
              foreign_sub_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '신원보증료',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["WARRANTY_AMT_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_subList.add(card);
              foreign_sub_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '상조회비',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["COMPANY_AID_FUND"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_subList.add(card);
              foreign_sub_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '기타공제',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["ETC_SUB_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_subList.add(card);
              foreign_sub_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '국민연금',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["ANUT_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_subList.add(card);
              foreign_sub_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '건강보험',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["MED_INSURE_TOT_WON"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_subList.add(card);
              foreign_sub_count++;

              card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.center,
                      child: Text(
                        '소득세',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.4,
                      height: (screenHeight - statusBarHeight) * 0.05,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${money.format(element["INCOME_TAX"])}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );

              foreign_subList.add(card);
              foreign_sub_count++;

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

class KeyValueModel {
  String key;
  String value;

  KeyValueModel({this.key, this.value});
}
