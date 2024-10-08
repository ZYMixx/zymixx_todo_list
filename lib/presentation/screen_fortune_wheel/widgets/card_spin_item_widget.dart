import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

class CardSpinItemWidget extends StatefulWidget {
  CardSpinItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.selectedItemNotifier,
  });

  final TodoItem item;
  final int index;
  final ValueNotifier<TodoItem?> selectedItemNotifier;

  @override
  State<CardSpinItemWidget> createState() => _CardSpinItemWidgetState();
}
class _CardSpinItemWidgetState extends State<CardSpinItemWidget> {
  bool isClicked = false;
  bool isWinner = false;

  @override
  void initState() {
    widget.selectedItemNotifier.addListener(() {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (widget.selectedItemNotifier.value == widget.item) {
            setState(() {
              isWinner = true;
            });
          } else {
            if (isWinner) {
              setState(() {
                isWinner = false;
              });
            }
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isClicked = !isClicked;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isClicked
                ? Colors.white
                : widget.index % 2 == 0
                ? Colors.deepPurpleAccent
                : Colors.blueAccent,
            border: Border.all(),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 4.0,
                spreadRadius: 3.0,
                offset: Offset(1, 1),
              ),
            ],
            image: DecorationImage(
              image: AssetImage('assets/frame_spin.png'),
              fit: BoxFit.fill,
              opacity: 0.2,
              colorFilter: ColorFilter.mode(
                Colors.black,
                BlendMode.srcATop, // режим наложения
              ),
            ),
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 750),
            alignment: Alignment.center,
            width: isWinner ? 255 : 240,
            height: 130,
            decoration: isWinner
                ? BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isClicked ? Colors.white : Colors.orangeAccent,
              border: Border.all(),
              boxShadow: [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 4.0,
                  spreadRadius: 3.0,
                  offset: Offset(1, 1),
                ),
              ],
              image: DecorationImage(
                image: AssetImage('assets/frame_spin.png'),
                fit: BoxFit.fill,
                opacity: 0.2,
                colorFilter: ColorFilter.mode(
                  Colors.black,
                  BlendMode.srcATop, // р// ежим наложения
                ),
              ),
            )
                : null,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 4),
                  child: Text(
                    isClicked
                        ? widget.item.content == ''
                        ? 'нет описания'
                        : widget.item.content
                        : widget.item.title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        fontWeight: isClicked ? FontWeight.w400 : FontWeight.w500,
                        fontSize: isClicked ? 18 : 22,
                        letterSpacing: -0.5,
                        wordSpacing: -1.0,
                        height: 0.9,
                        fontStyle: isClicked ? FontStyle.italic : null,
                        shadows: ToolThemeData.defTextShadow),
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
