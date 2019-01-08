import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marine_app/common/DateUtil.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter/src/material/dialog.dart' as Dialog;
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:marine_app/common/AppConst.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;

class RecoverListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecoverListPageState();
}

class RecoverListPageState extends State<RecoverListPage> {
  String dataFlag = '1'; //1:标示初始化，  2;表示已经查询过

  String barcode = "";
  String gangkou = "";
  final TextEditingController boatController = new TextEditingController();
  Color todayDateColor = Colors.greenAccent;
  Color yesterdayDateColor = Colors.grey;
  Color weekDateColor = Colors.grey;
  Color monthDateColor = Colors.grey;
  Color otherDateColor = Colors.grey;
  String dateView = DateUtil.formatDateTime(
      DateUtil.getNowDateStr(), DateFormat.YEAR_MONTH_DAY, null, null);

  String startDate = DateUtil.formatDateTime(
      DateUtil.getNowDateStr(), DateFormat.YEAR_MONTH_DAY, null, null);
  String endDate = DateUtil.formatDateTime(
      DateUtil.getNowDateStr(), DateFormat.YEAR_MONTH_DAY, null, null);

  String gangkouId = '';
  String gangkouName = '';

  List<PickerItem> gangkouItems = new List();
  List<Map> gangkouList3 = new List();

  static String _time = DateUtil.formatDateTime(
      DateUtil.getNowDateStr(), DateFormat.ZH_NORMAL, null, null);

  List<Map> dataMapQuery = [
    {
      'weight': '10.0',
              'count': '12',
              'dgtime': 'dgtime',
              'facName': 'facName',
              'facId': 'facId',
    },
  ];

  List<Map> _queryItemMap = new List<Map>();

  List<Map> dataMap = [];

  Color allTypeColor = Colors.greenAccent;
  Color lifeTypeColor = Colors.grey;
  Color oilTypeColor = Colors.grey;

  Color gangkouColor = Colors.grey;

  String typeView = '全部';

  String rbType = '';
  String facid = '';

  String total1 = '';
  Color bootSheetColor = Colors.white;

  ScrollController _scrollController = ScrollController();

  int _page = 1;
  int _rows = 10;
  String _order = 'Asc';
  String _sort = 'CARDATE';

  String url = marineURL.RubiAnalyseListUrl;
  DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();
  @override
  void initState() {
    super.initState();
    getGangkouData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });
  }

  Future _getMore() async {
    setState(() {
      dataFlag = '2';
      _page++;
    });
    await getHttpData().then((_v) {
      setState(() {
        dataMap.addAll(_queryItemMap);
        String _t1 = gettotal1();
        String _t2 = gettotal2();
        total1 = '总计: $_t1吨\t\t $_t2次';
        if (dataMap.length != 0) {
          bootSheetColor = Colors.greenAccent;
          dataFlag = '3';
        } else {
          bootSheetColor = Colors.white;
          dataFlag = '4';
        }
      });
    });
  }

  Future<bool> getHttpData() async {
    _queryItemMap = new List<Map>();
    bool result = false;

    Map<String, String> _params = {
      'rows': _rows.toString(),
      'page': _page.toString(),
      'order': _order,
      'sort': _sort,
      'begTime': startDate,
      'endTime': endDate,
      'rbType': rbType,
      'Facid': gangkouId,
      'Carid': barcode
    };
    String dbPath = await marineUser.createNewDb();
    Map uMap = await marineUser.getFirstData(dbPath);
    if (uMap == null) {
      Navigator.of(context).pushReplacementNamed('/LoginPage');
    }

    DBUtil.MarineUser mUser = DBUtil.MarineUser.fromMap(uMap);
    String _token = mUser.token;
    Map<String, String> _header = {'token': _token};
    result = await http
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
          Map<String, dynamic> _dataMap = json.decode(data[AppConst.RESP_DATA]);
          List _listMap = _dataMap['rows'];
          _listMap.forEach((listItem) {
            String dgtime = listItem['CARDATE'].toString();
            String facId = listItem['FACID'].toString();
            String count = listItem['COUT'].toString();
            String facName = listItem['FACNAME'].toString();
            String weight = listItem['CARQTY2'].toString();
            _queryItemMap.add({
              'weight': weight,
              'count': count,
              'dgtime': dgtime,
              'facName': facName,
              'facId': facId,
            });
          });
        });
      }
    });
    return result;
  }

  Future searchGangkouData() async {
    await getGangkouData().then((_v) {
      Navigator.pop(context);
      showPicker();
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
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return new MaterialApp(
    return new Scaffold(
      appBar: AppBar(
        title: Text('回收分析'),
        backgroundColor: Colors.greenAccent,
      ),
      body: getBody(),
      endDrawer: getNavDrawer(context),
      bottomSheet: new BottomSheet(
        onClosing: () {},
        builder: (BuildContext context) {
            return 
            new Container(
              height: 40.0,
              color: bootSheetColor,
              child:new Row(
              children: <Widget>[
                Expanded( child:
                new Text(total1, textAlign: TextAlign.left, style: TextStyle(fontSize: 14.0,color: Colors.white), ),),
              ],
            ));
        },
),
    );
  }

  Widget getBody() {
    if (dataFlag == '1') {
      return loading(context);
    } else if (dataFlag == '3') {
      return RefreshIndicator(
        onRefresh: _forSubmitted,
        child: ListView.builder(
            itemBuilder: _renderRow,
            itemCount: dataMap.length,
            controller: _scrollController),
      );
    } else if (dataFlag == '4') {
      return noData(context);
    } else {
      return querying();
    }
  }

  Widget _renderRow(BuildContext context, int index) {
    return buildOutCard(index);
  }

  Widget querying() {
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
            child: new Text(
              '加载中...',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget noData(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 80.0),
          child: new Center(
              child: new InkWell(
            onTap: () {},
            child: Icon(
              Icons.data_usage,
              size: 100.0,
              color: Colors.greenAccent,
            ),
          )),
        ),
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
          child: new Center(
            child: new Text(
              '未查询到数据',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget loading(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 80.0),
          child: new Center(
              child: new InkWell(
            onTap: () {},
            child: Icon(
              Icons.search,
              size: 100.0,
              color: Colors.greenAccent,
            ),
          )),
        ),
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
          child: new Center(
            child: new Text(
              '请点击右上角图标进行查询',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        ),
      ],
    );
  }

  Drawer getNavDrawer(BuildContext context) {
    ListTile getNavItem(String s, {onTapFunc}) {
      return new ListTile(
        title: new Text(
          s,
          style: TextStyle(color: Colors.greenAccent, fontSize: 12.0),
        ),
        onTap: onTapFunc,
      );
    }

    var myNavChildren = [
      // headerChild,
      search(),
      Divider(),
      getNavItem("时间:  $dateView"),

      new Container(
          child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10.0,
        runSpacing: 10.0,
        direction: Axis.horizontal,
        children: <Widget>[
          getDateButton('今天', todayDateColor, '1'),
          getDateButton('昨天', yesterdayDateColor, '2'),
          getDateButton('近一周', weekDateColor, '3'),
          getDateButton('本月', monthDateColor, '4'),
          getDateButton('其他时间', otherDateColor, '5'),
        ],
      )),
      Divider(),
      getNavItem("类别:  $typeView"),
      new Container(
          child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10.0,
        runSpacing: 10.0,
        direction: Axis.horizontal,
        children: <Widget>[
          getTypeButton('全部', allTypeColor, '1'),
          getTypeButton('生活垃圾', lifeTypeColor, '2'),
          getTypeButton('油污垃圾', oilTypeColor, '3'),
        ],
      )),
      Divider(),
      getNavItem("港口:  $gangkouName"),

      new Container(
          child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10.0,
        runSpacing: 10.0,
        direction: Axis.horizontal,
        children: <Widget>[
          getGangkouButton('请选择港口', gangkouColor),
        ],
      )),

      Divider(),
      new Container(child: geneButton('', '')),
    ];
    ListView listView = new ListView(children: myNavChildren);
    return new Drawer(child: listView);
  }

  Widget geneButton(_title, _key, {Widget w3}) {
    return new Container(
      color: Colors.white70,
      height: 60.0,
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
              padding: new EdgeInsets.fromLTRB(1.0, 0.0, 1.0, 0.0),
              child: new RaisedButton(
                color: Colors.greenAccent,
                elevation: 10,
                highlightElevation: 10,
                disabledElevation: 10,
                child: new Text(
                  '查 询',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0),
                ),
                onPressed: () {
                  _forSubmitted();
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

  Future<bool> _forSubmitted() async {
    Navigator.pop(context);
    setState(() {
      dataFlag = '2';
      _page = 1;
    });

    await getHttpData().then((_v) {
      setState(() {
        dataMap.clear();
        // _queryItemMap.addAll(dataMapQuery);
        dataMap.addAll(_queryItemMap);
        String _t1 = gettotal1();
        String _t2 = gettotal2();
        total1 = '总计: $_t1吨\t\t $_t2次';
        if (dataMap.length != 0) {
          bootSheetColor = Colors.greenAccent;
          dataFlag = '3';
        } else {
          bootSheetColor = Colors.white;
          dataFlag = '4';
        }
      });
    });
    return true;
  }

  String gettotal1() {
    double _ret = 0;
    dataMap.forEach((item) {
      _ret = _ret + double.parse(item['weight']);
    });
    return _ret.toStringAsFixed(2);
  }

  String gettotal2() {
    double _ret = 0;
    dataMap.forEach((item) {
      _ret = _ret + double.parse(item['count']);
    });
    return _ret.toStringAsFixed(0);
  }

  Widget buildOutCard(int index) {
    Map boatMap = dataMap[index];
    String weight = double.parse(boatMap['weight']).toStringAsFixed(2);
    String count = double.parse(boatMap['count']).toStringAsFixed(0);
    String dgtime = boatMap['dgtime'];
    String rType = boatMap['rType'];
    return new Card(
      child: InkWell(
        onTap: (){},
        child: ListTile(
          contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              rType == 'A' ? 
              Image.asset('images/life.png',width: 45.0, height: 50.0):
              Image.asset('images/oil.png',width: 45.0, height: 50.0),
            ],
          ),
          title: Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              '日期: $dgtime',
              maxLines: 1,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.greenAccent, fontSize: 16.0),
            ),
          ),
          subtitle: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Text(
                  "重量:",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Text(
                  '$weight吨',
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Text(
                  "趟次:",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              Text(
                '$count次',
                style: TextStyle(fontSize: 12.0),
              ),
            ],
          ),
          // trailing: Icon(Icons.directions_boat, color:Colors.greenAccent, size:40.0),
        ),
      ),
    );
  }

  Widget search() {
    return new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: new Container(
              alignment: Alignment.center,
              child: TextField(
                controller: boatController,
                onChanged: (word) => barcode = word,
                style: new TextStyle(fontSize: 15.0, color: Colors.black),
                decoration: new InputDecoration(
                  contentPadding: EdgeInsets.all(10.0),
                  hintText: '请输入船舶号 ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.grey)),
                  labelStyle:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 13.0),
                  hintStyle: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
              ),
            ),
          ),
          new Container(
            child: IconButton(
              icon: Icon(Icons.camera),
              iconSize: 40.0,
              onPressed: doScanCode,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget getDateButton(String title, Color color, String range) {
    return OutlineButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(
              color: Color(0xFFFFFF00), style: BorderStyle.solid, width: 2)),
      borderSide: new BorderSide(color: color),
      child: new Text(title, style: new TextStyle(color: color)),
      onPressed: () {
        if (range == '5') {
          showPickerDateRange(context);
        } else {
          changeDate(range, context);
        }
      },
    );
  }

  Widget getTypeButton(String title, Color color, String range) {
    return OutlineButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(
              color: Color(0xFFFFFF00), style: BorderStyle.solid, width: 2)),
      borderSide: new BorderSide(color: color),
      child: new Text(title, style: new TextStyle(color: color)),
      onPressed: () {
        changeType(range, context);
      },
    );
  }

  Future<void> changeType(String range, BuildContext context) async {
    allTypeColor = Colors.grey;
    lifeTypeColor = Colors.grey;
    oilTypeColor = Colors.grey;
    setState(() {
      if (range == '1') {
        //今天
        typeView = '全部';
        rbType = '';
        allTypeColor = Colors.greenAccent;
      } else if (range == '2') {
        //昨天
        typeView = '生活垃圾';
        rbType = 'A';
        lifeTypeColor = Colors.greenAccent;
      } else {
        typeView = '油污垃圾';
        rbType = 'B';
        oilTypeColor = Colors.greenAccent;
      }
    });
  }

  Future<void> changeDate(String range, BuildContext context) async {
    todayDateColor = Colors.grey;
    yesterdayDateColor = Colors.grey;
    weekDateColor = Colors.grey;
    monthDateColor = Colors.grey;
    otherDateColor = Colors.grey;
    setState(() {
      if (range == '1') {
        //今天
        startDate = DateUtil.formatDateTime(
            DateUtil.getNowDateStr(), DateFormat.YEAR_MONTH_DAY, null, null);
        endDate = DateUtil.formatDateTime(
            DateUtil.getNowDateStr(), DateFormat.YEAR_MONTH_DAY, null, null);
        todayDateColor = Colors.greenAccent;
      } else if (range == '2') {
        //昨天
        DateTime yesterDay = DateTime.now().subtract(Duration(days: 1));
        startDate = DateUtil.formatDateTime(
            yesterDay.toString(), DateFormat.YEAR_MONTH_DAY, null, null);
        endDate = DateUtil.formatDateTime(
            yesterDay.toString(), DateFormat.YEAR_MONTH_DAY, null, null);
        yesterdayDateColor = Colors.greenAccent;
      } else if (range == '3') {
        //本周
        weekDateColor = Colors.greenAccent;
        DateTime weekBegin = DateTime.now().subtract(Duration(days: 6));
        startDate = DateUtil.formatDateTime(
            weekBegin.toString(), DateFormat.YEAR_MONTH_DAY, null, null);
        endDate = DateUtil.formatDateTime(
            DateUtil.getNowDateStr(), DateFormat.YEAR_MONTH_DAY, null, null);
      } else if (range == '4') {
        //一个月
        monthDateColor = Colors.greenAccent;
        DateTime _now = DateTime.now();
        int _month = _now.month;
        int _year = _now.year;
        int _monthDay = MONTH_DAY[_month];
        startDate =
            _year.toString() + '-' + _month.toString().padLeft(2, '0') + '-01';
        endDate = _year.toString() +
            '-' +
            _month.toString().padLeft(2, '0') +
            '-$_monthDay';
      }

      if (startDate == endDate) {
        dateView = startDate;
      } else {
        dateView = startDate + '~' + endDate;
      }
    });
  }

  Future<void> showPickerDateRange(BuildContext context) async {
    Picker ps = new Picker(
        hideHeader: true,
        adapter: new DateTimePickerAdapter(
            type: PickerDateTimeType.kYMD, isNumberMonth: true),
        onConfirm: (Picker picker, List value) {
          setState(() {
            DateTime _value = (picker.adapter as DateTimePickerAdapter).value;
            startDate = DateUtil.getDateStrByDateTime(_value,
                format: DateFormat.YEAR_MONTH_DAY);
          });
        });

    Picker pe = new Picker(
        hideHeader: true,
        adapter: new DateTimePickerAdapter(
            type: PickerDateTimeType.kYMD, isNumberMonth: true),
        onConfirm: (Picker picker, List value) {
          setState(() {
            DateTime _value = (picker.adapter as DateTimePickerAdapter).value;
            endDate = DateUtil.getDateStrByDateTime(_value,
                format: DateFormat.YEAR_MONTH_DAY);
          });
        });

    List<Widget> actions = [
      FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: new Text('取消')),
      FlatButton(
          onPressed: () {
            Navigator.pop(context);
            ps.onConfirm(ps, ps.selecteds);
            pe.onConfirm(pe, pe.selecteds);
            setState(() {
              if (startDate == endDate) {
                dateView = startDate;
              } else {
                dateView = startDate + '~' + endDate;
              }
              todayDateColor = Colors.grey;
              yesterdayDateColor = Colors.grey;
              weekDateColor = Colors.grey;
              monthDateColor = Colors.grey;
              otherDateColor = Colors.greenAccent;
            });
          },
          child: new Text('确定'))
    ];

    Dialog.showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text(
              "其他时间",
              style: TextStyle(decorationColor: Colors.greenAccent),
            ),
            actions: actions,
            content: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("开始:"),
                  ps.makePicker(),
                  Divider(),
                  Text("结束:"),
                  pe.makePicker(),
                  Divider(),
                ],
              ),
            ),
          );
        });
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

  showPicker() {
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
            gangkouName = gangkouList3[index]['FACNAME'];
            gangkouId = gangkouList3[index]['FACID'];
            gangkouColor = Colors.greenAccent;
          });
        });
    picker.showModal(context);
    // picker.show(_scaffoldKey.currentState);
  }

  Widget getGangkouButton(String title, Color color) {
    return OutlineButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(
              color: Color(0xFFFFFF00), style: BorderStyle.solid, width: 2)),
      borderSide: new BorderSide(color: color),
      child: new Text(title, style: new TextStyle(color: color)),
      onPressed: showPicker,
    );
  }

  Future<void> doScanCode() async {
    await scanCode().then((flag) {});
  }

  Future<bool> scanCode() async {
    try {
      barcode = await BarcodeScanner.scan();
      setState(() {
        boatController.text = barcode;
        return true;
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
          return false;
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
          return false;
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
        return false;
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
        return false;
      });
    }
    return false;
  }
}
