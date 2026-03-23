import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:zymixx_todo_list/domain/todo_item.dart';
import '../bloc_global/all_item_control_bloc.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1117), Color(0xFF151826)],
          ),
        ),
        child: SafeArea(
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
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 40),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 20),
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
          Container(
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
        ],
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
