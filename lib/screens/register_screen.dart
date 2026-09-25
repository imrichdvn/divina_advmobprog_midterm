import 'package:divina/constants.dart';
import 'package:divina/widgets/custom_font.dart';
import 'package:divina/widgets/custom_inkwell_button.dart';
import 'package:divina/widgets/custom_textformfield.dart';
import 'package:divina/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/custom_dialogs.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController mobilenumController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  // Password visibility states
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isRegistering = false;

  Future<void> register() async {
    // TODO: Create your own validation
    // Get values from controllers
    String firstname = firstnameController.text.trim();
    String lastname = lastnameController.text.trim();
    String mobilenum = mobilenumController.text.trim();
    String username = usernameController.text.trim();
    String password = passwordController.text;
    String confirmpassword = confirmpasswordController.text;

    // Validate if fields are empty
    if (firstname.isEmpty) {
      customDialog(context, title: 'Error', content: 'First name is required');
      return;
    }

    if (lastname.isEmpty) {
      customDialog(context, title: 'Error', content: 'Last name is required');
      return;
    }

    // Validate mobile number (must be exactly 11 digits)
    if (mobilenum.isEmpty) {
      customDialog(
        context,
        title: 'Error',
        content: 'Mobile number is required',
      );
      return;
    }

    if (mobilenum.length != 11) {
      customDialog(
        context,
        title: 'Error',
        content: 'Mobile number must be exactly 11 digits',
      );
      return;
    }

    // Validate username
    if (username.isEmpty) {
      customDialog(context, title: 'Error', content: 'Username is required');
      return;
    }

    if (username.length < 3) {
      customDialog(
        context,
        title: 'Error',
        content: 'Username must be at least 3 characters',
      );
      return;
    }

    // Validate password (8 chars, mixed letters/numbers, special char, upper/lowercase)
    if (password.isEmpty) {
      customDialog(context, title: 'Error', content: 'Password is required');
      return;
    }

    if (password.length < 8) {
      customDialog(
        context,
        title: 'Error',
        content: 'Password must be at least 8 characters',
      );
      return;
    }

    // Check for uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      customDialog(
        context,
        title: 'Error',
        content: 'Password must contain at least one uppercase letter',
      );
      return;
    }

    // Check for lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      customDialog(
        context,
        title: 'Error',
        content: 'Password must contain at least one lowercase letter',
      );
      return;
    }

    // Check for number
    if (!password.contains(RegExp(r'[0-9]'))) {
      customDialog(
        context,
        title: 'Error',
        content: 'Password must contain at least one number',
      );
      return;
    }

    // Check for special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      customDialog(
        context,
        title: 'Error',
        content: 'Password must contain at least one special character',
      );
      return;
    }

    // Validate password confirmation
    if (confirmpassword.isEmpty) {
      customDialog(
        context,
        title: 'Error',
        content: 'Please confirm your password',
      );
      return;
    }

    if (password != confirmpassword) {
      customDialog(context, title: 'Error', content: 'Passwords do not match');
      return;
    }

    setState(() => isRegistering = true);
    try {
      await UserService.instance.register(
        firstName: firstname,
        lastName: lastname,
        mobileNumber: mobilenum,
        username: username,
        password: password,
      );
      if (!mounted) return;
      customDialog(
        context,
        title: 'Success',
        content: 'Registration successful! You can now sign in.',
      );
    } catch (error) {
      if (mounted) {
        customDialog(
          context,
          title: 'Error',
          content: error is StateError
              ? error.message
              : 'Registration failed. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          padding: EdgeInsets.fromLTRB(
            ScreenUtil().setWidth(25),
            ScreenUtil().setHeight(40),
            ScreenUtil().setWidth(25),
            ScreenUtil().setHeight(10),
          ),
          child: Column(
            children: [
              SizedBox(height: ScreenUtil().setHeight(25)),
              CustomFont(
                text: 'Register Here',
                fontSize: ScreenUtil().setSp(50),
                fontWeight: FontWeight.bold,
                color: FB_DARK_PRIMARY,
              ),
              SizedBox(height: ScreenUtil().setHeight(25)),
              CustomTextFormField(
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                onSaved: null,
                fontColor: null,
                hintText: 'First name',
                validator: (value) => null,
                hintTextSize: ScreenUtil().setSp(15),
                fontSize: ScreenUtil().setSp(15),
                controller: firstnameController,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              CustomTextFormField(
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                onSaved: null,
                fontColor: null,
                hintText: 'Last name',
                validator: (value) => null,
                hintTextSize: ScreenUtil().setSp(15),
                fontSize: ScreenUtil().setSp(15),
                controller: lastnameController,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              CustomTextFormField(
                maxLength: 11,
                keyboardType: TextInputType.number,
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                onSaved: null,
                fontColor: null,
                hintText: 'Mobile Num',
                validator: (value) => null,
                hintTextSize: ScreenUtil().setSp(15),
                fontSize: ScreenUtil().setSp(15),
                controller: mobilenumController,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              CustomTextFormField(
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                onSaved: null,
                fontColor: null,
                hintText: 'Username',
                validator: (value) => null,
                hintTextSize: ScreenUtil().setSp(15),
                fontSize: ScreenUtil().setSp(15),
                controller: usernameController,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              CustomTextFormField(
                isObscure: !isPasswordVisible,
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                onSaved: null,
                fontColor: null,
                hintText: 'Password',
                validator: (value) => null,
                hintTextSize: ScreenUtil().setSp(15),
                fontSize: ScreenUtil().setSp(15),
                controller: passwordController,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: FB_DARK_PRIMARY,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              Text(
                '(Password should be 8 characters, a mixture of letter and numbers consisting of at least one special character with Uppercase and Lowercase letters.)',
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Frutiger',
                  fontSize: ScreenUtil().setSp(10),
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              CustomTextFormField(
                isObscure: !isConfirmPasswordVisible,
                hintText: 'Confirm Password',
                height: ScreenUtil().setHeight(10),
                width: ScreenUtil().setWidth(10),
                onSaved: null,
                fontColor: null,
                validator: (value) => null,
                hintTextSize: ScreenUtil().setSp(15),
                fontSize: ScreenUtil().setSp(15),
                controller: confirmpasswordController,
                suffixIcon: IconButton(
                  icon: Icon(
                    isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: FB_DARK_PRIMARY,
                  ),
                  onPressed: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'You have an account? ',
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Frutiger',
                      fontSize: ScreenUtil().setSp(15),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.popAndPushNamed(context, '/login'),
                    child: Text(
                      'Login here',
                      style: TextStyle(
                        color: FB_DARK_PRIMARY,
                        fontFamily: 'Frutiger',
                        fontSize: ScreenUtil().setSp(15),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              CustomInkwellButton(
                onTap: () {
                  if (!isRegistering) register();
                },
                height: ScreenUtil().setHeight(45),
                width: ScreenUtil().screenWidth,
                fontSize: ScreenUtil().setSp(15),
                fontWeight: FontWeight.bold,
                buttonName: 'Submit',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
