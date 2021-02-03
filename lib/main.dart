import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_shop/ProgressDialog.dart';
import 'package:flutter_shop/api.dart';
import 'package:flutter_shop/register_data.dart';
import 'package:flutter_shop/urls.dart';
import 'package:flutter_shop/xyweb.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_shop/NetUtils.dart';
import 'dart:io';
import 'dart:convert' show json;
import 'package:shared_preferences/shared_preferences.dart';

/**
 * 主界面 包含登录功能
 */
void main(){
  runApp(MaterialApp(
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
  ));
  //设置顶部状态栏
  /*if(Platform.isAndroid){
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }*/
}

class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage>{

  Future<SharedPreferences> sp = SharedPreferences.getInstance();

  //焦点
  FocusNode _focusNodeUserName = new FocusNode();
  FocusNode _focusNodePassWord = new FocusNode();

  TextEditingController _userNameController = new TextEditingController();

  //表单状态
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _username = ''; //用户名
  var _password = ''; //密码

  bool isBtnEnabled = true; //发送验证码按钮的状态
  String btnText="发送验证码";
  int count = 60; //倒计时时间
  Timer timer;  //倒计时的计时器
  TextEditingController mController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    _focusNodeUserName.addListener(_focusNodeListener);
    _focusNodePassWord.addListener(_focusNodeListener);
    _userNameController.addListener(() {
      print(_userNameController.text);
    });
    initLogin();
    super.initState();
  }

  @override
  void dispose() {
    _focusNodeUserName.removeListener(_focusNodeListener);
    _focusNodePassWord.removeListener(_focusNodeListener);
    timer.cancel();
    timer = null;
    mController.dispose();
    super.dispose();
  }

  /**
   * 初始化登录页面
   */
  void initLogin() async {
    final SharedPreferences _sp = await sp;
    String username = _sp.getString("username");
    if(username != null){
      _userNameController.text = username;
    }
  }

  //焦点的监听
  Future<Null> _focusNodeListener() async {
    if(_focusNodeUserName.hasFocus){
      _focusNodePassWord.unfocus();
    }
    if(_focusNodePassWord.hasFocus){
      _focusNodeUserName.unfocus();
    }
  }
  
  String validateUserName(value){
    //正则表达式匹配手机号
    RegExp exp = RegExp(r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    if(value.isEmpty){
      return "用户名不能为空";
    }else if(!exp.hasMatch(value)){
      return "请输入正确的手机号";
    }
    return null;
  }

  String validatePassword(value){
    if(value.isEmpty){
      return "密码不能为空";
    }else if(value.trim().length < 6 || value.trim().length > 18){
      return "密码的长度不正确";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    //输入文本区域
    Widget inputTextArea = new Container(
      margin: EdgeInsets.only(left: 20,right: 20),
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white
      ),
      child: new Form(
          key: _formKey,
          child:new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new TextFormField(
                controller: _userNameController,
                focusNode: _focusNodeUserName,
                //设置键盘类型
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "用户名",
                  hintText: "请输入手机号",
                  prefixIcon: Icon(Icons.person),
                ),
                //验证用户名
                validator: validateUserName,
                //保存数据
                onSaved: (String value){
                  _username = value;
                },
              ),
              /*new TextFormField(
                focusNode: _focusNodePassWord,
                decoration: InputDecoration(
                  labelText: "密码",
                  hintText: "请输入密码",
                  prefixIcon: Icon(Icons.lock),
                  //是否显示密码
                ),
                //验证密码
                validator: validatePassword,
                //保存数据
                onSaved: (String value){
                  _password = value;
                },
              )*/
            ],
          )
      ),
    );

    //免费注册忘记密码

    //保存token
    void _saveToken(String username,String token) async{
      final SharedPreferences _sp = await sp;
      _sp.setString("username", username);
      _sp.setString("token", token);
    }

    //验证码
    /**
     * 开启倒计时
     */
    void _initTimer(){
      timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) {
        count --;
        setState(() {
          if(count == 0){
            timer.cancel();
            isBtnEnabled = true;
            count = 60;
            btnText = "发送验证码";
          }else{
            btnText = "重新发送($count)";
          }
        });
      });
    }

    /**
     * 发送验证码点击事件
     */
    void sendVerifyCodeClickListener(){
      setState(() {
        if(isBtnEnabled){
          isBtnEnabled = false;
          _initTimer();
          return null;
        }else{
          return null;
        }
      });
    }


    Widget verifyCodeArea = new Container(
      child: Column(
        children: <Widget>[
          Container(
            color:Colors.white,
            padding: EdgeInsets.only(left:20,right:20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.ideographic,
              children: <Widget>[
                Text("验证码",style: TextStyle(fontSize: 13,color:Color(0xff33333333),),),
                Expanded(
                  child: Padding(
                    padding:EdgeInsets.only(left: 15,right: 15,top: 0),
                    child: TextFormField(
                      maxLines: 1,
                      onSaved: (value){

                      },
                      controller: mController,
                      textAlign: TextAlign.left,
                      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(6)],
                      decoration: InputDecoration(
                        hintText: ("填写验证码"),
                        contentPadding: EdgeInsets.only(top:0,bottom:0),
                        hintStyle: TextStyle(
                          color: Color(0xff999999),
                          fontSize: 13,
                        ),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120,
                  child: FlatButton(
                    disabledColor: Colors.grey.withOpacity(0.1),
                    disabledTextColor: Colors.white,
                    textColor: isBtnEnabled?Colors.white:Colors.black.withOpacity(0.2),
                    color: isBtnEnabled?Color(0xff44c5fe):Colors.grey.withOpacity(0.1),
                    splashColor: isBtnEnabled?Colors.white.withOpacity(0.1):Colors.transparent,
                    shape:StadiumBorder(side:BorderSide.none),
                    onPressed: (){
                      setState(() {
                        sendVerifyCodeClickListener();
                      });
                    },
                    child: Text('$btnText',style: TextStyle(fontSize: 13),),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );

    //登录按钮
    Widget loginButtonArea = new Container(
      margin: EdgeInsets.only(left:20,right:20),
      height: 45,
      child: new RaisedButton(
        color: Colors.blue[300],
        child: Text("登录",style: Theme.of(context).primaryTextTheme.headline,),
        //设置圆角
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: (){
          //点击登录回收键盘，解除焦点
          _focusNodeUserName.unfocus();
          _focusNodePassWord.unfocus();
          if(_formKey.currentState.validate()){
            //验证通过执行保存操作
            _formKey.currentState.save();
            //登录
            print("username:$_username password:$_password");
            int timestamp = NetUtils.currentTimeMillis();
            String token = NetUtils.md5Hex(Urls.Appsecret+timestamp.toString());
            String url = ServiceApi.xy_login;
            Map<String,dynamic> map = Map();
            /*map["username"]="yun";
            map["password"]="111111";*/
            map["appid"] = Urls.appid;
            map["timestamp"] = timestamp;
            map["token"] = token;
            map["mobile"] = _username;
            ProgressDialog.showProgress(context,child: SpinKitCircle(
              itemBuilder: (_,int index){
                return DecoratedBox(
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red
                  ),
                );
              },
            ));
            Urls.post(url, (result){
              var login = json.decode(result.toString());
              if(login["_login"]){
                var token = login["token"];
                _saveToken(_username,token);
                ProgressDialog.dismiss(context);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (BuildContext context)=>WebViewPage()),
                    (route)=>route == null);

              }
            },map);
          }
        },
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      // 外层添加一个手势，用户点击空白部分回收键盘
      body:new GestureDetector(
        onTap: (){
          print("点击空白地方");
          _focusNodeUserName.unfocus();
          _focusNodePassWord.unfocus();
        },
        child: new ListView(
          children: [
            new SizedBox(height: 100,),
            inputTextArea,
            verifyCodeArea,
            new SizedBox(height: 50,),
            loginButtonArea,
          ],
        ),
      ),
    );
  }

}