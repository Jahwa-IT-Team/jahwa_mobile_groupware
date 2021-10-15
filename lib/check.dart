import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jahwa_mobile_groupware/util/common.dart';
import 'package:jahwa_mobile_groupware/util/globals.dart';

/// 사전체크를 진행하여 업데이트, 로그인, 기본페이지로의 이동을 결정함
class Check extends StatefulWidget {
  @override
  _CheckState createState() => _CheckState();
}

class _CheckState extends State<Check> {

  ButtonState btnState = ButtonState.loading; /// Progress_State_Button 상태변수 - 초기는 Checking Update!!!

  /// Call When Form Init
  @override
  void initState() {
    super.initState();
    print("open Check Page : " + DateTime.now().toString());
    
    Timer(Duration(seconds: 1), () {
      preferenceSetting(); /// Make Session And Language Data, Check Login
    });
  }

  @override
  Widget build(BuildContext context) {

    /// globals.dart에 있는 화면관련 크키 변수에 기초정보를 담는다.
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
        body: SingleChildScrollView( /// Scroll이 생기도록 하는 Object
          child: Column(
            children: <Widget>[
              Container( /// Top Status Bar Area
                height: statusBarHeight,
                width: screenWidth,
                color: Color.fromARGB(0xFF, 0x34, 0x40, 0x4E),
              ),
              SizedBox(height: 50,), /// 여백을 위한 Object
              Container( /// 회사 마크
                  width: screenWidth,
                  height: (screenHeight - statusBarHeight) * 0.60,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: baseWidth,
                    child: Image.asset("assets/image/jahwa.png"),
                  )
              ),
              Container( /// Main Area
                width: baseWidth,
                height: (screenHeight - statusBarHeight) * 0.35,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    buildCustomButton(), /// Progress_State_Button
                    SizedBox(height: 20,),
                    Text('Checking Update! Please Wait!!!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14, ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Progress_State_Button Setting
  Widget buildCustomButton() {
    var progressTextButton = ProgressButton(
      stateWidgets: { /// Widget Setting
        ButtonState.idle: Text("Update required!!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
        ButtonState.loading: Text("Checking Update!!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
        ButtonState.fail: Text("Failed. If you want to Reload, Click Here!!", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),),
        ButtonState.success: Text("The update was successful!!", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),)
      },
      stateColors: { /// Button Color
        ButtonState.idle: Colors.grey.shade400,
        ButtonState.loading: Colors.blue.shade300,
        ButtonState.fail: Colors.red.shade300,
        ButtonState.success: Colors.green.shade400,
      },
      onPressed: () {
        if(btnState == ButtonState.fail) { /// Check Fail이 발생할 경우 Button을 Click하면 다시 처리
          btnState = ButtonState.loading;
          setState(() {});
          preferenceSetting();
        }
        else { setState(() {}); }
      },
      state: btnState,
      padding: EdgeInsets.all(8.0),
    );
    return progressTextButton;
  }

  /// Check Login Info -> Move to Login Or Main Page : Index Page Use
  Future<bool> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /// Due Date가 지난 경우 모든 세션정보를 삭제하고 Login Page로 이동
    if((prefs.getString('DueDate') ?? '') != DateFormat('yyyy-MM-dd').format(DateTime.now())) {
      clearSession();
      removeUserSharedPreferences();
      return true;
    }
    else { return false; }
  }

  /// Get And Make Menu Data
  Future<bool> getMenu() async {
    try {

      var url = 'https://jhapi.jahwa.co.kr/Menu'; /// API Url
      var data = {'lang': session['Language'], 'category' : 'JHMobile', 'entgroup' : session['EntGroup'], 'entcode' : session['EntCode'], 'empcode' : session['EmpCode'], 'auth' : session['Auth']}; /// Send Parameter

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 15)).then<bool>((http.Response response) {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ return false; }
        if(response.statusCode == 200){
          menudata = jsonDecode(response.body);
          return true;
        }
        else{ return false; }
      });
    }
    catch (e) {
      print("getMenu Error : " + e.toString());
      return false;
    }
  }

  /// Check 순서 : Version Check -> Language & DD Data Check -> Session Check -> Menu Check
  Future<void> preferenceSetting() async {

    /// 0. Declare Screen Size
    screenWidth = MediaQuery.of(context).size.width; /// Screen Width
    screenHeight = MediaQuery.of(context).size.height; /// Screen Height
    statusBarHeight = MediaQuery.of(context).padding.top; /// Top Status Bar Height
    appBarHeigight = AppBar().preferredSize.height; /// App Bar Height

    SharedPreferences prefs = await SharedPreferences.getInstance(); /// SharedPreferences를 사용하기 위한 변수선언

    try {

      /// 1. Language Check
      language = prefs.getString('Language') ?? ui.window.locale.languageCode; /// 기본적으로 System의 언어정보 설정
      languagedata = jsonDecode(prefs.getString('LanguageData') ?? '{}'); /// DD Data를 가져오기전에 변수 초기화

      /// DD Data 가져오기 - 현재는 언어별 json 파일로 되어 있으나 장기적으로 DB화 하여 가져오도록 처리 예정
      if(await prefs.setString('LanguageData', await rootBundle.loadString("assets/lang/" + language + ".json"))){
        if((prefs.getString('LanguageData') ?? '') == '') languagedata = jsonDecode(await rootBundle.loadString("assets/lang/" + language + ".json"));
        else languagedata = jsonDecode(prefs.getString('LanguageData'));
      }

      /// 2. Session Check
      if(await checkLogin())
      {
        /// 로그인이 필요한 경우 처리되는 프로세스
        btnState = ButtonState.success;
        setState(() {});
        Timer(Duration(seconds: 1), () {
          Navigator.pushNamedAndRemoveUntil(context, '/Login', (route) => false);  /// Direct Move to Login
        });
      }
      else {
        session['EntCode'] = prefs.getString('EntCode') ?? '';
        session['EntName'] = prefs.getString('EntName') ?? '';
        session['DeptCode'] = prefs.getString('DeptCode') ?? '';
        session['DeptName'] = prefs.getString('DeptName') ?? '';
        session['EmpCode'] = prefs.getString('EmpCode') ?? '';
        session['Name'] = prefs.getString('Name') ?? '';
        session['RollPstn'] = prefs.getString('RollPstn') ?? '';
        session['Position'] = prefs.getString('Position') ?? '';
        session['Role'] = prefs.getString('Role') ?? '';
        session['Title'] = prefs.getString('Title') ?? '';
        session['PayGrade'] = prefs.getString('PayGrade') ?? '';
        session['Level'] = prefs.getString('Level') ?? '';
        session['Email'] = prefs.getString('Email') ?? '';
        session['Photo'] = prefs.getString('Photo') ?? '';
        session['Auth'] = prefs.getInt('Auth').toString() ?? '0';
        session['EntGroup'] = prefs.getString('EntGroup') ?? '';
        session['OfficeTel'] = prefs.getString('OfficeTel') ?? '';
        session['Mobile'] = prefs.getString('Mobile') ?? '';
        session['DueDate'] = prefs.getString('DueDate') ?? '';

        /// 3. Menu Check
        if(session['EmpCode'] != '') {

          if(await getMenu()) {
            btnState = ButtonState.success;
            setState(() {});
            Timer(Duration(seconds: 1), () {
              Navigator.pushNamedAndRemoveUntil(context, '/Index', (route) => false); /// 모든 Check가 성공하면 초기페이지로 이동
            });
          }
          else {
            btnState = ButtonState.fail;
            setState(() {});
            showMessageBox(context, 'Alert', 'Preference Setting Error : getMenu Fail!!!');
          }
        }
        else {
          btnState = ButtonState.fail;
          setState(() {});
          showMessageBox(context, 'Alert', 'Preference Setting Error : Employee Number Not Exists!!!');
        }
      }
    }
    catch (e){
      btnState = ButtonState.fail;
      setState(() {});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('Language');
      prefs.remove('DueDate');
      showMessageBox(context, 'Alert', 'Preference Setting Error B : ' + e.toString());
      Navigator.pushNamedAndRemoveUntil(context, '/Check', (route) => false); /// 모든 Check가 성공하면 초기페이지로 이동
    }
  }
}