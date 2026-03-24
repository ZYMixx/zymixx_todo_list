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
import 'package:zymixx_todo_list/presentation/bloc_global/list_todo_screen_bloc.dart';

import '../../../data/tools/tool_time_string_converter.dart';
import '../../../domain/todo_item.dart';
import '../../app.dart';
import '../../app_widgets/my_animated_card.dart';
import '../todo_item_bloc.dart';

// основной виджет со всеми активностями

class TodoItemWidget extends StatelessWidget {
  final TodoItem todoItem;
  Color bgColor;

  TodoItemWidget(
      {Key? key, required this.todoItem, this.bgColor = ToolThemeData.todoItemColor})
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
    super.initState();
    dismissArrow = DismissAnimationWidget();
  }

  @override
  Widget build(BuildContext context) {
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    bool isChangeTextMod =
        context.select((TodoItemBloc bloc) => bloc.state.changeTextMod);
    DateTime? targetDateTime = context
        .select((TodoItemBloc bloc) => bloc.state.todoItem.targetDateTime);

    // Приоритетный цвет для accent strip
    final Color priorityColor =
        targetDateTime?.getHighlightColor(targetDateTime) ??
            Colors.grey.shade600;
    final bool isSocial =
        bloc.state.todoItem.category == EnumTodoCategory.social.name;
    final theme = Theme.of(context);

    return MyAnimatedCard(
      intensity: 0.002,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Container(
          width: ToolThemeData.itemWidth,
          constraints: BoxConstraints(
            minHeight: ToolThemeData.itemHeight,
          ),
          child: GestureDetector(
            onSecondaryTap: () {
              bloc.add(SetItemDateEvent(userDateTime: DateTime.now()));
            },
            onSecondaryLongPress: () {
              bloc.add(SetItemDateEvent(userDateTime: DateTime.now()));
              Get.find<ListTodoScreenBloc>().add(
                  MoveItemToFirstEvent(movedItemId: bloc.state.todoItemId));
            },
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
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  // Более мягкая и современная тень карточки
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Тонкая левая полоска приоритета (accent strip)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 3.5,
                        decoration: BoxDecoration(
                          color: isSocial
                              ? ToolThemeData.specialItemColor
                              : priorityColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          // Объём для accent strip
                          boxShadow: [
                            BoxShadow(
                              color: (isSocial
                                      ? ToolThemeData.specialItemColor
                                      : priorityColor)
                                  .withOpacity(0.4),
                              blurRadius: 3,
                              spreadRadius: 0,
                              offset: const Offset(1, 0),
                            ),
                          ],
                        ),
                      ),
                      // Основное тело карточки
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: App.inWorkMod ? 0 : 4,
                          ),
                          decoration: App.inWorkMod ? null : BoxDecoration(
                            color: isSocial
                                ? ToolThemeData.specialItemColor
                                    .withOpacity(0.14)
                                : (widget.bgColor == Colors.transparent
                                    ? theme.colorScheme.surface
                                        .withOpacity(0.96)
                                    : widget.bgColor.withOpacity(0.98)),
                            gradient: isSocial
                                ? LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      ToolThemeData.specialItemColor
                                          .withOpacity(0.24),
                                      theme.colorScheme.surface
                                          .withOpacity(0.96),
                                    ],
                                  )
                                : null,
                            border: Border.all(
                              color: widget.bgColor == Colors.transparent
                                  ? theme.dividerColor.withOpacity(0.25)
                                  : ToolThemeData.itemBorderColor
                                      .withOpacity(0.5),
                              width: 0.6,
                            ),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          //? начало фронт-графики
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 12,
                                  child: GestureDetector(
                                    onLongPress: () {},
                                    onTap: () {},
                                    child: isChangeTextMod
                                        ? const TitleChangeWidget()
                                        : const TitlePresentWidget(),
                                  ),
                                ),
                                // Убрали отдельную цветную полоску из середины — она теперь слева
                                MyAnimatedCard(
                                  intensity: 0.01,
                                  directionUp: false,
                                  child: AnimatedCirclesWidget(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 5.0, left: 4),
                                      child: SizedBox(
                                        width: 2.5,
                                        height: double.infinity,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color:
                                                priorityColor.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            // Объём для разделителя
                                            boxShadow: [
                                              BoxShadow(
                                                color: priorityColor
                                                    .withOpacity(0.3),
                                                blurRadius: 2,
                                                spreadRadius: 0,
                                                offset: const Offset(0.5, 0),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Flexible(
                                    flex: 6, child: TimerWorkWidget()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
            400 * (animValue / 2) +
                (8 * Random().nextDouble()) +
                (isRightArrow ? -230 : 220),
            0),
        child: Container(
          alignment:
              isRightArrow ? Alignment.centerLeft : Alignment.centerRight,
          padding: const EdgeInsets.only(right: 30),
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
                  color: isRightArrow
                      ? ToolThemeData.mainGreenColor
                      : ToolThemeData.highlightColor,
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
    DateTime? targetDateTime = context
        .select((TodoItemBloc bloc) => bloc.state.todoItem.targetDateTime);
    final bool isSocial =
        bloc.state.todoItem.category == EnumTodoCategory.social.name;
    final String? dateStr =
        Get.find<ToolDateFormatter>().formatToMonthDay(targetDateTime);

    return Stack(
      children: [
        InkWell(
          onTap: () {
            bloc.add(ChangeModEvent(isChangeMod: true));
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: App.inWorkMod ? 2.0 : 8.0,
              top: App.inWorkMod ? 0.0 : 2.5,
              bottom: App.inWorkMod ? 0.0 : 1.0,
              right: todoImageFile != null ? 25 : App.inWorkMod ? 4 : 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (title.capStart() ?? '') ?? '',
                  maxLines: App.inWorkMod ? 2 : null,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                    letterSpacing: -0.2,
                    height: App.inWorkMod ? 0.7 : 1.1,
                    color: Colors.black,
                  ),
                ),
                if (dateStr != null && !App.inWorkMod )
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: DecoratedBox(
                      decoration: todoImageFile != null
                          ? BoxDecoration(
                              border: Border.all(
                                  color: ToolThemeData.highlightColor
                                      .withOpacity(0.3),
                                  width: 0.5),
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            )
                          : const BoxDecoration(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          dateStr,
                          style: TextStyle(
                            color: isSocial
                                ? ToolThemeData.mainGreenColor
                                : Colors.black.withOpacity(0.65),
                            fontWeight: FontWeight.w700,
                            fontSize: isSocial ? 11 : 10.5,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
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
                      color:
                          targetDateTime?.getHighlightColor(targetDateTime) ??
                              Colors.black,
                      width: 0.5),
                  borderRadius: BorderRadius.circular(ToolThemeData.itemHeight),
                  // Объём для миниатюры изображения
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: ToolThemeData.itemHeight - 10,
                  height: ToolThemeData.itemHeight,
                  child: InkWell(
                    onTap: () {
                      //ii image top
                      Get.find<ServiceImagePluginWork>()
                          .openImage(todoImageFile);
                    },
                    child: MyAnimatedCard(
                      intensity: 0.01,
                      directionUp: false,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Opacity(
                          opacity: 0.85,
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
      descriptionForSave = _controllerDescription.text;
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
    File? todoImageFile =
        context.select((TodoItemBloc bloc) => bloc.state.imageFile);
    _controllerTitle.text = bloc.state.todoItem.title ?? '';
    initialText = bloc.state.todoItem.content ?? '';
    _controllerDescription.text = bloc.state.todoItem.content ?? '';
    descriptionForSave = _controllerDescription.text;
    DateTime? targetDateTime = bloc.state.todoItem.targetDateTime;
    String formattedTargetDateTime =
        Get.find<ToolDateFormatter>().formatToMonthDay(targetDateTime) ?? '';
    return Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 4.0, right: 2.0),
        child: Focus(
          onFocusChange: (focus) {
            if (focus) {
              _controllerTitle
                ..selection = TextSelection(
                    baseOffset: 0, extentOffset: _controllerTitle.text.length);
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
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controllerTitle,
                  autofocus: true,
                  maxLines: 1,
                  focusNode: _focusNodeTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    letterSpacing: -0.2,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    suffixIcon: MyAnimatedCard(
                      intensity: 0.012,
                      child: Container(
                        width: 50,
                        height: 36,
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
                                    buildContext: context,
                                    restoreFocusCallBack: _restoreSelection),
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
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              letterSpacing: 0.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 0.5),
                                  blurRadius: 1.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor:
                        MaterialStateProperty.all<Color>(Colors.black54),
                    thumbVisibility: MaterialStateProperty.all<bool>(true),
                    thickness: MaterialStateProperty.all<double>(4),
                  ),
                  child: TextField(
                    controller: _controllerDescription,
                    focusNode: _focusNodeDescription,
                    minLines: 2,
                    selectionControls: MaterialTextSelectionControls(),
                    maxLines: initialText == '' ? 3 : 8,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 4),
                      suffixIconConstraints: todoImageFile == null
                          ? const BoxConstraints.tightFor(width: 35, height: 35)
                          : const BoxConstraints.tightFor(
                              width: 45, height: 45),
                      suffixIcon: (bloc.state.todoItem.title == 'New Title')
                          ? Container()
                          : todoImageFile != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: InkWell(
                                          onTap: () {
                                            Get.find<ServiceImagePluginWork>()
                                                .openImage(todoImageFile);
                                          },
                                          onSecondaryTap: () {},
                                          onLongPress: () {
                                            Get.find<ServiceImagePluginWork>()
                                                .deleteImage(
                                              todoItem: bloc.state.todoItem,
                                              updateCallBack: () => bloc
                                                  .add(SetTodoItemImageEvent()),
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: Opacity(
                                              opacity: 0.85,
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
                                        Get.find<ServiceImagePluginWork>()
                                            .drawImage(
                                                title:
                                                    bloc.state.todoItem.title,
                                                id: bloc.state.todoItem.id,
                                                updateCallBack: () => bloc.add(
                                                    SetTodoItemImageEvent()));
                                        Log.e('ADD NEW IMAGE');
                                      },
                                      onSecondaryTap: () {
                                        Get.find<ServiceImagePluginWork>()
                                            .selectAndSetTodoImage(
                                          todoItem: bloc.state.todoItem,
                                          updateCallBack: () =>
                                              bloc.add(SetTodoItemImageEvent()),
                                        );
                                      },
                                      child: Center(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            // Объём для кнопки добавления фото
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.15),
                                                blurRadius: 3,
                                                spreadRadius: 0,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: MyAnimatedCard(
                                              intensity: 0.012,
                                              child: const ClipOval(
                                                child: Opacity(
                                                  opacity: 0.7,
                                                  child: Icon(
                                                    Icons.add_a_photo_outlined,
                                                    color: Colors.black87,
                                                    size: 20,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13.5,
                      letterSpacing: -0.3,
                      wordSpacing: -0.3,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black12,
                          offset: Offset(0, 0.1),
                          blurRadius: 1.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
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
    TodoItem todoItem =
        context.select((TodoItemBloc bloc) => bloc.state.todoItem);
    bool needTimerSong =
        context.select((TodoItemBloc bloc) => bloc.state.needTimerSong);
    int autoPauseSeconds = todoItem.autoPauseSeconds;
    TimeModEnum timerMod =
        context.select((TodoItemBloc bloc) => bloc.state.timerMod);
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
                  border: Border.all(width: 1.0, color: Colors.black38),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: CircleAvatar(
                      radius: 3.5,
                      backgroundColor: autoPauseSeconds == 30
                          ? ToolThemeData.specialItemColor
                          : ToolThemeData.highlightColor),
                ),
              ),
            ),
          ),
        if (!needTimerSong)
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0, top: 2.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(0.5),
                child: Opacity(
                  opacity: 0.6,
                  child: Icon(
                    Icons.music_off_outlined,
                    size: 16,
                    color: Colors.black45,
                  ),
                ),
              ),
            ),
          ),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              Offset animateOffset;
              if (child is StopwatchWidget) {
                animateOffset = const Offset(-0.4, 0.0);
                lastTimeMod = TimeModEnum.stopwatch;
              } else if (child is TimerWidget) {
                animateOffset = const Offset(0.4, 0.0);
                lastTimeMod = TimeModEnum.timer;
              } else {
                if (timerMod == TimeModEnum.timer) {
                  animateOffset = const Offset(-0.4, 0.0);
                } else {
                  if (lastTimeMod == TimeModEnum.timer) {
                    animateOffset = const Offset(-0.4, 0.0);
                    lastTimeMod = null;
                  } else {
                    animateOffset = const Offset(0.4, 0.0);
                    lastTimeMod = null;
                  }
                }
              }
              var slideAnimation = Tween<Offset>(
                begin: animateOffset,
                end: const Offset(0.0, 0.0),
              ).animate(animation);
              return FadeTransition(
                  opacity: animation,
                  child:
                      SlideTransition(position: slideAnimation, child: child));
            },
            child: buildCrntWidget(bloc: bloc, timerMod: timerMod),
          ),
        ),
      ],
    );
  }

  Widget buildCrntWidget(
      {required TodoItemBloc bloc, required TimeModEnum timerMod}) {
    switch (timerMod) {
      case TimeModEnum.timer:
        return const TimerWidget();
      case TimeModEnum.stopwatch:
        return const StopwatchWidget();
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
                      bloc.add(
                          ChangeTimeModEvent(timerMod: TimeModEnum.stopwatch));
                    });
                  },
                  icon: const Icon(
                    Icons.timer_outlined,
                    color: Colors.black54,
                    size: 22,
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
                  icon: const Icon(
                    Icons.hourglass_empty_outlined,
                    color: Colors.black54,
                    size: 22,
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
    int timer =
        context.select((TodoItemBloc bloc) => bloc.state.todoItem.timerSeconds);
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    Get.find<ToolTimeStringConverter>().formatSecondsToTimeMinute(timer);
    String timerString =
        Get.find<ToolTimeStringConverter>().formatSecondsToTimeMinute(timer);
    bool isTimerActive =
        context.select((TodoItemBloc bloc) => bloc.state.isTimerActive);

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
              child: const Icon(
                Icons.remove_rounded,
                size: 16,
                color: Colors.black54,
              ),
            ),
          ),
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black12,
                          offset: Offset(0, 0.5),
                          blurRadius: 1.0,
                        ),
                      ],
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
                    duration: const Duration(seconds: 1),
                    opacity: opacity,
                    child: AnimatedScale(
                      scale: scale,
                      duration: const Duration(seconds: 1),
                      child: Icon(
                        Icons.arrow_downward_outlined,
                        size: 13,
                        color:
                            isTimerActive ? Colors.black87 : Colors.grey[500],
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
            child: const Icon(
              Icons.add_rounded,
              size: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 15),
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
  Tween<Offset> positionTween =
      Tween(begin: const Offset(0, 0), end: const Offset(0, 0.2));

  @override
  Widget build(BuildContext context) {
    int stopwatch = context
        .select((TodoItemBloc bloc) => bloc.state.todoItem.stopwatchSeconds);
    bool isTimerActive =
        context.select((TodoItemBloc bloc) => bloc.state.isTimerActive);
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    String stopwatchString = Get.find<ToolTimeStringConverter>()
        .formatSecondsToTimeMinute(stopwatch);
    return IconButton(
      onPressed: null,
      icon: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
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
          padding: const EdgeInsets.only(left: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onLongPress: () {
                  bloc.add(SetTimerNeedSongEvent());
                },
                child: Text(
                  stopwatchString,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black12,
                        offset: Offset(0, 0.5),
                        blurRadius: 1.0,
                      ),
                    ],
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
                  duration: const Duration(seconds: 1),
                  opacity: opacity,
                  child: AnimatedScale(
                    scale: scale,
                    duration: const Duration(seconds: 1),
                    child: Icon(
                      Icons.arrow_upward_outlined,
                      size: 13,
                      color: isTimerActive ? Colors.black87 : Colors.grey[500],
                    ),
                  ),
                );
              }),
              const SizedBox(width: 3)
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedCirclesWidget extends StatefulWidget {
  final Widget child;

  const AnimatedCirclesWidget({Key? key, required this.child})
      : super(key: key);

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
    _controller = AnimationController(
        duration: const Duration(milliseconds: 120), vsync: this);
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
    _timer = Timer(const Duration(milliseconds: 1500), () {
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
          circleColor = ToolThemeData.highlightColor!;
          break;
      }
      return OverlayEntry(
        builder: (context) {
          return AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 120),
                left: calculateX(index, _scaleAnimation.value) - 10,
                top: calculateY(index, _scaleAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        parentContext.read<TodoItemBloc>().add(
                            SetAutoPauseSeconds(
                                autoPauseSeconds:
                                    index == 0 ? 0 : 30 ~/ index));
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
                              color: Colors.white,
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
      return ToolThemeData.highlightColor!;
    } else {
      // Это только ещё будет
      return Colors.grey;
    }
  }
}
