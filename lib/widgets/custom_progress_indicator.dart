import 'package:flutter/material.dart';
import 'package:get_fit/themes/app_theme.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const CustomProgressIndicator({
    super.key,
    this.size = 50.0, // Default size
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
