import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marine_app/HomePage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BoatDetailPage extends StatefulWidget {

  final String carId;

  BoatDetailPage({this.carId});

  @override
  State<StatefulWidget> createState() {
    return new BoatDetailPageState(carId: carId);
  }

}

class BoatDetailPageState extends State<BoatDetailPage>{

  String carId; //船舶号
  BoatDetailPageState({this.carId});
  final TextEditingController facIdController = new TextEditingController();
  final TextEditingController carNoController = new TextEditingController();
  final TextEditingController carTypeController = new TextEditingController();
  final TextEditingController carBelongController = new TextEditingController();
  final TextEditingController carUnitController = new TextEditingController();
  final TextEditingController carOwnerController = new TextEditingController();
  final TextEditingController carContactController = new TextEditingController();

  String facId = ""; //港口信息
  String carNo = ""; //船舶牌照
  String carType = ""; //船舶类型
  String carBelong = ""; //船港籍
  String carUnit = ""; //船吨位
  String carOwner = ""; //船主
  String carContact = ""; //联系方式
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

   Future getData() async {
     if (carId.isNotEmpty) {
       isLoading = true;
        await Future.delayed(Duration(seconds: 3), () {
              setState(() {
                facId = "KXXX_000001"; //港口信息
                carNo = "CBPZ_000002"; //船舶牌照
                carType = "CBLX_00000r"; //船舶类型
                carBelong = "CGJ_999999"; //船港籍
                carUnit = "CDW_877666"; //船吨位
                carOwner = "CZ_OWNER_123"; //船主
                carContact = "13888888888"; //联系方式
                facIdController.text = facId;
                carNoController.text = carNo;
                carTypeController.text = carType;
                carBelongController.text = carBelong;
                carUnitController.text = carUnit;
                carOwnerController.text = carOwner;
                carContactController.text = carContact;
              });
              isLoading = false;
            });
     }
    
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: 
            AppBar(
              title: Text('船舶详情'),
              backgroundColor: Colors.greenAccent,
            ),
            body: isLoading?loading():geneColumn(),
      ) ;
  }


  Widget loading() {
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

  Widget geneColumn() {
    return new Column(
        children: <Widget>[
              _geneRow('港口信息','facId', facIdController),
              _div(),
              _geneRow('船舶牌照','carNo', carNoController),
              _div(),
              _geneRow('船舶类型','carType', carTypeController),
              _div(),
              _geneRow('船港籍','carBelong', carBelongController),
              _div(),
              _geneRow('船吨位','carUnit', carUnitController),
              _div(),
              _geneRow('船主','carOwner', carOwnerController),
              _div(),
              _geneRow('联系方式','carContact', carContactController),
              _div(),
              geneButton('',''),
            ]
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



  Widget _geneRow (String _title, String _key,TextEditingController _controller,  {Widget w3} ) {
  return new Container(
      color: Colors.white70,
      height: 50.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
          new Container(
            width: 100.0,
            child: new Text('$_title:', overflow:TextOverflow.ellipsis,softWrap:false, textAlign: TextAlign.right, style: TextStyle(fontSize: 14.0, color: Colors.black45,fontWeight: FontWeight.w700),),
          ),
          Expanded(
            child:
            new Container(
              alignment: Alignment.center,
              child: new TextField(
                        controller: _controller,
                        onChanged: (world) {
                            if (_key == 'facId') {
                              facId = world;
                            } else if (_key == 'carNo') {
                              carNo = world;
                            } else if (_key == 'carType') {
                              carType = world;
                            } else if (_key == 'carBelong') {
                              carBelong = world;
                            } else if (_key == 'carUnit') {
                              carUnit = world;
                            } else if (_key == 'carOwner') {
                              carOwner = world;
                            } else if (_key == 'carContact') {
                              carContact = world;
                            }
                          },
                          style: new TextStyle(
                              fontSize: 15.0, color: Colors.black),
                          decoration: new InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            hintText: '请输入$_title ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13.0),
                              hintStyle: TextStyle(fontSize: 12.0),
                              ),
                        ),
            ),
          ),
          null==w3?new Container(
            child: IconButton(
            icon: Icon(Icons.camera_enhance, size: 40.0, color: Colors.white,),
            onPressed: null,
          ),
          ):w3
      ]
    ),
    );
  }

}
