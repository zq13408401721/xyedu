
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shop/login.dart';
import 'package:flutter_shop/unlogin.dart';
import 'package:shared_preferences/shared_preferences.dart';

/**
 * 主页面 包含两部分
 * sso用户手机号登录
 * 用户手机号登录
 *
 */
void main(){
  runApp(MaterialApp(
    home: MainPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class MainPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _MainPage();
  }
}

class _MainPage extends State<MainPage>{

  Future<SharedPreferences> sp = SharedPreferences.getInstance();

  void checkLogin(BuildContext context) async{
    final SharedPreferences _sp = await sp;
    String username = _sp.getString("username");
    if(username != null && username.isNotEmpty){
      print("username is $username");
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context)=>Unlogin(phone: username)),
              (route)=>route == null);
    }else{
      print("username is null");
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context)=>LoginPage()),
              (route)=>route == null);
    }
  }

  @override
  Widget build(BuildContext context) {
    checkLogin(context);
     return Scaffold(
       body: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
       ),
     );
  }
}