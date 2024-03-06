import 'package:cleaning_duty_project/core/utils/validation_ulti.dart';
import 'package:cleaning_duty_project/feature/data/entities/request/authentication/register/register_request.dart';
import 'package:cleaning_duty_project/feature/data/repository/authenticate/authenticate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthenticationRepositoryImpl authenticationRepository;
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String errorEmail = '';
  String errorPassword = '';
  String errorPasswordConfirm = '';
  String errorUsername = '';

  RegisterBloc(this.authenticationRepository) : super(RegisterInitial()) {
    on<RegisterStarted>(_onRegisterStarted);
    on<CleanErrorField>(_cleanErrorField);
  }

  void _onRegisterStarted(RegisterStarted event, Emitter<RegisterState> emit) {
    emit(RegisterProgress());
    if (!validateFields(emailController.text, passwordController.text,
        confirmPasswordController.text, usernameController.text)) {
      emit(RegisterFailure());
      return;
    }
  }

  void handleRegister(
      BuildContext context,
      TextEditingController usernameController,
      TextEditingController passwordController,
      TextEditingController emailController) {
    context.read<RegisterBloc>().add(
          RegisterStarted(
            registerRequest: RegisterRequest(
              username: usernameController.text,
              password: passwordController.text,
              email: emailController.text,
            ),
          ),
        );
  }

  bool validateFields(
    String email,
    String username,
    String password,
    String confirmPassword,
  ) {
    bool result = true;

    if (!ValidateUtil.isValidEmail(email)) {
      result = false;
      errorEmail = 'Sai mail rồi';
    }

    if (!ValidateUtil.isValidPassword(password) ||
        password.length < 8 ||
        password.length > 50) {
      result = false;
      errorPassword = 'Password phải từ 8-50 ký tự';
    }

    if (email.isEmpty) {
      result = false;
      errorEmail = 'Email không được để trống';
    }

    if (password.isEmpty) {
      result = false;
      errorPassword = 'Password không được để trống';
      errorPasswordConfirm = 'Confirm Password không được để trống';
    }

    if (username.isEmpty) {
      result = false;
      errorUsername = 'Username không được để trống';
    }

    if (password != confirmPassword) {
      result = false;
      errorPasswordConfirm = 'Confirm Password không trùng khớp với Password';
    }
    return result;
  }

  void _cleanErrorField(
      CleanErrorField event, Emitter<RegisterState> emit) async {
    switch (event.field) {
      case 'email':
        errorEmail = '';
        emit(CleanErrorEmailSuccess());
        break;
      case 'password':
        errorPassword = '';
        emit(CleanErrorPasswordSuccess());
        break;
      case 'passwordConfirm':
        errorPasswordConfirm = '';
        emit(CleanErrorPasswordConfirmSuccess());
        break;
      case 'username':
        errorUsername = '';
        emit(CleanErrorUsernameSuccess());
        break;
      default:
        // Handle unknown field name
        break;
    }
  }
}
