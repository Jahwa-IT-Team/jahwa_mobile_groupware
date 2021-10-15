import 'package:flutter/material.dart';

import 'package:jahwa_mobile_groupware/check.dart';
import 'package:jahwa_mobile_groupware/login.dart';
import 'package:jahwa_mobile_groupware/notice.dart';
import 'package:jahwa_mobile_groupware/index.dart';

import 'package:jahwa_mobile_groupware/mail/email_gw.dart';

import 'package:jahwa_mobile_groupware/util/update.dart';
import 'package:jahwa_mobile_groupware/util/check_employee.dart';
import 'package:jahwa_mobile_groupware/util/reset_password.dart';
import 'package:jahwa_mobile_groupware/util/reset_password_question.dart';
import 'package:jahwa_mobile_groupware/util/reset_password_mobile.dart';

import 'package:jahwa_mobile_groupware/menu/attend.dart';
import 'package:jahwa_mobile_groupware/menu/approve.dart';
import 'package:jahwa_mobile_groupware/menu/pay.dart';
import 'package:jahwa_mobile_groupware/menu/annual.dart';
import 'package:jahwa_mobile_groupware/menu/document.dart';

final routes = {
  /// Basic Program
  '/' : (BuildContext context) => Check(), /// 기본으로 main -> check -> update, login or index page로 이동
  '/Update' : (BuildContext context) => Update(), /// Android Update Apk Download Page로 이동, IOS 미지원
  '/Login' : (BuildContext context) => Login(),
  '/Notice' : (BuildContext context) => Notice(),
  '/Index' : (BuildContext context) => Index(), /// 기본 Page -> 설계 필요

  '/CheckEmployee' : (BuildContext context) => CheckEmployee(), /// 사원확인
  '/ResetPassword' : (BuildContext context) => ResetPassword(), /// 비밀번호 초기화 관리자용
  '/ResetPasswordQuestion' : (BuildContext context) => ResetPasswordQuestion(), /// 비밀번호 초기화 질문답변 인증용
  '/ResetPasswordMobile' : (BuildContext context) => ResetPasswordMobile(), /// 비밀번호 초기화 휴대폰 인증용

  /// menu
  '/Attend' : (BuildContext context) => AttendApp(), ///근태관리
  '/Approve' : (BuildContext context) => ApproveApp(), ///전자결재
  '/Document' : (BuildContext context) => DocumentApp(), ///전자결재
  '/Pay' : (BuildContext context) => PayApp(), ///급여조회
  '/Annual' : (BuildContext context) => AnnualApp(), ///연차조회

  /// Email
  '/EmailGW' : (BuildContext context) => EmailGW(),

};