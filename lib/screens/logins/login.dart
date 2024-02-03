import 'package:flutter/material.dart';
import 'package:get_fit/providers/auth_provider.dart';
import 'package:get_fit/screens/base_screen.dart';
import 'package:get_fit/screens/logins/signin_screen.dart';
import 'package:get_fit/screens/logins/signup_screen.dart';
import 'package:get_fit/themes/app_theme.dart';
import 'package:get_fit/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
// Assuming you have separate files for SignIn and _SignUp widgets

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      authProvider: Provider.of<AuthProviderClass>(context, listen: false),
      showAppBar: false,
      customAppBar: CustomAppBar(
        backgroundColor: AppTheme.primaryBackgroundColor,
        showEndDrawerIcon: false,
        showLeading: false,
        title: const Text('Get Fit'),
      ),
      showDrawer: false,
      bottomNavigationBar: null, // Your bottom navigation bar, if any
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.primaryBackgroundColor,
            automaticallyImplyLeading: false,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Sign In'),
                Tab(text: 'Sign Up'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              SignIn(), // Your SignIn widget
              SignUp(), // Your _SignUp widget
            ],
          ),
        ),
      ),
    );
  }
}
