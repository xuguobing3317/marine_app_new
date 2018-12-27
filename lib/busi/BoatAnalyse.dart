import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'BoatDetail.dart';
import 'package:marine_app/common/DateUtil.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter/src/material/dialog.dart' as Dialog;

class BoatAnalyse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BoatAnalyseState();
}


class BoatAnalyseState extends State<BoatAnalyse> {

  String dataFlag = '1';//1:标示初始化，  2;表示已经查询过
  
  String barcode = "";
  String gangkou = "";
  List<Map> _itemMap = new List<Map>();
  final TextEditingController boatController = new TextEditingController();
  Color todayDateColor = Colors.greenAccent;
  Color yesterdayDateColor = Colors.grey;
  Color weekDateColor = Colors.grey;
  Color monthDateColor = Colors.grey;
  Color otherDateColor = Colors.grey;
  String dateView = DateUtil.formatDateTime(DateUtil.getNowDateStr(),
  DateFormat.YEAR_MONTH_DAY, null , null);

  String startDate = '';
  String endDate = '';

  String gangkouId = '';
  String gangkouName = '';

  List<PickerItem> gangkouItems = new List();
  List<Map> gangkouList3 = new List();

  
  static String _time = DateUtil.formatDateTime(DateUtil.getNowDateStr(),
  DateFormat.ZH_NORMAL, null , null);

  List<Map> dataMapQuery = [
    {'boatNo':'ISO88090001','boatOwner':'苏州船0001','weight':'120.3','count':'32','dgtime': _time},
    {'boatNo':'ISO88090002','boatOwner':'苏州船0002','weight':'67.3','count':'3','dgtime': _time},
    {'boatNo':'ISO88090003','boatOwner':'苏州船0003','weight':'3','count':'3','dgtime':_time},
    {'boatNo':'ISO88090004','boatOwner':'苏州船0004','weight':'3','count':'3','dgtime':_time},
    {'boatNo':'ISO88090005','boatOwner':'苏州船0005','weight':'3','count':'3','dgtime':_time},
    {'boatNo':'ISO88090006','boatOwner':'苏州船0005','weight':'3','count':'3','dgtime':_time},
    {'boatNo':'ISO88090007','boatOwner':'苏州船0005','weight':'3','count':'3','dgtime':_time},
    {'boatNo':'ISO88090008','boatOwner':'苏州船0005','weight':'3','count':'3','dgtime':_time},
    {'boatNo':'ISO88090009','boatOwner':'苏州船0005','weight':'3','count':'3','dgtime':_time},
    {'boatNo':'ISO88090010','boatOwner':'苏州船0005','weight':'3','count':'3','dgtime':_time},
    {'boatNo':'ISO88090011','boatOwner':'苏州船0005','weight':'3','count':'3','dgtime':_time},
    {'boatNo':'ISO88090012','boatOwner':'苏州船0005','weight':'3','count':'3','dgtime':_time},
  ];

  List<Map> dataMap = [
  ];

  Color allTypeColor = Colors.greenAccent;
  Color lifeTypeColor = Colors.grey;
  Color oilTypeColor = Colors.grey;

  Color gangkouColor = Colors.grey;

  String  typeView = '全部';

  String total1 = '';
  String total2 = '';
  Color bootSheetColor = Colors.white;

  

  @override
  void initState() {
    super.initState();
    getGangkouData();
  }

  Future getGangkouData() async {
    String title = '苏州码头';
    if (null != gangkou && gangkou.isNotEmpty) {
      title = gangkou;
    }
    setState(() {
      gangkouList3.clear();
      gangkouItems.clear();
      for (int i=0; i<10; i++) {
        String _text = title + '$i';
        PickerItem gangkouItem = new PickerItem(text: Text(_text));
        Map _map = {'gkId': 'gkId$i', 'gkName': _text};
        gangkouList3.add(_map);
        gangkouItems.add(gangkouItem);
      }
    });
    

  }

  @override
  void dispose() {
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    // return new MaterialApp(
    return new Scaffold(
       appBar: AppBar(
        title: Text('船舶分析'),
        backgroundColor: Colors.greenAccent,
      ),
      body: getBody(),
      endDrawer: getNavDrawer(context),
      bottomSheet: new BottomSheet(
        onClosing: () {},
        builder: (BuildContext context) {
            return 
            new Container(
              height: 40.0,
              color: bootSheetColor,
              child:new Row(
              children: <Widget>[
                Expanded( child:
                new Text(total1, textAlign: TextAlign.left, style: TextStyle(fontSize: 14.0), ),),
                Expanded( child:
                new Text(total2, textAlign: TextAlign.right, style: TextStyle(fontSize: 14.0), ),)
              ],
            ));
        },
),
    );
  }


  Widget getBody() {
    if (dataFlag == '1') {
      return loading(context);
    } else if (dataFlag == '3') {
      return geneBody();
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
                  child: new Center( child: new Text('加载中...'), ),
                ),
              ],
            );
  }

  List<Widget> buildBody() {
    List<Widget> _result = new List();
    dataMap.forEach((_map){
      String boatNo = _map['boatNo'];
      String boatOwner = _map['boatOwner'];
      String weight = _map['weight'];
      String count = _map['count'];
      String dgtime = _map['dgtime'];
      Widget _item = buildCard(boatNo, boatOwner, weight, count, dgtime);
      _result.add(_item);
    }
    );
    return _result;
  }


  Widget buildCard(String boatNo, String boatOwner, String weight, String count, String dgtime) {
    return new Card(
      color: Colors.white,
      elevation: 5.0,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
            buildColumn1(boatNo, boatOwner),
            buildColumn2(weight, count),
            buildColumn3(dgtime),
        ],
      ),
    );
  }

  Widget buildColumn1(String boatNo, String boatOwner) {
    return new Row(
              children: <Widget>[
                Expanded( child:
                new Text('船号:$boatNo', textAlign: TextAlign.left, style: TextStyle(fontSize: 12.0), ),),
                Expanded( child:
                new Text('船主:$boatOwner', textAlign: TextAlign.left, style: TextStyle(fontSize: 12.0), ),)
              ],
    );
  }

  
  Widget buildColumn2(String weight, String count) {
    return new Row(
              children: <Widget>[
                Expanded( child:
                new Text('重量: $weight 吨', textAlign: TextAlign.left, style: TextStyle(fontSize: 12.0), ),),
                Expanded( child:
                new Text('趟次:$count 次', textAlign: TextAlign.left, style: TextStyle(fontSize: 12.0), ),)
              ],
    );
  }

  
  
  Widget buildColumn3(String dgtime) {
    return new Row(
              children: <Widget>[
                Expanded( child:
                new Text('最近到港时间: $dgtime ', textAlign: TextAlign.left, style: TextStyle(fontSize: 12.0), ),),
              ],
    );
  }

  Widget geneBody() {
    return new Center(
          child: new ListView(
            //控制方向 默认是垂直的
            children: buildBody(),
          ),
        );
  }

  Widget loading(BuildContext context) {
    return new Stack(
              children: <Widget>[        new Padding(
                  padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 80.0),
                  child: new Center( child: 
                  new InkWell(
                    onTap: (){},
                    child:
                  Icon(Icons.search, size: 100.0, color: Colors.greenAccent,), )),
                ),        new Padding(
                  padding: new EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
                  child: new Center( child: new Text('请点击右上角图标进行查询', style: TextStyle(color: Colors.greenAccent),), ),
                ),
              ],
            );
  }


  Drawer getNavDrawer(BuildContext context) {
    ListTile getNavItem(String s,{onTapFunc}) {
      return new ListTile(
        title: new Text(s,style: TextStyle(color: Colors.greenAccent,fontSize: 12.0),),
        onTap: onTapFunc,
      );
    }

    var myNavChildren = [
      // headerChild,
      search(),
      Divider(),
      getNavItem("时间:  $dateView"),

      new Container(
        child:
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 10.0,
          runSpacing: 10.0,
          direction: Axis.horizontal,
          children: <Widget>[
            getDateButton('今天', todayDateColor,'1'),
            getDateButton('昨天', yesterdayDateColor,'2'),
            getDateButton('近一周', weekDateColor,'3'),
            getDateButton('本月', monthDateColor,'4'),
            getDateButton('其他时间', otherDateColor, '5'),
          ],
        )
       
      ),
     Divider(),
      getNavItem("类别:  $typeView"),
      new Container(
        child:
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 10.0,
          runSpacing: 10.0,
          direction: Axis.horizontal,
          children: <Widget>[
            getTypeButton('全部', allTypeColor,'1'),
            getTypeButton('生活垃圾', lifeTypeColor,'2'),
            getTypeButton('油污垃圾', oilTypeColor,'3'),
          ],
        )
       
      ),
      Divider(),
      getNavItem("港口:  $gangkouName"),

      new Container(
        child:
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 10.0,
          runSpacing: 10.0,
          direction: Axis.horizontal,
          children: <Widget>[
            getGangkouButton('请选择港口', gangkouColor),
          ],
        )
      ),

      
    Divider(),
      new Container(
        child:
        geneButton('','')
       
      ),
    ];
    ListView listView = new ListView(children: myNavChildren);
    return new Drawer(
      child: listView);
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
                child: new Text('查 询',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16.0),),
                onPressed: (){
                  _forSubmitted(context);
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


  Future<bool> _forSubmitted(BuildContext context) async {
    Navigator.pop(context);
    setState(() {
          dataFlag = '2';
        });
     try {
    String url =
        "http://116.62.149.237:8080/USR000100001?usrName=admin&passwd=123456";
   
      // result = await http.get(url).then((http.Response response) {
        // var data = json.decode(response.body);
        // String rescode = data["rescode"];
        String rescode = '000000';
        if (rescode == '999999') {
         
          return false;
        } else if (rescode == '000000') {

await Future.delayed(Duration(seconds: 3), () {

          setState(() {
                      dataMap.clear();
                      dataMap.addAll(dataMapQuery);
                      total1 = '累计重量: 1000 吨';
                      total2 = '累计趟次： 983 次';
                      bootSheetColor = Colors.lightGreenAccent;
                      dataFlag = '3';
                    });
        });
        }
    } catch (e) {
      return false;
    }
    return true;
  }

void _handlerDrawerButtonEnd(BuildContext context) {
  print('11111111111111111111111111111');
    Scaffold.of(context).openEndDrawer();
  print('22222222222222222222222222222222');
  }

  Widget search() {
    return new Container(
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
                    hintText: '请输入船舶号 ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Colors.grey)),
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.0),
                    hintStyle: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                ),
              ),
            ),
            new Container(child: 
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

  Widget getDateButton(String title, Color color, String range) {
    return OutlineButton(
              shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(
              color: Color(0xFFFFFF00), style: BorderStyle.solid, width: 2)),
              borderSide:new BorderSide(color: color),
              child: new Text(title,style: new TextStyle(color: color)),
            onPressed: (){
              if (range == '5') {
                 showPickerDateRange(context);
              } else {
                changeDate(range, context);
              }
            },
            );
  }

  Widget getTypeButton(String title, Color color, String range) {
    return OutlineButton(
              shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(
              color: Color(0xFFFFFF00), style: BorderStyle.solid, width: 2)),
              borderSide:new BorderSide(color: color),
              child: new Text(title,style: new TextStyle(color: color)),
            onPressed: (){
              changeType(range, context);
            },
            );
  }

  Future<void> changeType(String range, BuildContext context) async  {
      allTypeColor = Colors.grey;
      lifeTypeColor = Colors.grey;
      oilTypeColor = Colors.grey;
      setState(() {
              if (range == '1') { //今天
                typeView = '全部';
                allTypeColor = Colors.greenAccent;
              } else if (range == '2') { //昨天
                typeView = '生活垃圾';
                lifeTypeColor = Colors.greenAccent;
              } else { 
                typeView = '油污垃圾';
                oilTypeColor = Colors.greenAccent;
              }
            });
    }

    Future<void> changeDate(String range, BuildContext context) async  {
      todayDateColor = Colors.grey;
      yesterdayDateColor = Colors.grey;
      weekDateColor = Colors.grey;
      monthDateColor = Colors.grey;
      otherDateColor = Colors.grey;
      setState(() {
              if (range == '1') { //今天
                startDate = DateUtil.formatDateTime(DateUtil.getNowDateStr(), DateFormat.YEAR_MONTH_DAY, null , null);
                endDate = DateUtil.formatDateTime(DateUtil.getNowDateStr(), DateFormat.YEAR_MONTH_DAY, null , null);
                todayDateColor = Colors.greenAccent;
              } else if (range == '2') { //昨天
                DateTime yesterDay = DateTime.now().subtract(Duration(days: 1));
                startDate = DateUtil.formatDateTime(yesterDay.toString(), DateFormat.YEAR_MONTH_DAY, null , null);
                endDate = DateUtil.formatDateTime(yesterDay.toString(), DateFormat.YEAR_MONTH_DAY, null , null);
                yesterdayDateColor = Colors.greenAccent;
              } else if (range == '3') { //本周
                weekDateColor = Colors.greenAccent;
                DateTime weekBegin = DateTime.now().subtract(Duration(days:6));
                startDate = DateUtil.formatDateTime(weekBegin.toString(), DateFormat.YEAR_MONTH_DAY, null , null);
                endDate = DateUtil.formatDateTime(DateUtil.getNowDateStr(), DateFormat.YEAR_MONTH_DAY, null , null);
              } else if (range == '4') { //一个月
                monthDateColor = Colors.greenAccent;
                DateTime _now = DateTime.now();
                int _month = _now.month;
                int _year = _now.year;
                int _monthDay = MONTH_DAY[_month];
                startDate = _year.toString() + '-' + _month.toString().padLeft(2, '0') + '-01';
                endDate = _year.toString() + '-' + _month.toString().padLeft(2, '0') + '-$_monthDay';
              }

              if (startDate == endDate) {
                dateView = startDate;
              } else {
                dateView = startDate + '~' + endDate;
              }
            });
    }


  Future<void> showPickerDateRange(BuildContext context) async  {
    Picker ps = new Picker(
        hideHeader: true,
        adapter: new DateTimePickerAdapter(type: PickerDateTimeType.kYMD, isNumberMonth: true),
        onConfirm: (Picker picker, List value) {

          setState(() {
            DateTime _value = (picker.adapter as DateTimePickerAdapter).value;
            startDate = DateUtil.getDateStrByDateTime(_value, format:DateFormat.YEAR_MONTH_DAY);
             print(startDate);
            });
         
        }
    );

    Picker pe = new Picker(
        hideHeader: true,
        adapter: new DateTimePickerAdapter(type: PickerDateTimeType.kYMD, isNumberMonth: true),
        onConfirm: (Picker picker, List value) {
          
          setState(() {
            DateTime _value = (picker.adapter as DateTimePickerAdapter).value;
            endDate = DateUtil.getDateStrByDateTime(_value, format:DateFormat.YEAR_MONTH_DAY);
             print(endDate);
            });
        }
    );

    List<Widget> actions = [
      FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: new Text('取消')),
      FlatButton(
          onPressed: () {
            Navigator.pop(context);
            ps.onConfirm(ps, ps.selecteds);
            pe.onConfirm(pe, pe.selecteds);
            setState(() {
              if (startDate == endDate) {
                dateView = startDate;
              } else {
                dateView = startDate + '~' + endDate;
              }
              todayDateColor = Colors.grey;
              yesterdayDateColor = Colors.grey;
              weekDateColor =  Colors.grey;
              monthDateColor =  Colors.grey;
              otherDateColor = Colors.greenAccent;          
            });
          },
          child: new Text('确定'))
    ];

    Dialog.showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text("其他时间", style: TextStyle(decorationColor: Colors.greenAccent),),
            actions: actions,
            content: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("开始:"),
                  ps.makePicker(),
                  Divider(),
                  Text("结束:"),
                  pe.makePicker(),
                  Divider(),
                ],
              ),
            ),
          );
        });
  }


  Widget gangkouSearch() {
    return new Container(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: new Container(
                alignment: Alignment.center,
                child: TextField(
                  onChanged: (word)=>gangkou = word,
                  style: new TextStyle(fontSize: 15.0, color: Colors.black),
                  decoration: new InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    hintText: '查询条件',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Colors.grey)),
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.0),
                    hintStyle: TextStyle(fontSize: 12.0, color: Colors.greenAccent),
                  ),
                ),
              ),
            ),
            new Container(child: 
            IconButton(
              icon: Icon(Icons.search),
              iconSize: 40.0,
              onPressed: getGangkouData,
              color: Colors.greenAccent,
            ),),
          ],
        ),
      );
  }


  showPicker() {
    Picker picker = new Picker(
      title:gangkouSearch(),
      adapter: PickerDataAdapter(
        data:gangkouItems,
      ),
      changeToFirst: true,
      textAlign: TextAlign.left,
      cancelText: '取消',
      cancelTextStyle: TextStyle(color: Colors.greenAccent),
      confirmText: '确定',
      confirmTextStyle:TextStyle(color: Colors.greenAccent),
      // hideHeader: true,
      columnPadding: const EdgeInsets.all(8.0),
      onConfirm: (Picker picker, List value) {
        String _value = value[0].toString();
        int index = int.parse(_value);
        setState(() {
          gangkouName = gangkouList3[index]['gkName'];
          gangkouColor = Colors.greenAccent;
        });
      }
    );
    picker.showModal(context);
    // picker.show(_scaffoldKey.currentState);
  }

  
  Widget getGangkouButton(String title, Color color) {
    return OutlineButton(
              shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(
              color: Color(0xFFFFFF00), style: BorderStyle.solid, width: 2)),
              borderSide:new BorderSide(color: color),
              child: new Text(title,style: new TextStyle(color: color)),
            onPressed: showPicker,
            );
  }

  Widget itemCard(int i) {
    return new Card(
      child: new ListTile(
          title: new Text(_itemMap[i]['carid']),
          subtitle: new Text(_itemMap[i]['facid']),
          //之前显示icon
          leading: new Icon(Icons.directions_boat, color: Colors.greenAccent,size: 30.0,),
          onTap: (){}
    )
    );
  }


  Future<void> doScanCode() async {
    await scanCode().then(
      (flag){
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

