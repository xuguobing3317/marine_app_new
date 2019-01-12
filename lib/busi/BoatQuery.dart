import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:marine_app/common/AppConst.dart';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marine_app/common/AppUrl.dart' as marineURL;
import 'package:marine_app/common/AppConst.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:marine_app/common/SqlUtils.dart' as DBUtil;

class BoatQuery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new BoatQueryPageState();
  }
}

class BoatQueryPageState extends State<BoatQuery> {
  final TextEditingController boatController = new TextEditingController();
  String barcode = "";

  String carId; //船舶号
  String facId = ""; //港口信息
  String carNo = ""; //船舶牌照
  String carType = ""; //船舶类型
  String carBelong = ""; //船港籍
  String carUnit = ""; //船吨位
  String carOwner = ""; //船主
  String carContact = ""; //联系方式
  String totalLifeWeight = ""; //累计回收生活垃圾
  String totalOilWeight = ""; //累计回收油污垃圾
  String lastDgTime = ""; //上次到岗时间
  String totalDgCount = ""; //累计到岗次数
  String totalWeight = ""; //累计回收
  String loadFlag = '1';

  @override
  void initState() {
    super.initState();
  }

  Future<bool> getData() async {
    if (barcode == '') {
      Fluttertoast.showToast(
          msg: " 请扫描船舶二维码 ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xFF499292),
          textColor: Color(0xFFFFFFFF));
      return false;
    }

    setState(() {
      loadFlag = '2';
    });

    String url = marineURL.GetLastRubishDataUrl;

    Map<String, String> _params = {
      'Carid': barcode,
    };
    DBUtil.MarineUserProvider marineUser = new DBUtil.MarineUserProvider();
    String dbPath = await marineUser.createNewDb();
    Map uMap = await marineUser.getFirstData(dbPath);
    if (uMap == null) {
      Navigator.of(context).pushReplacementNamed('/LoginPage');
    }
    DBUtil.MarineUser mUser = DBUtil.MarineUser.fromMap(uMap);
    String _token = mUser.token;
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
      String resMsg = data[AppConst.RESP_MSG];
      if (rescode != '10' && rescode != '20') {
        String _msg = '未查询到数据[$resMsg]';
        Fluttertoast.showToast(
            msg: _msg,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xFF499292),
            textColor: Color(0xFFFFFFFF));
            setState(() {
                          loadFlag = '4';
                        });
      } else {
        setState(() {
          var content = json.decode(data[AppConst.RESP_DATA]);
          print(content);
          facId = (null==content['FACNAME'])?'-':content['FACNAME'].toString(); //港口信息
          carNo = (null==content['CARNO'])?'-':content['CARNO'].toString(); //船舶牌照
          carType = (null==content['CARTYPE'])?'-':content['CARTYPE'].toString();  //船舶类型
          carBelong = (null==content['CARVENDID'])?'-':content['CARVENDID'].toString();  //船港籍
          carUnit =  (null==content['CARCAP'])?'-':content['CARCAP'].toString(); //船吨位
          carOwner = (null==content['EMPID'])?'-':content['EMPID'].toString(); //船主
          carContact = (null==content['MEMO'])?'-':content['MEMO'].toString(); //联系方式
          totalLifeWeight = (null==content['CARRQTY'])?'-':content['CARRQTY'].toString();  //累计回收生活垃圾
          totalOilWeight = (null==content['CARQTY2'])?'-':content['CARQTY2'].toString(); //累计回收油污垃圾
          lastDgTime = (null==content['CARDATE1'])?'-':content['CARDATE1'].toString(); //上次到岗时间
          totalDgCount = (null==content['CARSENO'])?'-':content['CARSENO'].toString();//累计到岗次数
          totalWeight = (null==content['CARRQTY'])?'-':content['CARRQTY'].toString();//累计到岗次数
          loadFlag = '3';
        });
      }
    });
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new PreferredSize(
        preferredSize: Size.fromHeight(110),
        child: new Column(
          children: <Widget>[
            AppBar(
              title: Text('船舶信息'),
              backgroundColor: Colors.greenAccent,
            ),
            search()
          ],
        ),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    if (loadFlag == '1') {
      return loading();
    } else if (loadFlag == '3') {
      return geneColumn();
    } else if (loadFlag == '4') {
      return noData(context);
    } else {
      return querying();
    }
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
              '船舶信息加载中...',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget loading() {
    return new Stack(
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 80.0),
          child: new Center(
              child: new InkWell(
            onTap: () {
              doScanCode();
            },
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
              '请扫描二维码',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget geneColumn() {
    return new SingleChildScrollView(
        child: new ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: 200.0,
            ),
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _geneRow('港口信息', facId),
                  _div(),
                  _geneRow('船舶牌照', carNo),
                  _div(),
                  _geneRow('船舶类型', carType),
                  _div(),
                  _geneRow('船港籍', carBelong),
                  _div(),
                  _geneRow('船吨位', carUnit),
                  _div(),
                  _geneRow('船主', carOwner),
                  _div(),
                  _geneRow('联系方式', carContact),
                  _div(),
                  _geneRow('累计回收', totalWeight),
                  _div(),
                  _geneRow('上次到岗时间', lastDgTime),
                  _div(),
                  _geneRow('累计到岗次数', totalDgCount),
                ])));
  }

  

  

  Widget _div() {
    return new Container(
      height: 1.0,
      child: new Divider(
        color: Colors.greenAccent,
      ),
    );
  }

  Widget _geneRow(String _title, String _key) {
    return new Container(
      color: Colors.white70,
      height: 50.0,
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              width: 130.0,
              child: new Text(
                '$_title:',
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black45,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: new Container(
                alignment: Alignment.center,
                child: new Text(
                  _key,
                  style: new TextStyle(fontSize: 12.0, color: Colors.black),
                ),
              ),
            )
          ]),
    );
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
              onPressed: getData,
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
      getData();
    });
  }

  Future<bool> scanCode() async {
    print('开始扫描二位吗');
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
