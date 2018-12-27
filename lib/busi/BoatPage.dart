import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'BoatDetail.dart';



class BoatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BoatPageState();
}


class BoatPageState extends State<BoatPage> {
  
  String barcode = "";
  List<Map> _itemMap = new List<Map>();
  int listLen = 0;
  ScrollController _scrollController = ScrollController();
  int _page = 1; //加载的页数
  bool isLoading = false; //是否正在加载数据
  final TextEditingController boatController = new TextEditingController();


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

  Future getData() async {
    String title = "船牌号：ISO8899-苏E-";
    String title2="码头：苏州宝码,  所有人:汪老板";
    if (barcode.isNotEmpty) {
      title = "船牌号：$barcode-苏E-";
      title2 = "码头：$barcode,  所有人:$barcode";
    }
    
    await Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _itemMap = List.generate(10, (i)=>
          {'carid': '$title$i', 'facid':'$title2$i', 'empId': 'empId$i', 'carNo':'carNo$i'});
          listLen = _itemMap.length;
      });
    });
  }


Future _getMore() async {
    if (!isLoading) {
      setState(() {
        Map _addMap = {'carid': 'loading', 'facid':'loading', 'empId': 'loading', 'carNo':'loading'};
        _itemMap.add(_addMap);
        isLoading = true;
      });

  String title = "船牌号：ISO8899-苏E-";
      String title2="码头：苏州宝码,  所有人:汪老板";
      if (barcode.isNotEmpty) {
        title = "船牌号：$barcode-苏E-";
        title2 = "码头：$barcode,  所有人:$barcode";
      }

      await Future.delayed(Duration(seconds: 3), () {
        setState(() {
          int size = listLen;
          _itemMap.removeLast();
          _itemMap.addAll(List.generate(10, (i)=>
          {'carid': '$title${i+size}', 'facid':'$title2${i+size}', 'empId': 'empId${i+size}', 'carNo':'carNo${i+size}'}
          ));
          _page++;
          isLoading = false;
          listLen = _itemMap.length;
        });
      });
    }
  }


  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
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
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add, size: 40.0, color: Colors.white70,),
                  tooltip: 'Air it',
                  onPressed: () => showBoatDetail(''),
                ),
        ],
      ),
      search()
          ],
        ),
      ) ,
      body: _itemMap.length==0?(
        new Stack(
              children: <Widget>[        new Padding(
                  padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 35.0),
                  child: new Center( child: SpinKitFadingCircle( color: Colors.blueAccent, size: 30.0, ), ),
                ),        new Padding(
                  padding: new EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
                  child: new Center( child: new Text('船舶列表加载中....'), ),
                ),
              ],
            )
      ):(
      RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  itemBuilder: _renderRow,
                  itemCount: listLen+1,
                  controller:_scrollController
                ),
              ))
      );
  }

  Widget itemCard(int i) {
    return new Card(
      child: new ListTile(
          title: new Text(_itemMap[i]['carid']),
          subtitle: new Text(_itemMap[i]['facid']),
          //之前显示icon
          leading: new Icon(Icons.directions_boat, color: Colors.greenAccent,size: 30.0,),
          onTap: () => showBoatDetail(_itemMap[i]['carid'])
    )
    );
  }

  void showBoatDetail(String _v) {
      Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => BoatDetailPage(carId:_v)));
  }

  Future<Null> _onSearch() async {
    setState(() {
        _itemMap = new List<Map>();
        listLen = _itemMap.length;
      });
    if (barcode==null || barcode.isEmpty) {
        _onRefresh();
    } else {
      await Future.delayed(Duration(seconds: 3), () {
            setState(() {
              _itemMap = List.generate(10, (i)=>
                {'carid': '船牌号：$barcode-苏E-$i', 'facid':'苏州宝码码头$barcode-$i', 'empId': 'empId$i', 'carNo':'carNo$i'}
                );
                isLoading = false;
                listLen = _itemMap.length;
            });
          });
    }
  }


  Future<Null> _onRefresh() async {
     String title = "船牌号：ISO8899-苏E-";
      String title2="码头：苏州宝码,  所有人:汪老板";
      if (barcode.isNotEmpty) {
        title = "船牌号：$barcode-苏E-";
        title2 = "码头：$barcode,  所有人:$barcode";
      }
    await Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _itemMap = List.generate(10, (i)=>
          {'carid': '$title$i', 'facid':'$title2$i', 'empId': 'empId$i', 'carNo':'carNo$i'}
          );
          isLoading = false;
          listLen = _itemMap.length;
      });
    });
  }
  
  Widget _renderRow(BuildContext context, int index) {
    if (index < listLen) {
      return itemCard(index);
    } else {
        if (listLen != _itemMap.length) {
          return _getMoreWidget();
        } else {
          return _getMoreWidget2();
        }
    }
  }

  Widget _getMoreWidget2() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }


  Widget _getMoreWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '加载中...',
              style: TextStyle(fontSize: 16.0),
            ),
            SpinKitFadingCircle( color: Colors.blueAccent, size: 30.0, )
            // CircularProgressIndicator(
            //   strokeWidth: 1.0,
            // )
          ],
        ),
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
              onPressed: _onSearch,
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
      _onSearch();
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
