import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_shared_preferences/models/notification_helper_model.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:remote_database_setting/remote_database_setting/domain/remote_database_setting_viewmodel.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:shared_widgets/config/app_enums.dart';
import 'package:shared_widgets/config/app_styles.dart';
import 'package:shared_widgets/shared_widgets/app_button.dart';
import 'package:shared_widgets/shared_widgets/app_dialog.dart';
import 'package:shared_widgets/shared_widgets/app_loading.dart';
import 'package:shared_widgets/shared_widgets/app_snack_bar.dart';
import 'package:shared_widgets/shared_widgets/app_text_field.dart';
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
        return SizeProvider(
          baseSize: Size(context.setWidth(454.48), context.setHeight(280)),
          width: context.setWidth(454.48),
          height: context.setHeight(280),
          child: Container(
            height: context.setHeight(280),
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
                        children: [
                          Text(
                            'support_ticket'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: SharedPr.isDarkMode!
                                  ? Colors.white
                                  : const Color(0xFF2E2E2E),
                              fontSize: context.setSp(20.03),
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Icon(
                            icon ?? Icons.airplane_ticket_outlined,
                            color: AppColor.amberLight,
                            size: context.setMinSize(40),
                          ),
                          SizedBox(height: context.setHeight(10)),
                          Text(
                            'exception_details_message'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: SharedPr.isDarkMode!
                                  ? const Color(0xFFB1B3BC)
                                  : const Color(0xFF9F9FA5),
                              fontSize: context.setSp(14.42),
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: context.setHeight(10)),
                          ContainerTextField(
                            controller: exceptionDetails,
                            keyboardType: TextInputType.text,
                            width: context.screenWidth,
                            height: context.setHeight(51.28),
                            fontSize: context.setSp(11.22),
                            maxLines: 6,
                            enabled: message == null ? true : false,
                            isAddOrEdit: true,
                            borderColor: !SharedPr.isDarkMode!
                                ? const Color(
                                    0xFFC2C3CB,
                                  )
                                : null,
                            fillColor: !SharedPr.isDarkMode!
                                ? Colors.white.withValues(
                                    alpha: 0.43,
                                  )
                                : const Color(
                                    0xFF2B2B2B,
                                  ),
                            hintcolor: !SharedPr.isDarkMode!
                                ? const Color(
                                    0xFFC2C3CB,
                                  )
                                : const Color(
                                    0xFFC2C3CB,
                                  ),
                            color: !SharedPr.isDarkMode!
                                ? const Color(
                                    0xFFC2C3CB,
                                  )
                                : const Color(
                                    0xFFC2C3CB,
                                  ),
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
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ButtonElevated(
                                text: message != null
                                    ? 'yes'.tr
                                    : 'send_ticket'.tr,
                                backgroundColor: AppColor.cyanTeal,
                                height: context.setHeight(35),
                                width: context.setWidth(180),
                                borderRadius: context.setMinSize(5),
                                textStyle: AppStyle.textStyle(
                                  color: AppColor.white,
                                  fontSize: context.setSp(12),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Tajawal',
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
                              ButtonElevated(
                                text: 'cancel'.tr,
                                height: context.setHeight(35),
                                width: context.setWidth(180),
                                borderColor: AppColor.paleAqua,
                                borderRadius: context.setMinSize(5),
                                textStyle: AppStyle.textStyle(
                                  color: AppColor.slateGray,
                                  fontSize: context.setSp(12),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Tajawal',
                                ),
                                onPressed: () async {
                                  Get.back();
                                },
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
        );
      },
    ),
  );
}
