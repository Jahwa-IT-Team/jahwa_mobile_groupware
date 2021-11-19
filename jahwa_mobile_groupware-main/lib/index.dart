import 'package:flutter/material.dart';

///import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info/package_info.dart';
import 'package:store_redirect/store_redirect.dart';

import 'package:jahwa_mobile_groupware/util/common.dart';
import 'package:jahwa_mobile_groupware/util/globals.dart';
import 'package:jahwa_mobile_groupware/menu.dart';
import 'package:jahwa_mobile_groupware/search.dart';
import 'package:jahwa_mobile_groupware/profile.dart';
import 'package:jahwa_mobile_groupware/home.dart';

class Index extends StatefulWidget {
  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> with SingleTickerProviderStateMixin {
  TabController controller;

  /// Call When Form Init
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
    NewVersion(
      ///iOSId: 'kr.co.jahwa.jahwa_mobile_working_center',
      androidId: 'kr.co.jahwa.jahwa_M',
    ).showAlertIfNecessary(context: context);

    print("open Index Page : " + DateTime.now().toString());
  }  

  @override
  Widget build(BuildContext context) {

    /// Notice가 있는 경우 /Notice로 이동
    //checkNotice(context);

    return Scaffold(
        body: TabBarView(
          children: <Widget>[
            HomeApp(),
            MenuApp(),
            SearchApp(),
            ProfileApp()],
          controller: controller,
        ),
        bottomNavigationBar:TabBar(tabs: <Tab>[
          Tab(icon: Icon(Icons.home, color: Colors.blue),),
          Tab(icon: Icon(Icons.apps, color: Colors.blue),),
          Tab(icon: Icon(Icons.search, color: Colors.blue),),
          Tab(icon: Icon(Icons.person, color: Colors.blue),)
        ],controller: controller,
        )
    );
  }
}


