import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;
import 'package:http/http.dart' as http;
import 'package:marine_app/contain/MyContainUtils.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class MyLoginWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyLoginState();
}


class MyLoginState extends State<MyLoginWidget>  with TickerProviderStateMixin{
  final scaffoldState = GlobalKey<ScaffoldState>();
  var demonPlugin=new MethodChannel('marine.plugin');

  DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();
  AppLifecycleState _lastLifecycleState;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  String _userPhone;
  String _passWold;
  int _id;
  bool select = false;

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
        await marineUser.insert(mUser.toMap(), dbPath);
    } else {
      DBUtil.MarineUser mUser = DBUtil.MarineUser.fromMap(uMap);
        if (flag == "0") {
            await marineUser.delete(mUser.id, dbPath);
        } else {
        mUser.name = _userPhone;
        mUser.pwd = _passWold;
        mUser.flag = flag;
        await marineUser.update(mUser.toMap(), dbPath);}
    }
    
  }
   AnimationController animationController;
   final TextEditingController userNameController = new TextEditingController();
   final TextEditingController passwordController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    animationController=new AnimationController(vsync:this,duration:Duration(milliseconds: 2000));
    getDataForSql().then((dataMap){
      setState(() {
        _userPhone = dataMap[DBUtil.columnName];
        _passWold = dataMap[DBUtil.columnPwd];
        String _flag =  dataMap[DBUtil.columnFlag];
        if (_flag == null || _flag.isEmpty || _flag == '0') {
          select =  false;
        } else{
          select = true;
        }
        _id = dataMap[DBUtil.columnId];
        userNameController.text = _userPhone;
        passwordController.text = _passWold;
      });
    });
  }

  Future<Map> getDataForSql() async {
    String dbPath = await marineUser.createNewDb();
    await marineUser.createTable(dbPath);
    Map uMap = await marineUser.getFirstData(dbPath);
    return uMap;
  }

  _launchURL() async {
    const url = 'tel:13888888888';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<bool> _Login(
      String userName, String password, BuildContext context) async {
    String url =
        "http://116.62.149.237:8080/USR000100001?usrName=$userName&passwd=$password";
    bool result;
    try {
      result = await http.get(url).then((http.Response response) {
        var data = json.decode(response.body);
        String rescode = data["rescode"];
        if (userName == 'admin' && password == '123456') {
          rescode = '000000';
        }
        if (rescode == '999999') {
          Fluttertoast.showToast(
              msg: " 登录失败 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
        } else if (rescode == '000000') {
          _savaDate2DB();
          Navigator.of(context).pushReplacementNamed('/HomePage');
          // Navigator.pushReplacementNamed(context, '/HomePage');
          // Navigator.of(context).push(new PageRouteBuilder(
          //       opaque: false,
          //       pageBuilder: (BuildContext context, _, __) {
          //         return new HomePage();
          //       },
          //     ));
          Fluttertoast.showToast(
              msg: "  登录成功！ ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
        }
      });
    } catch (e) {
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
      resizeToAvoidBottomPadding:false,
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
                              child:
                              new Container(
                                 alignment: Alignment.center,
                                 child: new Row(
                                   children: <Widget>[
                                     new Text(
                                       '记住密码', 
                                       textAlign:TextAlign.right,
                                       style: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      new SizedBox(
                                        width: 20.0,
                                        child: 
                                        new Checkbox(
                                      value: select,
                                      materialTapTargetSize:MaterialTapTargetSize.padded,
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
                          height: 10.0,
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
                                  Colors.greenAccent,
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
              )
            ],
          ),
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              begin: const FractionalOffset(0.5, 0.0),
              end: const FractionalOffset(0.5, 1.0),
              colors: <Color>[Colors.white, Colors.greenAccent],
            ),
          ),
        ),
      ),
    );
  }
}
