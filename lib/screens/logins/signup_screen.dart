
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_fit/providers/auth_provider.dart';
import 'package:get_fit/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String confirmPassword = '';
  String firstName = '';
  String lastName = '';
  String error = '';
  bool isLoading = false;
  bool _signInPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _signInPasswordVisible = false;
    _confirmPasswordVisible = false; // Initially password is obscure
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CustomProgressIndicator()) // Centered progress indicator
        : SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: _buildSignUpForm(),
          );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(
            Icons.person_add_alt_1_sharp, // Outlined person icon
            size: 100, // Large icon size
            color: Theme.of(context).primaryColor, // Icon color
          ),
          const SizedBox(height: 24),
          _buildTextFormField(
            labelText: 'First Name',
            prefixIcon: Icons.person,
            validator: (val) => val!.isEmpty ? 'Enter your first name' : null,
            onChanged: (val) => setState(() => firstName = val),
          ),
          const SizedBox(height: 15.0),
          _buildTextFormField(
            labelText: 'Last Name',
            prefixIcon: Icons.person,
            validator: (val) => val!.isEmpty ? 'Enter your last name' : null,
            onChanged: (val) => setState(() => lastName = val),
          ),
          const SizedBox(height: 15.0),
          _buildTextFormField(
            labelText: 'Email',
            prefixIcon: Icons.email_outlined,
            validator: (val) => val!.isEmpty ? 'Enter your email' : null,
            onChanged: (val) => setState(() => email = val),
          ),
          const SizedBox(height: 15.0),
          _buildTextFormField(
            labelText: 'Password',
            prefixIcon: Icons.password_outlined,
            validator: (val) =>
                val!.length < 6 ? 'Enter a password 6+ chars long' : null,
            onChanged: (val) => setState(() => password = val),
            isPassword: true,
            passwordVisible: _signInPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _signInPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _signInPasswordVisible = !_signInPasswordVisible;
                });
              },
            ),
          ),
          const SizedBox(height: 15.0),
          _buildTextFormField(
            labelText: 'Confirm Password',
            prefixIcon: Icons.password_outlined,
            validator: (val) =>
                val != password ? 'Passwords do not match' : null,
            onChanged: (val) => setState(() => confirmPassword = val),
            isPassword: true,
            passwordVisible: _confirmPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _confirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _confirmPasswordVisible = !_confirmPasswordVisible;
                });
              },
            ),
          ),
          const SizedBox(height: 40.0),
          ElevatedButton(
            style: ElevatedButtonTheme.of(context).style,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                signUserUp();
              }
            },
            child: const Text(
              'Sign Up',
            ),
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
              ),
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    required Function(String) onChanged,
    bool isPassword = false,
    bool passwordVisible = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(
          color: Colors.black45,
        ),
      ),
      obscureText: isPassword && !passwordVisible, // Adjusted line
      validator: (value) => validator(value), // Adjusted line
      onChanged: onChanged,
    );
  }

  void signUserUp() async {
    final authProvider = Provider.of<AuthProviderClass>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    try {
      await authProvider.signUpWithEmailAndPassword(
        email,
        password,
      );
      User? user = authProvider.currentUser;
      if (user != null) {
        await user.updateDisplayName("$firstName $lastName");
        await user.reload();
      }

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/onboardingWelcome',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
