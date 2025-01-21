import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingCommon extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final Widget? child;
  final Widget? text;
  final Color? color;
  final BoxBorder? border;
  final bool isDisconnect;

  const SettingCommon({
    super.key,
    this.icon,
    this.title,
    this.child,
    this.text,
    this.color,
    this.border,
    required this.isDisconnect
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        // onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: border,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(icon, color: isDisconnect? Colors.red : AppColors.appColor, size: 20,),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: text,
            ),
            const Spacer(),
            Transform.scale(
              scale: 0.6,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
