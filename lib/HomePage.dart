import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marine_app/common/AppConst.dart';
import 'package:marine_app/busi/BoatQuery.dart';
import 'package:marine_app/busi/BoatAnalyse.dart';
import 'package:marine_app/busi/BoatPageNew.dart';
import 'package:marine_app/busi/MemberCenter.dart';
import 'package:marine_app/busi/RecoverAnalyse.dart';
import 'package:marine_app/busi/RecoverPage.dart';
import 'package:marine_app/busi/GonggaoPage.dart';
import 'package:marine_app/busi/RecoverListPageNew.dart';
import 'dart:async';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:marine_app/common/AppConst.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  @override
  SwiperPageState createState() {
    return SwiperPageState();
  }
}

class SwiperPageState extends State<HomePage> {
  var bannerList = [];
  var gonggaoList = [];
  var boatCount = 0;
  var recyclCount = 0;
  Timer _timer;
  int gonggaoIndex = 0;
  int _seconds = 0;

  bool _autoPlay = false;

  String _token = '';


  DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();
  String userName='';
  String token='';

  @override
  void initState() {
    super.initState();
    getToken().then((_v) {
      loadData().then((_v){
        _autoPlay = true;
      });
      loadGonggaoData().then((_v) {
        int ggLen = gonggaoList.length;
        if (ggLen == 0) {
          setState(() {
            gonggaoIndex = -1;
          });
        } else {
          _timer = new Timer.periodic(new Duration(seconds: 3), (timer) {
            _seconds++;
            setState(() {
              gonggaoIndex = _seconds % ggLen;
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new SingleChildScrollView(
        child: new ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: 120.0,
            ),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                swiperWidget(),
                gonggaoIndex == -1 ? new Divider() : gonggaoWidget(),
                new Divider(),
                menuWidget(),
                new Divider(),
                bottomWidget()
              ],
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConst.appColor,
        foregroundColor: Colors.white,
        shape: new CircleBorder(),
        isExtended: false,
        onPressed: () {
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => RecoverPage()));
        },
        child: Text('回收',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0)),
      ),
    );
  }

  Widget menuWidget() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              imageExpanded('船舶', '船舶列表', Icons.directions_boat, '1'),
              // imageExpanded('船舶', '$boatCount艘', Icons.directions_boat, '1'),
              // VerticalDivider(color: Colors.blueGrey,),
              imageExpanded('回收', '回收列表', Icons.filter_tilt_shift, '2'),
              // '回收', '共$recyclCount个申请', Icons.filter_tilt_shift, '2'),
            ],
          ),
          new Divider(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              imageExpanded('船舶分析', '来港次数', Icons.confirmation_number, '3'),
              // VerticalDivider(color: Colors.red, width:20.0),
              imageExpanded('回收分析', '回收物分析', Icons.table_chart, '4'),
            ],
          ),
          new Divider(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              imageExpanded('船舶查询', '船舶查询', Icons.directions_boat, '5'),
              //  VerticalDivider(color: Colors.blueGrey,),
              imageExpanded('我的', '个人信息', Icons.person, '6'),
            ],
          ),
        ],
      ),
    );
  }

  Expanded imageExpanded(title, subTitle, _icon, _page) {
    return new Expanded(
        child: new Container(
      height: 90.0,
      alignment: Alignment.center,
      child: new Column(
        children: <Widget>[
          ListTile(
            title: new Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                  color: AppConst.appColor),
            ),
            subtitle: new Text(
              subTitle,
              style: TextStyle(fontSize: 10.0),
            ),
            leading: new Icon(
              _icon,
              color: AppConst.appColor,
              size: 50.0,
            ),
            onTap: () => toBoat(_page),
          ),
        ],
      ),
    ));
  }

  Flexible cardExpanded() {
    return new Flexible(
        child: new Container(
      height: 90.0,
      width: 1.0,
      color: Colors.grey,
    ));
  }

  Widget bottomWidget() {
    return new Container(
      alignment: Alignment.topCenter,
      child: new Column(children: <Widget>[
        new Text(
          AppConst.corpName + ' 版权所有',
          style: TextStyle(
              fontSize: 16.0, fontFamily: 'serif', color: AppConst.appColor),
          textAlign: TextAlign.left,
        ),
        new Text(
          AppConst.teckName + ' 提供技术支持',
          style: TextStyle(
              fontSize: 14.0, fontFamily: 'serif', color: AppConst.appColor),
          textAlign: TextAlign.left,
        )
      ]),
    );
  }

  Widget gonggaoWidget() {
    return new Container(
      color: Colors.white70,
      height: 40.0,
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Icon(
              Icons.star,
              color: AppConst.appColor,
            ),
            Expanded(
              child: new Container(
                child: gonggaoSwiperWidget(),
              ),
            ),
            new IconButton(
              icon: Icon(
                Icons.menu,
                color: AppConst.appColor,
              ),
              tooltip: 'More',
              onPressed: () => onGonggaoMore(),
            ),
          ]),
    );
  }

  Widget _gonggaoSwiperBuilder(BuildContext context, int index) {
    return new Text(
      gonggaoList[index]['ggTitle'],
      style: new TextStyle(
          fontFamily: 'serif',
          fontSize: 20.0,
          decorationStyle: TextDecorationStyle.dotted),
      textAlign: TextAlign.center,
    );
  }

//banner轮播图
  Widget swiperWidget() {
    return new SizedBox(
        width: 200.0,
        height: 180.0,
        child: Swiper(
          itemBuilder: _swiperBuilder,
          itemCount: bannerList.length,
          pagination: new SwiperPagination(
              builder: DotSwiperPaginationBuilder(
            color: Colors.black54,
            activeColor: AppConst.appColor,
          )),
          control: new SwiperControl(color: AppConst.appColor),
          scrollDirection: Axis.horizontal,
          autoplay: _autoPlay,
          onTap: (index) => onItemClick(index, '点击了第$index 个'),
        ));
  }

  Widget gonggaoSwiperWidget() {
    return gonggaoList.length > 0
        ? Container(
            child: new RaisedButton(
              child: new Text(
                gonggaoList[gonggaoIndex]['ggTitle'],
                style: TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              onPressed: () {
                onGonggaoItemClick(gonggaoIndex, '点击了第 $gonggaoIndex 个');
              },
              color: Colors.white,
              elevation: 0.0,
            ),
          )
        : new Container();
  }

  Widget gonggaoSwiperWidget2() {
    return new SizedBox(
        height: 40.0,
        child: Swiper(
          itemBuilder: _gonggaoSwiperBuilder,
          itemCount: 3,
          control: new SwiperControl(iconPrevious: null, iconNext: null),
          scrollDirection: Axis.vertical,
          autoplay: true,
          onTap: (index) => onGonggaoItemClick(index, '点击了第$index 个'),
        ));
  }

  void toBoat(_page) {
    if (_page == '1') {
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => BoatPageNew()));
    } else if (_page == '2') {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => RecoverListPageNew()));
    } else if (_page == '3') {
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => BoatAnalyse()));
    } else if (_page == '4') {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => RecoverAnalyse()));
    } else if (_page == '5') {
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => BoatQuery()));
    } else if (_page == '6') {
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => MemberCenter()));
    }
  }

  void onGonggaoItemClick(int i, String articleTitle) {
    String h5Url = gonggaoList[i]['ggUrl'];
    if (null == h5Url || h5Url.isEmpty) {
      return;
    }
    articleTitle = gonggaoList[i]['ggTitle'];
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new WebviewScaffold(
                  url: h5Url,
                  appBar: new AppBar(
                    title: new Text('$articleTitle'),
                    backgroundColor: AppConst.appColor,
                  ),
                )));
  }

  void onItemClick(int i, String articleTitle) {
    String h5Url = bannerList[i]['click_url'];
    if (null == h5Url || h5Url.isEmpty) {
      return;
    }
    articleTitle = bannerList[i]['banner_title'];
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new WebviewScaffold(
                  url: h5Url,
                  appBar: new AppBar(
                    title: new Text('$articleTitle'),
                    backgroundColor: AppConst.appColor,
                  ),
                )));
  }

  void onGonggaoMore() {
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => GongGaoPage()));
  }


  Widget _swiperBuilder(BuildContext context, int index) {
    return bannerList.length > 0
        ? Image.network(
            bannerList[index]['banner_url'],
            fit: BoxFit.cover,
          )
        : new Container();
  }

  Future getToken() async {
    String dbPath = await marineUser.createNewDb();
    Map uMap = await marineUser.getFirstData(dbPath);
    DBUtil.MarineUser mUser = DBUtil.MarineUser.fromMap(uMap);
    setState(() {
      _token = mUser.token;
      userName = mUser.name;
    });
  }

  Future loadData() async {
    String url = marineURL.bannerUrl;

    Map<String, String> _params = {};

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
      } else {
        setState(() {
          bannerList = json.decode(data[AppConst.RESP_DATA]);
        });
      }
    });
  }

  Future<Null> _logout() async {
    String dbPath = await marineUser.createNewDb();
    await marineUser.deleteALL(dbPath).then((_v){
      Navigator.of(context).pushReplacementNamed('/LoginPage');
    });
  }

  Future loadGonggaoData() async {
    String url = marineURL.gonggaoUrl;
    Map<String, String> _params = {'rows': '5', 'page': '1'};
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
      if (rescode != '10') {
      } else {
        setState(() {
          try {
            Map<String, dynamic> _dataMap = json.decode(data[AppConst.RESP_DATA]);
            gonggaoList.clear();
            gonggaoList.addAll(_dataMap['rows']);
          } catch (e) {

          }
        });
      }
    });
  }
}

class GridViewState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) => new GridView.count(
      primary: false,
      padding: const EdgeInsets.all(8.0),
      mainAxisSpacing: 8.0, //竖向间距
      crossAxisCount: 2, //横向Item的个数
      crossAxisSpacing: 8.0, //横向间距
      children: buildGridTileList(5));

  List<Widget> buildGridTileList(int number) {
    List<Widget> widgetList = new List();
    for (int i = 0; i < number; i++) {
      widgetList.add(getItemWidget());
    }
    return widgetList;
  }

  String url =
      "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=495625508,"
      "3408544765&fm=27&gp=0.jpg";
  Widget getItemWidget() {
    //BoxFit 可设置展示图片时 的填充方式
    return new Image(image: new NetworkImage(url), fit: BoxFit.cover);
  }
}
