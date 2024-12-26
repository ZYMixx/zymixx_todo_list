import 'package:flutter/material.dart';

class MyRadioIcon extends StatefulWidget {
  const MyRadioIcon({
    Key? key,
    this.size,
    required this.onSelect,
    required this.iconData,
    required this.onDeselect,
    this.initStatus,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);
  final double? size;
  final IconData iconData;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Function onSelect;
  final Function onDeselect;
  final bool? initStatus;

  @override
  State<MyRadioIcon> createState() => _MyRadioIconState();
}

class _MyRadioIconState extends State<MyRadioIcon> {
  late bool isSelected;

  @override
  void initState() {
    isSelected = widget.initStatus ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Icon(
        widget.iconData,
        size: widget.size,
        color: isSelected ? widget.selectedColor ?? Colors.green : widget.unselectedColor ?? Colors.grey[700],
      ),
      onTap: () {
        setState(() {
          if (isSelected) {
            widget.onDeselect.call();
          } else {
            widget.onSelect.call();
          }
          isSelected = !isSelected;
        });
      },
    );
  }
}
