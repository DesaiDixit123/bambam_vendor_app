// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.leading,
    this.textStyle,
    this.heightBtn,
    this.widthBtn,
    this.radius,
    this.backgroundColor,
    this.isBorder,
    this.bordercolors,
    this.isboxsedo,
  });

  final void Function()? onPressed;
  final String? text;
  final Widget? leading;
  final TextStyle? textStyle;
  final double? radius;
  final double? widthBtn;
  final double? heightBtn;
  final Color? backgroundColor;
  final Color? bordercolors;
  final bool? isBorder;
  final bool? isboxsedo;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.backgroundColor ?? Colors.blue;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 120), () {
          setState(() => _isPressed = false);
        });
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: widget.heightBtn ?? 45,
        width: widget.widthBtn ?? double.infinity,
        decoration: BoxDecoration(
          color: _isPressed
              ? baseColor.withOpacity(0.8) // darken on press
              : baseColor,
          borderRadius: BorderRadius.circular(widget.radius ?? 12),
          border: widget.isBorder ?? false
              ? Border.all(
                  width: 1,
                  color: widget.bordercolors ?? Colors.black26,
                )
              : null,
          boxShadow: [
            if (_isPressed)
              BoxShadow(
                color: baseColor.withOpacity(0.4),
                offset: const Offset(0, 4),
                blurRadius: 10,
                spreadRadius: 1,
              )
            else if (widget.isboxsedo == true)
              const BoxShadow(
                color: Color(0x99F4F5FA),
                offset: Offset(0, -3),
                blurRadius: 6,
              ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 10),
              ],
              Text(
                widget.text ?? "",
                style:
                    widget.textStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
