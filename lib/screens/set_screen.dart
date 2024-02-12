import 'package:flutter/material.dart';
import 'package:get_fit/providers/auth_provider.dart';
import 'package:get_fit/screens/base_screen.dart';
import 'package:get_fit/themes/app_theme.dart';
import 'package:get_fit/widgets/custom_app_bar.dart';
//import 'package:get_fit/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';

class SetScreen extends StatelessWidget {
  const SetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //bool isLoading = true;

    return BaseScreen(
      authProvider: Provider.of<AuthProviderClass>(context, listen: false),
      customAppBar: CustomAppBar(
        title: Image.asset(
          'lib/assets/images/get_fit_icon.png',
          fit: BoxFit.cover,
          height: 40,
        ),
        backgroundColor: AppTheme.primaryBackgroundColor,
        showEndDrawerIcon: true,
        showLeading: true,
      ),
      showDrawer: true,
      showAppBar: true,
      child: Stack(
        children: [
          //_buildLoadingOverlay(),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return const Center(
      child: Text('Set Screen'),
    );
  }

  // Widget _buildLoadingOverlay() {
  //   return Positioned.fill(
  //     child: Container(
  //       color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
  //       child: Center(
  //         child: CustomProgressIndicator(
  //           color: AppTheme.primaryColor,
  //         ), // Loading indicator
  //       ),
  //     ),
  //   );
  // }
}
