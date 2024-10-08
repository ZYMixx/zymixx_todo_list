import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/domain/app_data.dart';
import '../app_widgets/my_animated_card.dart';
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
            onTap: () => Get.find<ToolShowOverlay>().submitUserData(null),
            splashColor: Colors.transparent,
          ),
          Center(
            child: StreamBuilder<Object>(
                stream: null,
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      heightFactor: 0.60,
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
                              offset: Offset(0, 2),
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

  String name = '';
  int prise = 0;
  int timer = 0;
  int autoPauseSeconds = 0;
  List<int> dailyDayList = [];
  int period = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _animation1 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 0.7),
      ),
    );
    _animation2 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 0.8),
      ),
    );
    _animation3 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.6, 0.9),
      ),
    );
    _animation4 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.7, 1.0),
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
                    offset: Offset(0, 2),
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
          SizedBox(height: 15.0),
          FadeTransition(
            opacity: _animation2,
            child: Row(
              children: [
                Flexible(
                  flex: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          blurRadius: 4.0,
                          spreadRadius: 2.0,
                          offset: Offset(0, 0),
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
                        maxLength: 3,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          hintText: 'Минуты в день',
                          prefixIcon: Icon(Icons.timelapse),
                          hintStyle: TextStyle(fontSize: 13),
                          suffixText: 'min',
                          counterText: '',
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
                SizedBox(width: 10),
                Flexible(
                  flex: 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          blurRadius: 4.0,
                          spreadRadius: 2.0,
                          offset: Offset(0, 0),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: MyAnimatedCard(
                      intensity: 0.007,
                      child: TextField(
                        onChanged: (value) {
                          prise = int.tryParse(value) ?? 0;
                        },
                        maxLength: 2,
                        maxLines: 1,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.emoji_events),
                          filled: true,
                          counterText: '',
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
              ],
            ),
          ),
          SizedBox(height: 5.0),
          FadeTransition(
            opacity: _animation3,
            child: MyAnimatedCard(
              intensity: 0.005,
              child: RadioButtonWidget(valueCallBack: (int value) {
                this.autoPauseSeconds = value;
              }),
            ),
          ),
          SizedBox(height: 3.0),
          FadeTransition(
            opacity: _animation3,
            child: MyAnimatedCard(
              intensity: 0.005,
              child: WeekdayRadioButtonWidget(valueCallBack: (List<int> value) {
                this.dailyDayList = value;
              }),
            ),
          ),
          SizedBox(height: 3.0),
          FadeTransition(
            opacity: _animation3,
            child: MyAnimatedCard(
              intensity: 0.005,
              child: PeriodicRadioButtonWidget(valueCallBack: (int value) {
                this.period = value;
              }),
            ),
          ),
          SizedBox(height: 5.0),
          FadeTransition(
            opacity: _animation4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 2.5,
                    spreadRadius: 1.5,
                    offset: Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: MyAnimatedCard(
                intensity: 0.01,
                child: ElevatedButton(
                  onPressed: () {
                    Get.find<ToolShowOverlay>().submitUserData({
                      'name': name,
                      'timer': timer,
                      'autoPauseSeconds': autoPauseSeconds,
                      'prise': prise,
                      'dailyDayList': dailyDayList,
                      'period': period,
                    });
                  },
                  child: Text(
                    'Создать',
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ToolThemeData.mainGreenColor,
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
              value: AppData.dailyMediumAutoPause,
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
              value: AppData.dailyHardAutoPause,
              splashRadius: 13,
              fillColor: MaterialStateProperty.all(ToolThemeData.highlightColor),
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

class WeekdayRadioButtonWidget extends StatefulWidget {
  final Function(List<int>) valueCallBack;

  const WeekdayRadioButtonWidget({
    required this.valueCallBack,
  });

  @override
  _WeekdayRadioButtonWidgetState createState() => _WeekdayRadioButtonWidgetState();
}

class _WeekdayRadioButtonWidgetState extends State<WeekdayRadioButtonWidget> {
  List<int> _dailyDayList = [];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        for (int i = 1; i < 8; i++)
          InkWell(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            onTap: () {
              setState(() {
                if (_dailyDayList.contains(i)) {
                  _dailyDayList.remove(i);
                } else {
                  _dailyDayList.add(i);
                }
                widget.valueCallBack(_dailyDayList);
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.5, vertical: 3.0),
              decoration: BoxDecoration(
                color: _dailyDayList.contains(i) ? Colors.blueAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _getWeekday(i),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _dailyDayList.contains(i) ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getWeekday(int index) {
    switch (index) {
      case 1:
        return 'Пн';
      case 2:
        return 'Вт';
      case 3:
        return 'Ср';
      case 4:
        return 'Чт';
      case 5:
        return 'Пт';
      case 6:
        return 'Сб';
      case 7:
        return 'Вс';
      default:
        return '';
    }
  }
}

class PeriodicRadioButtonWidget extends StatefulWidget {
  final Function(int) valueCallBack;

  const PeriodicRadioButtonWidget({
    required this.valueCallBack,
  });

  @override
  _PeriodicRadioButtonWidgetState createState() => _PeriodicRadioButtonWidgetState();
}

class _PeriodicRadioButtonWidgetState extends State<PeriodicRadioButtonWidget> {
  int _selectedValue = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 30,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              ' Период:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 1; i < 4; i++)
              InkWell(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                onTap: () {
                  setState(() {
                    if (_selectedValue == i) {
                      _selectedValue = 0;
                      widget.valueCallBack(_selectedValue);
                    } else {
                      _selectedValue = i;
                      widget.valueCallBack(_selectedValue);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: _selectedValue == i ? Colors.blueAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    i.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedValue == i ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
