import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

import '../../data/tools/tool_navigator.dart';
import '../../data/tools/tool_theme_data.dart';
import '../bloc_global/all_item_control_bloc.dart';
import '../screen_settings/settings_screen.dart';
import 'widgets/week_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AllItemControlBloc>(
      create: (_) => Get.find<AllItemControlBloc>(),
      child: const HistoryScreenWidget(),
    );
  }
}

class HistoryScreenWidget extends StatefulWidget {
  static const int diffYellowMin = -120;
  static const int diffYellowMax = 120;

  static const int minutesRedThreshold = 40;
  static const int minutesYellowThreshold = 80;

  const HistoryScreenWidget({Key? key}) : super(key: key);

  @override
  State<HistoryScreenWidget> createState() => _HistoryScreenWidgetState();
}

class _HistoryScreenWidgetState extends State<HistoryScreenWidget> {
  final ScrollController weekListScrollController = ScrollController();

  @override
  void dispose() {
    weekListScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<TodoItem> todoHistoryItemList = context
        .select((AllItemControlBloc bloc) => bloc.state.todoHistoryItemList);

    Map<String, List<TodoItem>> groupedMap =
        _groupItemsByWeek(todoHistoryItemList);

    List<String> weekKeys = groupedMap.keys.toList()
      ..sort((a, b) {
        DateTime dateA = _parseInternalWeekKey(a);
        DateTime dateB = _parseInternalWeekKey(b);
        return dateB.compareTo(dateA);
      });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: weekKeys.isEmpty
                  ? const Center(
                      child: Text(
                        'Нет данных',
                        style:
                            TextStyle(color: Color(0xFFB9C1D9), fontSize: 16),
                      ),
                    )
                  : ClipRect(
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (Rect rect) {
                          return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.92),
                              Colors.white,
                              Colors.white,
                            ],
                            stops: const [0.0, 0.02, 1.0],
                          ).createShader(rect);
                        },
                        child: ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thickness: WidgetStateProperty.all<double>(3),
                            radius: const Radius.circular(999),
                            thumbColor: WidgetStateProperty.all<Color>(
                              const Color(0xFFAEB4C2).withValues(alpha: 0.45),
                            ),
                            trackVisibility:
                                WidgetStateProperty.all<bool>(false),
                            thumbVisibility:
                                WidgetStateProperty.all<bool>(true),
                          ),
                          child: Scrollbar(
                            controller: weekListScrollController,
                            child: ListView.builder(
                              controller: weekListScrollController,
                              padding:
                                  const EdgeInsets.only(top: 0, bottom: 40),
                              itemCount: weekKeys.length,
                              itemBuilder: (context, index) {
                                String weekKey = weekKeys[index];
                                List<TodoItem> items = groupedMap[weekKey]!;
                                List<TodoItem>? prevItems =
                                    (index + 1 < weekKeys.length)
                                        ? groupedMap[weekKeys[index + 1]]
                                        : null;

                                return WeekCard(
                                  weekStartDate: _parseInternalWeekKey(weekKey),
                                  items: items,
                                  prevItems: prevItems,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsetsGeometry.only(top: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.4), Colors.transparent],
          begin: Alignment.bottomCenter,
          end: AlignmentGeometry.topCenter,
        )),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'История',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE6E8EF),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ToolNavigator.push(
                    screen: const SettingsScreen(),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFFAEB4C2),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStatIndicator(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF8A93A6)),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFE6E8EF),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A93A6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Map<String, List<TodoItem>> _groupItemsByWeek(List<TodoItem> items) {
    Map<String, List<TodoItem>> groupedItems = {};
    for (var item in items) {
      if (item.targetDateTime == null) continue;
      DateTime date = item.targetDateTime!;
      DateTime monday = date.subtract(Duration(days: date.weekday - 1));
      String internalKey = DateFormat('yyyy-MM-dd').format(monday);
      groupedItems.putIfAbsent(internalKey, () => []).add(item);
    }
    return groupedItems;
  }

  DateTime _parseInternalWeekKey(String key) {
    return DateFormat('yyyy-MM-dd').parse(key);
  }
}
