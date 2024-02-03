
import 'package:flutter/material.dart';
import 'package:get_fit/providers/auth_provider.dart';
import 'package:get_fit/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool _passwordVisible = false;
  bool isLoading = false;
  final TextEditingController _controller1 = TextEditingController();
  final FocusNode _focusNode1 = FocusNode();
  final TextEditingController _controller2 = TextEditingController();
  final FocusNode _focusNode2 = FocusNode();

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _controller1.text = 'gmtfrombc@gmail.com';
    _controller2.text = 'password1';
    _focusNode1.addListener(() {
      if (_focusNode1.hasFocus) {
        _controller1.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller1.text.length,
        );
      }
    });
    _focusNode2.addListener(() {
      if (_focusNode2.hasFocus) {
        _controller2.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller2.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _focusNode1.dispose();
    _controller2.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CustomProgressIndicator(),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: _buildSigninForm(),
          );
  }

  Widget _buildSigninForm() {
    final authProvider = Provider.of<AuthProviderClass>(context, listen: false);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(
            Icons.person_sharp,
            size: 100,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          TextFormField(
            //controller: _controller1,
            focusNode: _focusNode1,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              labelStyle: TextStyle(
                color: Colors.black45,
              ),
            ),
            validator: (val) => val!.isEmpty ? 'Enter an email' : null,
            onChanged: (val) {
              setState(() => email = val);
            },
          ),
          const SizedBox(height: 15.0),
          TextFormField(
            //controller: _controller2,
            autofillHints: const [AutofillHints.password],
            focusNode: _focusNode2,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
              prefixIcon: const Icon(Icons.password_outlined),
              labelStyle: const TextStyle(
                color: Colors.black45,
              ),
            ),
            obscureText: !_passwordVisible,
            validator: (val) =>
                val!.length < 6 ? 'Enter a password 6+ chars long' : null,
            onChanged: (val) {
              setState(() => password = val);
            },
          ),
          const SizedBox(height: 40.0),
          ElevatedButton(
            style: ElevatedButtonTheme.of(context).style,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                signUserIn();
              }
            },
            child: const Text('Sign In'),
          ),
          TextButton(
            onPressed: () async {
              if (email.isNotEmpty) {
                try {
                  await authProvider.resetPassword(email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password reset email sent to $email'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to reset password'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Forgot Password?'),
          ),
          Text(error, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  void signUserIn() async {
    final authProvider = Provider.of<AuthProviderClass>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    try {
      email = email;
      password = password;
      //email = "gmtfrombc@gmail.com";
      //password = "password";
      await authProvider.signInWithEmailAndPassword(
        email,
        password,
      );
      if (mounted) {
        Navigator.pushNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = 'Failed to sign in');
      }
    } finally {
      if (mounted) {
        setState(
          () {
            isLoading = false;
          },
        );
      }
    }
  }
}
