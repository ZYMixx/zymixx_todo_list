import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/data/services/service_statistic_data.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/presentation/app_widgets/my_animated_card.dart';
import 'package:zymixx_todo_list/presentation/app_widgets/wave_shimmer_overlay.dart';

class DataTableWidget extends StatelessWidget {
  final List<StatisticWeekHolder> weekData;

  const DataTableWidget({
    required this.weekData,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color cardColor = colorScheme.surface.withValues(alpha: 0.92);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MyAnimatedCard(
        intensity: 0.004,
        child: Card(
          elevation: 6,
          color: cardColor,
          shadowColor: Colors.black.withValues(alpha: 0.30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.black12, width: 0.8),
          ),
          clipBehavior: Clip.antiAlias,
          child: WaveShimmerOverlay(
            id: 'stat_table',
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: SizedBox(
                height: 270,
                child: StreamBuilder<Object>(
                    stream: null,
                    builder: (context, snapshot) {
                      return SingleChildScrollView(
                        child: DataTable(
                          headingRowColor:
                              WidgetStateProperty.all<Color>(Colors.grey[300]!),
                          columnSpacing: 40,
                          border: TableBorder(
                            verticalInside: BorderSide(color: Colors.black26),
                            bottom: BorderSide(color: Colors.black12),
                          ),
                          columns: [
                            DataColumn(label: Center(child: Text('Дата'))),
                            DataColumn(label: Center(child: Text('Дел'))),
                            DataColumn(label: Center(child: Text('Fails'))),
                            DataColumn(label: Center(child: Text('Story'))),
                            DataColumn(label: Center(child: Text('Итого'))),
                          ],
                          rows: weekData
                              .map(
                                (item) => DataRow(cells: [
                                  DataCell(Center(
                                      child: Text(item.weekName,
                                          style: TextStyle(
                                              color: item.isInactiveWeek
                                                  ? Colors.grey
                                                  : Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                              fontSize: item.isInactiveWeek
                                                  ? 13
                                                  : 15.5)))),
                                  DataCell(Center(
                                      child: Text(
                                          item.isInactiveWeek
                                              ? '—'
                                              : item.todoItemCount.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18)))),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        item.isInactiveWeek
                                            ? '—'
                                            : item.dailyFails.toString(),
                                        style: TextStyle(
                                            color: item.isInactiveWeek
                                                ? Colors.grey
                                                : item.dailyFails == 0
                                                    ? ToolThemeData
                                                        .mainGreenColor
                                                    : item.dailyFails > 3
                                                        ? Colors.red[700]
                                                        : Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        item.isInactiveWeek
                                            ? '—'
                                            : item.storyItems.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        item.isInactiveWeek
                                            ? '—'
                                            : '${item.weekScore}h',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ]),
                              )
                              .toList(),
                        ),
                      );
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
