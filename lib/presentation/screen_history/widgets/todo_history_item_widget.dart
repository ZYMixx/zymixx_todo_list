import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import '../../bloc_global/all_item_control_bloc.dart';

class TodoHistoryItemWidget extends StatefulWidget {
  final TodoItem todoItem;

  const TodoHistoryItemWidget({Key? key, required this.todoItem})
      : super(key: key);

  @override
  State<TodoHistoryItemWidget> createState() => _TodoHistoryItemWidgetState();
}

class _TodoHistoryItemWidgetState extends State<TodoHistoryItemWidget>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _shimmerController;

  void restoreToActiveList() {
    final bool isSocial =
        widget.todoItem.category == EnumTodoCategory.history_social.name;

    context.read<AllItemControlBloc>().add(
          ChangeItemEvent(
            todoItem: widget.todoItem,
            category:
                isSocial ? EnumTodoCategory.social : EnumTodoCategory.active,
          ),
        );
  }

  void deleteFromHistory() {
    context
        .read<AllItemControlBloc>()
        .add(DeleteItemEvent(todoItem: widget.todoItem));
  }

  Widget buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final double t = _shimmerController.value;
        final double pulse =
            0.80 + 0.20 * (1.0 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 34,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: color.withValues(alpha: 0.22 + 0.10 * pulse),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12 + 0.10 * pulse),
                  blurRadius: 10 + 10 * pulse,
                  spreadRadius: 0.2 + 0.8 * pulse,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 18,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isSocial =
        widget.todoItem.category == EnumTodoCategory.history_social.name;

    int minutes = widget.todoItem.secondsSpent ~/ 60;

    return InkWell(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    double shimmer = 0.75 + 0.25 * _shimmerController.value;
                    Color glowColor = isSocial
                        ? const Color(0xFFB14CFF)
                        : const Color(0xFF60A5FA);
                    return Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: glowColor.withValues(alpha: shimmer),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withValues(alpha: 0.5 * shimmer),
                            blurRadius: 4 * shimmer,
                            spreadRadius: 1 * shimmer,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.todoItem.title,
                    style: const TextStyle(
                      color: Color(0xFFC7CBD6),
                      fontSize: 14,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (isSocial)
                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          final double t = _shimmerController.value;
                          final double glow = 0.35 +
                              0.65 *
                                  (1.0 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                begin: Alignment(-1.0 + 2.0 * t, -0.2),
                                end: Alignment(1.0 + 2.0 * t, 0.2),
                                colors: [
                                  const Color(0xFFB14CFF)
                                      .withValues(alpha: 0.10),
                                  const Color(0xFFB14CFF)
                                      .withValues(alpha: 0.22),
                                  const Color(0xFF7C3AED)
                                      .withValues(alpha: 0.18),
                                  const Color(0xFFB14CFF)
                                      .withValues(alpha: 0.12),
                                ],
                                stops: const [0.0, 0.40, 0.60, 1.0],
                              ),
                              border: Border.all(
                                color: const Color(0xFFB14CFF)
                                    .withValues(alpha: 0.26 + 0.12 * glow),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFB14CFF)
                                      .withValues(alpha: 0.18 + 0.18 * glow),
                                  blurRadius: 10 + 10 * glow,
                                  spreadRadius: 0.5 + 0.8 * glow,
                                ),
                              ],
                            ),
                            child: const Text(
                              'story',
                              style: TextStyle(
                                color: Color(0xFFE7DAFF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                          );
                        },
                      ),
                    Text(
                      '${minutes}м',
                      style: const TextStyle(
                        color: Color(0xFF8A93A6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isExpanded && widget.todoItem.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  widget.todoItem.content,
                  style: const TextStyle(
                    color: Color(0xFF8A93A6),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            if (isExpanded) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    buildActionButton(
                      icon: Icons.keyboard_return_rounded,
                      color: const Color(0xFF60A5FA),
                      onTap: restoreToActiveList,
                    ),
                    const SizedBox(width: 10),
                    buildActionButton(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFF87171),
                      onTap: deleteFromHistory,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
