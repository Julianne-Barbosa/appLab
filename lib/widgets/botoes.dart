import 'package:flutter/material.dart';

class Botoes extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;
  final Widget? icon;
  final bool isAnimated;

  const Botoes({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
    this.shadows,
    this.gradient,
    this.icon,
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration:
              isAnimated ? Duration(milliseconds: 300) : Duration.zero,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  colors: [
                    backgroundColor,
                    Color.lerp(backgroundColor, Colors.black, 0.1)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: shadows ??
                [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
              shadowColor: WidgetStateProperty.all(Colors.transparent),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(horizontal: 24),
              ),
              overlayColor: WidgetStateProperty.resolveWith<Color>(
                (states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.white.withOpacity(0.1);
                  }
                  return Colors.transparent;
                },
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
