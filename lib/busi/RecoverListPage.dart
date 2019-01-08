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

class RecoverListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecoverListPageState();
}

class RecoverListPageState extends State<RecoverListPage> {
  // String url = marineURL.RecoverListUrl;
  String url = marineURL.BoatListUrl;
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

  @override
  void initState() {
    super.initState();
    getData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });
  }

  Future<bool> getHttpData() async {
    _queryItemMap = new List<Map>();
    bool result = false;
    Map<String, String> _params = {
      'rows': _rows.toString(),
      'page': _page.toString(),
      'order': _order,
      'sort': _sort
    };
    if (barcode.isNotEmpty) {
      _params = {
        'rows': _rows.toString(),
        'page': _page.toString(),
        'order': _order,
        'sort': _sort,
        'queryStr': barcode
      };
    }
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
          
          _queryItemMap=[
          {'gkName':'无名港','dgTime':'2019-01-08 08:08:08','boatNo':'沪 太空货00001','weight':'100.00','count':'3','totalWeight':'20000.00','rbType':'A'},
          {'gkName':'无名港','dgTime':'2019-01-08 08:08:08','boatNo':'沪 太空货00001','weight':'100.00','count':'3','totalWeight':'20000.00','rbType':'B'},
          {'gkName':'无名港','dgTime':'2019-01-08 08:08:08','boatNo':'沪 太空货00001','weight':'100.00','count':'3','totalWeight':'20000.00','rbType':'A'},
          {'gkName':'无名港','dgTime':'2019-01-08 08:08:08','boatNo':'沪 太空货00001','weight':'100.00','count':'3','totalWeight':'20000.00','rbType':'B'},
          {'gkName':'无名港','dgTime':'2019-01-08 08:08:08','boatNo':'沪 太空货00001','weight':'100.00','count':'3','totalWeight':'20000.00','rbType':'A'},
          {'gkName':'无名港','dgTime':'2019-01-08 08:08:08','boatNo':'沪 太空货00001','weight':'100.00','count':'3','totalWeight':'20000.00','rbType':'B'},
          {'gkName':'无名港','dgTime':'2019-01-08 08:08:08','boatNo':'沪 太空货00001','weight':'100.00','count':'3','totalWeight':'20000.00','rbType':'A'},
          {'gkName':'无名港','dgTime':'2019-01-08 08:08:08','boatNo':'沪 太空货00001','weight':'100.00','count':'3','totalWeight':'20000.00','rbType':'B'},
          {'gkName':'无名港','dgTime':'2019-01-08 08:08:08','boatNo':'沪 太空货00001','weight':'100.00','count':'3','totalWeight':'20000.00','rbType':'A'},
          {'gkName':'无名港','dgTime':'2019-01-08 08:08:08','boatNo':'沪 太空货00001','weight':'100.00','count':'3','totalWeight':'20000.00','rbType':'B'},
        ];
        List _listMap = _dataMap['rows'];
          // _listMap.forEach((listItem) {
          //   String carid = listItem['CARID'].toString();
          //   String facid = listItem['FACID'].toString();
          //   String empid = listItem['EMPID'].toString();
          //   String carNo = listItem['CARNO1'].toString();
          //   _queryItemMap.add({
          //     'boatNo': '$carid',
          //     'carid': '船牌号：$carid',
          //     'facid': '码头：$facid,  所有人:$empid',
          //     'empId': '$empid',
          //     'carNo': '$carNo'
          //   });
          // });
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

  Future _getMore() async {
    setState(() {
      loadingFlag = '1';
      _page++;
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

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }


  Widget getBody() {
    if (loadingFlag == '1') {
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
                      '回收列表加载中...',
                      style: TextStyle(color: Colors.greenAccent),
                    ),
                  ),
                ),
              ]);
    } else if (loadingFlag == '2') {
      return RefreshIndicator(
                    onRefresh: _onSearch,
                    child: ListView.builder(
                        itemBuilder: _renderRow,
                        itemCount: _itemMap.length,
                        controller: _scrollController),
                  );
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
        appBar: new PreferredSize(
          preferredSize: Size.fromHeight(110),
          child: new Column(
            children: <Widget>[
              AppBar(
                title: Text('回收列表'),
                backgroundColor: Colors.greenAccent,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      size: 40.0,
                      color: Colors.white70,
                    ),
                    tooltip: '添加回收信息',
                    onPressed: () {Navigator.push(
          context, new MaterialPageRoute(builder: (context) => RecoverPage()));},
                  ),
                ],
              ),
              search()
            ],
          ),
        ),
        body: getBody()
    );
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
            subtitle: 
            new Container(
              child: new Column(
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('时间:$dgTime', style: TextStyle(fontSize: 13.0),),
                        ),
                      
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('港口:$gkName', style: TextStyle(fontSize: 13.0),),
                        ),
                      Expanded(
                        child: Text('本次重量:$weight KG', style: TextStyle(fontSize: 13.0),),
                      )
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('累计次数:$count次', style: TextStyle(fontSize: 13.0),),
                        ),
                      Expanded(
                        child: Text('累计重量:$totalWeight KG', style: TextStyle(fontSize: 13.0),),
                      )
                    ],
                  )
                ],
              ),
            )
            //new Text(_itemMap[i]['facid'])
            ,
            //之前显示icon
            leading: rbType == 'A' ? 
              Image.asset('images/life.png',width: 30.0, height: 50.0):
              Image.asset('images/oil.png',width: 30.0, height: 50.0),
          )
      )
    );
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

  Widget _renderRow(BuildContext context, int index) {
    return itemCard(index);
  }


  Widget search() {
    return new Container(
      decoration: new BoxDecoration(
        border: new Border.all(width: 2.0, color: Colors.greenAccent),
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
              color: Colors.greenAccent,
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

  Future<void> doScanCode() async {
    await scanCode().then((flag) {
      _onSearch();
    });
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
