import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:marine_app/common/DateUtil.dart';
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:marine_app/common/AppConst.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'RecoverListPageNew.dart';

class RecoverPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecoverPageState();
}

class RecoverPageState extends State<RecoverPage> {
  String _recoverDate = DateUtil.formatDateTime(
      DateUtil.getNowDateStr(), DateFormat.YEAR_MONTH_DAY, null, null); //回收日期

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

  String gangkou = "";
  String facIdName = '请选择港口';
  String facId = '';
  String comId = '';

  List<PickerItem> gangkouItems = new List();
  List<Map> gangkouList3 = new List();

  final TextEditingController rbTypeController = new TextEditingController();
  final TextEditingController fomesWeightController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getGangkouData();
    setState(() {
      rbTypeController.text = rbName;
      rbTypeList.forEach((item) {
        PickerItem rbTypeItem = new PickerItem(text: Text(item['rbName']));
        rbTypeItems.add(rbTypeItem);
      });
    });
  }


  Future getGangkouData() async {
    print('查询港口列表');
    String _url = marineURL.FactListUrl;

    String title = '';
    if (null != gangkou && gangkou.isNotEmpty) {
      title = gangkou;
    }

    Map<String, String> _params = {
      'rows': '20',
      'page': '1',
      'order': 'Asc',
      'sort': 'FACID',
      'queryStr': title,
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
        .post(_url, body: _params, headers: _header)
        .then((http.Response response) {
      var data = json.decode(response.body);

      print('body:$_params');
      print('headers:$_header');
      print('data:$data');

      int type = data[AppConst.RESP_CODE];
      String rescode = '$type';
      if (rescode != '10') {
      } else {
        setState(() {
          Map<String, dynamic> _dataMap = json.decode(data[AppConst.RESP_DATA]);
          List _listMap = _dataMap['rows'];
          if (_listMap.length > 0) {
            gangkouItems.clear();
            gangkouList3.clear();
          }
          _listMap.forEach((listItem) {
            gangkouList3.add(listItem);
            String _text = listItem['FACNAME'];
            PickerItem gangkouItem = new PickerItem(text: Text(_text));
            gangkouItems.add(gangkouItem);
          });
        });
      }
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
  String _boatTypeName = ""; //船舶类型名称
  String _lastTime = ""; //上次来港
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('污染物回收'),
        backgroundColor: Colors.greenAccent,
      ),
      body: isLoading?loading():getBody(),
    );
  }

  getBody() {
    return 
    new SingleChildScrollView(
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
                _geneBoatNo2(_geneOtherNo2('船舶类型', _boatTypeName), _div2()),
                _geneBoatNo2(
                    _geneGkTypeNo('港口', 'facid', w3: _w6()), _div()),
                _geneBoatNo2(
                    _geneRbTypeNo('污染物种类', 'fomesType', w3: _w5()), _div()),
                _geneBoatNo2(
                    _geneRecoverDate('回收时间', 'recoverDate', w3: _w4()), _div()),
                _geneBoatNo2(_geneOtherNo('重量(KG)', 'fomesWeight'), _div()),
                _geneBoatNo2(_button2('', '')),
              ],
            )),
      );
  }


  Widget loading() {
    return new Stack(
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 35.0),
          child: new Center(
            child: SpinKitFadingCircle(
              color: Colors.greenAccent,
              size: 30.0,
            ),
          ),
        ),
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
          child: new Center(
            child: new Text('船舶信息保存中...', style: TextStyle(color: Colors.greenAccent),),
          ),
        ),
      ],
    );
  }

  Widget _div2() {
    return new Container(
      color: Colors.greenAccent,
      height: 1.5,
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

  Widget _w6() {
    return IconButton(
      icon: Icon(
        Icons.satellite,
        size: 40.0,
        color: Colors.greenAccent,
      ),
      onPressed: showGangkouPicker,
    );
  }

  Widget gangkouSearch() {
    return new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: new Container(
              alignment: Alignment.center,
              child: TextField(
                onChanged: (word) => gangkou = word,
                style: new TextStyle(fontSize: 15.0, color: Colors.black),
                decoration: new InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  hintText: '查询条件',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.grey)),
                  labelStyle:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 13.0),
                  hintStyle:
                      TextStyle(fontSize: 12.0, color: Colors.greenAccent),
                ),
              ),
            ),
          ),
          new Container(
            child: IconButton(
              icon: Icon(Icons.search),
              iconSize: 40.0,
              onPressed: searchGangkouData,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

   Future searchGangkouData() async {
    await getGangkouData().then((_v) {
      Navigator.pop(context);
      showGangkouPicker();
    });
  }


  
  showGangkouPicker() {
    Picker picker = new Picker(
        title: gangkouSearch(),
        adapter: PickerDataAdapter(
          data: gangkouItems,
        ),
        changeToFirst: true,
        textAlign: TextAlign.left,
        cancelText: '取消',
        cancelTextStyle: TextStyle(color: Colors.greenAccent),
        confirmText: '确定',
        confirmTextStyle: TextStyle(color: Colors.greenAccent),
        // hideHeader: true,
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List value) {
          String _value = value[0].toString();
          int index = int.parse(_value);
          setState(() {
            facIdName = gangkouList3[index]['FACNAME'];
            facId = gangkouList3[index]['FACID'];
            comId = gangkouList3[index]['COMID'];
          });
        });
    picker.showModal(context);
    // picker.show(_scaffoldKey.currentState);
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
                  (null==_textValue||_textValue.isEmpty)?'-':_textValue,
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
                  controller: fomesWeightController,
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

  Widget _geneGkTypeNo(_title, _key, {Widget w3}) {
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
                  facIdName,
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
    DatePicker.showDatePicker(context, showTitleActions: true,
        onChanged: (date) {
      setState(() {
        _recoverDate =
            DateUtil.getDateStrByDateTime(date, format: DateFormat.YEAR_MONTH_DAY);
      });
    }, onConfirm: (date) {
      setState(() {
        _recoverDate =
            DateUtil.getDateStrByDateTime(date, format: DateFormat.YEAR_MONTH_DAY);
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
      if (rescode != '10' && rescode != '20') {
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
          _owner = content['EMPID']==null?'-':content['EMPID'].toString(); //船舶所有人
          _count = content['CARSENO']==null?'-':content['CARSENO'].toString(); //次数
          _recoverWeight = content['CARRQTY']==null?'-':content['CARRQTY'].toString(); //已回收重量
          _boatUnit = content['CARCAP']==null?'-':content['CARCAP'].toString();  //船舶吨位
          _boatBelong = content['CARVENDID']==null?'-':content['CARVENDID'].toString(); //船集港
          _boatType = content['CARTYPE']==null?'-':content['CARTYPE'].toString(); //船舶类型
          if (_boatType == 'Dg') {
            _boatTypeName = '危险品船只';
          } else if (_boatType == 'Nl') {
            _boatTypeName = '常规船只';
          } else {
            _boatTypeName = _boatType;
          }
          _lastTime = content['CARDATE1']==null?'-':content['CARDATE1'].toString();; //上次来港
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

  Future<bool> _forSubmitted() async {

    setState(() {
          isLoading = true;
        });
    try {
      if (barcode == '') {
        Fluttertoast.showToast(
            msg: " 请扫描船舶二维码 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
            setState(() {
          isLoading = false;
        });
        return false;
      }

      if (facId == '') {
        Fluttertoast.showToast(
            msg: " 请选择港口 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
             setState(() {
          isLoading = false;
        });
        return false;
      }


      if (_fomesWeight == '') {
        Fluttertoast.showToast(
            msg: " 请输入污染物重量 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
             setState(() {
          isLoading = false;
        });
        return false;
      }

      if(!RegExp(r'^\d+(\.\d+)?$').hasMatch(_fomesWeight)) {
      Fluttertoast.showToast(
            msg: " 请输入正确的污染物重量 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
             setState(() {
          isLoading = false;
        });
        return false;
      }


    Map<String, String> _params = {
        'CARID': barcode,
        'FACID': facId,
        'COMID': comId,
        'CARDATE': _recoverDate,
        'RTYPE': rbCode,
        'CARQTY2': _fomesWeight,
    };
    String url = marineURL.CreateRubishUrl;
    DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();
    String dbPath = await marineUser.createNewDb();
    Map uMap = await marineUser.getFirstData(dbPath);
    if (uMap == null) {
      Navigator.of(context).pushReplacementNamed('/LoginPage');
    }

    DBUtil.MarineUser mUser = DBUtil.MarineUser.fromMap(uMap);
    String _token = mUser.token;
    Map<String, String> headers = {'token': _token};
    await http.post(url, body: _params, headers: headers).then((http.Response response) {
        var data = json.decode(response.body);
        print('请求报文:body:$_params');
        print('请求报文:headers:$headers');
        print('响应报文:$data');
        int type = data[AppConst.RESP_CODE];
        String rescode = '$type';
        String resMsg = data[AppConst.RESP_MSG];
    
      if (rescode != '10') {
        Fluttertoast.showToast(
            msg: " 保存失败[$resMsg] ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        return false;
      } else {
        Navigator.of(context).pushReplacement(new PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
            return new RecoverListPageNew();
          },
        ));
        Fluttertoast.showToast(
            msg: "  保存成功！ ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
      }});
    }catch(e) {
      debugPrint(e);
      Fluttertoast.showToast(
            msg: " 保存失败 ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
    }
     setState(() {
          isLoading = false;
        });
    return true;
  }
}
