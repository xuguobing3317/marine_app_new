import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marine_app/HomePage.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:marine_app/common/DateUtil.dart';
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:marine_app/common/AppConst.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;

class RecoverPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecoverPageState();
}

class RecoverPageState extends State<RecoverPage> {
  String _recoverDate = DateUtil.formatDateTime(
      DateUtil.getNowDateStr(), DateFormat.ZH_NORMAL, null, null); //回收日期

  DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();
  String barcode = "";

  String _fomesWeight = "";

  List<PickerItem> rbTypeItems = new List();
  List<Map> rbTypeList = [
    {'rbCode': 'A', 'rbName': '生活垃圾'},
    {'rbCode': 'B', 'rbName': '油污垃圾'}
  ];

  String rbName = '油污垃圾';
  String rbCode = 'B';

  final TextEditingController rbTypeController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      rbTypeController.text = rbName;
      rbTypeList.forEach((item) {
        PickerItem gangkouItem = new PickerItem(text: Text(item['rbName']));
        rbTypeItems.add(gangkouItem);
      });
    });
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _owner = ""; //船舶所有人
  String _count = ""; //次数
  String _recoverWeight = ""; //已回收重量
  String _boatUnit = ""; //船舶吨位
  String _boatBelong = ""; //船集港
  String _boatType = ""; //船舶类型
  String _lastTime = ""; //上次来港

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('污染物回收'),
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
                _geneBoatNo2(_geneBoatNo('船舶编号', barcode, w3: _w3()), _div()),
                _geneBoatNo2(_geneOtherNo2('船舶所有人', _owner), _div()),
                _geneBoatNo2(_geneOtherNo2('入港次数', _count), _div()),
                _geneBoatNo2(_geneOtherNo2('已回收重量', _recoverWeight), _div()),
                _geneBoatNo2(_geneOtherNo2('船舶吨位', _boatUnit), _div()),
                _geneBoatNo2(_geneOtherNo2('船籍港', _boatBelong), _div()),
                _geneBoatNo2(_geneOtherNo2('上次来港', _lastTime), _div()),
                _geneBoatNo2(_geneOtherNo2('船舶类型', _boatType), _div2()),
                _geneBoatNo2(
                    _geneRbTypeNo('污染物种类', 'fomesType', w3: _w5()), _div()),
                _geneBoatNo2(
                    _geneRecoverDate('回收时间', 'recoverDate', w3: _w4()), _div()),
                _geneBoatNo2(_geneOtherNo('重量(KG)', 'fomesWeight'), _div()),
                _geneBoatNo2(_button2('', '')),
              ],
            )),
      ),
    );
  }

  Widget _div2() {
    return new Container(
      color: Colors.greenAccent,
      height: 5.0,
      child: new Divider(),
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

  Widget _geneBoatNo2(Widget w1, [Widget w2]) {
    return new Container(
      child: new Column(
        children: <Widget>[w1, null == w2 ? new Container() : w2],
      ),
    );
  }

  Widget _w3() {
    return IconButton(
      icon: Icon(
        Icons.camera_enhance,
        size: 40.0,
        color: Colors.greenAccent,
      ),
      onPressed: scanCode,
    );
  }

  Widget _w5() {
    return IconButton(
      icon: Icon(
        Icons.restore_from_trash,
        size: 40.0,
        color: Colors.greenAccent,
      ),
      onPressed: showPicker,
    );
  }

  Widget _w4() {
    return IconButton(
      icon: Icon(
        Icons.date_range,
        size: 40.0,
        color: Colors.greenAccent,
      ),
      onPressed: toSetTime,
    );
  }

  Widget _geneOtherNo2(_title, _textValue, {Widget w3}) {
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
                    color: Colors.black38,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: new Container(
                alignment: Alignment.center,
                child: new Text(
                  _textValue,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black38,
                      fontWeight: FontWeight.w400),
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

  Widget _geneOtherNo(_title, _key, {Widget w3}) {
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
                    color: Colors.black38,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: new Container(
                alignment: Alignment.center,
                child: new TextField(
                  // controller: boatController,
                  // focusNode: _focusNode,
                  onChanged: (world) {
                    _fomesWeight = world;
                  },
                  style: new TextStyle(fontSize: 15.0, color: Colors.black),
                  decoration: new InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    hintText: '请输入$_title ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(color: Colors.greenAccent),
                    ),
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 13.0),
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

  showPicker() {
    Picker picker = new Picker(
        adapter: PickerDataAdapter(
          data: rbTypeItems,
        ),
        changeToFirst: true,
        textAlign: TextAlign.left,
        cancelText: '取消',
        cancelTextStyle: TextStyle(color: Colors.greenAccent),
        confirmText: '确定',
        confirmTextStyle: TextStyle(color: Colors.greenAccent),
        textStyle: TextStyle(fontSize: 30.0),
        // hideHeader: true,
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List value) {
          String _value = value[0].toString();
          int index = int.parse(_value);
          setState(() {
            rbName = rbTypeList[index]['rbName'];
            rbCode = rbTypeList[index]['rbCode'];
            rbTypeController.text = rbName;
          });
        });
    picker.showModal(context);
    // picker.show(_scaffoldKey.currentState);
  }

  Widget _geneBoatNo(_title, String _keyValue, {Widget w3}) {
    return new Container(
      color: Colors.white70,
      height: 50.0,
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
                    color: Colors.black38,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: new Container(
                alignment: Alignment.center,
                child: new Text(
                  (_keyValue == null || _keyValue.isEmpty)
                      ? '请扫描二维码'
                      : _keyValue,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black38,
                      fontWeight: FontWeight.w400),
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
                    fontWeight: FontWeight.w500),
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
                  '立  即  回  收',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0),
                ),
                onPressed: () {
                  _forSubmitted('', context);
                },
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

  Widget _geneRecoverDate(_title, _key, {Widget w3}) {
    return new Container(
      color: Colors.white70,
      height: 50.0,
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
                    color: Colors.black38,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: new Container(
                  alignment: Alignment.center,
                  child: new Text(
                    _recoverDate,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black38,
                        fontWeight: FontWeight.w400),
                  )),
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

  Widget _geneRbTypeNo(_title, _key, {Widget w3}) {
    return new Container(
      color: Colors.white70,
      height: 50.0,
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
                    color: Colors.black38,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: new Container(
                alignment: Alignment.center,
                child: new Text(
                  rbName,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black38,
                      fontWeight: FontWeight.w400),
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

  Future<Null> toSetTime() async {
    DatePicker.showDateTimePicker(context, showTitleActions: true,
        onChanged: (date) {
      setState(() {
        _recoverDate =
            DateUtil.getDateStrByDateTime(date, format: DateFormat.NORMAL);
      });
    }, onConfirm: (date) {
      setState(() {
        _recoverDate =
            DateUtil.getDateStrByDateTime(date, format: DateFormat.NORMAL);
      });
    }, locale: LocaleType.zh,
    currentTime:DateUtil.getDateTime(_recoverDate));
  }

  Future<void> queryBoatDetail() async {
    String url = marineURL.GetLastRubishDataUrl;

    Map<String, String> _params = {
      'Carid': barcode,
    };
    String dbPath = await marineUser.createNewDb();
    Map uMap = await marineUser.getFirstData(dbPath);
    if (uMap == null) {
      Navigator.of(context).pushReplacementNamed('/LoginPage');
    }
    DBUtil.MarineUser mUser = DBUtil.MarineUser.fromMap(uMap);
    String _token = mUser.token;
    Map<String, String> _header = {'token': _token};
    await http
        .post(url, body: _params, headers: _header)
        .then((http.Response response) {
      var data = json.decode(response.body);
      print('url:$url');
      print('body:$_params');
      print('headers:$_header');
      print('data:$data');

      int type = data[AppConst.RESP_CODE];
      String rescode = '$type';
      String resMsg = data[AppConst.RESP_MSG];
      if (rescode != '10') {
        String _msg = '未查询到数据[$resMsg]';
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
          print(content);
          _owner = ""; //船舶所有人
          _count = ""; //次数
          _recoverWeight = ""; //已回收重量
          _boatUnit = ""; //船舶吨位
          _boatBelong = ""; //船集港
          _boatType = ""; //船舶类型
          _lastTime = ""; //上次来港
        });
      }
    });
  }

  Future<void> scanCode() async {
    print('开始扫描二位吗');
    try {
      String barcode2 = await BarcodeScanner.scan();

      setState(() {
        barcode = barcode2;
        queryBoatDetail();
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          Fluttertoast.showToast(
              msg: " 请重新扫描 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF));
          return this.barcode = '';
        });
      } else {
        setState(() {
          Fluttertoast.showToast(
              msg: " 请重新扫描 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF));
          return this.barcode = '';
        });
      }
    } on FormatException {
      setState(() {
        Fluttertoast.showToast(
            msg: " 请重新扫描 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return this.barcode = '';
      });
    } catch (e) {
      setState(() {
        Fluttertoast.showToast(
            msg: " 请重新扫描 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return this.barcode = '';
      });
    }
  }

  Future<bool> _forSubmitted(String _fileOwner, BuildContext context) async {
    try {
      if (barcode == '') {
        Fluttertoast.showToast(
            msg: " 请扫描船舶二维码 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return false;
      }

      if (_fileOwner == '') {
        Fluttertoast.showToast(
            msg: " 请输入船舶所有人 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return false;
      }

      String url =
          "http://116.62.149.237:8080/USR000100001?usrName=admin&passwd=123456";

      // result = await http.get(url).then((http.Response response) {
      // var data = json.decode(response.body);
      // String rescode = data["rescode"];
      String rescode = '000000';

      if (rescode == '999999') {
        Fluttertoast.showToast(
            msg: " 回收失败 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return false;
      } else if (rescode == '000000') {
        Navigator.of(context).push(new PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
            return new HomePage();
          },
        ));
        Fluttertoast.showToast(
            msg: "  回收成功！ ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "  回收失败 ",
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
