import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jahwa_mobile_groupware/util/common.dart';
import 'package:jahwa_mobile_groupware/util/globals.dart';

ProgressDialog pr; /// 0. Progress Dialog Declaration

class MenuApp extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuApp> {
  @override
  Widget build(BuildContext context) {

    final List<MenuData> menu = [
      MenuData("assets/image/attend.png", '근태관리', '/Attend'),
      MenuData("assets/image/approve.png", '전자결재', '/Document'),
      MenuData("assets/image/pay.png", '급여조회', '/Pay'),
      MenuData("assets/image/annual.png", '연차조회', '/Annual'),
    ];

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
                            '  ' + 'Menu',
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
                  child: GridView.count(
                    padding: EdgeInsets.all(10),
                    crossAxisCount: 3,
                    children: List.generate(4, (index) {
                      return Center(
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: screenWidth * 0.18,
                                child:GestureDetector(
                                  child: Image.asset(menu[index].image),
                                  onTap: () {
                                    Navigator.pushNamed(context, menu[index].name);
                                  },
                                )
                              ),
                              Text(
                                  menu[index].title,
                                  style: TextStyle(fontSize: 14),
                              )
                            ],
                          )
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MenuData {
  MenuData(this.image, this.title, this.name);

  final String image;
  final String title;
  final String name;
}