import 'package:flutter/material.dart';
import 'package:get_fit/themes/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Color backgroundColor;
  final double elevation;
  final List<Widget>? actions;
  final bool showLeading;
  final bool showEndDrawerIcon;
  final bool showShoppingCartIcon;
  final PreferredSizeWidget? bottom; // Add this line
  // New parameter

  const CustomAppBar({
    super.key,
    required this.title,
    required this.backgroundColor, // Default color
    this.elevation = 0.0, // Default elevation
    this.actions,
    this.showLeading = true,
    this.showEndDrawerIcon = true,
    this.showShoppingCartIcon = false,
    this.bottom, // Add this line
    // Default value
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> appBarActions = [];

    if (showEndDrawerIcon) {
      appBarActions.add(
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: IconButton(
            iconSize: 25,
            icon: const Icon(Icons.menu),
            color: Colors.black,
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      );
    }
    return AppBar(
      // title: Image.asset(
      //   'lib/assets/images/pm_icon_full.png',
      //   fit: BoxFit.cover,
      //   height: 35,
      // ),
      centerTitle: true,
      backgroundColor: AppTheme.primaryBackgroundColor,
      elevation: elevation,
      automaticallyImplyLeading: showLeading,
      leading: showLeading
          ? IconButton(
              icon: const Icon(Icons.arrow_back), // Custom icon
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      actions: appBarActions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight +
            (bottom?.preferredSize.height ?? 0), // Modify this line
      );
}
