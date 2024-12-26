import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/services/service_image_plugin_work.dart';
import 'package:zymixx_todo_list/data/tools/tool_date_formatter.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/presentation/bloc_global/all_item_control_bloc.dart';

import '../../../data/tools/tool_time_string_converter.dart';
import '../../../domain/todo_item.dart';
import '../../app_widgets/my_animated_card.dart';
import '../todo_item_bloc.dart';
import 'package:zymixx_todo_list/presentation/bloc_global/all_item_control_bloc.dart';

// основной виджет со всеми активностями

class TodoItemWidget extends StatelessWidget {
  final TodoItem todoItem;
  Color bgColor;

  TodoItemWidget({Key? key, required this.todoItem, this.bgColor = Colors.blueAccent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoItemBloc(todoItem: todoItem),
      child: TodoItemBody(bgColor: bgColor),
    );
  }
}

class TodoItemBody extends StatefulWidget {
  final Color bgColor;

  const TodoItemBody({
    super.key,
    required this.bgColor,
  });

  @override
  State<TodoItemBody> createState() => _TodoItemBodyState();
}

class _TodoItemBodyState extends State<TodoItemBody> {
  late DismissAnimationWidget dismissArrow;

  @override
  void initState() {
    dismissArrow = DismissAnimationWidget();
  }

  @override
  Widget build(BuildContext context) {
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    bool isChangeTextMod = context.select((TodoItemBloc bloc) => bloc.state.changeTextMod);
    String todoContent = bloc.state.todoItem.content;
    int lineSeparator = bloc.state.todoItem.content.split('\n').length - 1;
    int lines = (todoContent.length + (lineSeparator * 8)) ~/ 24;
    DateTime? targetDateTime =
        context.select((TodoItemBloc bloc) => bloc.state.todoItem.targetDateTime);
    if (lines < 2) {
      lines = 2;
    }
    if (lines > 5) {
      lines = 5;
    }
    return MyAnimatedCard(
      intensity: 0.003,
      child: AnimatedContainer(
        width: ToolThemeData.itemWidth,
        curve: Curves.easeInOut,
        height: isChangeTextMod
            ? (21 * lines).toDouble() + (ToolThemeData.itemHeight + 18)
            : (ToolThemeData.itemHeight),
        constraints: BoxConstraints(
          minHeight: isChangeTextMod
              ? (21 * lines).toDouble() + ToolThemeData.itemHeight
              : ToolThemeData.itemHeight,
        ),
        duration: Duration(milliseconds: 250),
        child: Dismissible(
          key: UniqueKey(),
          background: dismissArrow,
          onDismissed: (DismissDirection direction) {
            bloc.add(DismissEvent(direction: direction));
          },
          onUpdate: (value) {
            if (value.direction == DismissDirection.startToEnd) {
              dismissArrow.setAnimation?.call(value.progress, true);
            } else {
              dismissArrow.setAnimation?.call(value.progress, false);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: bloc.state.todoItem.category == EnumTodoCategory.social.name
                  ? ToolThemeData.specialItemColor
                  : widget.bgColor,
              gradient: bloc.state.todoItem.category == EnumTodoCategory.social.name
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ToolThemeData.specialItemColor,
                        widget.bgColor,
                      ],
                      transform: GradientRotation(-0.04),
                      stops: [0.5, 1],
                    )
                  : null,
              border: Border.all(
                color: widget.bgColor == Colors.transparent
                    ? Colors.transparent
                    : ToolThemeData.itemBorderColor,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            //? начало фронт-графики
            child: Row(
              children: [
                Flexible(
                  flex: 12,
                  fit: FlexFit.tight,
                  child: GestureDetector(
                    onLongPress: () {},
                    onTap: () {},
                    child: isChangeTextMod ? TitleChangeWidget() : TitlePresentWidget(),
                  ),
                ),
                MyAnimatedCard(
                  intensity: 0.01,
                  directionUp: false,
                  child: AnimatedCirclesWidget(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 4),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 1.5,
                              spreadRadius: 1.0,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: ColoredBox(
                            color:
                                targetDateTime?.getHighlightColor(targetDateTime) ?? Colors.black,
                            child: SizedBox(
                              width: 3.5,
                              height: double.infinity,
                            )),
                      ),
                    ),
                  ),
                ),
                Flexible(flex: 6, child: TimerWorkWidget()),
                //SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DismissAnimationWidget extends StatefulWidget {
  Function(double value, bool right)? setAnimation;

  DismissAnimationWidget({Key? key}) : super(key: key);

  @override
  _DismissAnimationWidgetState createState() => _DismissAnimationWidgetState();
}

class _DismissAnimationWidgetState extends State<DismissAnimationWidget>
    with SingleTickerProviderStateMixin {
  double animValue = 0.0;
  bool isRightArrow = true;

  @override
  void initState() {
    super.initState();
    widget.setAnimation = (double value, bool right) {
      if (mounted) {
        setState(() {
          isRightArrow = right;
          animValue = value * (right ? 1 : -1);
        });
      }
      ;
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //int mnog = isRightArrow ? -1 : 1;
    return Opacity(
      opacity: animValue == 0 ? 0 : 1,
      child: Transform.translate(
        //offset: Offset(0, 0),
        offset: Offset(
            400 * (animValue / 2) + (8 * Random().nextDouble()) + (isRightArrow ? -230 : 220), 0),
        child: Container(
          alignment: isRightArrow ? Alignment.centerLeft : Alignment.centerRight,
          padding: EdgeInsets.only(right: 30),
          child: ListView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            clipBehavior: Clip.none,
            children: List.generate(24, (index) {
              return SizedBox(
                width: 35,
                child: Icon(
                  isRightArrow
                      ? Icons.keyboard_double_arrow_right
                      : Icons.keyboard_double_arrow_left,
                  color: isRightArrow ? ToolThemeData.mainGreenColor : ToolThemeData.highlightColor,
                  // Цвет стрелок
                  size: 50,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class TitlePresentWidget extends StatelessWidget {
  const TitlePresentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bloc = context.select((TodoItemBloc bloc) => bloc);
    File? todoImageFile = bloc.state.imageFile;
    String title = bloc.state.todoItem.title;
    DateTime? targetDateTime =
        context.select((TodoItemBloc bloc) => bloc.state.todoItem.targetDateTime);
    return Stack(
      children: [
        InkWell(
          onTap: () {
            bloc.add(ChangeModEvent(isChangeMod: true));
          },
          child: Padding(
            padding: EdgeInsets.only(left: 6.0, bottom: 4.0, right: todoImageFile != null ? 25 : 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                (' ' + (title.capStart() ?? '')) ?? '',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: -0.5,
                    wordSpacing: -1.0,
                    height: 0.9,
                    shadows: ToolThemeData.defTextShadow),
              ),
            ),
          ),
        ),
        if (todoImageFile != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
            child: Align(
              alignment: Alignment.bottomRight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: targetDateTime?.getHighlightColor(targetDateTime) ?? Colors.black,
                      width: 0.5),
                  borderRadius: BorderRadius.circular(ToolThemeData.itemHeight),
                ),
                child: SizedBox(
                  width: ToolThemeData.itemHeight - 10,
                  height: ToolThemeData.itemHeight,
                  child: InkWell(
                    onTap: () {
                      //ii image top
                      Get.find<ServiceImagePluginWork>().openImage(todoImageFile);
                    },
                    child: MyAnimatedCard(
                      intensity: 0.01,
                      directionUp: false,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Opacity(
                          opacity: 0.80,
                          child: Image.file(
                            todoImageFile,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Align(
            alignment: Alignment.bottomRight,
            child: DecoratedBox(
              decoration: todoImageFile != null
                  ? BoxDecoration(
                      border: Border.all(
                          color: ToolThemeData.highlightColor.withOpacity(0.5), width: 0.5),
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : BoxDecoration(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  Get.find<ToolDateFormatter>().formatToMonthDay(targetDateTime) ?? '',
                  style: TextStyle(
                    color: bloc.state.todoItem.category == EnumTodoCategory.social.name
                        ? ToolThemeData.mainGreenColor
                        : Colors.black,
                    fontWeight: bloc.state.todoItem.category == EnumTodoCategory.social.name ||
                            todoImageFile != null
                        ? FontWeight.w700
                        : FontWeight.w600,
                    fontSize:
                        bloc.state.todoItem.category == EnumTodoCategory.social.name ? 13 : 11,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class TitleChangeWidget extends StatefulWidget {
  const TitleChangeWidget({Key? key}) : super(key: key);

  @override
  State<TitleChangeWidget> createState() => _TitleChangeWidgetState();
}

class _TitleChangeWidgetState extends State<TitleChangeWidget> {
  late TextEditingController _controllerTitle;
  late TextEditingController _controllerDescription;
  late String initialText;
  String descriptionForSave = '';

  late FocusNode _focusNodeTitle;
  late FocusNode _focusNodeDescription;
  TextSelection? _selectionTitle;
  TextSelection? _selectionDescription;

  @override
  void initState() {
    super.initState();
    _controllerTitle = TextEditingController();
    _controllerDescription = TextEditingController();
    _focusNodeTitle = FocusNode();
    _focusNodeDescription = FocusNode();
    _controllerDescription.addListener(() {
      _replaceNewLinesWithEmoji();
      descriptionForSave = _formatTextForSave(_controllerDescription.text);
    });
  }

  void _saveSelection() {
    if (_focusNodeTitle.hasFocus) {
      _selectionTitle = _controllerTitle.selection;
    } else {
      _selectionTitle = null;
    }
    if (_focusNodeDescription.hasFocus) {
      _selectionDescription = _controllerDescription.selection;
    } else {
      _selectionDescription = null;
    }
  }

  void _restoreSelection() {
    if (_selectionTitle != null) {
      _controllerTitle.selection = _selectionTitle!;
      _focusNodeTitle.requestFocus();
    }
    if (_selectionDescription != null) {
      _controllerDescription.selection = _selectionDescription!;
      _focusNodeDescription.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    File? todoImageFile = context.select((TodoItemBloc bloc) => bloc.state.imageFile);
    _controllerTitle.text = bloc.state.todoItem.title ?? '';
    initialText = bloc.state.todoItem.content ?? '';
    _controllerDescription.text = bloc.state.todoItem.content ?? '';
    DateTime? targetDateTime = bloc.state.todoItem.targetDateTime;
    String formattedTargetDateTime =
        Get.find<ToolDateFormatter>().formatToMonthDay(targetDateTime) ?? '';
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, bottom: 4.0),
      child: Focus(
        onFocusChange: (focus) {
          if (focus) {
            _controllerTitle
              ..selection =
                  TextSelection(baseOffset: 0, extentOffset: _controllerTitle.text.length);
          }
          if (!focus) {
            print('focus locc add Event ${_controllerTitle.text.trim()}');
            //_saveSelection();
            Future.delayed(Duration.zero, () {
              bloc.add(
                SaveItemChangeEvent(
                  titleText: _controllerTitle.text.trim(),
                  descriptionText: descriptionForSave,
                ),
              );
            });
          }
        },
        child: Column(
          children: [
            TextField(
              controller: _controllerTitle,
              autofocus: true,
              maxLines: 1,
              focusNode: _focusNodeTitle,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                suffixIcon: MyAnimatedCard(
                  intensity: 0.012,
                  child: Container(
                    width: 50,
                    height: 40,
                    alignment: Alignment.center,
                    child: InkWell(
                      focusNode: FocusNode(skipTraversal: true),
                      onTap: () => {
                        _saveSelection(),
                        bloc
                          ..add(
                            SaveItemChangeEvent(
                              titleText: _controllerTitle.text.trim(),
                              descriptionText: descriptionForSave,
                              setChangeMod: true,
                            ),
                          )
                          ..add(
                            RequestChangeItemDateEvent(
                                buildContext: context, restoreFocusCallBack: _restoreSelection),
                          )
                      },
                      onLongPress: () => bloc
                        ..add(
                          SaveItemChangeEvent(
                            titleText: _controllerTitle.text.trim(),
                            descriptionText: descriptionForSave,
                            setChangeMod: true,
                          ),
                        )
                        ..add(
                          SetItemDateEvent(userDateTime: DateTime.now()),
                        ),
                      onSecondaryTap: () => bloc
                        ..add(
                          SaveItemChangeEvent(
                            titleText: _controllerTitle.text.trim(),
                            descriptionText: descriptionForSave,
                            setChangeMod: true,
                          ),
                        )
                        ..add(
                          IncreaseItemDateEvent(),
                        ),
                      child: Text(
                        formattedTargetDateTime,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          shadows: ToolThemeData.defTextShadow,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all<Color>(Colors.black),
                thumbVisibility: MaterialStateProperty.all<bool>(true),
                thickness: MaterialStateProperty.all<double>(5),
              ),
              child: TextField(
                controller: _controllerDescription,
                focusNode: _focusNodeDescription,
                minLines: 2,
                selectionControls: MaterialTextSelectionControls(),
                maxLines: initialText == '' ? 3 : 8,
                decoration: InputDecoration(
                  suffixIconConstraints: todoImageFile == null
                      ? BoxConstraints.tightFor(width: 35, height: 35)
                      : BoxConstraints.tightFor(width: 45, height: 45),
                  suffixIcon: (bloc.state.todoItem.title == 'New Title')
                      ? Container()
                      : todoImageFile != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: InkWell(
                                      onTap: () {
                                        Get.find<ServiceImagePluginWork>().openImage(todoImageFile);
                                      },
                                      onSecondaryTap: () {},
                                      onLongPress: () {
                                        Get.find<ServiceImagePluginWork>().deleteImage(
                                          todoItem: bloc.state.todoItem,
                                          updateCallBack: () => bloc.add(SetTodoItemImageEvent()),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12.0),
                                        child: Opacity(
                                          opacity: 0.80,
                                          child: AspectRatio(
                                            aspectRatio:
                                                1.0, // Устанавливаем квадратное соотношение сторон
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              child: Image.file(
                                                todoImageFile,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: InkWell(
                                  focusNode: FocusNode(skipTraversal: true),
                                  onTap: () {
                                    //ii image
                                    Get.find<ServiceImagePluginWork>().drawImage(
                                        title: bloc.state.todoItem.title,
                                        id: bloc.state.todoItem.id,
                                        updateCallBack: () => bloc.add(SetTodoItemImageEvent()));
                                    Log.e('ADD NEW IMAGE');
                                  },
                                  onSecondaryTap: () {
                                    Get.find<ServiceImagePluginWork>().selectAndSetTodoImage(
                                      todoItem: bloc.state.todoItem,
                                      updateCallBack: () => bloc.add(SetTodoItemImageEvent()),
                                    );
                                  },
                                  child: Center(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: MyAnimatedCard(
                                          intensity: 0.012,
                                          child: ClipOval(
                                            child: Opacity(
                                              opacity: 0.9,
                                              child: Icon(
                                                Icons.add_a_photo_outlined,
                                                color: Colors.purple,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: -0.5,
                  wordSpacing: -0.5,
                  height: 0.95,
                  shadows: [
                    Shadow(
                      color: Colors.black12,
                      offset: Offset(0, 0.1),
                      blurRadius: 1.5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _replaceNewLinesWithEmoji() {
    String currentText = _controllerDescription.text;
    String regexPattern = '\\n(?!${ToolThemeData.lineIndicator})';
    String newText = currentText.replaceAllMapped(
        RegExp(regexPattern), (match) => '\n${ToolThemeData.lineIndicator}');
    if (newText != currentText) {
      _controllerDescription.value = _controllerDescription.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
            offset: _controllerDescription.selection.baseOffset +
                (newText.length - currentText.length)),
      );
    }
  }

  String _formatTextForSave(test) {
    return _controllerDescription.text.replaceAll(ToolThemeData.lineIndicator, '');
  }
}

class TimerWorkWidget extends StatefulWidget {
  const TimerWorkWidget({Key? key}) : super(key: key);

  @override
  State<TimerWorkWidget> createState() => _TimerWorkWidgetState();
}

class _TimerWorkWidgetState extends State<TimerWorkWidget> {
  TimeModEnum? lastTimeMod;

  @override
  Widget build(BuildContext context) {
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    TodoItem todoItem = context.select((TodoItemBloc bloc) => bloc.state.todoItem);
    bool needTimerSong = context.select((TodoItemBloc bloc) => bloc.state.needTimerSong);
    int autoPauseSeconds = todoItem.autoPauseSeconds;
    TimeModEnum timerMod = context.select((TodoItemBloc bloc) => bloc.state.timerMod);
    return Stack(
      children: [
        if (autoPauseSeconds > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0, left: 5.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: DecoratedBox(
                position: DecorationPosition.background,
                decoration: BoxDecoration(
                  border: Border.all(width: 1.5, color: Colors.black),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: Opacity(
                    opacity: 1,
                    child: CircleAvatar(
                        radius: 4,
                        backgroundColor: autoPauseSeconds == 30
                            ? ToolThemeData.specialItemColor
                            : ToolThemeData.highlightColor),
                  ),
                ),
              ),
            ),
          ),
        if (!needTimerSong)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 2.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(0.5),
                child: Opacity(
                  opacity: 1,
                  child: Icon(
                    Icons.music_off_outlined,
                    size: 18,
                    color: ToolThemeData.itemBorderColor,
                  ),
                ),
              ),
            ),
          ),
        Center(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              Offset animateOffset;
              if (child is StopwatchWidget) {
                animateOffset = Offset(-0.4, 0.0);
                lastTimeMod = TimeModEnum.stopwatch;
              } else if (child is TimerWidget) {
                animateOffset = Offset(0.4, 0.0);
                lastTimeMod = TimeModEnum.timer;
              } else {
                if (timerMod == TimeModEnum.timer) {
                  animateOffset = Offset(-0.4, 0.0);
                } else {
                  if (lastTimeMod == TimeModEnum.timer) {
                    animateOffset = Offset(-0.4, 0.0);
                    lastTimeMod = null;
                  } else {
                    animateOffset = Offset(0.4, 0.0);
                    lastTimeMod = null;
                  }
                }
              }
              var slideAnimation = Tween<Offset>(
                begin: animateOffset,
                end: Offset(0.0, 0.0),
              ).animate(animation);
              return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slideAnimation, child: child));
            },
            child: buildCrntWidget(bloc: bloc, timerMod: timerMod),
          ),
        ),
      ],
    );
  }

  Widget buildCrntWidget({required TodoItemBloc bloc, required TimeModEnum timerMod}) {
    switch (timerMod) {
      case TimeModEnum.timer:
        return TimerWidget();
      case TimeModEnum.stopwatch:
        return StopwatchWidget();
      case TimeModEnum.none:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: GestureDetector(
                onLongPress: () {
                  bloc.add(SetTimerNeedSongEvent());
                },
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      bloc.add(ChangeTimeModEvent(timerMod: TimeModEnum.stopwatch));
                    });
                  },
                  icon: Icon(
                    Icons.timer,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: GestureDetector(
                onLongPress: () {
                  bloc.add(SetTimerNeedSongEvent());
                },
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      bloc.add(ChangeTimeModEvent(timerMod: TimeModEnum.timer));
                    });
                  },
                  icon: Icon(
                    Icons.timelapse_outlined,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  double scale = 1.0;
  double opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    int timer = context.select((TodoItemBloc bloc) => bloc.state.todoItem.timerSeconds);
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    Get.find<ToolTimeStringConverter>().formatSecondsToTimeMinute(timer);
    String timerString = Get.find<ToolTimeStringConverter>().formatSecondsToTimeMinute(timer);
    bool isTimerActive = context.select((TodoItemBloc bloc) => bloc.state.isTimerActive);

    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: InkWell(
              onTap: () {
                bloc.add(ChangeTimerEvent(changeNum: -60));
              },
              onSecondaryTap: () {
                bloc.add(ChangeTimerEvent(changeNum: -300));
              },
              onLongPress: () {
                bloc.add(ChangeTimerEvent(changeNum: -3600));
              },
              child: Icon(
                Icons.remove,
                size: 16,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            onTap: () {
              bloc.add(StopStartTimerEvent());
            },
            onSecondaryTap: () {
              bloc.add(ChangeTimeModEvent(timerMod: TimeModEnum.none));
            },
            child: Row(
              children: [
                GestureDetector(
                  onLongPress: () {
                    bloc.add(SetTimerNeedSongEvent());
                  },
                  child: Text(
                    timerString,
                    style: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w500,
                      shadows: ToolThemeData.defTextShadow,
                    ),
                  ),
                ),
                Builder(builder: (context) {
                  if (scale == 1.0) {
                    scale = 1.10;
                    opacity = 1.0;
                  } else {
                    scale = 1.0;
                    opacity = 0.8;
                  }
                  return AnimatedOpacity(
                    duration: Duration(seconds: 1),
                    opacity: opacity,
                    child: AnimatedScale(
                      scale: scale,
                      duration: Duration(seconds: 1),
                      child: Icon(
                        Icons.arrow_downward_outlined,
                        size: 14,
                        color: isTimerActive ? Colors.black : Colors.grey[700],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              bloc.add(ChangeTimerEvent(changeNum: 60));
            },
            onSecondaryTap: () {
              bloc.add(ChangeTimerEvent(changeNum: 300));
            },
            onLongPress: () {
              bloc.add(ChangeTimerEvent(changeNum: 3600));
            },
            child: Icon(
              Icons.add,
              size: 16,
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
    );
  }
}

class StopwatchWidget extends StatefulWidget {
  const StopwatchWidget({Key? key}) : super(key: key);

  @override
  State<StopwatchWidget> createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> {
  double scale = 1.0;
  double opacity = 1.0;
  Tween<Offset> positionTween = Tween(begin: Offset(0, 0), end: Offset(0, 0.2));

  @override
  Widget build(BuildContext context) {
    int stopwatch = context.select((TodoItemBloc bloc) => bloc.state.todoItem.stopwatchSeconds);
    bool isTimerActive = context.select((TodoItemBloc bloc) => bloc.state.isTimerActive);
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    String stopwatchString =
        Get.find<ToolTimeStringConverter>().formatSecondsToTimeMinute(stopwatch);
    return IconButton(
      onPressed: null,
      icon: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(20)),

        onSecondaryTap: () {
          bloc.add(ChangeTimeModEvent(timerMod: TimeModEnum.none));
        },
        onTap: () {
          bloc.add(StopStartStopwatchEvent());
        },
        onLongPress: () {
          bloc.add(StopwatchResetTimeEvent());
        },
        child: Padding(
          padding: EdgeInsets.only(left: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onLongPress: () {
                  bloc.add(SetTimerNeedSongEvent());
                },
                child: Text(
                  stopwatchString,
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w500,
                    shadows: ToolThemeData.defTextShadow,
                  ),
                ),
              ),
              //ii timer arrow
              Builder(builder: (context) {
                if (scale == 1.0) {
                  scale = 1.25;
                  opacity = 1.0;
                } else {
                  scale = 1.0;
                  opacity = 0.7;
                }
                return AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  opacity: opacity,
                  child: AnimatedScale(
                    scale: scale,
                    duration: Duration(seconds: 1),
                    child: Icon(
                      Icons.arrow_upward_outlined,
                      size: 14,
                      color: isTimerActive ? Colors.black : Colors.grey[700],
                    ),
                  ),
                );
              }),
              SizedBox(width: 3)
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedCirclesWidget extends StatefulWidget {
  final Widget child;

  const AnimatedCirclesWidget({Key? key, required this.child}) : super(key: key);

  @override
  _AnimatedCirclesWidgetState createState() => _AnimatedCirclesWidgetState();
}

class _AnimatedCirclesWidgetState extends State<AnimatedCirclesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  Offset? _tapPosition;
  List<OverlayEntry> _overlayEntries = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 120), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntries.forEach((entry) => entry.remove());
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details, BuildContext parentContext) {
    _tapPosition = details.globalPosition;
    _timer?.cancel();
    if (_overlayEntries.isNotEmpty) {
      _handleTapUp();
    } else {
      _controller.forward(from: 0.0);
      _showCircles(parentContext);
    }
    _timer = Timer(Duration(milliseconds: 1500), () {
      if (mounted) {
        if (!_controller.isAnimating) {
          _handleTapUp();
          _timer = null;
        }
      }
    });
  }

  void _handleTapUp() {
    _timer?.cancel();
    _controller.reverse()..then((value) => _hideCircles());
  }

  void _showCircles(BuildContext parentContext) {
    _overlayEntries = List.generate(3, (index) {
      Color circleColor = Colors.white;
      switch (index) {
        case 0:
          circleColor = Colors.grey[300]!;
          break;
        case 1:
          circleColor = Colors.amberAccent!;
          break;
        case 2:
          circleColor = ToolThemeData.highlightColor;
          break;
      }
      return OverlayEntry(
        builder: (context) {
          return AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return AnimatedPositioned(
                duration: Duration(milliseconds: 120),
                left: calculateX(index, _scaleAnimation.value) - 10,
                top: calculateY(index, _scaleAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        parentContext.read<TodoItemBloc>().add(
                            SetAutoPauseSeconds(autoPauseSeconds: index == 0 ? 0 : 30 ~/ index));
                        Log.i('set auto pause on ${30 ~/ index}');
                        _handleTapUp();
                      },
                      child: MyAnimatedCard(
                        intensity: 0.01,
                        child: Container(
                          width: 20.0,
                          height: 20.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: circleColor.withOpacity(0.8),
                            border: Border.all(
                              color: Colors.white!,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    });

    _overlayEntries.forEach((entry) {
      Overlay.of(context)?.insert(entry);
    });
  }

  double calculateX(int index, double animation) {
    double rangeX = 30;
    switch (index) {
      case 0:
        return (-rangeX * animation) + _tapPosition!.dx;
      case 1:
        return _tapPosition!.dx;
      case 2:
        return (rangeX * animation) + _tapPosition!.dx;
    }
    return 0;
  }

  double calculateY(int index, double animation) {
    double rangeY = 20;
    double dif = 20;

    switch (index) {
      case 0:
        return ((rangeY - dif) * animation) + _tapPosition!.dy;
      case 1:
        return (rangeY * animation) + _tapPosition!.dy;
      case 2:
        return ((rangeY - dif) * animation) + _tapPosition!.dy;
    }
    return 0;
  }

  void _hideCircles() {
    _overlayEntries.forEach((entry) => entry.remove());
    _overlayEntries.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _handleTapDown(details, context),
      onTapCancel: _handleTapUp,
      child: widget.child,
    );
  }
}

//grp Ext

extension HighlightData on DateTime {
  Color getHighlightColor(DateTime date) {
    DateTime today = DateTime.now();
    DateTime tomorrow = DateTime(today.year, today.month, today.day + 1);
    if (date.isSameDay(today)) {
      // Это сегодня
      return ToolThemeData.mainGreenColor!;
    } else if (date.isSameDay(tomorrow)) {
      // Это завтра
      return Colors.orange;
    } else if (date.isBefore(today)) {
      // День уже прошёл
      return ToolThemeData.highlightColor;
    } else {
      // Это только ещё будет
      return Colors.grey;
    }
  }
}
