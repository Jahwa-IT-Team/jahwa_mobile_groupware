import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jahwa_mobile_groupware/util/common.dart';
import 'package:jahwa_mobile_groupware/util/globals.dart';

ProgressDialog pr; /// 0. Progress Dialog Declaration

class DocumentApp extends StatefulWidget {
  @override
  _DocumentWidgetState createState() => _DocumentWidgetState();
}

class _DocumentWidgetState extends State<DocumentApp> {
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
                                    '  ' + '전자결재       ',
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


                    child: Column(
                        children: <Widget>[
                          SizedBox( height: (screenHeight - statusBarHeight) * 0.05, ),

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
                              ' ' + '개인문서함',
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),

                          Container(
                              width: screenWidth,
                              height: (screenHeight - statusBarHeight) * 0.05,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                              child:GestureDetector(
                                child: Text(
                                  ' 예고함                                                      ',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  GWType = "PreApproval";
                                  GWTypeNm = "예고함";
                                  Navigator.pushNamed(context, '/Approve');
                                },
                              )
                          ),

                          Container(
                            width: screenWidth,
                            height: (screenHeight - statusBarHeight) * 0.05,
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                              child:GestureDetector(
                                child: Text(
                                  ' 미결함                                                      ',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  GWType = "UnApproved";
                                  GWTypeNm = "미결함";
                                  Navigator.pushNamed(context, '/Approve');
                                },
                              )
                          ),

                          Container(
                              width: screenWidth,
                              height: (screenHeight - statusBarHeight) * 0.05,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,

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
                              child:GestureDetector(
                                child: Text(
                                  ' 진행함                                                      ',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  GWType = "OnGoing";
                                  GWTypeNm = "진행함";
                                  Navigator.pushNamed(context, '/Approve');
                                },
                              )
                          ),

                          Container(
                              width: screenWidth,
                              height: (screenHeight - statusBarHeight) * 0.05,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,

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
                              child:GestureDetector(
                                child: Text(
                                  ' 관리함                                                      ',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  GWType = "Managed";
                                  GWTypeNm = "관리함";
                                  Navigator.pushNamed(context, '/Approve');
                                },
                              )
                          ),

                          Container(
                              width: screenWidth,
                              height: (screenHeight - statusBarHeight) * 0.05,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,

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
                              child:GestureDetector(
                                child: Text(
                                  ' 참조/회람함                                                   ',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  GWType = "Reference";
                                  GWTypeNm = "참조회람함";
                                  Navigator.pushNamed(context, '/Approve');
                                },
                              )
                          ),

                          Container(
                              width: screenWidth,
                              height: (screenHeight - statusBarHeight) * 0.05,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,

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
                              child:GestureDetector(
                                child: Text(
                                  ' 협조진행함                                                    ',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  GWType = "Cooperation";
                                  GWTypeNm = "협조진행함";
                                  Navigator.pushNamed(context, '/Approve');
                                },
                              )
                          ),

                          Container(
                              width: screenWidth,
                              height: (screenHeight - statusBarHeight) * 0.05,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,

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
                              child:GestureDetector(
                                child: Text(
                                  ' 반려함                                                      ',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  GWType = "Rejected";
                                  GWTypeNm = "반려함";
                                  Navigator.pushNamed(context, '/Approve');
                                },
                              )
                          ),

                          Container(
                              width: screenWidth,
                              height: (screenHeight - statusBarHeight) * 0.05,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,

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
                              child:GestureDetector(
                                child: Text(
                                  ' 임시함                                                      ',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  GWType = "Temporary";
                                  GWTypeNm = "임시함";
                                  Navigator.pushNamed(context, '/Approve');
                                },
                              )
                          ),

                          SizedBox(height: (screenHeight - statusBarHeight) * 0.025,),

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
                              ' ' + '부서문서함',
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),


                          Container(
                              width: screenWidth,
                              height: (screenHeight - statusBarHeight) * 0.05,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,

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
                              child:GestureDetector(
                                child: Text(
                                  ' 품의함                                                      ',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  GWType = "Consultation";
                                  GWTypeNm = "품의함";
                                  Navigator.pushNamed(context, '/Approve');
                                },
                              )
                          ),

                          Container(
                              width: screenWidth,
                              height: (screenHeight - statusBarHeight) * 0.05,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,

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
                              child:GestureDetector(
                                child: Text(
                                  ' 발신함                                                      ',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  GWType = "Sent";
                                  GWTypeNm = "발신함";
                                  Navigator.pushNamed(context, '/Approve');
                                },
                              )
                          ),

                          Container(
                              width: screenWidth,
                              height: (screenHeight - statusBarHeight) * 0.05,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,

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
                              child:GestureDetector(
                                child: Text(
                                  ' 수신함                                                      ',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  GWType = "Received";
                                  GWTypeNm = "수신함";
                                  Navigator.pushNamed(context, '/Approve');
                                },
                              )
                          ),

                          Container(
                              width: screenWidth,
                              height: (screenHeight - statusBarHeight) * 0.05,
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.white,

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
                              child:GestureDetector(
                                child: Text(
                                  ' 참조/회람함                                                   ',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                                onTap: () {
                                  GWType = "DeptReference";
                                  GWTypeNm = "참조/회람함";
                                  Navigator.pushNamed(context, '/Approve');
                                },
                              )
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
}
