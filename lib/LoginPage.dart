import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:http/http.dart' as http;
import 'package:marine_app/contain/MyContainUtils.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:marine_app/common/AppConst.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/rendering.dart';

class MyLoginWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyLoginState();
}

class MyLoginState extends State<MyLoginWidget> with TickerProviderStateMixin {
  final scaffoldState = GlobalKey<ScaffoldState>();
  var demonPlugin = new MethodChannel('marine.plugin');

  DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();
  AppLifecycleState _lastLifecycleState;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  String _userPhone;
  String _passWold;
  String _token;
  int _id;
  bool select = false;
  bool _isLoading = false;

  //写数据
  Future<Null> _savaDate2DB() async {
    String dbPath = await marineUser.createNewDb();
    Map uMap = await marineUser.getFirstData(dbPath);
    String flag = "0";
    if (select) {
      flag = "1";
    }
    if (uMap == null) {
      DBUtil.MarineUser mUser = new DBUtil.MarineUser();
      mUser.name = _userPhone;
      mUser.pwd = _passWold;
      mUser.flag = flag;
      mUser.token = _token;
      await marineUser.insert(mUser.toMap(), dbPath);
    } else {
      DBUtil.MarineUser mUser = DBUtil.MarineUser.fromMap(uMap);
      mUser.name = _userPhone;
      mUser.pwd = _passWold;
      mUser.flag = flag;
      mUser.token = _token;
      await marineUser.update(mUser.toMap(), dbPath);
    }
  }

  AnimationController animationController;
  final TextEditingController userNameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    getDataForSql().then((dataMap) {
      if (null != dataMap) {
        setState(() {
          _userPhone = dataMap[DBUtil.columnName];
          _passWold = dataMap[DBUtil.columnPwd];
          String _flag = dataMap[DBUtil.columnFlag];
          if (_flag == null || _flag.isEmpty || _flag == '0') {
            select = false;
            _userPhone = '';
            _passWold = '';
          } else {
            select = true;
          }
          _id = dataMap[DBUtil.columnId];
          userNameController.text = _userPhone;
          passwordController.text = _passWold;
        });
      }
    });
  }

  Future<Map> getDataForSql() async {
    String dbPath = await marineUser.createNewDb();
    await marineUser.createTable(dbPath);
    Map uMap = await marineUser.getFirstData(dbPath);
    return uMap;
  }

  _launchURL() async {
    const url = 'tel:13764204000';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<bool> _Login(
      String userName, String password, BuildContext context) async {
    if (null == userName || userName.isEmpty) {
      Fluttertoast.showToast(
          msg: '请输入用户名',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xFF499292),
          textColor: Color(0xFFFFFFFF));
      return false;
    }

    if (null == password || password.isEmpty) {
      Fluttertoast.showToast(
          msg: '请输入密码',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xFF499292),
          textColor: Color(0xFFFFFFFF));
      return false;
    }

    setState(() {
      _isLoading = true;
    });
    String url = marineURL.LoginUrl;
    bool result;
    try {
      Map _params = {'UserName': userName, 'Password': password};
      Map<String, String> headers = {
        'OsName': Platform.operatingSystem.toUpperCase()
      };
      result = await http
          .post(url, body: _params, headers: headers)
          .then((http.Response response) {
        var data = json.decode(response.body);
        print('请求报文:body:$_params');
        print('请求报文:headers:$headers');
        print('响应报文:$data');
        int type = data[AppConst.RESP_CODE];
        String rescode = '$type';
        String resMsg = data[AppConst.RESP_MSG];
        if (rescode != '10') {
          String _msg = '登录失败';
          if (resMsg != null) {
            _msg = "登录失败[$resMsg]";
          }
          setState(() {
            _isLoading = false;
          });
          Fluttertoast.showToast(
              msg: _msg,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF));
        } else {
          setState(() {
            var content = json.decode(data[AppConst.RESP_DATA]);
            _token = content['token'];
          });
          _savaDate2DB();
          var _duration = new Duration(seconds: 1);
          new Future.delayed(_duration, () {
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context)
                .pushReplacementNamed('/HomePage', result: _token);
            Fluttertoast.showToast(
                msg: "  登录成功！ ",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Color(0xFF499292),
                textColor: Color(0xFFFFFFFF));
          });
        }
      });
    } catch (e) {
      print(e);
      return result;
    }

    return result;
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lastLifecycleState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height_screen = MediaQuery.of(context).size.height;
    final width_srcreen = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: scaffoldState,
      backgroundColor: Colors.white,
      body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: new Container(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              new Container(
                alignment: Alignment.topCenter,
                child: MyContainUtils(""),
              ),
              Card(
                color: Colors.white70,
                margin: EdgeInsets.only(
                    top: 190.0, right: 50.0, left: 50.0, bottom: 90.0),
                elevation: 11.0,
                child: Container(
                  alignment: Alignment.center,
                  width: width_srcreen - 120,
                  child: new Container(
                    margin: new EdgeInsets.all(16.0),
                    child: ListView(
                      children: <Widget>[
                        new SizedBox(
                          height: 30.0,
                        ),
                        new TextField(
                          controller: userNameController,
                          onChanged: (phone) => _userPhone = phone,
                          style: new TextStyle(
                              fontSize: 15.0, color: Colors.black),
                          decoration: new InputDecoration(
                              icon: Icon(Icons.person),
                              hintText: '请输入您的用户名',
                              labelText: "用户名",
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13.0),
                              hintStyle: TextStyle(fontSize: 12.0)),
                        ),
                        new SizedBox(
                          height: 10.0,
                        ),
                        new TextField(
                          controller: passwordController,
                          obscureText: true,
                          onChanged: (world) => _passWold = world,
                          style: new TextStyle(
                              fontSize: 15.0, color: Colors.black),
                          decoration: new InputDecoration(
                              icon: Icon(Icons.lock),
                              hintText: '请输入您的密码',
                              labelText: "密码",
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13.0),
                              hintStyle: TextStyle(fontSize: 12.0)),
                        ),
                        new SizedBox(
                          height: 15.0,
                        ),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            InkWell(
                              child: new Container(
                                alignment: Alignment.center,
                                child: new Row(
                                  children: <Widget>[
                                    new Text(
                                      '记住密码',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    new SizedBox(
                                      width: 20.0,
                                      child: new Checkbox(
                                          value: select,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.padded,
                                          onChanged: (bool cb) {
                                            setState(() {
                                              select = cb;
                                            });
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _launchURL();
                              },
                              child: Text(
                                '忘记密码?',
                                style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        new SizedBox(
                          height: 1.0,
                        ),
                        Material(
                          elevation: 10.0,
                          color: Colors.transparent,
                          shape: const StadiumBorder(),
                          child: InkWell(
                            onTap: () {
                              _Login(this._userPhone, this._passWold, context);
                            },
                            splashColor: Colors.purpleAccent,
                            child: Ink(
                              height: 40.0,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                colors: <Color>[
                                  AppConst.appColor,
                                  Colors.green
                                ],
                              )),
                              child: Center(
                                child: Text(
                                  '登  录',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _loadingContainer(),
            ],
          ),
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              begin: const FractionalOffset(0.5, 0.0),
              end: const FractionalOffset(0.5, 1.0),
              colors: <Color>[Colors.white, AppConst.appColor],
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingContainer() {
    return !_isLoading
        ? SizedBox(height: 1.0)
        : Container(
            constraints: BoxConstraints.expand(),
            color: Colors.black12,
            child: Center(
              child: Opacity(
                opacity: 0.9,
                child: SpinKitCircle(
                  color: Colors.blueAccent,
                  size: 50.0,
                ),
              ),
            ));
  }
}
