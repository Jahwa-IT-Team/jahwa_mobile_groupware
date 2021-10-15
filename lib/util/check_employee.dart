import 'dart:async';
import 'dart:core';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jahwa_mobile_groupware/util/common.dart';
import 'package:jahwa_mobile_groupware/util/globals.dart';

ProgressDialog pr; /// 0. Progress Dialog Declaration

class CheckEmployee extends StatefulWidget {
  @override
  _CheckEmployeeState createState() => _CheckEmployeeState();
}

class _CheckEmployeeState extends State<CheckEmployee> {

  TextEditingController empcodeController = new TextEditingController(); /// Employee Number Data Controller
  TextEditingController nameController = new TextEditingController(); /// Name Data Controller

  FocusNode empcodeFocusNode = FocusNode(); /// Employee Number Input Focus
  FocusNode nameFocusNode = FocusNode(); /// Name Input Focus

  var Company = "KO532";

  void initState() {
    super.initState();
    print("open Check Employee Page : " + DateTime.now().toString());
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

    return GestureDetector( /// Keyboard UnFocus시를 위해 onTap에 GestureDetector를 위치시킴
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) { currentFocus.unfocus(); }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(0xFF, 0x34, 0x40, 0x4E),
          title: Text(translateText(context, "Check Employee"), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15,),
          ),
        ),
        body: SingleChildScrollView ( /// Scroll이 생기도록 하는 Object
            child: Container(
              height: screenHeight,
              width: screenWidth,
              color: Color.fromARGB(0xFF, 0xFF, 0xFF, 0xFF),
              child: Column(
                children: <Widget>[
                  Container( /// Jahwa Mark
                    width: screenWidth,
                    height: (screenHeight - statusBarHeight) * 0.15,
                    alignment: Alignment.center,
                    child: Text(translateText(context, 'Check Employee'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black,)),
                  ),
                  Container( /// Input Area
                    width: screenWidth,
                    alignment: Alignment.center,
                    child: Container(
                      width: baseWidth,
                      height: (screenHeight - statusBarHeight) * 0.85,
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget> [
                          DropdownButton(
                            value: Company,
                            isExpanded: true,
                            items: makeDropdownMenuItem(context, 'Select_Company', languagelist, Company),
                            onChanged: (val) {
                              setState(() {
                                Company = val;
                              });
                            },
                          ),
                          SizedBox(height: 16,),
                          TextField(
                            autofocus: false,
                            controller: empcodeController,
                            focusNode: empcodeFocusNode,
                            keyboardType: TextInputType.text,
                            onSubmitted: (String inputText) {
                              FocusScope.of(context).requestFocus(nameFocusNode);  /// Input Box에서 Enter 적용시 Password 입력 Box로 이동됨
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(const Radius.circular(10.0),),
                                borderSide: new BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                              labelText: translateText(context, 'Employee Number'),
                              contentPadding: EdgeInsets.all(10),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 16,),
                          TextField(
                            autofocus: false,
                            controller: nameController,
                            focusNode: nameFocusNode,
                            keyboardType: TextInputType.text,
                            onSubmitted: (String inputText) async {
                              await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
                              checkEmployee(context, empcodeController, nameController, pr); /// 수동으로 로그인 프로세스를 실행시킴
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(const Radius.circular(10.0),),
                                borderSide: new BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                              labelText: translateText(context, 'Name'),
                              contentPadding: EdgeInsets.all(10),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 16,),
                          ButtonTheme(
                            minWidth: baseWidth,
                            height: 50.0,
                            child: RaisedButton(
                              child:Text(translateText(context, 'Check Employee'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white,)),
                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                              splashColor: Colors.grey,
                              onPressed: () async {
                                await pr.show(); /// 3. Progress Dialog Show - Need Declaration, Setting, Style
                                checkEmployee(context, empcodeController, nameController, pr);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }

  /// Check Employee
  Future<void> checkEmployee(BuildContext context, TextEditingController empcodeController, TextEditingController nameController, ProgressDialog pr) async {

    pr.hide(); /// 4. Progress Dialog Close

    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus.unfocus();
    }

    var list;

    if(empcodeController.text.isEmpty || nameController.text.isEmpty) { showMessageBox(context, 'Alert', 'Employee Number Or Name Not Exists !!!'); } /// Employee Number and Name Empty Check
    else {
      try {

        // Login API Url
        var url = 'https://jhapi.jahwa.co.kr/CheckEmployee';

        // Send Parameter
        var data = {'Company': Company, 'EmpCode': empcodeController.text, 'Name' : nameController.text};

        return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 15)).then<bool>((http.Response response) {
          if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ return false; }
          if(response.statusCode == 200){
            if (response.body == "User does not exist." || response.body == "User Name is incorrect." || response.body == "Error") showMessageBox(context, "Alert", response.body);
            else if (response.body == "A/D Not Use.") {
              ///Navigator.pushNamed(context, '/ResetPasswordQuestion'); ///주민등록번호를 이용한 비밀번호 초기화로 이동
              showMessageBox(context, "Alert", "본 앱에서는 A/D사용자만 사용이 가능합니다.");
            }
            else {
              if(jsonDecode(response.body)['DATA'].length != 0) {
                jsonDecode(response.body)['DATA'].forEach((element) {
                  if (element['Question1'].toString() == "" || element['Question2'].toString() == "") { showMessageBox(context, "Alert", "Not Exists Reset Question Data"); }
                  else {
                    if (element['Dispatch'].toString() == "1" && (Company == 'KO532' || Company == 'KO536')) {
                      Navigator.pushNamed(context, '/ResetPasswordQuestion'); /// 질문 답변 인증 페이지로 이동
                    }
                    else if (Company == 'KO532' || Company == 'KO536') {
                      resetpass['Table'][0]['company'] = Company;
                      resetpass['Table'][0]['empcode'] = empcodeController.text;
                      resetpass['Table'][0]['name'] = nameController.text;
                      resetpass['Table'][0]['question1'] = element['Question1'].toString();
                      resetpass['Table'][0]['question2'] = element['Question2'].toString();
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            title: Text(translateText(context, 'Select Reset Method !!!'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black, )),
                            children: [
                              SimpleDialogOption(
                                onPressed: () async {
                                  await checkPhone(context, empcodeController, nameController);
                                },
                                child: Text(translateText(context, 'Mobile Authentication'),),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/ResetPasswordQuestion'); /// 질문 답변 인증 페이지로 이동
                                },
                                child: Text(translateText(context, 'Question & Answer Authentication'),),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    else {
                      Navigator.pushNamed(context, '/ResetPasswordQuestion'); /// 질문 답변 인증 페이지로 이동
                    }
                  }
                });
              }
              else{
                showMessageBox(context, "Alert", "Not Exists Reset Question Data");
              }
            }
            print(response.body);
          }
          else{ return false; }
        });
      }
      catch (e) {
        print("check Employee Error : " + e.toString());
        return false;
      }
    }
  }

  /// Reset Password Process
  Future<bool> checkPhone(BuildContext context, TextEditingController empcodeController, TextEditingController nameController) async {
    if(empcodeController.text.isEmpty) { showMessageBox(context, 'Alert', 'Employee Number Not Exists !!!'); }
    else if(nameController.text.isEmpty) { showMessageBox(context, 'Alert', 'Name Not Exists !!!'); }
    else {
      try {

        // Login API Url
        var url = 'https://jhapi.jahwa.co.kr/CheckPhone';

        // Send Parameter
        var data = {'EmpCode': empcodeController.text, 'Name' : nameController.text};

        return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 15)).then<bool>((http.Response response) {
          if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ return false; }
          if(response.statusCode == 200) {
            if (response.body.toString() == "하루 5회 전송 제한횟수를 초과했습니다.") {
              showMessageBox(context, "Alert", response.body.toString());
            }
            else {
              var strArray = response.body.toString().split('/');
              showMessageBox(context, "Alert", "[" + strArray[1] + "]로 인증번호가 성공적으로 전송되었습니다.");
              messagenum = strArray[0];
              Future.delayed(Duration(seconds: 3), () {
                Navigator.pushNamed(context, '/ResetPasswordMobile'); /// 휴대폰 인증 페이지로 이동
              });
            }
            return true;
          }
          else{ return false; }
        });
      }
      catch (e) {
        print("reset Password Error : " + e.toString());
        return false;
      }
    }
  }
}