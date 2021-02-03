
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'ProgressDialog.dart';



class WebViewPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _WebViewState();
  }
}

class _WebViewState extends State<WebViewPage>{

  WebViewController _webViewController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom,SystemUiOverlay.top]
    );
    if(Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  /**
   * 退出当前应用
   */
  static Future<void> pop() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  Widget build(BuildContext context) {
    //设置loading
    Future.delayed(Duration.zero,(){
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
    });
    return GestureDetector(
      child:WillPopScope(
          onWillPop: () async{
            _webViewController.canGoBack().then((value) {
              if (value) {
                _webViewController.goBack();
              }else{
                pop();
              }
            });
          },
        child: Scaffold(
          body: SafeArea(
            child: Builder(builder: (BuildContext context) {
              return WebView(
                initialUrl: 'https://xyedu.app-yundian.xy100.cn/m/usercase-index?_mobile_preview=true',
                onWebViewCreated: (WebViewController webviewController){
                  _webViewController = webviewController;
                },
                navigationDelegate: (NavigationRequest request) {
                  if (request.url.startsWith('js://webview')) {
                    print('blocking navigation to $request');
                    return NavigationDecision.prevent;
                  }
                  print('allowing navigation to $request');
                  return NavigationDecision.navigate;
                },
                onPageFinished: (String url) {
                  print("onPageFinish:" + url);
                  ProgressDialog.dismiss(context);
                },
              );
            },),
            bottom: true,
            left: true,
            right: true,
            top: true,
          ),
        ),
      )
    );
  }
}