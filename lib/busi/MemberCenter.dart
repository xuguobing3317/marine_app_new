import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;
import 'package:marine_app/member/ModifyPwdPage.dart';

class MemberCenter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExpandedAppBarState();
}

class _ExpandedAppBarState extends State<MemberCenter> {
DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();
  String userName='';

  var titles = ["我的信息", "帮助中心", "修改密码", "系统简介", "关于雅雀漾", "关于宝码"];
  var imagePaths = [
    "images/ic_my_message.png",
    "images/ic_my_blog.png",
    "images/ic_my_question.png",
    "images/ic_discover_pos.png",
    "images/ic_my_team.png",
    "images/ic_my_recommend.png"
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
      });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final heightScreen = MediaQuery.of(context).size.height;
    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(''),
          backgroundColor: Colors.greenAccent,
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
                          image: new AssetImage('images/lunch_yasuo.png'),
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
    String _title = titles[index];
    return new InkWell(
      onTap: (){ 
        if (index == 2) {
          Navigator.push(
              context, new MaterialPageRoute(builder: (context) => ModifyPwdPage()));
        } else {
        Fluttertoast.showToast(
              msg: " 您点击的是:$_title ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
        }
      },
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
                    titles[index],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              )),
          ClipRRect(
            child: SizedBox(
              width: 25.0,
              height: 25.0,
              child: Image.asset(
                imagePaths[index],
                fit: BoxFit.cover,
                color: Colors.greenAccent,
              ),
            ),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ],
      ),
    ),
    );  
    
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
