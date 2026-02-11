import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/domain/app_data.dart';
import 'package:zymixx_todo_list/presentation/app_widgets/my_radio_icon.dart';
import '../../app_widgets/my_animated_card.dart';

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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22.0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.58),
                              borderRadius: BorderRadius.circular(22.0),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.65),
                                  blurRadius: 24.0,
                                  spreadRadius: 4.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CreateDailyContentColumn(),
                            ),
                          ),
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
  bool autoStart = false;

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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Название',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: ToolThemeData.highlightGreenColor,
                        width: 1.4,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      borderRadius: BorderRadius.circular(12.0),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Минуты в день',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.68),
                          ),
                          prefixIcon: const Icon(
                            Icons.timelapse,
                            color: Colors.white,
                            size: 20,
                          ),
                          suffixText: 'min',
                          suffixStyle: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.35),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: ToolThemeData.highlightGreenColor,
                              width: 1.4,
                            ),
                          ),
                        ),
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
                      borderRadius: BorderRadius.circular(12.0),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          suffixIcon: const Icon(
                            Icons.emoji_events,
                            color: Colors.amberAccent,
                            size: 22,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.35),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: ToolThemeData.highlightGreenColor,
                              width: 1.4,
                            ),
                          ),
                        ),
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: RadioButtonWidget(
                  valueCallBack: (int value) {
                    this.autoPauseSeconds = value;
                  },
                  autoStartCallBack: (bool autoStart) {
                    this.autoStart = autoStart;
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 3.0),
          FadeTransition(
            opacity: _animation3,
            child: MyAnimatedCard(
              intensity: 0.005,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: WeekdayRadioButtonWidget(
                  valueCallBack: (List<int> value) {
                    this.dailyDayList = value;
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 3.0),
          FadeTransition(
            opacity: _animation3,
            child: MyAnimatedCard(
              intensity: 0.005,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: PeriodicRadioButtonWidget(
                  valueCallBack: (int value) {
                    this.period = value;
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 5.0),
          FadeTransition(
            opacity: _animation4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999.0),
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
                      'autoStart': autoStart,
                    });
                  },
                  child: Text(
                    'Создать',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ToolThemeData.mainGreenColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 14.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999.0),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.4),
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
  final Function valueCallBack;
  final Function autoStartCallBack;

  RadioButtonWidget({
    required this.valueCallBack,
    required this.autoStartCallBack,
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
          scale: 1.2,
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
          scale: 1.2,
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
          scale: 1.2,
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
        Transform.scale(
          scale: 1.1,
          child: MyAnimatedCard(
            intensity: 0.007,
            child: MyRadioIcon(
              unselectedColor: Colors.white70,
              selectedColor: Colors.amberAccent,
              onSelect: () {
                widget.autoStartCallBack.call(true);
              },
              iconData: Icons.run_circle_outlined,
              size: 33,
              onDeselect: () {
                widget.autoStartCallBack.call(false);
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 7.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: _dailyDayList.contains(i)
                    ? ToolThemeData.highlightColor
                    : Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(999.0),
                border: Border.all(
                  color: _dailyDayList.contains(i)
                      ? ToolThemeData.highlightColor
                      : Colors.white.withOpacity(0.35),
                  width: 0.8,
                ),
              ),
              child: Text(
                _getWeekday(i),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: _dailyDayList.contains(i)
                      ? Colors.white
                      : Colors.white.withOpacity(0.95),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        Text(
          'Период:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
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
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedValue == i
                        ? ToolThemeData.highlightColor
                        : Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999.0),
                    border: Border.all(
                      color: _selectedValue == i
                          ? ToolThemeData.highlightColor
                          : Colors.white.withOpacity(0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    i.toString(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _selectedValue == i
                          ? Colors.white
                          : Colors.white.withOpacity(0.95),
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
