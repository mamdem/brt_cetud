import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String? buttonText;
  final void Function()? onPressed;
  final Size? fixedSize;
  final BorderSide? side;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? style;
  final BorderRadiusGeometry? borderRadius;
  final IconData? icon;

  const AppButton({
    Key? key,
    this.buttonText,
    this.onPressed,
    this.fixedSize,
    this.side,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.style,
    this.icon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: fixedSize,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          side: side!,
          borderRadius: borderRadius!,
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,  // S'assurer que le Row ne prend pas plus d'espace que nécessaire
        children: [
          if (icon != null) ...[  // Ajouter l'icône seulement si elle est fournie
            Icon(icon, size: 24.0),  // Vous pouvez ajuster la taille si nécessaire
            const SizedBox(width: 8),  // Espace entre l'icône et le texte
          ],
          Text(
            buttonText!,
            style: style,
          ),
        ],
      ),
    );
  }
}
