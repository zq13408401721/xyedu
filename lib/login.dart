import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_shop/api.dart';
import 'package:flutter_shop/register_data.dart';
import 'package:flutter_shop/urls.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_shop/NetUtils.dart';

class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage>{

  final loginUrl = "http://sprout.cdwan.cn/api/auth/login"; //登录地址


  //焦点
  FocusNode _focusNodeUserName = new FocusNode();
  FocusNode _focusNodePassWord = new FocusNode();

  TextEditingController _userNameController = new TextEditingController();

  //表单状态
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _username = ''; //用户名
  var _password = ''; //密码

  @override
  void initState() {
    // TODO: implement initState
    _focusNodeUserName.addListener(_focusNodeListener);
    _focusNodePassWord.addListener(_focusNodeListener);
    _userNameController.addListener(() {
      print(_userNameController.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNodeUserName.removeListener(_focusNodeListener);
    _focusNodePassWord.removeListener(_focusNodeListener);
    super.dispose();
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

  //登录
  _login() async{
    Urls.post(
      ServiceApi.Login,
        (result){

        }
    );
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
              new TextFormField(
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
              )
            ],
          )
      ),
    );

    //免费注册忘记密码

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
            Urls.post(url, (result){
              print(result);
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
            new SizedBox(height: 50,),
            loginButtonArea,
          ],
        ),
      ),
    );
  }

}