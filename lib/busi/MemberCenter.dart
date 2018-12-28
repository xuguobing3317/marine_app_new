import 'package:flutter/material.dart';

class MemberCenter extends StatefulWidget {
  @override
  _MyInfoPageState createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MemberCenter> {
  static const double IMAGE_ICON_WIDTH = 30.0;
  static const double ARROW_ICON_WIDTH = 16.0;

  var userName = 'admin';
  var   userAvatar = 'http://www.wanandroid.com/resources/image/pc/logo.png';
  var titles = ["我的消息", "阅读记录", "我的博客", "我的问答", "我的活动", "我的团队", "邀请好友"];
  var imagePaths = [
    "images/ic_my_message.png",
    "images/ic_my_blog.png",
    "images/ic_my_blog.png",
    "images/ic_my_question.png",
    "images/ic_discover_pos.png",
    "images/ic_my_team.png",
    "images/ic_my_recommend.png"
  ];

  var titleTextStyle = new TextStyle(fontSize: 16.0);
  var rightArrowIcon = new Image.asset(
    'images/ic_arrow_right.png',
    width: ARROW_ICON_WIDTH,
    height: ARROW_ICON_WIDTH,
  );

  @override
  void initState() {
    super.initState();
     
  }

  @override
  Widget build(BuildContext context) {
    return initView();
  }

//  构建布局
  Widget initView() {
    return new CustomScrollView(reverse: false, shrinkWrap: false, slivers: <
        Widget>[
      new SliverAppBar(
        pinned: false,
        backgroundColor: Colors.green,
        expandedHeight: 200.0,
        iconTheme: new IconThemeData(color: Colors.transparent),
        flexibleSpace: new InkWell(
            onTap: () {
              _login();
            },
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                userAvatar == null
                    ? new Image.asset(
                        "images/lunch_yasuo.png",
                        width: 60.0,
                        height: 60.0,
                      )
                    : new Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            image: new DecorationImage(
                                image: new NetworkImage(userAvatar),
                                fit: BoxFit.cover),
                            border: new Border.all(
                                color: Colors.white, width: 2.0)),
                      ),
                new Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  child: new Text(
                    userName == null ? '点击头像登录' : userName,
                    style: new TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                )
              ],
            )),
      ),
      new SliverFixedExtentList(
          delegate:
              new SliverChildBuilderDelegate((BuildContext context, int index) {
            String title = titles[index];
            return new Container(
                alignment: Alignment.centerLeft,
                child: new InkWell(
                  onTap: () {
                    // print("the is the item of $title");
                  },
                  child: new Row(
                          children: <Widget>[
                            new Expanded(
                                child: new Text(
                              title,
                              style: titleTextStyle,
                            )),
                            rightArrowIcon
                          ],
                        ),
                  
                  // new Column(
                  //   children: <Widget>[
                  //     new Container(
                  //       child: new Row(
                  //         children: <Widget>[
                  //           new Expanded(
                  //               child: new Text(
                  //             title,
                  //             style: titleTextStyle,
                  //           )),
                  //           rightArrowIcon
                  //         ],
                  //       ),
                  //     ),
                  //     new Divider(
                  //       height: 1.0,
                  //     )
                  //   ],
                  // ),
                ));
          }, childCount: titles.length),
          itemExtent: 50.0),
    ]);
  }

  _login() async {
    // final result = await Navigator.of(context)
    //     .push(new MaterialPageRoute(builder: (context) {
    //   return new LoginPage();
    // }));
    
    Navigator.of(context).pushReplacementNamed('/LoginPage');
  }

 
}
