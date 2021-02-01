
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';


class Urls{

  //分配给商户的appid
  static const String appid = "xyedu";
  //分配给商户的api调用密匙
  static const String Appsecret = "li8xnq8bk92grdcz";

  //基础网络地址
  static const String BaseUrl = "https://sprout.cdwan.cn/api/";
  //星猿网络请求地址
  static const String XY_URL = "https://xyedu.app-yundian.xy100.cn/";

  static const String GET = "get";
  static const String POST = "post";

  /**
   * get网络请求
   */
  static Future get(String api,Function callback,[dynamic params,Function errorCallback]) async {
    return _request(Urls.XY_URL+api, callback,method: GET,params: params,errorCallback: errorCallback);
  }

  /**
   * post网络请求
   */
  static Future post(String api,Function callback,[dynamic params,Function errorCallback]) async{
    return _request(Urls.XY_URL+api, callback,method: POST,params: params,errorCallback: errorCallback);
  }

  /**
   * 封装网络请求
   */
  static Future _request(String url,Function callback,{String method,dynamic params,Function errorCallback}) async {
    if(params != null && params.isNotEmpty){
      print("params:$params");
    }
    int statusCode;
    Response response;
    try{
      if(method == GET){
        if(params != null && params is Map && params.isNotEmpty){
          StringBuffer sb = new StringBuffer("?");
          params.forEach((key, value) {
            sb.write("$key"+"="+"$value"+"&");
          });
          String paramStr = sb.toString();
          paramStr = paramStr.substring(0,paramStr.length-1);
          url += paramStr;
        }
        response = await Dio().get(url);
      }else if(method == POST){
        if(params != null && params.isNotEmpty){
          StringBuffer sb = new StringBuffer("?");
          params.forEach((key, value) {
            sb.write("$key"+"="+"$value"+"&");
          });
          String paramStr = sb.toString();
          paramStr = paramStr.substring(0,paramStr.length-1);
          url += paramStr;
          Dio dio = Dio();
          (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client){
            client.badCertificateCallback = (cert,host,port){
              return true;
            };
          };
          response = await dio.post(url);
        }else{
          response = await Dio().post(url);
        }
      }
    }catch(exception){
      _handError(errorCallback, statusCode);
      return Future.value();
    }
    statusCode = response.statusCode;
    var result = response.data;
    //处理错误
    if(statusCode != 200){
      _handError(errorCallback, statusCode);
    }
    if(callback != null){
      callback(result);
      print("response data:$result");
    }
  }

  //异常处理
  static void _handError(Function errorCallback,int statusCode){
    print("statusCode:$statusCode");
    errorCallback("网络连接失败");
  }

}