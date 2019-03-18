import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:marine_app/common/AppConst.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;
import 'RecoverPage.dart';
import 'package:pulltorefresh_flutter/pulltorefresh_flutter.dart';
import 'BoatList.dart';


class RecoverListPageNew extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecoverListPageNewState();
}

class RecoverListPageNewState extends State<RecoverListPageNew>
    with TickerProviderStateMixin {
  // String url = marineURL.RecoverListUrl;
  String url = marineURL.RecoverListUrl;
  DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();
  String barcode = "";
  String carid = "";
  List<Map> _itemMap = new List<Map>();
  List<Map> _queryItemMap = new List<Map>();
  ScrollController _scrollController = ScrollController();
  int _page = 1; //加载的页数
  String loadingFlag = '1'; //1:加载中 2：加载到数据  3：无数据
  final TextEditingController boatController = new TextEditingController();
  int _rows = 10;
  String _order = 'Desc';
  String _sort = 'CARDATE';
  int total = -1;
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
    super.initState();
    customBoxWaitAnimation = new AnimationController(
        duration: const Duration(milliseconds: 1000 * 100), vsync: this);
    getData();
  }

  Future<bool> getHttpData() async {
    _queryItemMap = new List<Map>();
    bool result = false;
    Map<String, String> _params = {
      'rows': _rows.toString(),
      'page': _page.toString(),
      'order': _order,
      'sort': _sort,
      'carid': carid,
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

      debugPrint('url:$url');
      debugPrint('body:$_params');
      debugPrint('headers:$_header');
      // debugPrint('data:$data');

      int type = data[AppConst.RESP_CODE];
      String rescode = '$type';
      String resMsg = data[AppConst.RESP_MSG];
        if (rescode == '14') {
        Fluttertoast.showToast(
            msg: '请重新登录',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        _logout();
      } else
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
          print(_listMap.length.toString());
          _listMap.forEach((listItem) {
            print(listItem.toString());
            String gkName = (null == listItem['FACNAME'])
                ? '-'
                : listItem['FACNAME'].toString();
            String dgTime = (null == listItem['CARDATE'])
                ? '-'
                : listItem['CARDATE'].toString();
            String boatNo = (null == listItem['CARNO'])
                ? '-'
                : listItem['CARNO'].toString();
            String weight = (null == listItem['CARQTY2'])
                ? '-'
                : listItem['CARQTY2'].toString();
            String count = (null == listItem['CARSENO'])
                ? '-'
                : listItem['CARSENO'].toString();
            String totalWeight = (null == listItem['CARRQTY'])
                ? '-'
                : listItem['CARRQTY'].toString();
            String rbType = (null == listItem['RTYPE'])
                ? 'A'
                : listItem['RTYPE'].toString();
            _queryItemMap.add({
              'gkName': gkName,
              'dgTime': dgTime,
              'boatNo': boatNo,
              'weight': weight,
              'count': count,
              'totalWeight': totalWeight,
              'rbType': rbType,
            });
          });
        });
      }
    });
    return result;
  }

   Future<Null> _logout() async {
    String dbPath = await marineUser.createNewDb();
    await marineUser.deleteALL(dbPath).then((_v){
      Navigator.of(context).pushReplacementNamed('/LoginPage');
    });
  }

  Future<bool> getData() async {
    setState(() {
      loadingFlag = "1";
    });
    bool result = false;
    result = await getHttpData().then((_v) {
      setState(() {
        _itemMap.addAll(_queryItemMap);
        if (_itemMap.length > 0) {
          loadingFlag = "2";
        } else {
          loadingFlag = "3";
        }
      });
    });
    return result;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Widget getBody() {
    if (loadingFlag == '1') {
      return new Stack(children: <Widget>[
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 35.0),
          child: new Center(
            child: SpinKitFadingCircle(
              color: AppConst.appColor,
              size: 30.0,
            ),
          ),
        ),
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
          child: new Center(
            child: new Text(
              '回收列表加载中...',
              style: TextStyle(color: AppConst.appColor),
            ),
          ),
        ),
      ]);
    } else if (loadingFlag == '2') {
      return getBody2();
    } else {
      return new Stack(
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
            child: new Center(
              child: new Text(
                '未查询到数据',
                style: TextStyle(color: AppConst.appColor),
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
return new WillPopScope(
    // return 
    child:
     new Scaffold(
        appBar: new PreferredSize(
          preferredSize: Size.fromHeight(110),
          child: new Column(
            children: <Widget>[
              AppBar(
                title: Text('回收列表'),
                backgroundColor: AppConst.appColor,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      size: 40.0,
                      color: AppConst.getIssellead()?Colors.white70:AppConst.appColor,
                    ),
                    tooltip: '添加回收信息',
                    onPressed: AppConst.getIssellead()?() {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => RecoverPage()));
                    }:(){},
                  ),
                ],
              ),
              search(context)
            ],
          ),
        ),
        body: getBody()
    ),
    onWillPop:_requestPop,
        );
  }

  Future<bool> _requestPop() {
   Navigator.of(context).pushReplacementNamed('/HomePage');
    return new Future.value(false);
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
          itemCount: _itemMap.length, //+2,
          controller: controller,
          physics: scrollPhysics,
          itemBuilder: (BuildContext context, int index) {
            return itemCard(index);
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
                      new TextStyle(fontSize: 18.0, color: AppConst.appColor),
                ),
              ),
            ),
          ],
        ));
  }

  Widget itemCard(int i) {
    String gkName = _itemMap[i]['gkName'];
    String dgTime = _itemMap[i]['dgTime'];
    String boatNo = _itemMap[i]['boatNo'];
    String count = _itemMap[i]['count'];
    String weight = _itemMap[i]['weight'];
    String totalWeight = _itemMap[i]['totalWeight'];
    String rbType = _itemMap[i]['rbType'];

    return new Card(
        child: InkWell(
            onTap: () {},
            child: new ListTile(
              title: new Text('船舶号:$boatNo'),
              subtitle: new Container(
                child: new Column(
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '时间:$dgTime',
                            style: TextStyle(fontSize: 13.0),
                          ),
                        ),
                      ],
                    ),
                    new Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '港口:$gkName',
                            style: TextStyle(fontSize: 13.0),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '本次重量:$weight KG',
                            style: TextStyle(fontSize: 13.0),
                          ),
                        )
                      ],
                    ),
                    new Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '累计次数:$count次',
                            style: TextStyle(fontSize: 13.0),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '累计重量:$totalWeight KG',
                            style: TextStyle(fontSize: 13.0),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
                  //new Text(_itemMap[i]['facid'])
                  ,
              //之前显示icon
              leading:  
              // container,
              AppConst.garbageMap[rbType]
              // rbType == 'A'
              //     ? Image.asset('images/life.png', width: 30.0, height: 50.0)
              //     : Image.asset('images/oil.png', width: 30.0, height: 50.0),
            )));
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
            customHeaderTipText = "刷新成功";
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
        if (_itemMap.length == total) {
          totalFlag = true;
        } else {
          totalFlag = false;
          _page++;
        }
      });
      if (_itemMap.length != total){
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
          _itemMap.clear();
        }
        _itemMap.addAll(_queryItemMap);
      });
    });
  }

  Future<Null> _onSearch() async {
    print('开始查询');
    setState(() {
      _itemMap = new List<Map>();
      loadingFlag = "1";
      _page = 1;
    });
    await getHttpData().then((_v) {
      setState(() {
        _itemMap.addAll(_queryItemMap);
        if (_itemMap.length > 0) {
          loadingFlag = "2";
        } else {
          loadingFlag = "3";
        }
      });
    });
  }

  Widget search(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        border: new Border.all(width: 1.0, color: AppConst.appColor),
      ),
      height: 50.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: new InkWell(
             onTap: (){doGetBoat(context);},
            child: new Container(
              alignment: Alignment.center,
              child: Text(
                (null==barcode || barcode.isEmpty)? '选择船舶或扫描':'$barcode'
                ,style: new TextStyle(fontSize: 18.0, color: AppConst.appColor),),
            )),
          ),
          new Container(
            child: IconButton(
              icon: Icon(Icons.camera),
              iconSize: 40.0,
              onPressed: doScanCode,
              color: AppConst.appColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> doGetBoat(BuildContext context) async {
    await _getBoat(context).then((flag) {
      _onSearch();
    });
  }

  Widget search2(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        border: new Border.all(width: 2.0, color: AppConst.appColor),
      ),
      height: 50.0,
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
                  hintText: '请输入搜索条件 ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  labelStyle:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 13.0),
                  hintStyle: TextStyle(fontSize: 12.0),
                ),
              ),
            ),
          ),
          
          new Container(
            child: IconButton(
              icon: Icon(Icons.search),
              iconSize: 40.0,
              onPressed: _onSearch,
              color: AppConst.appColor,
            ),
          ),
          _addBoat(context),
          new Container(
            child: IconButton(
              icon: Icon(Icons.camera),
              iconSize: 40.0,
              onPressed: doScanCode,
              color: AppConst.appColor,
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
        color: AppConst.appColor,
      ),
      onPressed: (){_getBoat(context);},
    );
  }

  Future<void> _getBoat(BuildContext context) async {
    var result = await Navigator.push(context,
        new MaterialPageRoute(builder: (context) => new BoatList()));
    setState(() {
          Map _dataMap = json.decode(result);
          barcode =  _dataMap['carno1'];
          boatController.text = barcode;
          carid = _dataMap['carid'];
        });
  }

  Future<void> doScanCode() async {
    await scanCode().then((flag) {
      _onSearch();
    });
  }

  Future<bool> scanCode() async {
    try {
      String result = await BarcodeScanner.scan();
      setState(() {
        boatController.text = barcode;
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
              msg: " 请打开权限 ",
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
