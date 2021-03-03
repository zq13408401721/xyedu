
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_shop/urls.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'ProgressDialog.dart';
import 'api.dart';
import 'main_web.dart';

class Unlogin extends StatefulWidget{

  final String phone;
  Unlogin({Key key,@required String this.phone}):super(key:key);

  @override
  State<StatefulWidget> createState() {
    return _UnLogin(phone);
  }
}


class _UnLogin extends State<Unlogin>{

  String _phone;
  _UnLogin(String phone){
    this._phone = phone;
  }
  /**
   * 登录soo
   */
  void loginSoo(BuildContext context){
    String url = ServiceApi.xy_login;
    Map<String,dynamic> map = Map();
    map["mobile"] = _phone;
    /*ProgressDialog.showProgress(context,child: SpinKitCircle(
      itemBuilder: (_,int index){
        return DecoratedBox(
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red
          ),
        );
      },
    ));*/
    Urls.postX(url, (result){
      var login = json.decode(result.toString());
      //Navigator.of(context).pop();
      if(login["_login"]){
        var token = login["token"];
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context)=>WebViewPage()),
                (route)=>route == null);

      }else if(login["_status"] != "success"){
        //登录失败给出错误提示
        var err = login["_err"]["msg"];
        Fluttertoast.showToast(msg: '$err');
      }
    },map);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      print("打开主页");
      loginSoo(this.context);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return Container(
      color: Colors.white,
      child: Align(
        alignment: Alignment.center,
        child: Text("loading",style: TextStyle(fontSize: 16,color: Colors.black87,decoration: TextDecoration.none),),
      ),
    );
  }
}