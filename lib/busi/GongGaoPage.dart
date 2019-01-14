import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:marine_app/common/AppConst.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;
import 'package:pulltorefresh_flutter/pulltorefresh_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class GongGaoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GongGaoPageState();
}

class GongGaoPageState extends State<GongGaoPage>
    with TickerProviderStateMixin {
  String url = marineURL.gonggaoUrl;
  DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();
  String barcode = "";
  List<Map> _itemMap = new List<Map>();
  List<Map> _queryItemMap = new List<Map>();
  ScrollController _scrollController = ScrollController();
  int _page = 1; //加载的页数
  String loadingFlag = '1'; //1:加载中 2：加载到数据  3：无数据
  final TextEditingController boatController = new TextEditingController();
  int _rows = 10;
  String _order = 'Asc';
  String _sort = 'CARNO1';
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
           _queryItemMap.clear();
          _listMap.forEach((listItem) {
            _queryItemMap.add(listItem);
          });
          total = _dataMap['total'];
        });
      }
    });
    return result;
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
                      new TextStyle(fontSize: 18.0, color: Colors.greenAccent),
                ),
              ),
            ),
          ],
        ));
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

    print('_itemMap.length=' + _itemMap.length.toString());
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


  // Future _loadData(bool isPullDown) async {
  //   if (!isPullDown) {
  //     setState(() {
  //       if (_itemMap.length == total) {
  //         totalFlag = true;
  //         return;
  //       }
  //       _page++;
  //     });
  //   } else {
  //     setState(() {
  //       totalFlag = false;
  //       _page = 1;
  //     });
  //   }
  //   await getHttpData().then((_v) {
  //     setState(() {
  //       if (isPullDown) {
  //         _itemMap.clear();
  //       }
  //       _itemMap.addAll(_queryItemMap);
  //     });
  //   });
  // }

  Widget getBody() {
    if (loadingFlag == '1') {
      return new Stack(children: <Widget>[
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
              '公告列表加载中...',
              style: TextStyle(color: Colors.greenAccent),
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
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text('公告列表'),
          backgroundColor: Colors.greenAccent,
        ),
        body: getBody());
  }

  Widget itemCard(int i) {
    return new Card(
        child: new ListTile(
            title: new Text(_itemMap[i]['ggTitle']),
            subtitle: new Text(_itemMap[i]['ggTime']),
            //之前显示icon
            leading: new Icon(
              Icons.announcement,
              color: Colors.greenAccent,
              size: 30.0,
            ),
            trailing: new Icon(
              Icons.arrow_right,
              color: Colors.greenAccent,
              size: 30.0,
            ),
            onTap: () => onItemClick(i),
          )
        );
  }

  void onItemClick(int i) {
    String h5Url = _itemMap[i]['ggUrl'];
    if (null == h5Url || h5Url.isEmpty) {
      return;
    }
    String articleTitle = _itemMap[i]['ggTitle'];
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new WebviewScaffold(
              url: h5Url,
              appBar: new AppBar(
            title: new Text('$articleTitle'),
            backgroundColor: Colors.greenAccent,
          ),
              )));
  }
}
