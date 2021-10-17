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
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/link.dart';
import 'dart:async';

ProgressDialog pr; /// 0. Progress Dialog Declaration

class SearchApp extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchApp> {

  List<Card> cardList = [];
  TextEditingController _editingController;
  bool _isLoading = true;

  /// Call When Form Init
  @override
  void initState() {
    super.initState();
    _editingController = new TextEditingController();
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
                            '  ' + 'Search',
                            style: TextStyle(fontSize: 25,color: Colors.white, fontWeight: FontWeight.w700),
                          ),
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
                  child:Column(
                    children: <Widget>[
                      Container(
                          width: screenWidth,
                          ///height: (screenHeight - statusBarHeight) * 0.1,
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.all(10),
                          child: Row(
                            children: <Widget> [
                              Container(
                                width: (screenWidth-40) * 0.69,
                                child:TextField(
                                  controller: _editingController,
                                  autofocus: false,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(const Radius.circular(10.0),),
                                      borderSide: new BorderSide(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                    labelText: translateText(context, '사번/이름/부서 검색'),
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              SizedBox(width: 2,),
                              Container( /// Search Button
                                width: (screenWidth-40) * 0.3,
                                child: ButtonTheme(
                                  minWidth: baseWidth,
                                  height: 50.0,
                                  child: RaisedButton(
                                    child:Text(translateText(context, 'Search'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white,)),
                                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                                    splashColor: Colors.grey,
                                    onPressed: () async {
                                      await getJSONData();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ),
                      Container( // Main Area
                        width: screenWidth * 0.9,
                        height: (screenHeight - statusBarHeight) * 0.7,
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
      var data = {'Text': '${_editingController.value.text}'};

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 30)).then<bool>((http.Response response) async {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Server Info. Data Error !!!'); }
        else if(response.statusCode == 200){
          if(jsonDecode(response.body)['Table'].length == 0) {
            showMessageBox(context, 'Alert', 'Data does not Exists!!!');
            cardList.clear();
          }
          else {
            await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            cardList.clear();
            jsonDecode(response.body)['Table'].forEach((element) {
              Widget card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth * 0.2,
                      height: (screenHeight - statusBarHeight) * 0.15,
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color:Colors.white, width: 2, style: BorderStyle.solid,),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage('https://gw.jahwa.co.kr/Photo/' + '${element["Photo"].toString()}',)),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.6,
                      padding: EdgeInsets.all(10.0),
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${element["CO_FULL_NM"].toString()}',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${element["DEPT_NM"].toString()} ${element["NAME"].toString()} ${element["ROLL_PSTN"].toString()}',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Container(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.call, color: Colors.blue),
                                  SizedBox(width: screenWidth * 0.01,),
                                  GestureDetector(
                                      onTap: (){
                                        print("Container clicked1");
                                        launch("tel://${element["EM_TEL_NO"].toString().replaceAll('-', '')}");
                                      },
                                      child: new Container(
                                        child: Text(
                                          '${element["EM_TEL_NO"].toString()}',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      )
                                  )
                                ],
                              )
                          ),
                          Container(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.phone_android, color: Colors.blue),
                                  SizedBox(width: screenWidth * 0.01,),
                                  GestureDetector(
                                    onTap: (){
                                      print("Container clicked2");
                                      launch("tel://${element["HAND_TEL_NO"].toString().replaceAll('-', '')}");
                                    },
                                    child: new Container(
                                      child: Text(
                                        '${element["HAND_TEL_NO"].toString()}',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    )
                                  )
                                ],
                              )
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.mail, color: Colors.blue),
                                SizedBox(width: screenWidth * 0.01,),
                                Container(
                                  child: Text(
                                    '${element["EMAIL_ADDR"].toString()}',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                )
                              ],
                            )
                          ),
                        ],
                      )

                    ),
                  ],
                ),
              );
              cardList.add(card);
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

}