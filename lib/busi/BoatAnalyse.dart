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
import 'package:pulltorefresh_flutter/pulltorefresh_flutter.dart';
import 'BoatList.dart';

class BoatAnalyse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BoatAnalyseState();
}

class BoatAnalyseState extends State<BoatAnalyse>
    with TickerProviderStateMixin {
  String dataFlag = '1'; //1:标示初始化，  2;表示已经查询过

  String barcode = "";
  String carid = "";
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

  int total = -1;

  List<Map> dataMapQuery = [];

  List<Map> _queryItemMap = new List<Map>();

  List<Map> dataMap = [];

  Color allTypeColor = Colors.greenAccent;
  Color lifeTypeColor = Colors.grey;
  Color oilTypeColor = Colors.grey;

  Color gangkouColor = Colors.grey;

  String typeView = '全部';

  String rbType = '';
  String facid = '';

  String total1 = '累计重量:0 KG';
  String total2 = '累计趟次:0 次';

  Color bootSheetColor = Colors.white;

  ScrollController _scrollController = ScrollController();

  int _page = 1;
  int _rows = 10;
  String _order = 'Asc';
  String _sort = 'CARNO1';

  String url = marineURL.BoatAnalyseListUrl;
  DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();

  bool totalFlag = false;

  ScrollController controller = new ScrollController();
  ScrollPhysics scrollPhysics = new RefreshAlwaysScrollPhysics();

  String customRefreshBoxIconPath = "images/icon_arrow.png";
  AnimationController customBoxWaitAnimation;
  int rotationAngle = 0;
  String customHeaderTipText = "松开加载！";
  String defaultRefreshBoxTipText = "松开加载！";

  ///button等其他方式，通过方法调用触发下拉刷新
  TriggerPullController triggerPullController = new TriggerPullController();

  @override
  void initState() {
    getGangkouData();
    customBoxWaitAnimation = new AnimationController(
        duration: const Duration(milliseconds: 1000 * 100), vsync: this);
    super.initState();
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
      'Carid': carid
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
          total = _dataMap['total'];
          _listMap.forEach((listItem) {
            String facId = listItem['FACID'].toString();
            String boatNo = listItem['CARNO1'].toString();
            String boatOwner = listItem['FACID'].toString();
            String weight = listItem['CARQTY2'].toString();
            String count = listItem['COUT'].toString();
            String dgtime = listItem['RECENTCARDATE'].toString();
            String facName = listItem['FACNAME'].toString();
            _queryItemMap.add({
              'boatNo': boatNo,
              'boatOwner': boatOwner,
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
          if (_listMap.length > 0) {
            gangkouItems.clear();
            gangkouList3.clear();
            gangkouList3.add({});
            String _text = '- - - - - - 不选 - - - - -';
            PickerItem gangkouItem = new PickerItem(text: Text(_text));
            gangkouItems.add(gangkouItem);
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
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return new MaterialApp(
    return new Scaffold(
      appBar: AppBar(
        title: Text('船舶分析'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Builder(builder: (context) => getBody(context)),
      endDrawer: getNavDrawer(context),
      bottomNavigationBar: getBottom(),
      // bottomSheet: new BottomSheet(
      //   onClosing: () {},
      //   builder: (BuildContext context) {
      //     return new Container(
      //         height: 40.0,
      //         color: bootSheetColor,
      //         child: new Row(
      //           children: <Widget>[
      //             Expanded(
      //               child: new Text(
      //                 '$total1\t\t$total2',
      //                 textAlign: TextAlign.center,
      //                 style: TextStyle(fontSize: 14.0, color: Colors.white),
      //               ),
      //             )
      //           ],
      //         ));
      //   },
      // ),
    );
  }

  Widget getBottom() {
    return new Container(
        color: Colors.greenAccent,
        height: 40.0,
        alignment: Alignment.center,
        child: new Text(
          '$total1\t\t$total2',
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ));
  }

  Widget getBody(BuildContext context) {
    if (dataFlag == '1') {
      return loading(context);
    } else if (dataFlag == '3') {
      return getBody2();
    } else if (dataFlag == '4') {
      return noData(context);
    } else {
      return querying();
    }
  }

  Widget _getCustomHeaderBox() {
    return new Container(
        color: Colors.grey,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Align(
              alignment: Alignment.centerLeft,
              child: new RotatedBox(
                quarterTurns: rotationAngle,
                child: new RotationTransition(
                  //布局中加载时动画的weight
                  child: new Image.asset(
                    customRefreshBoxIconPath,
                    height: 45.0,
                    width: 45.0,
                    fit: BoxFit.cover,
                  ),
                  turns: new Tween(begin: 100.0, end: 0.0)
                      .animate(customBoxWaitAnimation)
                        ..addStatusListener((animationStatus) {
                          if (animationStatus == AnimationStatus.completed) {
                            customBoxWaitAnimation.repeat();
                          }
                        }),
                ),
              ),
            ),
            new Align(
              alignment: Alignment.centerRight,
              child: new ClipRect(
                child: new Text(
                  customHeaderTipText,
                  style:
                      new TextStyle(fontSize: 18.0, color: Colors.greenAccent),
                ),
              ),
            ),
          ],
        ));
  }

  Widget getBody2() {
    return new PullAndPush(
      defaultRefreshBoxTipText: defaultRefreshBoxTipText,
      headerRefreshBox: _getCustomHeaderBox(),
      footerRefreshBox: _getCustomHeaderBox(),
      triggerPullController: triggerPullController,
      animationStateChangedCallback: (AnimationStates animationStates,
          RefreshBoxDirectionStatus refreshBoxDirectionStatus) {
        _handleStateCallback(animationStates, refreshBoxDirectionStatus);
      },
      listView: new ListView.builder(
          //ListView的Item
          itemCount: dataMap.length, //+2,
          controller: controller,
          physics: scrollPhysics,
          itemBuilder: (BuildContext context, int index) {
            return buildOutCard(index);
          }),
      loadData: (isPullDown) async {
        await _loadData(isPullDown);
      },
      scrollPhysicsChanged: (ScrollPhysics physics) {
        //这个不用改，照抄即可；This does not need to change，only copy it
        setState(() {
          scrollPhysics = physics;
        });
      },
    );
  }

  void _handleStateCallback(AnimationStates animationStates,
      RefreshBoxDirectionStatus refreshBoxDirectionStatus) {
    switch (animationStates) {
      //RefreshBox高度达到50,上下拉刷新可用;RefreshBox height reached 50，the function of load data is  available
      case AnimationStates.DragAndRefreshEnabled:
        setState(() {
          //3.141592653589793是弧度，角度为180度,旋转180度；3.141592653589793 is radians，angle is 180⁰，Rotate 180⁰
          rotationAngle = 2;
        });
        break;

      //开始加载数据时；When loading data starts
      case AnimationStates.StartLoadData:
        setState(() {
          customRefreshBoxIconPath = "images/refresh.png";
          customHeaderTipText = "加载.....";
        });
        customBoxWaitAnimation.forward();
        break;

      //加载完数据时；RefreshBox会留在屏幕2秒，并不马上消失，这里可以提示用户加载成功或者失败
      // After loading the data，RefreshBox will stay on the screen for 2 seconds, not disappearing immediately，Here you can prompt the user to load successfully or fail.
      case AnimationStates.LoadDataEnd:
        customBoxWaitAnimation.reset();
        setState(() {
          rotationAngle = 0;
          if (refreshBoxDirectionStatus == RefreshBoxDirectionStatus.PULL) {
            customRefreshBoxIconPath = "images/icon_ok.png";
            customHeaderTipText = "加载成功！";
          } else if (refreshBoxDirectionStatus ==
              RefreshBoxDirectionStatus.PUSH) {
            customRefreshBoxIconPath = "images/icon_ok.png";
            if (totalFlag) {
              customHeaderTipText = "没有更多数据了";
            } else {
              customHeaderTipText = "加载成功！";
            }
          }
        });
        break;

      //RefreshBox已经消失，并且闲置；RefreshBox has disappeared and is idle
      case AnimationStates.RefreshBoxIdle:
        setState(() {
          rotationAngle = 0;
          defaultRefreshBoxTipText = customHeaderTipText = "松开加载";
          customRefreshBoxIconPath = "images/icon_arrow.png";
        });
        break;
    }
  }

  Future _loadData(bool isPullDown) async {
    if (!isPullDown) {
      setState(() {
        if (dataMap.length == total) {
          totalFlag = true;
        } else {
          totalFlag = false;
          _page++;
        }
      });
      if (dataMap.length != total) {
        toGetData(isPullDown);
      }
    } else {
      setState(() {
        totalFlag = false;
        _page = 1;
      });
      toGetData(isPullDown);
    }
  }

  Future toGetData(isPullDown) async {
    await getHttpData().then((_v) {
      setState(() {
        if (isPullDown) {
          dataMap.clear();
        }
        dataMap.addAll(_queryItemMap);
        String _t1 = gettotal1();
        String _t2 = gettotal2();
        total1 = '累计重量:$_t1 KG';
        total2 = '累计趟次:$_t2 次';
        if (dataMap.length != 0) {
          dataFlag = '3';
        } else {
          dataFlag = '4';
        }
      });
    });
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

  // List<Widget> buildBody() {
  //   List<Widget> _result = new List();
  //   dataMap.forEach((_map){
  //     String boatNo = _map['boatNo'];
  //     String boatOwner = _map['boatOwner'];
  //     String weight = _map['weight'];
  //     String count = _map['count'];
  //     String dgtime = _map['dgtime'];
  //     Widget _item = buildOutCard(boatNo, boatOwner, weight, count, dgtime);
  //     _result.add(_item);
  //   }
  //   );
  //   return _result;
  // }

  Widget buildCard(String boatNo, String boatOwner, String weight, String count,
      String dgtime) {
    return new Card(
      color: Colors.white,
      elevation: 5.0,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildColumn1(boatNo, boatOwner),
          buildColumn2(weight, count),
          buildColumn3(dgtime),
        ],
      ),
    );
  }

  Widget buildColumn1(String boatNo, String boatOwner) {
    return new Row(
      children: <Widget>[
        Expanded(
          child: new Text(
            '船号:$boatNo',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12.0),
          ),
        ),
        Expanded(
          child: new Text(
            '船主:$boatOwner',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12.0),
          ),
        )
      ],
    );
  }

  Widget buildColumn2(String weight, String count) {
    return new Row(
      children: <Widget>[
        Expanded(
          child: new Text(
            '重量: $weight 吨',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12.0),
          ),
        ),
        Expanded(
          child: new Text(
            '趟次:$count 次',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12.0),
          ),
        )
      ],
    );
  }

  Widget buildColumn3(String dgtime) {
    return new Row(
      children: <Widget>[
        Expanded(
          child: new Text(
            '最近到港时间: $dgtime ',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12.0),
          ),
        ),
      ],
    );
  }

  // Widget geneBody() {
  //   return new Center(
  //         child: new ListView(
  //           //控制方向 默认是垂直的
  //           children: buildBody(),
  //         ),
  //       );
  // }

  Widget noData(BuildContext context) {
    return new InkWell(
        onTap: () {
          _handlerDrawerButton2(context);
        },
        child: new Stack(
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
        ));
  }

  Widget loading(BuildContext context) {
    return new InkWell(
        onTap: () {
          _handlerDrawerButton2(context);
        },
        child: new Stack(
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 80.0),
              child: new Center(
                child: Icon(
                  Icons.search,
                  size: 100.0,
                  color: Colors.greenAccent,
                ),
              ),
            ),
            new Padding(
              padding: new EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
              child: new Center(
                child: new Text(
                  '请点击图标进行查询',
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ),
            ),
          ],
        ));
  }

  void _handlerDrawerButton2(context) {
    Scaffold.of(context).openEndDrawer();
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
      search(context),
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
        total1 = '累计重量:$_t1吨';
        total2 = '累计趟次:$_t2次';
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
    String boatNo = boatMap['boatNo'];
    String weight = double.parse(boatMap['weight']).toStringAsFixed(2);
    String count = double.parse(boatMap['count']).toStringAsFixed(0);
    String dgtime = boatMap['dgtime'];
    String facName = boatMap['facName'];
    return new Card(
      child: InkWell(
        onTap: () {},
        child: ListTile(
            contentPadding: EdgeInsets.only(left: 1.0, right: 1.0),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.directions_boat,
                  size: 45.0,
                  color: Colors.greenAccent,
                )
              ],
            ),
            title: Padding(
              padding: EdgeInsets.only(bottom: 1.0),
              child: Text(
                '船号: $boatNo',
                maxLines: 2,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.greenAccent, fontSize: 16.0),
              ),
            ),
            subtitle: new Container(
              child: new Column(
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 1.0),
                        child: Text(
                          "港口:$facName",
                          style: TextStyle(fontSize: 13.0),
                        ),
                      ),
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '重量: $weight KG',
                          style: TextStyle(fontSize: 13.0),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '趟次: $count 次',
                          style: TextStyle(fontSize: 13.0),
                        ),
                      )
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 1.0),
                        child: Text(
                          "最近到港时间:$dgtime",
                          style: TextStyle(fontSize: 13.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget search(BuildContext context) {
    return new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: new InkWell(
              onTap: (){_getBoat(context);},
              child: Text((null==barcode || barcode.isEmpty)? '选择船舶或扫描':'$barcode'
                ,style: new TextStyle(fontSize: 18.0, color: Colors.greenAccent),
                textAlign: TextAlign.center,),
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


  Widget _addBoat(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.add_circle,
        size: 40.0,
        color: Colors.greenAccent,
      ),
      onPressed: (){_getBoat(context);},
    );
  }

  Future<void> _getBoat(BuildContext context) async {
    var result = await Navigator.push(context,
        new MaterialPageRoute(builder: (context) => new BoatList()));
    setState(() {
          // barcode = boatNo;
          // boatController.text = boatNo;

          Map _dataMap = json.decode(result);
          barcode =  _dataMap['carno1'];
          boatController.text = barcode;
          carid = _dataMap['carid'];
        });
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
          if (index != 0) {
            setState(() {
              gangkouName = gangkouList3[index]['FACNAME'];
              gangkouId = gangkouList3[index]['FACID'];
              gangkouColor = Colors.greenAccent;
            });
          } else {
            setState(() {
              gangkouName = '';
              gangkouId = '';
              gangkouColor = Colors.grey;
            });
          }
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
      String result = await BarcodeScanner.scan();
      setState(() {
        Map _dataMap = json.decode(result);
          barcode =  _dataMap['carno1'];
          boatController.text = barcode;
          carid = _dataMap['carid'];
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
