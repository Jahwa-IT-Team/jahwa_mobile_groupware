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
import 'package:intl/intl.dart';

ProgressDialog pr; /// 0. Progress Dialog Declaration

class HomeApp extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeApp> {
  var toDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  var work_type = "";
  var start_time = "";
  var end_time = "";
  var rest_time = "";
  var preApproval = "";
  var unApproved = "";
  var onGoing = "";
  var circulation = "";
  var cooperation = "";
  var deptReceived = "";
  var end_time_YN = "N";

  List<Card> cardList0 = [];
  List<Card> cardList1 = [];
  List<Card> cardList2 = [];


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
                   height: (screenHeight - statusBarHeight) * 0.13,
                   alignment: Alignment.centerLeft,
                   color: Colors.blue,
                   child: Column(
                     children: <Widget>[
                       SizedBox( height: (screenHeight - statusBarHeight) * 0.03, ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '  ' + 'JAHWA',
                            style: TextStyle(fontSize: 25,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                       ),
                       Container(
                         alignment: Alignment.bottomLeft,
                         child: Text(
                           '   ' + '${session['Name']}님 안녕하세요.',
                           style: TextStyle(fontSize: 20,color: Colors.white, fontWeight: FontWeight.w200),
                         ),
                       ),
                     ],
                   )
                 ),
                 Container(
                     width: screenWidth,
                     ///height: (screenHeight - statusBarHeight) * 0.3,
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
                   child: Column(
                     children: <Widget>[
                       Container(
                         height: (screenHeight - statusBarHeight) * 0.05,
                         width: screenWidth,
                         padding: EdgeInsets.all(5),
                         alignment: Alignment.centerLeft,
                         decoration: BoxDecoration(
                           color: Colors.green,
                           borderRadius: BorderRadius.only(
                               topLeft: Radius.circular(10.0),
                               topRight: Radius.circular(10.0)
                           ),
                         ),
                         child: Text(
                           ' ' + '최근게시',
                           style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                         ),
                       ),
                       Container(
                         height: (screenHeight - statusBarHeight) * 0.25,
                         width: screenWidth,
                         child: MediaQuery.removePadding(
                           context: context,
                           removeTop: true,
                           child: ListView(
                             children: ListTile.divideTiles(
                               context: context,
                               tiles: cardList0,
                             ).toList(),
                           ),
                         ),
                       )
                     ],
                   )
                 ),
                 Container(
                   width: screenWidth,
                   ///height: (screenHeight - statusBarHeight) * 0.3,
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
                           ' ' + '나의 근로시간 [${toDate}]',
                           style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                         ),
                       ),
                       Container(
                         alignment: Alignment.topLeft,
                         margin: EdgeInsets.all(10),
                         child: Text(
                           ' ${work_type}',
                           style: TextStyle(fontSize: 18),
                         ),
                       ),
                       Container(
                         width: screenWidth,
                         ///height: (screenHeight - statusBarHeight) * 0.15,
                         alignment: Alignment.topCenter,
                         margin: EdgeInsets.all(7),
                         child: Row(
                           children: <Widget>[
                             Container(
                               width: screenWidth * 0.27,
                               ///height: (screenHeight - statusBarHeight) * 0.15,
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
                                       style: TextStyle(fontSize: 32,color: Colors.white, fontWeight: FontWeight.w700, decoration: TextDecoration.underline,),
                                     ),
                                   )
                                 ],
                               ),
                             ),
                             Container(
                               width: screenWidth * 0.27,
                               ///height: (screenHeight - statusBarHeight) * 0.15,
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
                                       style: TextStyle(fontSize: 32,color: Colors.blue, fontWeight: FontWeight.w700, decoration: TextDecoration.underline,),
                                     ),
                                   ),
                                   if(end_time_YN == "Y") Container(
                                     margin: EdgeInsets.all(7),
                                     child: Text(
                                       '${end_time}',
                                       style: TextStyle(fontSize: 32,color: Colors.white, fontWeight: FontWeight.w700, decoration: TextDecoration.underline,),
                                     ),
                                   )
                                 ],
                               ),
                             ),
                             Container(
                               width: screenWidth * 0.27,
                               ///height: (screenHeight - statusBarHeight) * 0.15,
                               margin: EdgeInsets.all(5),
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
                                     margin: EdgeInsets.all(6),
                                     child: Text(
                                       '${rest_time}',
                                       style: TextStyle(fontSize: 32,color: Colors.white, fontWeight: FontWeight.w700, decoration: TextDecoration.underline,),
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
                 Container(
                   width: screenWidth,
                   height: (screenHeight - statusBarHeight) * 0.2,
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
                           color: Colors.teal,
                           borderRadius: BorderRadius.only(
                               topLeft: Radius.circular(10.0),
                               topRight: Radius.circular(10.0)
                           ),
                         ),
                         child: Text(
                           ' ' + '업무리스트',
                           style: TextStyle(fontSize: 17,color: Colors.white, fontWeight: FontWeight.w700),
                         ),
                       ),
                       Container(
                         child: Column(
                           children: <Widget>[
                             Container(
                                 height: (screenHeight - statusBarHeight) * 0.05,
                                 alignment: Alignment.center,
                                 child: Row(
                                   children: <Widget>[
                                     Container(
                                       width: screenWidth * 0.27,
                                       alignment: Alignment.centerLeft,
                                         child:GestureDetector(
                                           child: Text(
                                             '  · 예고함',
                                             style: TextStyle(fontSize: 15, color: Colors.black),
                                           ),
                                           onTap: () {
                                             GWType = "PreApproval";
                                             GWTypeNm = "예고함";
                                             Navigator.pushNamed(context, '/Approve');
                                           },
                                         )
                                     ),
                                     Container(
                                       width: screenWidth * 0.2,
                                       alignment: Alignment.center,
                                       child: Text(
                                           ':   ' + '${preApproval}건',
                                         style: TextStyle(fontSize: 15),
                                       ),
                                     ),
                                     Container(
                                       width: screenWidth * 0.27,
                                       alignment: Alignment.centerLeft,
                                         child:GestureDetector(
                                           child: Text(
                                             '  · 미결함',
                                             style: TextStyle(fontSize: 15, color: Colors.black),
                                           ),
                                           onTap: () {
                                             GWType = "UnApproved";
                                             GWTypeNm = "미결함";
                                             Navigator.pushNamed(context, '/Approve');
                                           },
                                         )
                                     ),
                                     Container(
                                       width: screenWidth * 0.2,
                                       alignment: Alignment.center,
                                       child: Text(
                                           ':   ' + '${unApproved}건',
                                         style: TextStyle(fontSize: 15),
                                       ),
                                     )
                                   ],
                                 ),
                             ),
                             Container(
                                 height: (screenHeight - statusBarHeight) * 0.05,
                                 alignment: Alignment.topCenter,
                               child: Row(
                                 children: <Widget>[
                                   Container(
                                     width: screenWidth * 0.27,
                                     alignment: Alignment.centerLeft,
                                       child:GestureDetector(
                                         child: Text(
                                           '  · 진행함',
                                           style: TextStyle(fontSize: 15, color: Colors.black),
                                         ),
                                         onTap: () {
                                           GWType = "OnGoing";
                                           GWTypeNm = "진행함";
                                           Navigator.pushNamed(context, '/Approve');
                                         },
                                       )
                                   ),
                                   Container(
                                     width: screenWidth * 0.2,
                                     alignment: Alignment.center,
                                     child: Text(
                                         ':   ' + '${onGoing}건',
                                       style: TextStyle(fontSize: 15),
                                     ),
                                   ),
                                   Container(
                                     width: screenWidth * 0.27,
                                     alignment: Alignment.centerLeft,
                                       child:GestureDetector(
                                         child: Text(
                                           '  · 수신함',
                                           style: TextStyle(fontSize: 15, color: Colors.black),
                                         ),
                                         onTap: () {
                                           GWType = "Received";
                                           GWTypeNm = "수신함";
                                           Navigator.pushNamed(context, '/Approve');
                                         },
                                       )
                                   ),
                                   Container(
                                     width: screenWidth * 0.2,
                                     alignment: Alignment.center,
                                     child: Text(
                                         ':   ' + '${deptReceived }건',
                                       style: TextStyle(fontSize: 15),
                                     ),
                                   )
                                 ],
                               ),
                             ),
                             Container(
                                 height: (screenHeight - statusBarHeight) * 0.05,
                                 alignment: Alignment.topCenter,
                               child: Row(
                                 children: <Widget>[
                                   Container(
                                     width: screenWidth * 0.27,
                                     alignment: Alignment.centerLeft,
                                       child:GestureDetector(
                                         child: Text(
                                           '  · 참조/회람함',
                                           style: TextStyle(fontSize: 15, color: Colors.black),
                                         ),
                                         onTap: () {
                                           GWType = "Reference";
                                           GWTypeNm = "참조/회람함";
                                           Navigator.pushNamed(context, '/Approve');
                                         },
                                       )
                                   ),
                                   Container(
                                     width: screenWidth * 0.2,
                                     alignment: Alignment.center,
                                     child: Text(
                                         ':   ' + '${circulation}건',
                                       style: TextStyle(fontSize: 15),
                                     ),
                                   ),
                                   Container(
                                     width: screenWidth * 0.27,
                                     alignment: Alignment.centerLeft,
                                       child:GestureDetector(
                                         child: Text(
                                           '  · 협조진행함',
                                           style: TextStyle(fontSize: 15, color: Colors.black),
                                         ),
                                         onTap: () {
                                           GWType = "Cooperation";
                                           GWTypeNm = "협조진행함";
                                           Navigator.pushNamed(context, '/Approve');
                                         },
                                       )
                                   ),
                                   Container(
                                     width: screenWidth * 0.2,
                                     alignment: Alignment.center,
                                     child: Text(
                                         ':   ' + '${cooperation }건',
                                       style: TextStyle(fontSize: 15),
                                     ),
                                   )
                                 ],
                               ),
                             )
                           ],
                         ),
                       )
                     ],
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
      var url = 'https://jhapi.jahwa.co.kr/Home';
      var count = 0;

      // Send Parameter
      var data = {'EntCode': '${session['EntCode']}', 'DeptCode':'${session['DeptCode']}', 'EmpCode':'${session['EmpCode']}'};

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 30)).then<bool>((http.Response response) async {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Server Info. Data Error !!!'); }
        else if(response.statusCode == 200){
          await pr.show();
          if(jsonDecode(response.body)['Table1'].length == 0) {

          }
          else {
             /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            jsonDecode(response.body)['Table1'].forEach((element) {
              preApproval = '${element["PreApproval"].toString()}';
              unApproved = '${element["UnApproved"].toString()}';
              onGoing = '${element["OnGoing"].toString()}';
              circulation = '${element["Circulation"].toString()}';
              cooperation = '${element["Cooperation"].toString()}';
              deptReceived = '${element["DeptReceived"].toString()}';
            });

          }
          if(jsonDecode(response.body)['Table7'].length == 0) {

            cardList0.clear();
          }
          else {
            /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            cardList0.clear();
            jsonDecode(response.body)['Table7'].forEach((element) {
              if(count<5 && element["Code"].toString() != "Special"){
                Widget card = Card(
                  child: Row(
                    children: <Widget> [
                      Container(
                        width: screenWidth * 0.9,
                        ///height: (screenHeight - statusBarHeight) * 0.025,
                        margin: EdgeInsets.all(3),
                        alignment: Alignment.centerLeft,
                          child:GestureDetector(
                            child: Text(
                              '${element["Subject"].toString()}',
                              style: TextStyle(fontSize: 13,color: Colors.black),
                            ),
                            onTap: () {
                              BbsCode = element["Code"].toString();
                              BbsNum = element["Num"].toString();
                              Navigator.pushNamed(context, '/BbsView');
                            },
                          )
                      ),
                    ],
                  ),
                );
                cardList0.add(card);
                count++;
              }
            });

          }
          if(jsonDecode(response.body)['Table19'].length == 0) {

          }
          else {
             /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            jsonDecode(response.body)['Table19'].forEach((element) {
              work_type = '${element["WORK_TYPE_NM"].toString()}';
              start_time = '${element["STRT_TIME"].toString()}';
              if ('${element["EXP_END_TIME"].toString()}' != ''){
                end_time = '${element["EXP_END_TIME"].toString()}';
                end_time_YN = "N";
              }
              else{
                end_time = '${element["END_TIME"].toString()}';
                end_time_YN = "Y";
              }
              rest_time = '${element["BREAK_TIME"].toString()}';
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