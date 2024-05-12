import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/presentation/bloc/daily_todo_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/mu_animated_card.dart';

class CreateDailyWidget extends StatefulWidget {
  const CreateDailyWidget({super.key});

  @override
  State<CreateDailyWidget> createState() => _CreateDailyWidgetState();
}

class _CreateDailyWidgetState extends State<CreateDailyWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Stack(
        children: [
          InkWell(
            onTap: () => ToolShowOverlay.cancelUserData(),
            splashColor: Colors.transparent,
          ),
          Center(
            child: StreamBuilder<Object>(
                stream: null,
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: FractionallySizedBox(
                      widthFactor: 0.7,
                      heightFactor: 0.6,
                      alignment: Alignment.topLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6.0,
                              spreadRadius: 4.0,
                              offset: Offset(0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CreateDailyContentColumn(),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class CreateDailyContentColumn extends StatefulWidget {
  @override
  _CreateDailyContentColumnState createState() => _CreateDailyContentColumnState();
}

class _CreateDailyContentColumnState extends State<CreateDailyContentColumn>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;
  late Animation<double> _animation4;

  String? name;
  int? timer;
  int autoPauseSeconds = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400), // Общая длительность анимации
    );
    _animation1 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 0.7), // Виджет 1 появляется сразу
      ),
    );
    _animation2 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 0.8), // Задержка для второго виджета
      ),
    );
    _animation3 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.6, 0.9), // Задержка для третьего виджета
      ),
    );
    _animation4 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.7, 1.0), // Задержка для третьего виджета
      ),
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _animation1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 4.0,
                    spreadRadius: 2.0,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: MyAnimatedCard(
                intensity: 0.007,
                child: TextField(
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Название',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          FadeTransition(
            opacity: _animation2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 4.0,
                    spreadRadius: 2.0,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: MyAnimatedCard(
                intensity: 0.007,
                child: TextField(
                  onChanged: (value) {
                    timer = int.tryParse(value) ?? 0;
                  },
                  maxLines: 1,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Минуты в день',
                    prefixIcon: Icon(Icons.timelapse),
                    suffixText: 'min',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          FadeTransition(
            opacity: _animation3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 2.5,
                    spreadRadius: 1.5,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: MyAnimatedCard(
                  intensity: 0.005,
                  child: RadioButtonWidget(valueCallBack: (int value) {
                    this.autoPauseSeconds = value;
                  }),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          FadeTransition(
            opacity: _animation4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 2.5,
                    spreadRadius: 1.5,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: MyAnimatedCard(
                intensity: 0.01,
                child: ElevatedButton(
                  onPressed: () {
                    ToolShowOverlay.submitUserData({
                      'name': name,
                      'timer': timer,
                      'autoPauseSeconds': autoPauseSeconds,
                    });
                  },
                  child: Text(
                    'Создать',
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.greenAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class RadioButtonWidget extends StatefulWidget {
  Function valueCallBack;

  RadioButtonWidget({
    required this.valueCallBack,
  });

  @override
  RadioButtonWidgetState createState() => RadioButtonWidgetState();
}

class RadioButtonWidgetState extends State<RadioButtonWidget> {
  var _selectedValue = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Transform.scale(
          scale: 1.5,
          child: MyAnimatedCard(
            intensity: 0.007,
            child: Radio(
              value: 0,
              splashRadius: 13,
              fillColor: MaterialStateProperty.all(Colors.white),
              groupValue: _selectedValue,
              onChanged: (value) {
                setState(() {
                  widget.valueCallBack.call(value);
                  _selectedValue = value!;
                });
              },
            ),
          ),
        ),
        Transform.scale(
          scale: 1.5,
          child: MyAnimatedCard(
            intensity: 0.007,
            child: Radio(
              value: 60,
              splashRadius: 13,
              fillColor: MaterialStateProperty.all(Colors.yellowAccent),
              groupValue: _selectedValue,
              onChanged: (value) {
                setState(() {
                  widget.valueCallBack.call(value);
                  _selectedValue = value!;
                });
              },
            ),
          ),
        ),
        Transform.scale(
          scale: 1.5,
          child: MyAnimatedCard(
            intensity: 0.007,
            child: Radio(
              value: 120,
              splashRadius: 13,
              fillColor: MaterialStateProperty.all(Colors.red),
              groupValue: _selectedValue,
              onChanged: (value) {
                setState(() {
                  widget.valueCallBack.call(value);
                  _selectedValue = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
