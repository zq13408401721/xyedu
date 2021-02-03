import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressDialog{
  static bool _isShowing = false;

  //显示loading
  static void showProgress(BuildContext context,{Widget child = const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.red),)}){
    if(!_isShowing){
      _isShowing = true;
      Navigator.push(
        context,
        _PopRoute(
          child: _Progress(
            child: child,
          )
        )
      );
    }
  }

  //隐藏
  static void dismiss(BuildContext context){
    if(_isShowing){
      Navigator.of(context).pop();
      _isShowing = false;
    }
  }

}

class _Progress extends StatelessWidget{
  final Widget child;
  _Progress({
    Key key,
    @required this.child,
  }):assert(child != null),super(key:key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: child,
      ),
    );
  }

}

class _PopRoute extends PopupRoute{
  final Duration _duration = Duration(milliseconds: 300);
  Widget child;
  _PopRoute({@required this.child});

  @override
  // TODO: implement barrierColor
  Color get barrierColor => null;

  @override
  // TODO: implement barrierDismissible
  bool get barrierDismissible => true;

  @override
  // TODO: implement barrierLabel
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  // TODO: implement transitionDuration
  Duration get transitionDuration => _duration;

}
