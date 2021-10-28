import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jahwa_mobile_groupware/util/common.dart';
import 'package:jahwa_mobile_groupware/util/globals.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

import 'package:jahwa_mobile_groupware/util/cryptojs_aes_encryption.dart';

ProgressDialog pr; /// 0. Progress Dialog Declaration

class ApproveApp extends StatefulWidget {
  @override
  _ApproveWidgetState createState() => _ApproveWidgetState();
}

class _ApproveWidgetState extends State<ApproveApp> {

  //List<Card> cardList = new List<Card>();
  List<Card> cardList = [];
  ScrollController _controller;
  TextEditingController _editingController;
  //bool _isLoading = true;

  int page = 1;  //추가


  @override
  void initState() {

    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    _editingController = new TextEditingController();

    //print(GWType);

    if (GWType == "PreApproval" || GWType == "UnApproved" || GWType == "OnGoing" || GWType == "Managed" || GWType == "Cooperation" || GWType == "Rejected" || GWType == "Temporary") {
      getJSONData(GWType, page.toString(), "Y");    //개인문서함리스트
      super.initState();
    }
    else if (GWType == "Reference") {
      getJSONData2(GWType, page.toString(), "Y");  //개인문서함 참조 리스트
    }
    else if (GWType == "Consultation" || GWType == "Sent" || GWType == "Received"){
      getJSONData3(GWType, page.toString(), "Y");  //개인문서함 참조 리스트
    }
    else if (GWType == "DeptReference") {
      getJSONData4(GWType, page.toString(), "Y");  //개인문서함 참조 리스트
    }

    super.initState();
  }

  _scrollListener() {
    // Reach The Bottom
    if (_controller.offset >= _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
      setState(() {
        //showMessageBox(context, "reach the bottom");
        page ++;
        //getJSONData(GWType, page.toString());

        if (GWType == "PreApproval" || GWType == "UnApproved" || GWType == "OnGoing" || GWType == "Managed" || GWType == "Cooperation" || GWType == "Rejected" || GWType == "Temporary") {
          getJSONData(GWType, page.toString(), "N");    //개인문서함리스트
          super.initState();
        }
        else if (GWType == "Reference") {
          getJSONData2(GWType, page.toString(), "N");  //개인문서함 참조 리스트
        }
        else if (GWType == "Consultation" || GWType == "Sent" || GWType == "Received"){
          getJSONData3(GWType, page.toString(), "N");  //개인문서함 참조 리스트
        }
        else if (GWType == "DeptReference") {
          getJSONData4(GWType, page.toString(), "N");  //개인문서함 참조 리스트
        }
      });
    }
    // Reach The Top : NonUse
    /*if (_controller.offset <= _controller.position.minScrollExtent && !_controller.position.outOfRange) {
      setState(() {
        showMessageBox(context, "reach the top");
      });
    }*/
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
                                    '  ' + GWTypeNm,
                                    style: TextStyle(fontSize: 25,color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.5, ),
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
                                    labelText: translateText(context, 'Title'),
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
                                    child:Text(translateText(context, '검색'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white,)),
                                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                                    splashColor: Colors.grey,
                                    onPressed: () async {
                                      //await getJSONData(GWType, page.toString());

                                      page = 1;
                                      if (GWType == "PreApproval" || GWType == "UnApproved" || GWType == "OnGoing" || GWType == "Managed" || GWType == "Cooperation" || GWType == "Rejected" || GWType == "Temporary") {
                                        await getJSONData(GWType, page.toString(), "Y");   //개인문서 리스트
                                      }
                                      else if (GWType == "Reference") {
                                        await getJSONData2(GWType, page.toString(), "Y");  //개인문서함 참조 리스트
                                      }
                                      else if (GWType == "Consultation" || GWType == "Sent" || GWType == "Received"){
                                        await getJSONData3(GWType, page.toString(),"Y");  //개인문서함 참조 리스트
                                      }
                                      else if (GWType == "DeptReference") {
                                        await getJSONData4(GWType, page.toString(), "Y");  //개인문서함 참조 리스트
                                      }
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
                              controller: _controller,
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


  Future<void> getJSONData(String GwType, String pageString, String ClearYN) async {
    try {
      // Login API Url
      var url = 'https://jhapi.jahwa.co.kr/GWDocument';

      // Send Parameter
      //var data = {'Text': '${_editingController.value.text}'};
      var data = {'Process': GwType, 'Page' : pageString, 'PageRowCount' : "10", 'Text' : _editingController.text, 'Empcode' : session['EmpCode'], 'Level' : 9 };

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 30)).then<bool>((http.Response response) async {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Server Info. Data Error !!!'); }
        else if(response.statusCode == 200){
          if(jsonDecode(response.body)['Table'].length == 0) {
            showMessageBox(context, 'Alert', 'Data does not Exists!!!');
            cardList.clear();
          }
          else {
            //await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            if (ClearYN == "Y") {
              cardList.clear();
            }
            jsonDecode(response.body)['Table'].forEach((element) {

              var Key = session['EmpCode'];
              var EncKey = Uri.encodeQueryComponent(encryptText2("Encrypt", Key));

              var UrlLink = 'DocId=' + '${element["DocId"].toString()}' + '&AppDeptCode=' + '${element["AppDeptCode"].toString()}' + '&Type=' + '${element["Type"].toString()}' + '&AppId=' + '${element["AppId"].toString()}' + '&Mode=General&Action=View&AppEmpCode=' + '${element["AppEmpCode"].toString()}';

              Widget card = Card(
                child: Row(
                  children: <Widget> [

                    Container(
                        width: screenWidth * 0.8,
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topLeft,
                              child: RaisedButton(
                                onPressed: () async {
                                  //await canLaunch(_url) ? await launch(_url) : throw 'Could not launch111 $_url';
                                  //await launch('https://gw.jahwa.co.kr/Common/Util/MobileDocumentLink.aspx?id=' + session['EmpCode'] + '&DocId=' + '${element["DocId"].toString()}' + '&AppDeptCode=' + '${element["AppDeptCode"].toString()}' + '&Type=' + '${element["Type"].toString()}' + '&AppId=' + '${element["AppId"].toString()}' + '&Mode=General&Action=View&AppEmpCode=' + '${element["AppEmpCode"].toString()}', forceWebView: false, forceSafariVC: true);
                                  await launch('https://gw.jahwa.co.kr/Common/Util/MobileDocumentLink.aspx?key=' + EncKey + '&' + UrlLink, forceWebView: false, forceSafariVC: true);
                                },
                                child: Text('${element["DocumentTitle"].toString()}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox( width: screenWidth * 0.5, ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${element["DocumentDate"].toString()} ${element["DeptName"].toString()} ${element["Name"].toString()}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${element["FormName"].toString()}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        )

                    ),
                  ],
                ),
              );
              cardList.add(card);
            });
            //await pr.hide();
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



  Future<void> getJSONData2(String GwType, String pageString, String ClearYN) async {   //개인 참조회람함
    try {
      // Login API Url
      var url = 'https://jhapi.jahwa.co.kr/GWDocumentCCList';

      // Send Parameter
      //var data = {'Text': '${_editingController.value.text}'};
      var data = {'Process': GwType, 'Page' : pageString, 'PageRowCount' : "10", 'Text' : _editingController.text, 'Empcode' : session['EmpCode'], 'Level' : 9 };

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 30)).then<bool>((http.Response response) async {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Server Info. Data Error !!!'); }
        else if(response.statusCode == 200){
          if(jsonDecode(response.body)['Table'].length == 0) {
            showMessageBox(context, 'Alert', 'Data does not Exists!!!');
            cardList.clear();
          }
          else {
            //await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            if (ClearYN == "Y") {
              cardList.clear();
            }
            jsonDecode(response.body)['Table'].forEach((element) {

              var Key = session['EmpCode'];
              var EncKey = Uri.encodeQueryComponent(encryptText2("Encrypt", Key));

              var UrlLink = 'DocId=' + '${element["DocId"].toString()}' + '&AppDeptCode=' + '${element["AppDeptCode"].toString()}' + '&Type=' + '${element["Type"].toString()}' + '&AppId=' + '${element["AppId"].toString()}' + '&Mode=General&Action=View&AppEmpCode=' + '${element["AppEmpCode"].toString()}';

              Widget card = Card(
                child: Row(
                  children: <Widget> [

                    Container(
                        width: screenWidth * 0.8,
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topLeft,
                              child: RaisedButton(
                                onPressed: () async {
                                  //await canLaunch(_url) ? await launch(_url) : throw 'Could not launch111 $_url';
                                  //await launch('https://gw.jahwa.co.kr/Common/Util/MobileDocumentLink.aspx?id=' + session['EmpCode'] + '&DocId=' + '${element["DocId"].toString()}' + '&AppDeptCode=' + '${element["AppDeptCode"].toString()}' + '&Type=' + '${element["Type"].toString()}' + '&AppId=' + '${element["AppId"].toString()}' + '&Mode=General&Action=View&AppEmpCode=' + '${element["AppEmpCode"].toString()}', forceWebView: false, forceSafariVC: true);
                                  await launch('https://gw.jahwa.co.kr/Common/Util/MobileDocumentLink.aspx?key=' + EncKey + '&' + UrlLink, forceWebView: false, forceSafariVC: true);
                                },
                                child: Text('${element["DocumentTitle"].toString()}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox( width: screenWidth * 0.5, ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${element["DocumentDate"].toString()} ${element["DeptName"].toString()} ${element["Name"].toString()}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${element["FormName"].toString()}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        )

                    ),
                  ],
                ),
              );
              cardList.add(card);
            });
            //await pr.hide();
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

  Future<void> getJSONData3(String GwType, String pageString, String ClearYN) async {   //부서문서 리스트
    try {
      // Login API Url
      var url = 'https://jhapi.jahwa.co.kr/GWDocumentDeptList';

      // Send Parameter
      //var data = {'Text': '${_editingController.value.text}'};
      var data = {'Process': GwType, 'Page' : pageString, 'PageRowCount' : "10", 'Text' : _editingController.text, 'DeptCode' : session['DeptCode'], 'Level' : 9 };

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 30)).then<bool>((http.Response response) async {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Server Info. Data Error !!!'); }
        else if(response.statusCode == 200){
          if(jsonDecode(response.body)['Table'].length == 0) {
            showMessageBox(context, 'Alert', 'Data does not Exists!!!');
            cardList.clear();
          }
          else {
           //await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            if (ClearYN == "Y") {
              cardList.clear();
            }
            jsonDecode(response.body)['Table'].forEach((element) {

              var Key = session['EmpCode'];
              var EncKey = Uri.encodeQueryComponent(encryptText2("Encrypt", Key));

              var UrlLink = 'DocId=' + '${element["DocId"].toString()}' + '&AppDeptCode=' + '${element["AppDeptCode"].toString()}' + '&Type=' + '${element["Type"].toString()}' + '&AppId=' + '${element["AppId"].toString()}' + '&Mode=General&Action=View&AppEmpCode=' + '${element["AppEmpCode"].toString()}';

              Widget card = Card(
                child: Row(
                  children: <Widget> [

                    Container(
                        width: screenWidth * 0.8,
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topLeft,
                              child: RaisedButton(
                                onPressed: () async {
                                  await launch('https://gw.jahwa.co.kr/Common/Util/MobileDocumentLink.aspx?key=' + EncKey + '&' + UrlLink, forceWebView: false, forceSafariVC: true);
                                },
                                child: Text('${element["DocumentTitle"].toString()}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox( width: screenWidth * 0.5, ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${element["DocumentDate"].toString()} ${element["DeptName"].toString()} ${element["Name"].toString()}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${element["FormName"].toString()}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        )

                    ),
                  ],
                ),
              );
              cardList.add(card);
            });
            //await pr.hide();
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

  Future<void> getJSONData4(String GwType, String pageString, String ClearYN) async {   //부서 참조회람함
    try {
      // Login API Url
      var url = 'https://jhapi.jahwa.co.kr/GWDocumentDeptCCList';

      // Send Parameter
      //var data = {'Text': '${_editingController.value.text}'};
      var data = {'Process': GwType, 'Page' : pageString, 'PageRowCount' : "10", 'Text' : _editingController.text, 'DeptCode' : session['DeptCode'], 'Level' : 9 };

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 30)).then<bool>((http.Response response) async {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ showMessageBox(context, 'Alert', 'Server Info. Data Error !!!'); }
        else if(response.statusCode == 200){
          if(jsonDecode(response.body)['Table'].length == 0) {
            showMessageBox(context, 'Alert', 'Data does not Exists!!!');
            cardList.clear();
          }
          else {
            //await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
            if (ClearYN == "Y") {
              cardList.clear();
            }
            jsonDecode(response.body)['Table'].forEach((element) {

              var Key = session['EmpCode'];
              var EncKey = Uri.encodeQueryComponent(encryptText2("Encrypt", Key));

              var UrlLink = 'DocId=' + '${element["DocId"].toString()}' + '&AppDeptCode=' + '${element["AppDeptCode"].toString()}' + '&Type=' + '${element["Type"].toString()}' + '&AppId=' + '${element["AppId"].toString()}' + '&Mode=General&Action=View&AppEmpCode=' + '${element["AppEmpCode"].toString()}';

              Widget card = Card(
                child: Row(
                  children: <Widget> [

                    Container(
                        width: screenWidth * 0.8,
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topLeft,
                              child: RaisedButton(
                                onPressed: () async {
                                  await launch('https://gw.jahwa.co.kr/Common/Util/MobileDocumentLink.aspx?key=' + EncKey + '&' + UrlLink, forceWebView: false, forceSafariVC: true);
                                },
                                child: Text('${element["DocumentTitle"].toString()}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox( width: screenWidth * 0.5, ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${element["DocumentDate"].toString()} ${element["DeptName"].toString()} ${element["Name"].toString()}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${element["FormName"].toString()}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        )

                    ),
                  ],
                ),
              );
              cardList.add(card);
            });
            //await pr.hide();
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