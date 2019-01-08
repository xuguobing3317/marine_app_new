import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:marine_app/common/AppConst.dart';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marine_app/busi/MemberCenter.dart';

class ModifyPwdPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ModifyPwdPageState();
}

class ModifyPwdPageState extends State<ModifyPwdPage> {
  String oldPwd = ""; //老密码
  String newPwd1 = ""; //新密码
  String newPwd2 = ""; //新密码
  DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('密码修改'),
        backgroundColor: Colors.greenAccent,
      ),
      body: new SingleChildScrollView(
        child: new ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: 200.0,
            ),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                geneColumn(_geneOtherNo('老密码', '请输入老密码', 'oldPwd'), _div()),
                geneColumn(_geneOtherNo('新密码', '请输入新密码', 'newPwd1'), _div()),
                geneColumn(_geneOtherNo('确认新密码', '请确认新密码', 'newPwd2'), _div()),
                geneColumn(_button2('', '')),
              ],
            )),
      ),
    );
  }

  Widget _div() {
    return new Container(
      height: 1.0,
      child: new Divider(
        color: Colors.greenAccent,
      ),
    );
  }

  Widget geneColumn(Widget w1, [Widget w2]) {
    return new Container(
      child: new Column(
        children: <Widget>[w1, null == w2 ? new Container() : w2],
      ),
    );
  }

  Widget _geneOtherNo(_title, _title2, _key, {Widget w3}) {
    return new Container(
      color: Colors.white70,
      height: 40.0,
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              width: 100.0,
              child: new Text(
                '$_title:',
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black45,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: new Container(
                alignment: Alignment.center,
                child: new TextField(
                  onChanged: (world) {
                    if (_key == 'oldPwd') {
                      oldPwd = world;
                    } else if (_key == 'newPwd1') {
                      newPwd1 = world;
                    } else {
                      newPwd2 = world;
                    }
                  },
                  style: new TextStyle(fontSize: 15.0, color: Colors.black),
                  decoration: new InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    hintText: '$_title2 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 13.0),
                    hintStyle: TextStyle(fontSize: 12.0),
                  ),
                ),
              ),
            ),
            null == w3
                ? new Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_enhance,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      onPressed: null,
                    ),
                  )
                : w3
          ]),
    );
  }

  Widget _button2(_title, _key, {Widget w3}) {
    return new Container(
      color: Colors.white70,
      height: 50.0,
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              width: 50.0,
              child: new Text(
                '$_title',
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black45,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
                child: new Container(
              padding: new EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 1.0),
              child: new RaisedButton(
                color: Colors.greenAccent,
                textTheme: ButtonTextTheme.normal,
                elevation: 10,
                highlightElevation: 10,
                disabledElevation: 10,
                child: new Text(
                  '确 认',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0),
                ),
                onPressed: _forSubmitted,
              ),
            )),
            null == w3
                ? new Container(
                    width: 50.0,
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_enhance,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      onPressed: null,
                    ),
                  )
                : w3
          ]),
    );
  }

  Future<bool> _forSubmitted() async {
    bool result = false;
    try {
      if (oldPwd == '') {
        Fluttertoast.showToast(
            msg: " 请输入原始密码 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return false;
      }

      if (newPwd1 == '') {
        Fluttertoast.showToast(
            msg: " 请输入新密码 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return false;
      }

      if (newPwd2 == '') {
        Fluttertoast.showToast(
            msg: " 请确认新密码 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return false;
      }

       if (newPwd1 != newPwd2) {
        Fluttertoast.showToast(
            msg: " 密码不一致 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return false;
      }

      String dbPath = await marineUser.createNewDb();
      Map uMap = await marineUser.getFirstData(dbPath);
      if (uMap == null) {
        Navigator.of(context).pushReplacementNamed('/LoginPage');
      }

      String url = marineURL.ModifyPwdUrl;
      Map<String, String> _params = {
        'oldPassword': oldPwd,
        'newPassword': newPwd1
      };
      DBUtil.MarineUser mUser = DBUtil.MarineUser.fromMap(uMap);
      String _token = mUser.token;
      Map<String, String> _header = {'token': _token};
      result = await http
          .post(url, body: _params, headers: _header)
          .then((http.Response response) {
        var data = json.decode(response.body);

        print('body:$_params');
      print('headers:$_header');
      print('data:$data');
        int type = data[AppConst.RESP_CODE];
        String rescode = '$type';
        String resMsg = data[AppConst.RESP_MSG];
        if (rescode == '14') {
         Navigator.of(context).pushReplacementNamed('/LoginPage');
          Fluttertoast.showToast(
              msg: "  登录超时， 请重新登录！",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF));
        } else if (rescode == '10') {
        Navigator.push(context,
          new MaterialPageRoute(builder: (context) => MemberCenter()));
          Fluttertoast.showToast(
              msg: "  修改成功！ ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF));
        }else{
           Fluttertoast.showToast(
              msg: " 修改失败[$resMsg]",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF));
          return false;
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "  修改失败！ ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Color(0xFF499292),
          textColor: Color(0xFFFFFFFF));
      return false;
    }
    return true;
  }
}
