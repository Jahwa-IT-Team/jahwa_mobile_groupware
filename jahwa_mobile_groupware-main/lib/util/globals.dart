import 'dart:convert';
import 'dart:ui' as ui;

/// Check Box Test Data
var checkboxlist = { "Table" : [ { "Code" : "ko", "Name" : "Korean", "Value" : true }, { "Code" : "vi", "Name" : "Vietnamese", "Value" : false }, { "Code" : "zh", "Name" : "Chinese", "Value" : false }, { "Code" : "en", "Name" : "English", "Value" : false } ] };

/// Language
var language = ui.window.locale.languageCode;
var languagedata = {};
var languagelist = { "Table" : [ { "Code" : "ko", "Name" : "Korean" }, { "Code" : "vi", "Name" : "Vietnamese" }, { "Code" : "zh", "Name" : "Chinese" }, { "Code" : "en", "Name" : "English" } ] };

/// Select
var selectCompanyList = {}; /// 회사리스트
var selectList = {};

/// Menu
var menudata = jsonDecode('{"Table":[{"id":"Root","title":"Root","parentId":"1","icon":"","url":""},{"id":"Jims","title":"JIMS","parentId":"Root","icon":"tv","url":"/Jims"},{"id":"Jims03","title":"Human Resource","parentId":"Jims","icon":"users","url":""},{"id":"Jims0301","title":"H/R Dashboard","parentId":"Jims03","icon":"circle","url":"/JimsHRDashboard"},{"id":"Email","title":"Email","parentId":"Root","icon":"solidEnvelope","url":""},{"id":"Email03","title":"GW Mail","parentId":"Email","icon":"circle","url":"/EmailGW"},{"id":"ESign","title":"Electronic Approval","parentId":"Root","icon":"paste","url":""},{"id":"ESign01","title":"Compose an Approval Document","parentId":"ESign","icon":"circle","url":"/ESignNew"},{"id":"ESign02","title":"User Document Box","parentId":"ESign","icon":"circle","url":""},{"id":"ESign0201","title":"PreApproval Box","parentId":"ESign02","icon":"caretRight","url":"/ESignPreAppBox"},{"id":"ESign0202","title":"UnApproved Box","parentId":"ESign02","icon":"caretRight","url":"/ESignUnAppBox"},{"id":"ESign0203","title":"OnGoing Box","parentId":"ESign02","icon":"caretRight","url":"/ESignOnGoingBox"},{"id":"ESign0204","title":"Managed Box","parentId":"ESign02","icon":"caretRight","url":"/ESignManabedBox"},{"id":"ESign0205","title":"Reference / Circulation Box","parentId":"ESign02","icon":"caretRight","url":"/ESignRefBox"},{"id":"ESign0206","title":"Cooperation Box","parentId":"ESign02","icon":"caretRight","url":"/ESignCoopBox"},{"id":"ESign0207","title":"Rejected Box","parentId":"ESign02","icon":"caretRight","url":"/ESignRejectBox"},{"id":"ESign0208","title":"Temporary Box","parentId":"ESign02","icon":"caretRight","url":"/ESignTempBox"},{"id":"ESign0209","title":"Responsible Box","parentId":"ESign02","icon":"caretRight","url":"/ESignResponseBox"},{"id":"ESign0210","title":"Favorite Site","parentId":"ESign02","icon":"caretRight","url":"/ESignFavoriteSite"},{"id":"ESign03","title":"Department Document Box","parentId":"ESign","icon":"circle","url":""},{"id":"ESign0301","title":"Consultation Box","parentId":"ESign03","icon":"caretRight","url":"/ESignConsultBox"},{"id":"ESign0302","title":"Sent Box","parentId":"ESign03","icon":"caretRight","url":"/ESignSentBox"},{"id":"ESign0303","title":"Received Box","parentId":"ESign03","icon":"caretRight","url":"/ESignReceivedBox"},{"id":"ESign0304","title":"Reference / Circulation Box","parentId":"ESign03","icon":"caretRight","url":"/ESignDeptRefBox"},{"id":"ESign04","title":"Setting","parentId":"ESign","icon":"circle","url":""},{"id":"ESign0401","title":"Electric Approval Setting","parentId":"ESign04","icon":"caretRight","url":"/ESignAppSetting"},{"id":"ESign0402","title":"Approval Line Management","parentId":"ESign04","icon":"caretRight","url":"/ESignAppLine"},{"id":"WorkPlan","title":"Work Plan","parentId":"Root","icon":"solidCalendarAlt","url":""},{"id":"WorkPlan01","title":"Weekly Schedule","parentId":"WorkPlan","icon":"circle","url":"/WorkPlanSchedule"},{"id":"WorkPlan02","title":"Weekly Report","parentId":"WorkPlan","icon":"circle","url":""},{"id":"WorkPlan0201","title":"Weekly Report Insert","parentId":"WorkPlan02","icon":"caretRight","url":"/WorkPlanInsert"},{"id":"WorkPlan0202","title":"Weekly Report View","parentId":"WorkPlan02","icon":"caretRight","url":"/WorkPlanView"},{"id":"WorkPlan0203","title":"Instructions","parentId":"WorkPlan02","icon":"caretRight","url":"/WorkPlanInstruct"},{"id":"WorkPlan0204","title":"Substitute writer","parentId":"WorkPlan02","icon":"caretRight","url":"/WorkPlanSubWriter"},{"id":"WorkPlan0205","title":"Weekly Report Close","parentId":"WorkPlan02","icon":"caretRight","url":"/WorkPlanClose"},{"id":"WorkPlan0206","title":"Exclusion Department","parentId":"WorkPlan02","icon":"caretRight","url":"/WorkPlanExcluDept"},{"id":"Vehicle","title":"Vehicle","parentId":"Root","icon":"car","url":""},{"id":"Vehicle01","title":"Write Vehicle Journal","parentId":"Vehicle","icon":"circle","url":"/VehicleWrite"},{"id":"Vehicle02","title":"Vehicle Journal List","parentId":"Vehicle","icon":"circle","url":"/VehicleJournal"}]}');

/// Screen Size
var screenWidth = 100.0;
var screenHeight = 100.0;
var statusBarHeight = 24.0;
var appBarHeigight = 56.0;

/// Session
var session = {
  'EntCode' : '', 'EntName' : '',
  'DeptCode' : '', 'DeptName' : '',
  'EmpCode' : '', 'Name' : '',
  'RollPstn' : '', 'Position' : '',
  'Role' : '', 'Title' : '',
  'PayGrade' : '', 'Level' : '',
  'Email' : '', 'Photo' : '',
  'Auth' : "0", 'EntGroup' : '',
  'OfficeTel' : '', 'Mobile' : '',
  'DueDate' : ''
};

/// User Info Map - Login
class User {
  final String EntCode; final String EntName;
  final String DeptCode; final String DeptName;
  final String EmpCode; final String Name;
  final String RollPstn; final String Position;
  final String Role; final String Title;
  final String PayGrade; final String Level;
  final String Email; final String Photo;
  final int Auth; final String EntGroup;
  final String OfficeTel; final String Mobile;

  User(this.EntCode, this.EntName, this.DeptCode, this.DeptName, this.EmpCode, this.Name, this.RollPstn, this.Position, this.Role, this.Title, this.PayGrade, this.Level, this.Email, this.Photo, this.Auth, this.EntGroup, this.OfficeTel, this.Mobile);

  User.fromJson(Map<String, dynamic> json)

      : EntCode = json['EntCode'], EntName = json['EntName'],
        DeptCode = json['DeptCode'], DeptName = json['DeptName'],
        EmpCode = json['EmpCode'], Name = json['Name'],
        RollPstn = json['RollPstn'], Position = json['Position'],
        Role = json['Role'], Title = json['Title'],
        PayGrade = json['PayGrade'], Level = json['Level'],
        Email = json['Email'], Photo = json['Photo'],
        Auth = json['Auth'], EntGroup = json['EntGroup'],
        OfficeTel = json['OfficeTel'], Mobile = json['Mobile'];

  Map<String, dynamic> toJson() =>
      {
        'EntCode' : EntCode, 'EntName' : EntName,
        'DeptCode' : DeptCode, 'DeptName' : DeptName,
        'EmpCode' : EmpCode, 'Name' : Name,
        'RollPstn' : RollPstn, 'Position' : Position,
        'Role' : Role, 'Title' : Title,
        'PayGrade' : PayGrade, 'Level' : Level,
        'Email' : Email, 'Photo' : Photo,
        'Auth' : Auth, 'EntGroup' : EntGroup,
        'OfficeTel' : OfficeTel, 'Mobile' : Mobile,
      };
}

/// 캘린더용 변수
var year = DateTime.now().year;
var day = "";

/// 비밀번호 초기화용 변수
var resetpass = {"Table": [{ "company" : "", "empcode" : "", "name" : "", "question1" : "", "question2" : "" }]};
var messagenum = "";

/// 전자결재 문서형식 변수
var GWType = "";
var GWTypeNm = "";

///게시판 변수
var BbsCode = "";
var BbsNum = "";
var BbsTitle = "";
var BbsContents = "";