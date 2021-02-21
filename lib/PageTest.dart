
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _Page(),
    );
  }

}

class _Page extends StatefulWidget{

  _Page({Key key}):super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _State();
  }

}

class _State extends State<_Page>{

  bool toggle = true;

  void _toggle(){
    setState(() {
      toggle = !toggle;
    });
  }

  _getToggleChild(){
    if(toggle){
      return Text("Toggle One");
    }else{
      return ElevatedButton(onPressed: (){}, child: Text("Toggle Two"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _getToggleChild(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggle,
        tooltip: "Update Text",
        child: Icon(Icons.update),
      ),
    );
  }

}
