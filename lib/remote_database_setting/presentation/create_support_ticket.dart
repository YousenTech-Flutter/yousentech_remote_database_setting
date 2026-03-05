import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_shared_preferences/models/notification_helper_model.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:remote_database_setting/remote_database_setting/domain/remote_database_setting_viewmodel.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:shared_widgets/config/app_enums.dart';
import 'package:shared_widgets/config/app_sizes.dart';
import 'package:shared_widgets/config/app_styles.dart';
import 'package:shared_widgets/config/theme_controller.dart';
import 'package:shared_widgets/shared_widgets/app_button.dart';
import 'package:shared_widgets/shared_widgets/app_dialog.dart';
import 'package:shared_widgets/shared_widgets/app_loading.dart';
import 'package:shared_widgets/shared_widgets/app_snack_bar.dart';
import 'package:shared_widgets/shared_widgets/app_text_field.dart';
import 'package:shared_widgets/utils/responsive_helpers/device_utils.dart';
import 'package:shared_widgets/utils/responsive_helpers/size_helper_extenstions.dart';

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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
                          children: [
                            Text(
                              'support_ticket'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:Get.find<ThemeController>().isDarkMode.value
                                    ? AppColor.white
                                    : AppColor.black,
                                fontSize: context.setSp(DeviceUtils.isMobile(context) ? AppSizes.title : 20.03),
                                fontFamily: DeviceUtils.isMobile(context) ?'SansMedium' : 'Tajawal',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Icon(
                              icon ?? Icons.airplane_ticket_outlined,
                              color: AppColor.amberLight,
                              size: context.setMinSize(AppSizes.titleIcon),
                            ),
                            Text(
                              'exception_details_message'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:Get.find<ThemeController>().isDarkMode.value
                                    ? const Color(0xFFB1B3BC)
                                    : const Color(0xFF9F9FA5),
                                fontSize: context.setSp(DeviceUtils.isMobile(context) ? AppSizes.subTitle : 14.42),
                                fontFamily: DeviceUtils.isMobile(context) ?'SansMedium' : 'Tajawal',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            ContainerTextField(
                              controller: exceptionDetails,
                              keyboardType: TextInputType.text,
                              fontSize: context.setSp(DeviceUtils.isMobile(context) ? AppSizes.textField : 11.22),
                              maxLines: 6,
                              enabled: message == null ? true : false,
                              isAddOrEdit: true,
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
                             
                              spacing: context.setWidth(AppSizes.spacingBetweenButtons),
                              children: [
                                Expanded(
                                  child: ButtonElevated(
                                    text: message != null
                                        ? 'yes'.tr
                                        : 'send_ticket'.tr,
                                    backgroundColor: AppColor.cyanTeal,
                                    height: context.setHeight(AppSizes.buttonHeight),
                                    
                                    borderRadius: context.setMinSize(AppSizes.textFieldButtonBorderRadius),
                                    textStyle: AppStyle.textStyle(
                                      color: AppColor.white,
                                      fontSize: context.setSp(AppSizes.buttonText),
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
                                    height: context.setHeight(AppSizes.buttonHeight),
                                    
                                    borderColor: AppColor.paleAqua,
                                    borderRadius: context.setMinSize(AppSizes.textFieldButtonBorderRadius),
                                    textStyle: AppStyle.textStyle(
                                      color: AppColor.slateGray,
                                      fontSize: context.setSp(AppSizes.buttonText),
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
            ),
          ],
        );
      },
    ),
  );
}
