// ignore_for_file: use_build_context_synchronously, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pos_shared_preferences/models/notification_helper_model.dart';
import 'package:pos_shared_preferences/models/pos_setting_info_model.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:remote_database_setting/remote_database_setting/domain/remote_database_setting_viewmodel.dart';
import 'package:remote_database_setting/remote_database_setting/presentation/create_support_ticket.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:shared_widgets/config/app_enums.dart';
import 'package:shared_widgets/config/app_images.dart';
import 'package:shared_widgets/config/app_styles.dart';
import 'package:shared_widgets/config/theme_controller.dart';
import 'package:shared_widgets/shared_widgets/app_button.dart';
import 'package:shared_widgets/shared_widgets/app_close_dialog.dart';
import 'package:shared_widgets/shared_widgets/app_dialog.dart';
import 'package:shared_widgets/shared_widgets/app_loading.dart';
import 'package:shared_widgets/shared_widgets/app_snack_bar.dart';
import 'package:shared_widgets/shared_widgets/app_text_field.dart';
import 'package:shared_widgets/shared_widgets/custom_app_bar.dart';
import 'package:shared_widgets/utils/responsive_helpers/size_helper_extenstions.dart';
import 'package:shared_widgets/utils/responsive_helpers/size_provider.dart';
import 'package:yousentech_authentication/authentication/presentation/views/employees_list.dart';
import 'package:yousentech_authentication/authentication/presentation/views/employees_list_mobile.dart';
import 'package:yousentech_pos_token/token_settings/domain/token_viewmodel.dart';

class KeyAndTokenScreenMobile extends StatefulWidget {
  final bool changeConnectionInfo;
  final bool isKeyScreen;
  KeyAndTokenScreenMobile({
    super.key,
    this.changeConnectionInfo = false,
    this.isKeyScreen = true,
  });

  @override
  State<KeyAndTokenScreenMobile> createState() =>
      _KeyAndTokenScreenMobileState();
}

class _KeyAndTokenScreenMobileState extends State<KeyAndTokenScreenMobile> {
  TextEditingController textEditingController = TextEditingController();
  DatabaseSettingController remoteDatabaseSettingController = Get.put(
    DatabaseSettingController.getInstance(),
  );
  TokenController tokenClassController = Get.put(TokenController.getInstance());
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;
  final fieldFocusNode = FocusNode();
  final _buttonFocusNode = FocusNode();
  bool flag = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fieldFocusNode.requestFocus();
      flutterWindowCloseshow(context);
    });
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
        ignoring: widget.isKeyScreen
            ? remoteDatabaseSettingController.isLoading.value
            : tokenClassController.isLoading.value,
        child: SafeArea(
          child: Scaffold(
            appBar: customAppBar(
              context: context,
              isMobile: true,
              onDarkModeChanged: () {},
            ),
            backgroundColor: !Get.find<ThemeController>().isDarkMode.value
                ? AppColor.white
                : AppColor.darkModeBackgroundColor,
            body: Shortcuts(
              shortcuts: <LogicalKeySet, Intent>{
                LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
              },
              child: Actions(
                actions: <Type, Action<Intent>>{
                  ActivateIntent: CallbackAction<ActivateIntent>(
                    onInvoke: (ActivateIntent intent) => widget.isKeyScreen
                        ? _onPressedConnect()
                        : _onPressedDisplayEmployees(),
                  ),
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(context.setMinSize(16.92)),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // SvgPicture.asset(
                            //   AppImages.logo,
                            //   package: 'shared_widgets',
                            //   fit: BoxFit.cover,
                            //   width: context.setWidth(164.94),
                            //   height: context.setHeight(60.5),
                            // ),
                            SizedBox(height: context.setHeight(40)),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      widget.isKeyScreen
                                          ? 'remote_connection_information'.tr
                                          : 'token_information'.tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: !Get.find<ThemeController>()
                                                .isDarkMode
                                                .value
                                            ? const Color(
                                                0xFF2E2E2E,
                                              )
                                            : Colors.white,
                                        fontSize: context.setSp(
                                          16,
                                        ),
                                        fontFamily: 'SansBold',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: context.setHeight(4.46),
                                  ),
                                  Center(
                                    child: Text(
                                      widget.isKeyScreen
                                          ? 'remote_connection_information_sub'
                                              .tr
                                          : 'token_information_sub'.tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Get.find<ThemeController>()
                                                .isDarkMode
                                                .value
                                            ? const Color(0xFFB1B3BC)
                                            : const Color(
                                                0xFF9F9FA5,
                                              ),
                                        fontSize: context.setSp(
                                          14,
                                        ),
                                        fontFamily: 'SansRegular',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: context.setHeight(67.44),
                                  ),
                                  Text(
                                    widget.isKeyScreen
                                        ? 'key_number'.tr
                                        : 'token_number'.tr,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: !Get.find<ThemeController>()
                                              .isDarkMode
                                              .value
                                          ? const Color(0xFF585858)
                                          : const Color(0xFFB1B3BC),
                                      fontSize: context.setSp(12),
                                      fontFamily: 'SansMedium',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  ContainerTextField(
                                    focusNode: fieldFocusNode,
                                    controller: textEditingController,
                                    labelText: widget.isKeyScreen
                                        ? 'key_number'.tr
                                        : 'token_number'.tr,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.]'),
                                      ),
                                    ],
                                    width: context.screenWidth,
                                    height: context.setHeight(
                                      51.28,
                                    ),
                                    fontSize: context.setSp(
                                      12,
                                    ),
                                    testFontSize: context.setSp(
                                      19,
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                      context.setWidth(
                                        14.82,
                                      ),
                                      context.setHeight(
                                        15.22,
                                      ),
                                      context.setWidth(
                                        14.82,
                                      ),
                                      context.setHeight(
                                        15.22,
                                      ),
                                    ),
                                    showLable: false,
                                    iconcolor: AppColor.appColor,
                                    borderColor: !Get.find<ThemeController>()
                                            .isDarkMode
                                            .value
                                        ? const Color(
                                            0xFFC2C3CB,
                                          )
                                        : null,
                                    fillColor: !Get.find<ThemeController>()
                                            .isDarkMode
                                            .value
                                        ? Colors.white.withValues(
                                            alpha: 0.43,
                                          )
                                        : const Color(
                                            0xFF2B2B2B,
                                          ),
                                    hintcolor: !Get.find<ThemeController>()
                                            .isDarkMode
                                            .value
                                        ? const Color(
                                            0xFFC2C3CB,
                                          )
                                        : const Color(
                                            0xFFC2C3CB,
                                          ),
                                    color: !Get.find<ThemeController>()
                                            .isDarkMode
                                            .value
                                        ? const Color(
                                            0xFFC2C3CB,
                                          )
                                        : const Color(
                                            0xFFC2C3CB,
                                          ),
                                    isAddOrEdit: true,
                                    borderRadius: context.setMinSize(8.01),
                                    hintText: widget.isKeyScreen
                                        ? 'key_number'.tr
                                        : 'token_number'.tr,
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: context.setWidth(
                                          14,
                                        ),
                                      ),
                                      child: SvgPicture.asset(
                                        AppImages.lockOn,
                                        package: 'shared_widgets',
                                        color: AppColor.appColor,
                                        width: context.setWidth(21.63),
                                        height: context.setHeight(21.63),
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          flag = !flag;
                                        });
                                      },
                                      icon: flag
                                          ? SvgPicture.asset(
                                              AppImages.eyeOpen,
                                              package: 'shared_widgets',
                                              width: context.setWidth(
                                                21.63,
                                              ),
                                              height: context.setHeight(
                                                21.63,
                                              ),
                                              color: AppColor.appColor,
                                            )
                                          : SvgPicture.asset(
                                              AppImages.eyeClosed,
                                              package: 'shared_widgets',
                                              width: context.setWidth(
                                                21.63,
                                              ),
                                              height: context.setHeight(
                                                21.63,
                                              ),
                                              color: AppColor.appColor,
                                            ),
                                    ),
                                    obscureText: flag ? false : true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        errorMessage = widget.isKeyScreen
                                            ? 'key_number_message'.tr
                                            : 'required_message'.trParams({
                                                'field_name': 'token_number'.tr,
                                              });
                                        return "";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: context.setHeight(183.5),
                                  ),
                                  Center(
                                    child: Focus(
                                        autofocus: true,
                                        child: Row(
                                          spacing: context.setWidth(
                                            16,
                                          ),
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: widget.isKeyScreen
                                                    ? _onPressedConnect
                                                    : _onPressedDisplayEmployees,
                                                child: Container(
                                                  width: context.screenWidth,
                                                  height: context.setHeight(
                                                    47.27,
                                                  ),
                                                  alignment: Alignment.center,
                                                  decoration: ShapeDecoration(
                                                    color: AppColor.appColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        context.setMinSize(
                                                          7.21,
                                                        ),
                                                      ),
                                                    ),
                                                    // shadows: const [
                                                    //   BoxShadow(
                                                    //     color: Color(
                                                    //       0x4C16A6B7,
                                                    //     ),
                                                    //     blurRadius:
                                                    //         24.04,
                                                    //     offset:
                                                    //         Offset(
                                                    //           0,
                                                    //           3.20,
                                                    //         ),
                                                    //     spreadRadius:
                                                    //         0,
                                                    //   ),
                                                    // ],
                                                  ),
                                                  child: Text(
                                                    widget.isKeyScreen
                                                        ? 'connect'.tr
                                                        : 'display_employees'
                                                            .tr,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: context.setSp(
                                                        12,
                                                      ),
                                                      color: AppColor.white,
                                                      fontFamily: "SansMedium",
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (widget
                                                .changeConnectionInfo) ...[
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    Get.back();
                                                  },
                                                  child: Container(
                                                    width: context.screenWidth,
                                                    height: context.setHeight(
                                                      47.27,
                                                    ),
                                                    decoration: ShapeDecoration(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 1,
                                                          color: Get.find<
                                                                      ThemeController>()
                                                                  .isDarkMode
                                                                  .value
                                                              ? Colors.white
                                                                  .withValues(
                                                                  alpha: 0.50,
                                                                )
                                                              : const Color(
                                                                  0xFFC2C3CB,
                                                                ),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          context.setMinSize(
                                                            9,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "back".tr,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize:
                                                              context.setSp(
                                                            12,
                                                          ),
                                                          color: !Get.find<
                                                                      ThemeController>()
                                                                  .isDarkMode
                                                                  .value
                                                              ? const Color(
                                                                  0xFFC2C3CB,
                                                                )
                                                              : const Color(
                                                                  0xFFC2C3CB,
                                                                ),
                                                          fontFamily: "SansMedium",
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.isKeyScreen) ...[
                      remoteDatabaseSettingController.isLoading.value
                          ? const LoadingWidget()
                          : Container(),
                    ],
                    if (!widget.isKeyScreen) ...[
                      tokenClassController.isLoading.value
                          ? const LoadingWidget()
                          : Container(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // );
  }

  _onPressedConnect() {
    if (_formKey.currentState!.validate()) {
      remoteDatabaseSettingController
          .checkDatabase(textEditingController.text)
          .then((value) async {
        if (value.status) {
          appSnackBar(
            messageType: MessageTypes.success,
            message: 'success_key_login'.tr,
          );
          await SharedPr.removeUserObj();
          Get.offAll(() => KeyAndTokenScreenMobile(isKeyScreen: false));
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
                  sendToMyCompany: false,
                )
                    .then((value) {
                  if (value.status) {
                    SharedPr.setNotificationObj(
                      notificationHelperObj: NotificationHelper(
                        sendTicket: true,
                      ),
                    );
                    Get.back();
                    appSnackBar(
                      message: 'success_send_ticket'.tr,
                      messageType: MessageTypes.success,
                    );
                  } else {
                    appSnackBar(message: value.message!);
                  }
                });
              },
            );
          } else {
            appSnackBar(message: value.message!);
          }
        }
      });
    } else {
      appSnackBar(message: errorMessage!);
    }
  }

  _onPressedDisplayEmployees() async {
    if (_formKey.currentState!.validate()) {
      var value = await tokenClassController.checkToken(
        token: textEditingController.text,
        context: context,
      );
      if (value.status) {
        if (value.message == "change_device_id") {
          dialogcontent(
            barrierDismissible: true,
            content: Builder(
              builder: (context) {
                return SizeProvider(
                  baseSize: Size(
                    context.setWidth(454.48),
                    context.setHeight(280),
                  ),
                  width: context.setWidth(454.48),
                  height: context.setHeight(280),
                  child: Container(
                    width: context.setWidth(454.48),
                    height: context.setHeight(280),
                    padding: EdgeInsets.all(context.setMinSize(20)),
                    child: Obx(
                      () => IgnorePointer(
                        ignoring: tokenClassController.isLoading.value,
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'change_device_id'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Get.find<ThemeController>()
                                            .isDarkMode
                                            .value
                                        ? Colors.white
                                        : const Color(0xFF2E2E2E),
                                    fontSize: context.setSp(20.03),
                                    fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: context.setHeight(15)),
                                Icon(
                                  Icons.browser_updated,
                                  color: AppColor.amberLight,
                                  size: context.setMinSize(40),
                                ),
                                SizedBox(height: context.setHeight(15)),
                                Text(
                                  'change_device_id_message'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Get.find<ThemeController>()
                                            .isDarkMode
                                            .value
                                        ? const Color(0xFFB1B3BC)
                                        : const Color(0xFF9F9FA5),
                                    fontSize: context.setSp(14.42),
                                    fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  spacing: context.setWidth(10),
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ButtonElevated(
                                        text: 'change_device_id_butt'.tr,
                                        height: context.setHeight(35),
                                        borderRadius: context.setMinSize(9),
                                        backgroundColor: AppColor.cyanTeal,
                                        textStyle: AppStyle.textStyle(
                                          color: Colors.white,
                                          fontSize: context.setSp(12),
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Tajawal',
                                        ),
                                        onPressed: () async {
                                          await tokenClassController
                                              .updateDeviceIdAddress(
                                            tokenValue: value,
                                            tokenText: textEditingController.text,
                                          )
                                              .then((insideValue) async {
                                            if (insideValue.status) {
                                              Get.back();
                                              appSnackBar(
                                                message:
                                                    'success_change_device_id'.tr,
                                                messageType: MessageTypes.success,
                                              );
                                              Get.to(
                                                () => const EmployeesListScreenMobile(),
                                              );
                                            } else {
                                              appSnackBar(
                                                message: insideValue.message!,
                                              );
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: ButtonElevated(
                                        text: 'cancel'.tr,
                                        height: context.setHeight(35),
                                        borderRadius: context.setMinSize(9),
                                        borderColor: AppColor.paleAqua,
                                        textStyle: AppStyle.textStyle(
                                          color: AppColor.slateGray,
                                          fontSize: context.setSp(12),
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Tajawal',
                                        ),
                                        onPressed: () async {
                                          Get.back();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                // )
                              ],
                            ),
                            tokenClassController.isLoading.value
                                ? const LoadingWidget()
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            context: context,
          );
        } else {
          await SharedPr.setCurrentPOSAndToken(
            posSettingInfo: PosSettingInfo(
              id: value.data.posId,
              name: value.data.posName,
            ),
            token: textEditingController.text,
          );

          appSnackBar(
            messageType: MessageTypes.success,
            message: 'success_token'.tr,
          );
          Get.to(() => const EmployeesListScreenMobile());
        }
      } else {
        appSnackBar(message: value.message!);
      }
    } else {
      appSnackBar(message: errorMessage!);
    }
  }
}
