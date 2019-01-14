import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:marine_app/common/AppConst.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class GongGaoPageNew extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GongGaoPageNewState();
}

class GongGaoPageNewState extends State<GongGaoPageNew> {
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
  int _total = -1;

  @override
  void initState() {
    super.initState();
    getData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
            if (_total != -1 && _total>_itemMap.length) {
              _getMore(); 
            }
      }
    });
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
          _listMap.forEach((listItem) {
            print(listItem);
            _itemMap.add(listItem);
          });
          _total = _dataMap['total'];
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
        appBar: AppBar(
          title: Text('公告列表'),
          backgroundColor: Colors.greenAccent,
        ),
        body: 
        getBody()
      );
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
}
