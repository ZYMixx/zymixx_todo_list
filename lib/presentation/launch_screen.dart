import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vec;
import 'package:window_manager/window_manager.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({Key? key}) : super(key: key);

  test() {
    windowManager.setBackgroundColor(Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    test();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          VirtualWindowFrame(
            child: WindowTitleBarBox(
              child: Container(
                //color: Colors.deepOrangeAccent.withOpacity(0.1),
                child: MoveWindow(),
              ),
            ),
          ),
          Ink(
            child: Center(
              child: ImageChange(),
            ),
          )
        ],
      ),
    );
  }
}

class ImageChange extends StatefulWidget {
  const ImageChange({Key? key}) : super(key: key);

  @override
  State<ImageChange> createState() => _ImageChangeState();
}

class _ImageChangeState extends State<ImageChange> with TickerProviderStateMixin {
  String firstImage = 'images/dariy.png';
  String secondImage = 'images/grh_sticer.png';
  bool isOn = false;
  bool isDariyOn = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          print('on tap');
          isOn = !isOn;
        });
      },
      onSecondaryTap: () {
        setState(() {
          isDariyOn = !isDariyOn;
        });
      },
      child: MoveWindow(
        onDoubleTap: () {},
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          //transform: Matrix4.identity()..scale(-1.0, isOn ? -1.0 : -1.0, -1.0),
          transform: Matrix4.identity()
            ..scale(!isOn ? -1.0 : 1.0, 1.0, 1.0)
            ..translate(!isOn ? -200.0 : 0.0, 0.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(isDariyOn ? firstImage : secondImage),
            ),
          ),
        ),
      ),
    );
  }
}
