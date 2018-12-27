import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:marine_app/common/AppUrl.dart' as Api;
import 'package:marine_app/common/AppConst.dart';

import 'dart:convert';

//这里只封装了常见的get和post请求类型
class HttpUtil2 {
  static const String GET = "get";
  static const String POST = "post";

  static void get(String url, Function callback,
      {Map<String, String> params,
        Map<String, String> headers,
        Function errorCallback}) async {

    if (!url.startsWith("http")) {
      url = Api.BaseUrl + url;
    }

    if (params != null && params.isNotEmpty) {
      StringBuffer sb = new StringBuffer("?");
      params.forEach((key, value) {
        sb.write("$key" + "=" + "$value" + "&");
      });
      String paramStr = sb.toString();
      paramStr = paramStr.substring(0, paramStr.length - 1);
      url += paramStr;
    }
    print('url=' + url);
    await _request(url, callback,
        method: GET,
        headers: headers,
        errorCallback: errorCallback);
  }

  static void post(String url, Function callback,
      {Map<String, String> params,
        Map<String, String> headers,
        Function errorCallback}) async {

    if (!url.startsWith("http")) {
      url = Api.BaseUrl + url;
    }
    await _request(url, callback,
        method: POST,
        headers: headers,
        params: params,
        errorCallback: errorCallback);
  }

  static Future _request(String url, Function callback,
      {String method,
        Map<String, String> headers,
        Map<String, String> params,
        Function errorCallback}) async {
    String errorMsg;
    String errorCode;
    var data;
    try {
      Map<String, String> headerMap = headers == null ? new Map() : headers;
      Map<String, String> paramMap = params == null ? new Map() : params;

      http.Response res;
      if (POST == method) {
        res = await http.post(url, headers: headerMap, body: paramMap);
      } else {
        res = await http.get(url, headers: headerMap);
      }

      if (res.statusCode != 200) {
        errorMsg = "网络请求错误,状态码:"+res.statusCode.toString();

        _handError(errorCallback, errorMsg);
        return;
      }

      //以下部分可以根据自己业务需求封装,这里是errorCode>=0则为请求成功,data里的是数据部分
      //记得Map中的泛型为dynamic
      Map<String, dynamic> map = json.decode(res.body);

      errorCode = map[AppConst.RESP_CODE];
      errorMsg = map[AppConst.RESP_MSG];
      data = map[AppConst.RESP_DATA];

      // callback返回data,数据类型为dynamic
      //errorCallback中为了方便我直接返回了String类型的errorMsg
      if (callback != null) {
        if (errorCode == AppConst.SUCCESS) {
          callback(data);
        } else {
          _handError(errorCallback, errorMsg);
        }
      }
    } catch (exception) {
      _handError(errorCallback, exception.toString());
    }
  }


  static void _handError(Function errorCallback,String errorMsg){
    if (errorCallback != null) {
      errorCallback(errorMsg);
    }
    print("errorMsg :"+errorMsg);
  }


  static Future requestSync(String url,
      {String method,
        Map<String, String> headers,
        Map<String, String> params}) async {
    try {
      Map<String, String> headerMap = headers == null ? new Map() : headers;
      Map<String, String> paramMap = params == null ? new Map() : params;

      http.Response res;
      if (POST == method) {
        res = await http.post(url, headers: headerMap, body: paramMap);
      } else {
        res = await http.get(url, headers: headerMap);
      }

      if (res.statusCode != 200) {
        print("网络请求错误,状态码:"+res.statusCode.toString());
        Map _retMap = new Map();
        _retMap[AppConst.RESP_CODE] = AppConst.NETWORK_ERROR;
        _retMap[AppConst.RESP_MSG] = AppConst.convert[AppConst.NETWORK_ERROR];
        return _retMap;
      }
      print(res.body);
      return json.decode(res.body);
    } catch (exception) {
      print(exception);
      Map _retMap = new Map();
      _retMap[AppConst.RESP_CODE] = AppConst.SYS_ERROR;
      _retMap[AppConst.RESP_MSG] = AppConst.convert[AppConst.SYS_ERROR];
      return _retMap;
    }
  }


  static Future postSync(String url, Function callback,
      {Map<String, String> params,
        Map<String, String> headers,
        Function errorCallback}) async {

    if (!url.startsWith("http")) {
      url = Api.BaseUrl + url;
    }
    return await requestSync(url,
        method: POST,
        headers: headers,
        params: params);
  }


  static Future getSync(String url,
      {Map<String, String> params,
        Map<String, String> headers}) async {

    if (!url.startsWith("http")) {
      url = Api.BaseUrl + url;
    }

    if (params != null && params.isNotEmpty) {
      StringBuffer sb = new StringBuffer("?");
      params.forEach((key, value) {
        sb.write("$key" + "=" + "$value" + "&");
      });
      String paramStr = sb.toString();
      paramStr = paramStr.substring(0, paramStr.length - 1);
      url += paramStr;
    }
    print('url=' + url);
    return await requestSync(url,
        method: GET,
        headers: headers);
  }


}