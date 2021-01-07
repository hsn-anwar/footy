import 'package:flutter/material.dart';
import 'package:footy/shared/constants.dart';
import 'package:footy/widgets/picker_field.dart';

class TimePicker extends StatelessWidget {
  final TextEditingController minController;
  final minFormKey;
  final TextEditingController secController;
  final secFormKey;

  TimePicker(
      {@required this.minController,
      @required this.secController,
      @required this.minFormKey,
      @required this.secFormKey});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      width: SizeConfig.screenWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Set Game Duration',
            style: kLabelStyle,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PickerField(
                label: 'Minutes',
                formKey: this.minFormKey,
                textController: minController,
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal * 2,
              ),
              PickerField(
                label: 'Seconds',
                formKey: this.secFormKey,
                textController: secController,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
