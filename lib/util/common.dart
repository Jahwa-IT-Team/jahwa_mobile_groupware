import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:device_apps/device_apps.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';

import 'package:jahwa_mobile_groupware/util/globals.dart';

/// Change Language Function
Future<void> changeLanguage(BuildContext context, String code) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("Language", code);

  if(await prefs.setString('LanguageData', await rootBundle.loadString("assets/lang/" + code + ".json"))){
    if((prefs.getString('LanguageData') ?? '') == '') languagedata = jsonDecode(await rootBundle.loadString("assets/lang/" + code + ".json"));
    else languagedata = jsonDecode(prefs.getString('LanguageData'));
    await Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}

/// Clear Session Function
clearSession() {
  try {
    session['EntCode'] =  '';
    session['EntName'] = '';
    session['DeptCode'] = '';
    session['DeptName'] = '';
    session['EmpCode'] = '';
    session['Name'] = '';
    session['RollPstn'] = '';
    session['Position'] = '';
    session['Role'] = '';
    session['Title'] = '';
    session['PayGrade'] = '';
    session['Level'] = '';
    session['Email'] = '';
    session['Photo'] = '';
    session['Auth'] = '0';
    session['EntGroup'] = '';
    session['OfficeTel'] = '';
    session['Mobile'] = '';
    session['DueDate'] = '';
  }
  catch (e) { print(e.toString()); }
}

/// Encrypt Text Function
String encryptText(String methood, var data) {
  String returnData = '';
  //String keydata = DateFormat('yyyyMMdd').format(DateTime.now());
  String keydata = DateFormat('yyyyMMdd').format(DateTime.now().toUtc().add(Duration(hours: 9)));
  keydata = keydata + keydata + keydata + keydata;

  final key = encrypt.Key.fromUtf8(keydata);
  final iv = encrypt.IV.fromLength(16);

  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  if(methood == "Encrypt") returnData = encrypter.encrypt(data, iv: iv).base64;
  else returnData = encrypter.decrypt64(data, iv: iv);

  return returnData;
}

/// Encrypt Text Function
String encryptText2(String methood, var data) {
  String returnData = '';
  String keydata = DateFormat('yyyyMMdd').format(DateTime.now().toUtc().add(Duration(hours: 9)));
  keydata = keydata + keydata + keydata + keydata;

  final key = encrypt.Key.fromUtf8(keydata);
  final iv = encrypt.IV.fromLength(16);

  final encrypter = encrypt.Encrypter(encrypt.AES(key, mode:encrypt.AESMode.cbc));

  if(methood == "Encrypt") returnData = encrypter.encrypt(data, iv: iv).base64;
  else returnData = encrypter.decrypt64(data, iv: iv);

  return returnData;
}

/// Select Dialog용 아이템 생성 Function
List<SimpleDialogOption> makeDialogItems(BuildContext context, String div, var jsondata, String selectedvalue, TextEditingController codeController, TextEditingController nameController) {
  List<SimpleDialogOption> itemsList = [];
  var textStyle = const TextStyle(color: Colors.blueAccent);
  jsondata['Table'].forEach((element) {
    if(selectedvalue == element['Code'])textStyle = const TextStyle(color: Colors.blueAccent);
    else textStyle = const TextStyle(color: Colors.black);
    Widget simpleDialogOption = SimpleDialogOption(
      onPressed: () {
        selectedvalue = element['Code'];
        if(div == 'Language') changeLanguage(context, selectedvalue);
        else if(div == 'FindEmployee') {
          codeController.text = element['Code'];
          nameController.text = element['Name'];
          Navigator.of(context).pop();
        }
        else showMessageBox(context, 'Alert', selectedvalue);
      },
      child: Text(element['Name'], style: textStyle,),
    );
    itemsList.add(simpleDialogOption);
  });
  return itemsList;
}

/// Dropdown용 아이템 생성 Function
List<DropdownMenuItem> makeDropdownMenuItem(BuildContext context, String div, var jsondata, String selectedvalue) {
  List<DropdownMenuItem> itemsList = [];
  var textStyle = const TextStyle(color: Colors.blueAccent);
  if(div.substring(0, 6) == "Select") {
    if(div == "Select_Company") jsondata = selectCompanyList;
    else jsondata = selectList;
    jsondata['Table'].forEach((element) {
      if(selectedvalue == element['Code'])textStyle = const TextStyle(color: Colors.blueAccent);
      else textStyle = const TextStyle(color: Colors.black);
      Widget dropdownMenuItem = DropdownMenuItem(
        child: Text(element['Name'], style:textStyle,),
        value: element['Code'],
      );
      itemsList.add(dropdownMenuItem);
    });
  }
  else {
    jsondata['Table'].forEach((element) {
      if(selectedvalue == element['Code'])textStyle = const TextStyle(color: Colors.blueAccent);
      else textStyle = const TextStyle(color: Colors.black);
      Widget dropdownMenuItem = DropdownMenuItem(
        child: Text(element['Name'], style:textStyle,),
        value: element['Code'],
      );
      itemsList.add(dropdownMenuItem);
    });
  }

  return itemsList;
}

/// Background Process
void onStart() {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  service.onDataReceived.listen((event) {
    if (event["action"] == "setAsForeground") { service.setForegroundMode(true); return; }
    if (event["action"] == "setAsBackground") { service.setForegroundMode(false); }
    if (event["action"] == "stopService") { service.stopBackgroundService(); }
  });

  // bring to foreground
  service.setForegroundMode(true);

  Timer.periodic(Duration(seconds: 10), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();
    service.setNotificationInfo(
      title: "Jahwa Mobile Notify Center",
      content: "Do not Turn off this Notification Process!!!",
    );

    await systemNotification();
  });
}

/// Get System Notification !!!
Future<bool> systemNotification() async {
  SharedPreferences prefs = await SharedPreferences.getInstance(); /// SharedPreferences를 사용하기 위한 변수선언
  session['EmpCode'] = prefs.getString('EmpCode') ?? '';

  if(session['EmpCode'] != "") {
    try {

      // Login API Url
      var url = 'https://jhapi.jahwa.co.kr/Notice';

      // Send Parameter
      var data = {'page': '1', 'pagerowcount' : '9999999999', 'div' : 'Notify', 'empcode' : session['EmpCode']};

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 15)).then<bool>((http.Response response) {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ return false; }
        if(response.statusCode == 200){
          if(jsonDecode(response.body)['Table'].length != 0) {
            jsonDecode(response.body)['Table'].forEach((element) {
              showNotification(element['Title'].toString(), element['Contents'].toString());
            });
          }
          return true;
        }
        else{ return false; }
      });
    }
    catch (e) {
      print("get Notiofy Error : " + e.toString());
      return false;
    }
  }
}

/// Check Notice And Move Notice Page !!!
Future<bool> checkNotice(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance(); /// SharedPreferences를 사용하기 위한 변수선언
  session['EmpCode'] = prefs.getString('EmpCode') ?? '';

  if(session['EmpCode'] != "") {
    try {

      // Login API Url
      var url = 'https://jhapi.jahwa.co.kr/Notice';

      // Send Parameter
      var data = {'page': '1', 'pagerowcount' : '9999999999', 'div' : 'New', 'empcode' : session['EmpCode']};

      return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 15)).then<bool>((http.Response response) {
        if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ return false; }
        if(response.statusCode == 200){
          if(jsonDecode(response.body)['Table'].length != 0) {
            Navigator.pushNamed(context, '/Notice');
            ///print('Move Notice Page!!!');
          }
          return true;
        }
        else{ return false; }
      });
    }
    catch (e) {
      print("get Notiofy Error : " + e.toString());
      return false;
    }
  }
}

/// Notification, iOS는 아직 세팅되지 않음
Future<void> showNotification(var title, var content) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var rng = new Random();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);

  AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('Id', 'Name', 'Description', importance: Importance.max, priority: Priority.high, ticker: 'ticker', enableLights: true, color: const Color.fromARGB(255, 0, 255, 0), ledColor: const Color.fromARGB(255, 255, 255, 255), ledOnMs: 1000, ledOffMs: 500, styleInformation: BigTextStyleInformation(''));
  IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
  NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(rng.nextInt(1000000), title, content, platformChannelSpecifics, payload: 'Notification'); // Id를 Random으로 생성하여 중복되지 않도록 처리하면 각 메시지가 별도로 나타난다.
}

/// Notification 클릭시 해당 프로그램의 실행여부 판단하여 실행시킴
Future selectNotification(String payload) async {
  bool isInstalled = await DeviceApps.isAppInstalled('kr.co.jahwa.jahwa_mobile_working_center');
  if (isInstalled != false) DeviceApps.openApp('kr.co.jahwa.jahwa_mobile_working_center');
  else {
    StoreRedirect.redirect(
        androidAppId: "kr.co.jahwa.jahwa_mobile_working_center"
    );
    ///await showNotification('Alert', 'ERROR : Can not Open JH Mobile !!!');
  }
}

Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
  bool isInstalled = await DeviceApps.isAppInstalled(
      'kr.co.jahwa.jahwa_mobile_working_center');
  if (isInstalled != false)
    DeviceApps.openApp('kr.co.jahwa.jahwa_mobile_working_center');
  else {
    StoreRedirect.redirect(
        androidAppId: "kr.co.jahwa.jahwa_mobile_working_center"
    );
    ///await showNotification('Alert', 'ERROR : Can not Open JH Mobile !!!');
  }
}

/// Remove User SharedPreferences
Future<void> removeUserSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('DueDate');
}

/// Show Confirm Message Box Function
showConfirmMessageBox(BuildContext context, String message, String div, String args) {
  /// set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel", style: TextStyle(fontFamily: "Malgun", color: Colors.blueAccent,),),
    onPressed:  () {Navigator.of(context).pop();},
  );
  Widget continueButton = FlatButton(
    child: Text("Continue", style: TextStyle(fontFamily: "Malgun", color: Colors.blueAccent,),
    ),
    onPressed:  () {
      Navigator.of(context).pop();
      /// By div call each Function, args has many argument data Join by '♭', Level 2 Join by '♪', Level 3 Join by '♬'
      /// String으로 Function Name을 호출하는 방법을 몰라 현재로서는 각개별로 생성 필요
      if(div == "") { showMessageBox(context, 'Alert', "Test Message Box"); }
    },
  );

  /// set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Confirm"),
    content: Text(translateText(context, message)),
    titleTextStyle: TextStyle(fontFamily: "Malgun", color: Colors.black, fontWeight: FontWeight.bold,),
    contentTextStyle: TextStyle(fontFamily: "Malgun", color: Colors.black,),
    actions: [ cancelButton, continueButton, ],
  );

  /// show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) { return alert; },
  );
}

/// Show Message Box Function
showMessageBox(BuildContext context, String title, String message) {
  /// set up the button
  Widget okButton = FlatButton(
    child: Text("Okay", style: TextStyle(fontFamily: "Malgun", color: Colors.blueAccent,), ),
    onPressed: () {Navigator.of(context).pop();},
  );

  /// set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(translateText(context, message)),
    titleTextStyle: TextStyle(fontFamily: "Malgun", color: Colors.black, fontWeight: FontWeight.bold,),
    contentTextStyle: TextStyle(fontFamily: "Malgun", color: Colors.black,),
    actions: [ okButton, ],
  );

  /// show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) { return alert; },
  );
}

/// Show Select Message Box Function
showSelectMessageBox(BuildContext context, String message, String buttonname, String div, String args) {
  /// set up the buttons
  Widget aButton = FlatButton(
    child: Text(buttonname.split('♭')[0]), // Button Name Join by '♭'
    onPressed:  () {
      Navigator.of(context).pop();
      /// By div call each Function, args has many argument data Join by '♭', Level 2 Join by '♪', Level 3 Join by '♬'
      /// String으로 Function Name을 호출하는 방법을 몰라 현재로서는 각개별로 생성 필요
      if(div == "") { showMessageBox(context, 'Alert', "Test Message Box"); }
    },
  );
  Widget cancelButton = FlatButton(
    child: Text("Cancel", style: TextStyle(fontFamily: "Malgun", color: Colors.blueAccent,),),
    onPressed:  () {Navigator.of(context).pop();},
  );
  Widget bButton = FlatButton(
    child: Text(buttonname.split('♭')[1], style: TextStyle(fontFamily: "Malgun", color: Colors.blueAccent,),), /// Button Name Join by '♭'
    onPressed:  () {
      Navigator.of(context).pop();
      /// By div call each Function, args has many argument data Join by '♭', Level 2 Join by '♪', Level 3 Join by '♬'
      /// String으로 Function Name을 호출하는 방법을 몰라 현재로서는 각개별로 생성 필요
      if(div == "") { showMessageBox(context, 'Alert', "Test Message Box"); }
    },
  );

  /// set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Notice"),
    content: Text(translateText(context, message)),
    titleTextStyle: TextStyle(fontFamily: "Malgun", color: Colors.black, fontWeight: FontWeight.bold,),
    contentTextStyle: TextStyle(fontFamily: "Malgun", color: Colors.black,),
    actions: [
      aButton,
      cancelButton,
      bButton,
    ],
  );

  /// show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) { return alert; },
  );
}

/// DD 번역 Function
String translateText(BuildContext context, String key) {
  String text = key;
  try {
    text = languagedata[key];
    if(text == null) text = key;
  }
  catch (e) {
    print("translateText Error : " + e.toString());
  }
  return text;
}

/// Get System Notification !!!
Future<bool> getSelectList(String div) async {
  try {

    // Login API Url
    var url = 'https://jhapi.jahwa.co.kr/SelectList';

    // Send Parameter
    var data = {'database': '', 'div' : div, 'data' : '', 'empcode' : session['EmpCode']};

    return await http.post(Uri.parse(url), body: json.encode(data), headers: {"Content-Type": "application/json"}).timeout(const Duration(seconds: 15)).then<bool>((http.Response response) {
      if(response.statusCode != 200 || response.body == null || response.body == "{}" ){ return false; }
      if(response.statusCode == 200){
        if(jsonDecode(response.body)['Table'].length != 0) {
          if(div == "Company") selectCompanyList = jsonDecode(response.body);
          else selectList = jsonDecode(response.body);
        }
        return true;
      }
      else{ return false; }
    });
  }
  catch (e) {
    print("get Select List Error : " + e.toString());
    return false;
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
  }
}
