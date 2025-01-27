import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:pos_shared_preferences/models/notification_helper_model.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:remote_database_setting/remote_database_setting/presentation/create_support_ticket.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:shared_widgets/config/app_enum.dart';
import 'package:shared_widgets/shared_widgets/app_close_dialog.dart';
import 'package:shared_widgets/shared_widgets/app_loading.dart';
import 'package:shared_widgets/shared_widgets/app_snack_bar.dart';
import 'package:shared_widgets/shared_widgets/app_text_field.dart';
import 'package:shared_widgets/shared_widgets/card_login.dart';
import 'package:shared_widgets/shared_widgets/custom_app_bar.dart';
import 'package:yousentech_pos_token/yousentech_pos_token.dart';

import '../domain/remote_database_setting_viewmodel.dart';

class KeyScreen extends StatefulWidget {
  final bool changeConnectionInfo;

  const KeyScreen({super.key, this.changeConnectionInfo = false});

  @override
  State<KeyScreen> createState() => _KeyScreenState();
}

class _KeyScreenState extends State<KeyScreen> {
  TextEditingController keyController = TextEditingController();
  DatabaseSettingController remoteDatabaseSettingController =
      Get.put(DatabaseSettingController.getInstance());
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;
  final keyFocusNode = FocusNode();
  final _buttonFocusNode = FocusNode();
  bool flag = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      keyFocusNode.requestFocus();
    });
    flutterWindowCloseshow(context);
  }

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IgnorePointer(
        ignoring: remoteDatabaseSettingController.isLoading.value,
        child: SafeArea(
          child: Scaffold(
            appBar: customAppBar(),
            backgroundColor: AppColor.white,
            body: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Shortcuts(
                    shortcuts: <LogicalKeySet, Intent>{
                      LogicalKeySet(LogicalKeyboardKey.enter):
                          const ActivateIntent(),
                    },
                    child: Actions(
                      actions: <Type, Action<Intent>>{
                        ActivateIntent: CallbackAction<ActivateIntent>(
                          onInvoke: (ActivateIntent intent) => _onPressed(),
                        ),
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Stack(
                          children: [
                            CardLogin(
                              children: [
                                Expanded(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            'remote_connection_information'.tr,
                                            style: TextStyle(
                                              fontSize: 12.r,
                                              color: AppColor.charcoal,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 0.01.sh),
                                        Center(
                                          child: Text(
                                            'remote_connection_information_sub'
                                                .tr,
                                            style: TextStyle(
                                              fontSize: 8.r,
                                              color: AppColor.lavenderGray,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 0.02.sh),
                                        ContainerTextField(
                                          labelText: 'key_number'.tr,
                                          showLable: true,
                                          width: ScreenUtil().screenWidth,
                                          height: 30.h,
                                          controller: keyController,
                                          iconcolor: AppColor.silverGray,
                                          focusNode: keyFocusNode,
                                          isAddOrEdit: true,
                                          borderRadius: 5.r,
                                          fontSize: 9.r,
                                          hintcolor: AppColor.silverGray,
                                          borderColor: AppColor.silverGray,
                                          hintText: 'key_number'.tr,
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.all(8.0.r),
                                            child: SvgPicture.asset(
                                              'assets/image/lock_on.svg',
                                              package:
                                                  'remote_database_setting',
                                              fit: BoxFit.scaleDown,
                                            ),
                                          ),
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, right: 10),
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  flag = !flag;
                                                });
                                              },
                                              icon: flag
                                                  ? SvgPicture.asset(
                                                      'assets/image/eye-open.svg',
                                                      package:
                                                          'remote_database_setting',
                                                      fit: BoxFit.scaleDown,
                                                      color:
                                                          AppColor.silverGray,
                                                    )
                                                  : SvgPicture.asset(
                                                      'assets/image/eye-closed.svg',
                                                      package:
                                                          'remote_database_setting',
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                            ),
                                          ),
                                          obscureText: flag ? false : true,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              errorMessage =
                                                  'key_number_message'.tr;
                                              return "";
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Obx(() {
                                //   if (remoteDatabaseSettingController.isLoading.value) {
                                //     return CircularProgressIndicator(
                                //       color: AppColor.white,
                                //       backgroundColor: AppColor.black,
                                //     );
                                //   } else {
                                //     return
                                Focus(
                                    autofocus: true,
                                    child: Builder(builder: (context) {
                                      return InkWell(
                                        onTap: _onPressed,
                                        child: Container(
                                          height: 30.h,
                                          width: ScreenUtil().screenWidth,
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.symmetric(
                                                  vertical: 5)
                                              .r,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color: AppColor.aqua,
                                                  blurRadius: 30,
                                                  offset: const Offset(0, 4),
                                                  spreadRadius: 0)
                                            ],
                                            color: AppColor.cyanTeal,
                                            borderRadius:
                                                BorderRadius.circular(5.r),
                                          ),
                                          child: Text(
                                            'connect'.tr,
                                            style: TextStyle(
                                                fontSize: 8.r,
                                                color: AppColor.white,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      );
                                    })),

                                //   }
                                // }),
                                if (widget.changeConnectionInfo) ...[
                                  SizedBox(width: 20.w),
                                  InkWell(
                                    onTap: () async {
                                      Get.back();
                                    },
                                    child: Container(
                                      height: 30.h,
                                      width: ScreenUtil().screenWidth,
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.symmetric(
                                              vertical: 5)
                                          .r,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColor.paleAqua,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5.r)),
                                      child: Text(
                                        'back'.tr,
                                        style: TextStyle(
                                            fontSize: 8.r,
                                            color: AppColor.slateGray,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            remoteDatabaseSettingController.isLoading.value
                                ? const LoadingWidget()
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ])),
          ),
        ),
      ),
    );
    // );
  }

  _onPressed() {
    if (_formKey.currentState!.validate()) {
      remoteDatabaseSettingController
          .checkDatabase(
        keyController.text,
      )
          .then((value) async {
        if (value.status) {
          appSnackBar(
            messageType: MessageTypes.success,
            message: 'success_key_login'.tr,
          );
          await SharedPr.removeUserObj();
          // TODO: tokenSCreen after build Token package
          Get.to(() => const TokenScreen());
        } else {
          if (value.data != null) {
            supportTicketDialog(
                context: Get.context!,
                message: value.message!,
                onPressed: () async {
                  await remoteDatabaseSettingController
                      .sendTicket(
                          subscriptionId: SharedPr
                              .subscriptionDetailsObj!.subscriptionId
                              .toString(),
                          message: value.message!,
                          sendToMyCompany: false)
                      .then((value) {
                    if (value.status) {
                      SharedPr.setNotificationObj(
                          notificationHelperObj:
                              NotificationHelper(sendTicket: true));
                      Get.back();
                      appSnackBar(
                          message: 'success_send_ticket'.tr,
                          messageType: MessageTypes.success);
                    } else {
                      appSnackBar(
                        message: value.message!,
                      );
                    }
                  });
                });
            // CustomDialog.getInstance().dialog(
            //   title: 'error_message',
            //   buttonheight: 0.04.sh,
            //   contentPadding: 20.r,
            //   message: value.message!,
            //   onPressed: () async {
            //     await remoteDatabaseSettingController.sendTicket(subscriptionId: SharedPr.subscriptionDetailsObj!.subscriptionId.toString(), message: value.message!)
            //     .then((value) {
            //       if (value.status) {
            //         Get.back();
            //         appSnackBar(
            //             message: 'success_send_ticket'.tr,
            //             messageType: MessageTypes.success);
            //       } else {
            //         appSnackBar(
            //           message: value.message!,
            //         );
            //       }
            //     });
            //   },
            //   dialogType: MessageTypes.error,
            //   buttonwidth: 77.w,
            //   fontSizetext: 9.r,
            //   fontSizetital: 10.r,
            //   primaryButtonText: 'send_ticket',
            // );
          } else {
            appSnackBar(
              message: value.message!,
            );
          }
        }
      });
    } else {
      appSnackBar(
        message: errorMessage!,
      );
    }
  }
}
