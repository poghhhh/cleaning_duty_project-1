import 'package:cleaning_duty_project/core/errors/exceptions.dart';
import 'package:cleaning_duty_project/feature/data/entities/request/authentication/login/login_request.dart';
import 'package:cleaning_duty_project/feature/data/repository/authenticate/authenticate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this.authenticationRepository) : super(LoginInitial()) {
    on<LoginStarted>(_onLoginStarted);
  }

  final AuthenticationRepositoryImpl authenticationRepository;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isDisable = false;

  void _onLoginStarted(LoginStarted event, Emitter<LoginState> emit) async {
    emit(LoginProgress());
    isDisable = true;
    try {
      final response = await authenticationRepository.login(event.loginRequest);
      if (response.accessToken != null) {
        isDisable = false;
        emit(LoginSuccess());
      }
    } on ServerException {
      isDisable = false;
      emit(LoginFailure());
    }
  }

  void handleLogin(
      BuildContext context,
      TextEditingController usernameController,
      TextEditingController passwordController) {
    context.read<LoginBloc>().add(
          LoginStarted(
            loginRequest: LoginRequest(
              username: usernameController.text,
              password: passwordController.text,
            ),
          ),
        );
  }
}
