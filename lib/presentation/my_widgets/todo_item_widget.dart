import 'package:flutter/material.dart';

class TodoItemWidget extends StatelessWidget {
  const TodoItemWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      child: Container(
        width: 400,
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          border: Border.all(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          children: [
            Flexible(flex: 4, fit: FlexFit.tight, child: TitleWidget()),
            VerticalDivider(
              width: 6,
              thickness: 2,
              indent: 4,
              endIndent: 4,
              color: Colors.red,
            ),
            Flexible(flex: 1, child: TimerWidget())
          ],
        ),
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, bottom: 4.0),
      child: Text('Всем привет! Вы на канале "TeachMeSkills Школа программирования"!'),
    );
  }
}

class TimerWidget extends StatelessWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.timer,
              color: Colors.black87,
            ),
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.timelapse_outlined,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
