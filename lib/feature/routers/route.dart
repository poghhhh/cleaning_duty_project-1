import 'package:cleaning_duty_project/core/networks/network_client.dart';
import 'package:cleaning_duty_project/feature/blocs/authenticate/login/bloc/login_bloc.dart';
import 'package:cleaning_duty_project/feature/blocs/authenticate/register/bloc/register_bloc.dart';
import 'package:cleaning_duty_project/feature/data/db/secure_storage.dart';
import 'package:cleaning_duty_project/feature/data/remote/authenticate/authenticate_network_client.dart';
import 'package:cleaning_duty_project/feature/data/repository/authenticate/authenticate.dart';
import 'package:cleaning_duty_project/feature/routers/screen_route.dart';
import 'package:cleaning_duty_project/feature/screen/authenticate/login/login.dart';
import 'package:cleaning_duty_project/feature/screen/authenticate/register/register.dart';
import 'package:cleaning_duty_project/feature/screen/home/home.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (ScreenRoute.publicRoute.contains(state.fullPath)) {
        return null;
      }
      if (context.read<LoginBloc>().state is HandleTokenSuccess) {
        return null;
      }
      return ScreenRoute.loginScreen;
    },
    routes: [
      GoRoute(
        path: ScreenRoute.loginScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => LoginBloc(
              AuthenticationRepositoryImpl(
                authenticateNetworkClient: AuthenticateNetworkClient(
                  secureStorage: SecureStorageImpl(),
                  networkClient: NetworkClient(
                    dio: Dio(),
                  ),
                ),
              ),
              SecureStorageImpl()),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: ScreenRoute.registerScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => RegisterBloc(
            AuthenticationRepositoryImpl(
              authenticateNetworkClient: AuthenticateNetworkClient(
                secureStorage: SecureStorageImpl(),
                networkClient: NetworkClient(
                  dio: Dio(),
                ),
              ),
            ),
          ),
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: ScreenRoute.homeScreen,
        pageBuilder: (context, state) => const MaterialPage(
          child: HomeScreen(),
        ),
      ),
    ],
  );
  static GoRouter get router => _router;
}
