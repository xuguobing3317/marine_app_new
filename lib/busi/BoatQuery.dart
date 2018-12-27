import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marine_app/HomePage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';

class BoatQuery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new BoatQueryPageState();
  }

}

class BoatQueryPageState extends State<BoatQuery>{

  
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
  String totalLifeWeight = "";//累计回收生活垃圾
  String totalOilWeight = "";//累计回收油污垃圾
  String lastDgTime = "";//上次到岗时间
  String totalDgCount = "";//累计到岗次数
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
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return false;
     }

     setState(() {
            loadFlag = '2';
          });
       
      await Future.delayed(Duration(seconds: 3), () {
            setState(() {
              facId = "KXXX_000001"; //港口信息
              carNo = "CBPZ_000002"; //船舶牌照
              carType = "CBLX_00000r"; //船舶类型
              carBelong = "CGJ_999999"; //船港籍
              carUnit = "CDW_877666"; //船吨位
              carOwner = "CZ_OWNER_123"; //船主
              carContact = "13888888888"; //联系方式
              totalLifeWeight = "100.23吨";//累计回收生活垃圾
              totalOilWeight = "1870.23吨";//累计回收油污垃圾
              lastDgTime = "2018-12-27 17:25:48";//上次到岗时间
              totalDgCount = "67 次";//累计到岗次数
            });
            loadFlag = '3';
          });
  return true;
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
     appBar: new PreferredSize(
        preferredSize: Size.fromHeight(110),
        child:
        new Column(
          children: <Widget>[
            AppBar(
              title: Text('船舶信息'),
              backgroundColor: Colors.greenAccent,
      ),
      search()
          ],
        ),
      ) ,
            body: getBody(),
      ) ;
  }

  Widget getBody() {
    if (loadFlag == '1') {
      return loading();
    } else if (loadFlag == '3') {
      return geneColumn();
    } else {
      return querying();
    }
  }

  Widget querying() {
    return new Stack(
              children: <Widget>[        new Padding(
                  padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 35.0),
                  child: new Center( child: SpinKitFadingCircle( color: Colors.blueAccent, size: 30.0, ), ),
                ),        new Padding(
                  padding: new EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
                  child: new Center( child: new Text('船舶信息加载中...'), ),
                ),
              ],
            );
  }


  Widget loading() {
    return new Stack(
              children: <Widget>[        new Padding(
                  padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 80.0),
                  child: new Center( child: 
                  new InkWell(
                    onTap: (){
                      doScanCode();
                    },
                    child:
                  Icon(Icons.search, size: 100.0, color: Colors.greenAccent,), )),
                ),        new Padding(
                  padding: new EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
                  child: new Center( child: new Text('请扫描二维码', style: TextStyle(color: Colors.greenAccent),), ),
                ),
              ],
            );
  }

  Widget geneColumn() {
return new SingleChildScrollView (
   child: new ConstrainedBox(
          constraints: new BoxConstraints(
            minHeight: 200.0,
          ),
          child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
              _geneRow('港口信息',facId),
              _div(),
              _geneRow('船舶牌照',carNo),
              _div(),
              _geneRow('船舶类型',carType),
              _div(),
              _geneRow('船港籍',carBelong),
              _div(),
              _geneRow('船吨位',carUnit),
              _div(),
              _geneRow('船主',carOwner),
              _div(),
              _geneRow('联系方式',carContact),
              _div(),
              _geneRow('累计生活垃圾',totalLifeWeight),
              _div(),
              _geneRow('累计油污垃圾',totalOilWeight),
              _div(),
              _geneRow('上次到岗时间',lastDgTime),
              _div(),
              _geneRow('累计到岗次数',totalDgCount),
            ]))
      );
  }

  Widget geneButton (_title, _key, {Widget w3}) {
  return new Container(
      color: Colors.white70,
      height: 60.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
          new Container(
            width: 50.0,
            child: new Text('$_title', overflow:TextOverflow.ellipsis,softWrap:false, textAlign: TextAlign.right, style: TextStyle(fontSize: 14.0, color: Colors.black45,fontWeight: FontWeight.w700),),
          ),
          Expanded(
            child:
            new Container(
              padding: new EdgeInsets.fromLTRB(1.0, 0.0, 1.0, 0.0),
              child: new RaisedButton(
                color: Colors.greenAccent,
                elevation: 10,
                highlightElevation: 10,
                disabledElevation: 10,
                child: new Text('保 存',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16.0),),
                onPressed: (){
                  _forSubmitted(facId, context);
                },
              ),
          )),
          null==w3?new Container(
            width: 50.0,
            child: IconButton(
            icon: Icon(Icons.camera_enhance, size: 40.0, color: Colors.white,),
            onPressed: null,
          ),
          ):w3
      ]
    ),
    );
  }


  Future<bool> _forSubmitted(String _fileOwner, BuildContext context) async {
     try {
    if (facId == '') {
        Fluttertoast.showToast(
              msg: " 请输入港口信息 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return false;
    }

    String url =
        "http://116.62.149.237:8080/USR000100001?usrName=admin&passwd=123456";

      // result = await http.get(url).then((http.Response response) {
        // var data = json.decode(response.body);
        // String rescode = data["rescode"];
        String rescode = '000000';
        if (rescode == '999999') {
          Fluttertoast.showToast(
              msg: " 保存失败 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return false;
        } else if (rescode == '000000') {
          Navigator.of(context).push(new PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) {
                  return new HomePage();
                },
              ));
          Fluttertoast.showToast(
              msg: "  保存成功！ ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
        }
    } catch (e) {
      Fluttertoast.showToast(
              msg: "  保存失败 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
      return false;
    }
    return true;
  }

  Widget _div(){
    return new Container(
      height: 1.0,
      child: new Divider(color: Colors.greenAccent,),
    );
  }



  Widget _geneRow (String _title, String _key ) {
  return new Container(
      color: Colors.white70,
      height: 50.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
          new Container(
            width: 130.0,
            child: new Text('$_title:', overflow:TextOverflow.ellipsis,softWrap:false, textAlign: TextAlign.right, style: TextStyle(fontSize: 12.0, color: Colors.black45,fontWeight: FontWeight.w700),),
          ),
          Expanded(
            child:
            new Container(
              alignment: Alignment.center,
              child: new Text(_key,
                          style: new TextStyle(
                              fontSize: 12.0, color: Colors.black),
                        ),
            ),
          )
      ]
    ),
    );
  }


  Widget search() {
    return new Container(
      decoration:new BoxDecoration(
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
                  onChanged: (word)=>barcode = word,
                  style: new TextStyle(fontSize: 15.0, color: Colors.black),
                  decoration: new InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    hintText: '请输入搜索条件 ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0),),
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.0),
                    hintStyle: TextStyle(fontSize: 12.0),
                  ),
                ),
              ),
            ),
            new Container(child: 
            IconButton(
              icon: Icon(Icons.search),
              iconSize: 40.0,
              onPressed: getData,
              color: Colors.greenAccent,
            ),),new Container(child: 
            IconButton(
              icon: Icon(Icons.camera),
              iconSize: 40.0,
              onPressed: doScanCode,
              color: Colors.greenAccent,
            ),),
          ],
        ),
      );
  }

  Future<void> doScanCode() async {
    await scanCode().then(
      (flag){
      getData();
      }
    );
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
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return false;
        });
      } else {
        setState(() {
           Fluttertoast.showToast(
              msg: " 请重新扫描 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return false;
        });
      }
    } on FormatException{
      setState(() {
           Fluttertoast.showToast(
              msg: " 请重新扫描 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return false;
        });
    } catch (e) {
      setState(() {
           Fluttertoast.showToast(
              msg: " 请重新扫描 ",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos:1,
              backgroundColor: Color(0xFF499292),
              textColor: Color(0xFFFFFFFF)
          );
          return false;
        });
    }
    return false;
  }

}
