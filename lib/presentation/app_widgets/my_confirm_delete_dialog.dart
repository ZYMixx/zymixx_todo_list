import 'package:flutter/material.dart';

class MyConfirmDeleteDialog extends StatelessWidget {
  final String contentMessage;
  final String? titleMessage;
  final String? labelOnConfirm;
  final String? labelOnCancel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const MyConfirmDeleteDialog({
    Key? key,
    required this.contentMessage,
    this.titleMessage,
    this.labelOnConfirm,
    this.labelOnCancel,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titleMessage ?? 'Подтвердите действие'),
      content: Text(contentMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel();
          },
          child: Text(labelOnCancel ?? 'Отмена'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(labelOnConfirm ?? 'Да'),
        ),

      ],
    );
  }
}
