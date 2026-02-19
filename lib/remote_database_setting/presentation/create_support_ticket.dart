import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_shared_preferences/models/notification_helper_model.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:remote_database_setting/remote_database_setting/domain/remote_database_setting_viewmodel.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:shared_widgets/config/app_enums.dart';
import 'package:shared_widgets/config/app_styles.dart';
import 'package:shared_widgets/config/theme_controller.dart';
import 'package:shared_widgets/shared_widgets/app_button.dart';
import 'package:shared_widgets/shared_widgets/app_dialog.dart';
import 'package:shared_widgets/shared_widgets/app_loading.dart';
import 'package:shared_widgets/shared_widgets/app_snack_bar.dart';
import 'package:shared_widgets/shared_widgets/app_text_field.dart';
import 'package:shared_widgets/utils/responsive_helpers/device_utils.dart';
import 'package:shared_widgets/utils/responsive_helpers/size_helper_extenstions.dart';
import 'package:shared_widgets/utils/responsive_helpers/size_provider.dart';

TextEditingController exceptionDetails = TextEditingController();

DatabaseSettingController databaseSettingController = Get.put(
  DatabaseSettingController.getInstance(),
);

final _formKey = GlobalKey<FormState>();
String? errorMessage;
int countErrors = 0;

supportTicketDialog({
  IconData? icon,
  required BuildContext context,
  String? message,
  void Function()? onPressed,
}) {
  exceptionDetails.text = message ?? "";
  dialogcontent(
    context: context,
    content: Builder(
      builder: (context) {
        return Container(
          // height: context.setHeight(280),
          width: context.setWidth(454.48),
          padding: EdgeInsets.all(context.setMinSize(20)),
          child: Obx(
            () => IgnorePointer(
              ignoring: databaseSettingController.isLoading.value,
              child: Stack(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      spacing: context.setHeight(10),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'support_ticket'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:Get.find<ThemeController>().isDarkMode.value
                                ? AppColor.white
                                : AppColor.black,
                            fontSize: context.setSp(DeviceUtils.isMobile(context) ? 16 : 20.03),
                            fontFamily: DeviceUtils.isMobile(context) ?'SansMedium' : 'Tajawal',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          icon ?? Icons.airplane_ticket_outlined,
                          color: AppColor.amberLight,
                          size: context.setMinSize(40),
                        ),
                        Text(
                          'exception_details_message'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:Get.find<ThemeController>().isDarkMode.value
                                ? const Color(0xFFB1B3BC)
                                : const Color(0xFF9F9FA5),
                            fontSize: context.setSp(DeviceUtils.isMobile(context) ? 14 : 14.42),
                            fontFamily: DeviceUtils.isMobile(context) ?'SansMedium' : 'Tajawal',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        ContainerTextField(
                          controller: exceptionDetails,
                          keyboardType: TextInputType.text,
                          width: context.screenWidth,
                          height: context.setHeight(51.28),
                          fontSize: context.setSp(DeviceUtils.isMobile(context) ? 12 : 11.22),
                          maxLines: 6,
                          enabled: message == null ? true : false,
                          isAddOrEdit: true,
                          borderColor: !Get.find<ThemeController>().isDarkMode.value
                              ? const Color(
                                  0xFFC2C3CB,
                                )
                              : null,
                          fillColor: !Get.find<ThemeController>().isDarkMode.value
                              ? AppColor.white.withValues(
                                  alpha: 0.43,
                                )
                              : const Color(
                                  0xFF2B2B2B,
                                ),
                          hintcolor: !Get.find<ThemeController>().isDarkMode.value
                              ? const Color(
                                  0xFFC2C3CB,
                                )
                              : const Color(
                                  0xFFC2C3CB,
                                ),
                          color: Get.find<ThemeController>().isDarkMode.value
                              ? AppColor.white
                              : AppColor.black,
                          borderRadius: context.setMinSize(5),
                          textAlign: TextAlign.start,
                          hintText: 'exception_details'.tr,
                          labelText: 'exception_details'.tr,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              errorMessage = 'required_message_f'.trParams({
                                'field_name': 'exception_details'.tr,
                              });
                              countErrors++;
                              return "";
                            }
                            return null;
                          },
                        ),
                        // const Spacer(),
                        SizedBox(height: context.setHeight(10),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: context.setWidth(10),
                          children: [
                            Expanded(
                              child: ButtonElevated(
                                text: message != null
                                    ? 'yes'.tr
                                    : 'send_ticket'.tr,
                                backgroundColor: AppColor.cyanTeal,
                                height: context.setHeight(35),
                                // width: context.setWidth(180),
                                borderRadius: context.setMinSize(5),
                                textStyle: AppStyle.textStyle(
                                  color: AppColor.white,
                                  fontSize: context.setSp(12),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: DeviceUtils.isMobile(context) ?'SansMedium' : 'Tajawal',
                                ),
                                onPressed: onPressed ??
                                    () async {
                                      countErrors = 0;
                                      if (_formKey.currentState!.validate()) {
                                        await databaseSettingController
                                            .sendTicket(
                                          subscriptionId: SharedPr
                                              .subscriptionDetailsObj!
                                              .subscriptionId
                                              .toString(),
                                          message: exceptionDetails.text,
                                        )
                                            .then((value) {
                                          if (value.status) {
                                            SharedPr.setNotificationObj(
                                              notificationHelperObj:
                                                  NotificationHelper(
                                                sendTicket: true,
                                              ),
                                            );
                                            Get.back();
                                            appSnackBar(
                                              message: 'success_send_ticket'.tr,
                                              messageType: MessageTypes.success,
                                            );
                                            exceptionDetails.clear();
                                          } else {
                                            appSnackBar(
                                              message: value.message!,
                                            );
                                            exceptionDetails.clear();
                                          }
                                        });
                                      } else {
                                        appSnackBar(
                                          message: countErrors > 1
                                              ? 'enter_required_info'.tr
                                              : errorMessage!,
                                        );
                                      }
                                    },
                              ),
                            ),
                            Expanded(
                              child: ButtonElevated(
                                text: 'cancel'.tr,
                                height: context.setHeight(35),
                                // width: context.setWidth(180),
                                borderColor: AppColor.paleAqua,
                                borderRadius: context.setMinSize(5),
                                textStyle: AppStyle.textStyle(
                                  color: AppColor.slateGray,
                                  fontSize: context.setSp(12),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: DeviceUtils.isMobile(context) ?'SansMedium' : 'Tajawal',
                                ),
                                onPressed: () async {
                                  Get.back();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  databaseSettingController.isLoading.value
                      ? const LoadingWidget()
                      : Container(),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
