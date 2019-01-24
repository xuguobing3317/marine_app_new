import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;
import 'package:marine_app/member/ModifyPwdPage.dart';
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:marine_app/common/AppConst.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class MemberCenter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExpandedAppBarState();
}

class _ExpandedAppBarState extends State<MemberCenter> {
DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();
  String userName='';
  String token='';

//   mine	我的信息
// helpduc	帮助中心
// sysintrodu	系统简介
// yaqueyang	关于鸦雀漾
// bomar	关于宝码
String mine = '';
String helpduc = '';
String sysintrodu = '';
String yaqueyang = '';
String bomar = '';

List urlList = [];

  var titles = [ 
    {'title':'我的信息','imagePath':'images/ic_my_message.png','titleKey':'mine'},
    {'title':'帮助中心','imagePath':'images/ic_my_blog.png','titleKey':'helpduc'},
    {'title':'修改密码','imagePath':'images/ic_my_question.png','titleKey':'modifypwd'},
    {'title':'系统简介','imagePath':'images/ic_discover_pos.png','titleKey':'sysintrodu'},
    {'title':'关于雅雀漾','imagePath':'images/ic_my_team.png','titleKey':'yaqueyang'},
    {'title':'关于宝码','imagePath':'images/ic_my_recommend.png','titleKey':'bomar'}
  ];

  Future<Map> getDataForSql() async {
    String dbPath = await marineUser.createNewDb();
    await marineUser.createTable(dbPath);
    Map uMap = await marineUser.getFirstData(dbPath);
    return uMap;
  }

   @override
  void initState() {
    super.initState();
    getDataForSql().then((dataMap){
      if (null != dataMap) {
      setState(() {
        userName = dataMap[DBUtil.columnName];
        token = dataMap[DBUtil.columnToken];
      });
      }
    });

    var _duration = new Duration(seconds: 1);
    new Future.delayed(_duration, getData);
    
  }


  Future<bool> getData() async {

    Map<String, String> _params = {};

    String url = marineURL.memberUrl;
    Map<String, String> _header = {'token': token};
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
      if (rescode == '14') {
        Fluttertoast.instance.showToast(
            msg: '请重新登录',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
        _logout();
      } else if (rescode != '10') {
        String _msg = '未查询到数据[$resMsg]';
        Fluttertoast.instance.showToast(
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
          urlList = json.decode(data[AppConst.RESP_DATA]);
          urlList.forEach((_item){
            String _key = _item['TYPE'];
            String _h5Url = _item['URL'];
            titles.forEach((_titleMap){
              String _titleKey = _titleMap['titleKey'];
              if(_titleKey == _key) {
                _titleMap['h5Url']=_h5Url;
              }
            });
          });
          // mine = (null==content['mine'])?'-':content['mine'].toString(); //我的信息
          // helpduc = (null==content['helpduc'])?'-':content['helpduc'].toString(); //帮助中心
          // sysintrodu = (null==content['sysintrodu'])?'-':content['sysintrodu'].toString();  //系统简介
          // yaqueyang = (null==content['yaqueyang'])?'-':content['yaqueyang'].toString();  //关于鸦雀漾
          // bomar =  (null==content['bomar'])?'-':content['bomar'].toString(); //关于宝码
        });
      }
    });
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final heightScreen = MediaQuery.of(context).size.height;
    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(''),
          backgroundColor: AppConst.appColor,
          expandedHeight: heightScreen/4,
          floating: false,
          pinned  :true,
          flexibleSpace:  new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      image: new DecorationImage(
                          image: new AssetImage('images/cycle4.png'),
                          fit: BoxFit.none),
                      border: new Border.all(color: Colors.white, width: 2.0)),
                ),
                new Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  child: new Text(
                    '欢迎您，$userName',
                    style: new TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                )
              ],
            ),
        ),
          new SliverFixedExtentList(
          delegate:
              new SliverChildBuilderDelegate((BuildContext context, int index) {
            return _buildItem(index);
          }, childCount: titles.length+1),
          itemExtent: 50.0)
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    if (index == titles.length) {
      return geneButton();
    } else {
      return _buildItem2(index);
    }
  }



  Widget _buildItem2(int index) {
    String _title = titles[index]['title'];
    return new InkWell(
      onTap: (){ 
        if (index == 2) {
          Navigator.push(
              context, new MaterialPageRoute(builder: (context) => ModifyPwdPage()));
        } else {
        onItemClick(index);
      }},
      child: Container(
      decoration: new BoxDecoration(
    border: new Border.all(width:1.0,color: Colors.green[50]),
    borderRadius: new BorderRadius.all(new Radius.circular(1.0)),),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[
          Positioned(
              left: 40.0,
              child:  Text(
                    titles[index]['title'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              )),
          ClipRRect(
            child: SizedBox(
              width: 25.0,
              height: 25.0,
              child: Image.asset(
                titles[index]['imagePath'],
                fit: BoxFit.cover,
                color: AppConst.appColor,
              ),
            ),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ],
      ),
    ),
    );  
    
  }

  void onItemClick(int i) {
    String h5Url = titles[i]['h5Url'];
    String _title = titles[i]['title'];
    print('h5Url======================$h5Url');
    if (null == h5Url || h5Url.isEmpty 
    // || !h5Url.toLowerCase().startsWith('http')
    ) {
      Fluttertoast.instance.showToast(
              msg: " 您点击的是:$_title ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
      return;
    }
    String articleTitle = titles[i]['title'];
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


  Future<Null> _logout() async {
    String dbPath = await marineUser.createNewDb();
    await marineUser.deleteByName(userName, dbPath).then((_v){
      Navigator.of(context).pushReplacementNamed('/LoginPage');
    });
    
  }

  Widget geneButton() {
    return new Container(
      color: Colors.white70,
      height: 60.0,
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              width: 50.0,
              child: new Text(
                '',
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
                color: Colors.redAccent,
                elevation: 10,
                highlightElevation: 10,
                disabledElevation: 10,
                child: new Text(
                  '退出登录',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0),
                ),
                onPressed: _logout,
              ),
            )),
            new Container(
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
          ]),
    );
  }
}
