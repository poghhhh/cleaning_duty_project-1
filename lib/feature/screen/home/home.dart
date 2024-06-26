// ignore_for_file: use_build_context_synchronously
import 'package:cleaning_duty_project/core/colors/app_color.dart';
import 'package:cleaning_duty_project/core/constants/constants.dart';
import 'package:cleaning_duty_project/core/utils/toast_util.dart';
import 'package:cleaning_duty_project/feature/blocs/authenticate/logout/bloc/logout_bloc.dart';
import 'package:cleaning_duty_project/feature/blocs/home/home/home_bloc.dart';
import 'package:cleaning_duty_project/feature/data/db/local_client.dart';
import 'package:cleaning_duty_project/feature/routers/screen_route.dart';
import 'package:cleaning_duty_project/feature/widget/BottomSheetActionBar/package/smoothness.dart';
import 'package:cleaning_duty_project/feature/widget/BottomSheetActionBar/package/solidBottomSheet.dart';
import 'package:cleaning_duty_project/feature/widget/Calendar/common_calendar.dart';
import 'package:cleaning_duty_project/feature/widget/Appbar/common_appbar_with_date_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocalClientImpl localClientImpl = LocalClientImpl();
  bool isAdmin = false;
  @override
  void initState() {
    context.read<HomeBloc>().add(HomeStarted(false));
    isAdmin = localClientImpl.readData('currentUser')['isAdmin'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homeBloc = context.read<HomeBloc>();
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: CommonAppbarWithDateBar(
        globalKey: context.read<HomeBloc>().key,
        onPressBack: () {
          context.read<HomeBloc>().handleDateBarPreviousUpdated(context);
          homeBloc.calendarKey.currentState!.onPressBackFunction();
        },
        onPressForward: () {
          context.read<HomeBloc>().handleDateBarForwardUpdated(context);
          homeBloc.calendarKey.currentState!.onPressForwardFunction();
        },
      ),
      bottomSheet: _buidlBottomSheet(context, isAdmin),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return CommonCalendar(
            cleaningDutyList: homeBloc.cleaningDutyList ?? [],
            funtionOnTapDate: (date) {
              PanaraConfirmDialog.show(
                context,
                message: 'Do you want to add a cleaning duty for this day?',
                confirmButtonText: 'Yes',
                cancelButtonText: 'No',
                onTapConfirm: () {},
                onTapCancel: () {
                  context.pop();
                },
                panaraDialogType: PanaraDialogType.normal,
              );
            },
          );
        },
      ),
    );
  }
}

_buidlBottomSheet(BuildContext context, bool isAdmin) {
  var logoutState = context.watch<LogoutBloc>().state;
  if (logoutState is LogoutSuccess) {
    ToastUtil.showSuccessMessage('Logout success!');
    context.pushReplacement(ScreenRoute.loginScreen);
  }

  return SolidBottomSheet(
    controller: context.read<HomeBloc>().solidController,
    onShow: () {
      context.read<HomeBloc>().handleBottomSheetOpened(context);
    },
    onHide: () {
      context.read<HomeBloc>().handleBottomSheetClosed(context);
    },
    toggleVisibilityOnTap: true,
    canUserSwipe: false,
    draggableBody: false,
    maxHeight: 400.h,
    smoothness: Smoothness.medium,
    headerBar: Container(
      decoration: const BoxDecoration(
        color: AppColor.colorAppBar,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      height: 93.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 5.h,
          ),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              Icon? bottomSheetIcon;
              if (state is HomeInitial) {
                bottomSheetIcon = Icon(Icons.keyboard_arrow_up,
                    color: Colors.white, size: 30.sp);
              }
              if (state is BottomSheetOpened) {
                bottomSheetIcon = Icon(Icons.keyboard_arrow_down,
                    color: Colors.white, size: 30.sp);
              }
              if (state is BottomSheetClosed) {
                bottomSheetIcon = Icon(Icons.keyboard_arrow_up,
                    color: Colors.white, size: 30.sp);
              }
              if (state is HomeReset) {
                bottomSheetIcon = Icon(Icons.keyboard_arrow_up,
                    color: Colors.white, size: 30.sp);
              }
              if (state is DateBarUpdated) {
                bottomSheetIcon = Icon(Icons.keyboard_arrow_up,
                    color: Colors.white, size: 30.sp);
              }
              return bottomSheetIcon ?? Container();
            },
          ),
          Text(
            'Quick actions',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              fontFamily: Constants.app_font_Lato,
            ),
          ),
        ],
      ),
    ),
    body: Container(
      alignment: Alignment.topCenter,
      height: double.infinity,
      color: AppColor.colorAppBar,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconButton(
                    OMIcons.person,
                    AppColor.colorE06D06,
                    'Profile',
                    () async {
                      context.read<HomeBloc>().resetState(context);
                      await context.push(ScreenRoute.profileScreen);
                      context.read<HomeBloc>().add(HomeStarted(false));
                    },
                  ),
                  if (isAdmin)
                    _buildIconButton(
                      OMIcons.personAdd,
                      AppColor.color219653,
                      'Add Duty',
                      () {
                        context.read<HomeBloc>().resetState(context);
                        context.push(ScreenRoute.cleanningDutyScreen);
                      },
                    ),
                  if (isAdmin)
                    _buildIconButton(
                      OMIcons.assignmentInd,
                      AppColor.color9B51E0,
                      'Quick Add ',
                      () {
                        PanaraConfirmDialog.showAnimatedGrow(context,
                            message:
                                'Tự động sắp lịch trực nhật cho tháng hiện tại',
                            confirmButtonText: 'Ok',
                            cancelButtonText: 'Hủy', onTapConfirm: () async {
                          context.pop();
                          context.read<HomeBloc>().resetState(context);

                          var response = await context
                              .read<HomeBloc>()
                              .handleQuickAssignDuties();
                          if (response == 200) {
                            PanaraInfoDialog.show(
                              context,
                              title: "Thành Công",
                              message:
                                  "Đã sắp lịch trực nhật cho tháng hiện tại",
                              buttonText: "Ok",
                              onTapDismiss: () {
                                context
                                    .read<HomeBloc>()
                                    .add(HomeStarted(false));
                                Navigator.pop(context);
                              },
                              panaraDialogType: PanaraDialogType.success,
                            );
                          } else {
                            PanaraInfoDialog.show(context,
                                message: "Có lỗi trong quá trình thực hiện !",
                                title: "Thất bại",
                                buttonText: "Ok",
                                onTapDismiss: () {},
                                panaraDialogType: PanaraDialogType.error);
                          }
                        }, onTapCancel: () {
                          context.pop();
                        }, panaraDialogType: PanaraDialogType.normal);
                      },
                    ),
                  _buildIconButton(
                    Icons.logout_outlined,
                    AppColor.colorEB5757,
                    'Logout',
                    () {
                      context.read<LogoutBloc>().handleLogout(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildIconButton(
  IconData icon,
  Color color,
  String text,
  VoidCallback onPressed,
) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: ShapeDecoration(
                  color: AppColor.colorWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              IconButton(
                onPressed: onPressed,
                icon: Icon(
                  icon,
                  size: 40.sp,
                  color: color,
                  weight: 100,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h)
        ],
      ),
      Positioned(
        bottom: 0,
        child: Text(
          textAlign: TextAlign.center,
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            fontFamily: Constants.app_font_Lato,
          ),
        ),
      ),
    ],
  );
}
