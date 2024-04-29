import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';

class ChooseDateWidget extends StatelessWidget {
  const ChooseDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FractionallySizedBox(
            heightFactor: 0.6,
            widthFactor: 0.9,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.single,
              view: DateRangePickerView.month,
              initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
              toggleDaySelection: true,
              showActionButtons: true,
              showNavigationArrow: true,
              onSubmit: (data) {
                ToolShowOverlay.submitUserData(data);
              },
              onCancel: () {
                ToolShowOverlay.cancelUserData();
              },
            ),
          ),
        ),
      ),
    );
  }
}
