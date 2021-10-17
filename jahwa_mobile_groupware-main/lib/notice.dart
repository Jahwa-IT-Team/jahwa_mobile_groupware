import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jahwa_mobile_groupware/util/common.dart';
import 'package:jahwa_mobile_groupware/util/globals.dart';

class Notice extends StatefulWidget {
  @override
  _NoticeState createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {

  List<Card> cardList = new List<Card>();
  ScrollController _controller;

  int page = 1;

  makeScrollBody(String pageString) async {

    SharedPreferences prefs = await SharedPreferences.getInstance(); /// SharedPreferences를 사용하기 위한 변수선언
    session['EmpCode'] = prefs.getString('EmpCode') ?? '';

    try {

      // Login API Url
      var url = 'https://jhapi.jahwa.co.kr/Notice';

      // Send Parameter
      var data = {'page': pageString, 'pagerowcount' : '10', 'div' : 'All', 'empcode' : session['EmpCode']};

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 15)).then<bool>((http.Response response) async {
        //print("Result Version : ${response.body}, (${response.statusCode}) - " + DateTime.now().toString());
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Check Version Data Error !!!'); }
        else if(response.statusCode == 200){
          if(jsonDecode(response.body)['Table'].length == 0) {
            showMessageBox(context, 'Alert', 'Data does not Exists!!!');
          }
          else {
            jsonDecode(response.body)['Table'].forEach((element) {
              Widget card = Card(
                child: Row(
                  children: <Widget> [
                    Container(
                      width: screenWidth - 30,
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget> [
                          Text(element['Title'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                          SizedBox(height: 10, ),
                          Html(
                            data : element['Contents'].replaceAll('\n', '<br>'),
                            style: {
                              "body" : Style(padding: EdgeInsets.all(0), margin: EdgeInsets.all(0),),
                            },
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            child: Text(element['DeptName'] + ' ' + element['Name'] + ' [ ' + element['InsDate'] + ' ]', style: TextStyle(color: Colors.blueAccent)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              cardList.add(card);
            });
            setState(() {
              ;
            });
          }
        }
      });
    }
    catch (e) {
      showMessageBox(context, 'Alert', 'Preference Setting Error A : ' + e.toString());
    }
  }

  _scrollListener() {
    // Reach The Bottom
    if (_controller.offset >= _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
      setState(() {
        //showMessageBox(context, "reach the bottom");
        page ++;
        makeScrollBody(page.toString());
      });
    }
    // Reach The Top : NonUse
    /*if (_controller.offset <= _controller.position.minScrollExtent && !_controller.position.outOfRange) {
      setState(() {
        showMessageBox(context, "reach the top");
      });
    }*/
  }

  // Call When Form Init
  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    makeScrollBody(page.toString());
    super.initState();
    print("open Notice Page : " + DateTime.now().toString());
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
            'Notification',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15,),
          ),
        ),
        body: SingleChildScrollView(
          child: Column (
            children: <Widget> [
              Container( // Main Area
                color: Color.fromARGB(0xFF, 0xE6, 0xE6, 0xE6),
                width: screenWidth,
                height: screenHeight - statusBarHeight - appBarHeigight - 50,
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: ListView(
                  controller: _controller,
                  children: ListTile.divideTiles(
                    context: context,
                    tiles: cardList,
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}