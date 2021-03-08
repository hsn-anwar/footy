import 'package:flutter/material.dart';
import 'package:footy/shared/constants.dart';
import 'package:flutter/services.dart';

import '../const.dart';

class PickerField extends StatelessWidget {
  PickerField(
      {@required this.label,
      @required this.formKey,
      @required this.textController});

  final String label;
  final formKey;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: SizeConfig.blockSizeHorizontal * 25,
        child: Form(
          key: this.formKey,
          child: TextFormField(
            controller: this.textController,
            onTap: () {
              this.textController.clear();
            },
            decoration: kInputDecoration.copyWith(labelText: this.label),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            validator: (val) {
              if (val.isEmpty == false) {
                final int value = int.parse(val);
                if (label == 'Minutes' && value > 90) {
                  return '>90';
                } else if (label == 'Seconds' && value > 60) {
                  return '>60';
                } else {
                  return null;
                }
              } else {
                return 'Empty field';
              }
            },
            keyboardType: TextInputType.number,
          ),
        ),
      ),
    );
  }
}
