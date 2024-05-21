import 'package:flutter/material.dart';

class MyExpansionPanel extends StatefulWidget {
  final List<Widget> listWidget;
  final String panelTitle;
  final Widget? buttonWidget;
  final double? widgetHeight;

  const MyExpansionPanel({
    Key? key,
    required this.listWidget,
    required this.panelTitle,
    this.widgetHeight,
    this.buttonWidget,
  }) : super(key: key);

  @override
  State<MyExpansionPanel> createState() => _MyExpansionPanelState();
}

class _MyExpansionPanelState extends State<MyExpansionPanel> {
  bool _isOpen = false;
  List<CustomExpansionPanel> _listCustomExpansionPanel = [];

  @override
  Widget build(BuildContext context) {
    _listCustomExpansionPanel = [];
    _listCustomExpansionPanel.add(
      CustomExpansionPanel(
        list: widget.listWidget,
        isExpanded: _isOpen,
        panelTitle: widget.panelTitle,
        widgetHeight: widget.widgetHeight,
        buttonWidget: widget.buttonWidget,
      ),
    );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.grey[300],
      ),
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.all(0.0),
        elevation: 6,
        dividerColor: Colors.black,
        children: _listCustomExpansionPanel,
        expansionCallback: (i, isOpen) {
          setState(() {
            _isOpen = isOpen;
            setState(() {});
          });
        },
      ),
    );
  }
}

class CustomExpansionPanel extends ExpansionPanel {
  CustomExpansionPanel({
    required List<Widget> list,
    required String panelTitle,
    double? widgetHeight,
    Widget? buttonWidget,
    required super.isExpanded,
  }) : super(
    headerBuilder: (_, _2) => buildExpansionHeader(panelTitle),
    body: buildExpansionBody(list, widgetHeight, buttonWidget),
    canTapOnHeader: true,
    backgroundColor: isExpanded ? Colors.white : Colors.blue[100],
  );
}

Widget buildExpansionHeader(String title) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(left: 28.0, bottom: 0),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
    ),
  );
}

Widget buildExpansionBody(List<Widget> listWidget, double? widgetHeight, Widget? buttonWidget) {
  int listSize = buttonWidget == null ? listWidget.length : listWidget.length + 1;
  double mHeight = ((widgetHeight ?? 30) + 6) * listSize;
  return Container(
    constraints: BoxConstraints(
      maxHeight: mHeight > 500 ? 500 : mHeight, // ограничиваем максимальную высоту контейнера
    ),
    child: ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all<Color>(Colors.purple),
        thumbVisibility: MaterialStateProperty.all<bool>(true),
      ),
      child: ListView.builder(
        itemCount: listSize,
        itemBuilder: (context, itemId) {
          if (buttonWidget != null && itemId == listSize - 1) {
            return buttonWidget;
          }
          return listWidget[itemId];
        },
      ),
    ),
  );
}