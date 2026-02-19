import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import '../app_widgets/my_animated_card.dart';

class AddItemButton extends StatelessWidget {
  final VoidCallback onTapAction;
  final VoidCallback? onLongTapAction;
  final VoidCallback? secondaryAction;
  final Color? bgColor;
  final String label;
  final IconData icon;

  AddItemButton({
    required this.onTapAction,
    this.onLongTapAction,
    this.secondaryAction,
    this.bgColor,
    this.label = 'New task',
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color baseColor =
        (bgColor ?? ToolThemeData.mainGreenColor).withOpacity(0.98);
    final bool isDark = theme.brightness == Brightness.dark;

    return MyAnimatedCard(
      intensity: 0.005,
      child: Tooltip(
        message: 'Alt + S',
        waitDuration: Duration(milliseconds: 400),
        child: InkWell(
          onTap: () {
            onTapAction.call();
          },
          onLongPress: () {
            onLongTapAction?.call();
          },
          onSecondaryTap: () {
            secondaryAction?.call();
          },
          child: Container(
            width: ToolThemeData.itemWidth,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor,
                  baseColor.withOpacity(isDark ? 0.9 : 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: baseColor.withOpacity(0.7),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.35),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Colors.white).withOpacity(isDark ? 0.05 : 0.07),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: (Colors.white).withOpacity(isDark ? 0.05 : 0.07),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.35),
                            offset: Offset(0, 0.8),
                            blurRadius: 1.6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
