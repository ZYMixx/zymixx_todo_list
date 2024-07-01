import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';

class ChooseDateWidget extends StatelessWidget {
  const ChooseDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () => Get.find<ToolShowOverlay>().submitUserData(null),
          splashColor: Colors.transparent,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 110.0),
            child: Material(
              elevation: 10,
              child: FractionallySizedBox(
                heightFactor: 0.55,
                widthFactor: 0.85,
                child: SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.single,
                  view: DateRangePickerView.month,
                  initialDisplayDate:
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                  toggleDaySelection: true,
                  showActionButtons: true,
                  showNavigationArrow: true,
                  onSubmit: (data) {
                    Get.find<ToolShowOverlay>().submitUserData(data);
                  },
                  onCancel: () {
                    Get.find<ToolShowOverlay>().submitUserData(null);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
