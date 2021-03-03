import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_shop/main_xylogin.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

void main(){
  runApp(MaterialApp(home: WebViewPage(),));
  //设置顶部状态栏
  if(Platform.isAndroid){
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}



class WebViewPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _WebViewState();
  }
}

/**
 * 带界面状态的页面
 */
class _WebViewState extends State<WebViewPage>{

  String htmlPath = 'assets/files/index.html';

  final Completer<WebViewController> _controller = Completer<WebViewController>();
  WebViewController _webViewController;


  JavascriptChannel _javascriptChannel(BuildContext context){
    return JavascriptChannel(name: "fromJs", onMessageReceived: (JavascriptMessage msg){
      print(msg.message);
    });
  }

  /**
   * js登录按钮点击操作
   */
  JavascriptChannel _javascriptLogin(BuildContext context){
    return JavascriptChannel(name: "loginJs", onMessageReceived: (JavascriptMessage msg){
      print("登录");
      Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage())
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  /**
   * 加载本地html数据内容
   */
  _loadHtmlFromAssets() async{
    String fileContents = await rootBundle.loadString(htmlPath);
    await _webViewController.loadUrl(Uri.dataFromString(fileContents,mimeType: 'text/html',encoding: Encoding.getByName('utf-8')).toString());
  }

  _initJs() async{
    await _loadHtmlFromAssets(); //加载本地html内容
    //webview加载完成调用js方法
    _webViewController.evaluateJavascript('fromFlutter("来至flutter")').then((value) => print("调用之后返回值：$value"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Builder(builder: (BuildContext context){
          return WebView(
            //initialUrl: 'https://xy100.cn/mobile-preview?url=aHR0cHM6Ly9hcHAteXVuZGlhbi54eTEwMC5jbi9tL3VzZXJjYXNlLWluZGV4O3h5dGVzdD9fbW9iaWxlX3ByZXZpZXc9dHJ1ZQ%3D%3D',
            //initialUrl: '',
            javascriptMode: JavascriptMode.unrestricted,
            javascriptChannels: <JavascriptChannel>[
              _javascriptChannel(context),
              _javascriptLogin(context)
            ].toSet(), // js和flutter通信channel
            onWebViewCreated: (WebViewController webViewController){
              _webViewController = webViewController;
              _controller.complete(webViewController);
              _initJs();
            },
            navigationDelegate: (NavigationRequest request){
              if(request.url.startsWith('js://webview')){
                print('blocking navigation to $request');
                return NavigationDecision.prevent;
              }
              print('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
            onPageFinished: (String url){
              print("onPageFinish:"+url);
            },
          );
        },),
        bottom: true,
        left: true,
        right: true,
        top: true,
      ),
    );
  }





}
