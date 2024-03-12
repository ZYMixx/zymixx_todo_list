import 'package:flutter/material.dart';

class ItemBottomNavigatorBar extends StatefulWidget {
  const ItemBottomNavigatorBar({super.key});

  @override
  State<ItemBottomNavigatorBar> createState() => _ItemBottomNavigatorBarState();
}

class _ItemBottomNavigatorBarState extends State<ItemBottomNavigatorBar> {
  List<BottomNavigationBarItem> listNavigatorItem = [
    BottomNavigationBarItem(icon: Icon(Icons.work_history_outlined), label: 'test'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: '1'),
    BottomNavigationBarItem(icon: Icon(Icons.data_thresholding_outlined), label: '2'),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: '3'),
  ];
  int selectedItemMenu = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: BottomNavigationBar(
        currentIndex: selectedItemMenu,
        onTap: (index){
          setState(() {
            selectedItemMenu = index;
          });
        },
        backgroundColor: Colors.deepPurpleAccent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false, // Скрыть метки для выбранных элементов
        showUnselectedLabels: false,
        selectedFontSize: 0, // Размер шрифта для выбранных элементов
        unselectedFontSize: 0, // Размер шрифта для невыбранных элементов
        iconSize: 28, // Размер иконок на элементах навигации
        type: BottomNavigationBarType.fixed,
        items: listNavigatorItem,
      ),
    );
  }
}
