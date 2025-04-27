import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pos_shared_preferences/models/notification_helper_model.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:shared_widgets/config/app_enums.dart';
import 'package:shared_widgets/config/app_styles.dart';
import 'package:shared_widgets/shared_widgets.dart';
import 'package:shared_widgets/shared_widgets/app_loading.dart';
import 'package:shared_widgets/shared_widgets/app_snack_bar.dart';
import 'package:shared_widgets/shared_widgets/app_text_field.dart';
import '../domain/remote_database_setting_viewmodel.dart';

TextEditingController exceptionDetails = TextEditingController();

DatabaseSettingController databaseSettingController =
    Get.put(DatabaseSettingController.getInstance());

final _formKey = GlobalKey<FormState>();
String? errorMessage;
int countErrors = 0;

supportTicketDialog(
    {IconData? icon,
    required BuildContext context,
    String? message,
    void Function()? onPressed}) {
  exceptionDetails.text = message ?? "";
  CustomDialog.getInstance().dialogcontent(
    context: context,
    content: Container(
      height: 280.h,
      width: 100.w,
      padding: EdgeInsets.all(20.r),
      child: Obx(
        () => IgnorePointer(
          ignoring: databaseSettingController.isLoading.value,
          child: Stack(
            children: [
              Column(
                children: [
                  Text('support_ticket'.tr,
                      textAlign: TextAlign.center,
                      style: AppStyle.textStyle(
                          fontSize: 12.r,
                          fontWeight: FontWeight.bold,
                          color: AppColor.black)),
                  Icon(
                    icon ?? Icons.airplane_ticket_outlined,
                    color: AppColor.amberLight,
                    // messageTypesIcon[dialogType]!.last as Color,
                    size: 35.r,
                  ),
                  SizedBox(
                    height: 5.r,
                  ),

                  Text('exception_details_message'.tr,
                      textAlign: TextAlign.center,
                      style: AppStyle.textStyle(
                          fontSize: 8.r,
                          fontWeight: FontWeight.w500,
                          color: AppColor.lavenderGray)),
                  SizedBox(
                    height: 10.r,
                  ),
                  // if(showTextField)
                  Center(
                    child: Container(
                      // width: Get.width * 0.4,
                      width: 100.w,
                      // height: Get.height * 0.5,
                      padding: const EdgeInsets.all(8),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ContainerTextField(
                              // maxLength: 4,
                              maxLines: 6,
                              enabled: message == null ? true : false,
                              isAddOrEdit: true,
                              borderColor: AppColor.silverGray,
                              iconcolor: AppColor.silverGray,
                              hintcolor: AppColor.silverGray,
                              borderRadius: 5.r,
                              fontSize: 10.r,
                              textAlign: TextAlign.start,
                              controller: exceptionDetails,
                              // prefixIcon: Icon(
                              //   Icons.key,
                              //   size: 4.sp,
                              //   color: AppColor.black,
                              // ),
                              hintText: 'exception_details'.tr,
                              labelText: 'exception_details'.tr,

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  errorMessage = 'required_message_f'.trParams(
                                      {'field_name': 'exception_details'.tr});
                                  countErrors++;
                                  return "";
                                }
                                return null;
                              },
                            ),
                            // SizedBox(
                            //   height: Get.width * 0.01,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.r,
                  ),
                  SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ButtonElevated(
                          text: message != null ? 'yes'.tr : 'send_ticket'.tr,
                          backgroundColor: AppColor.cyanTeal,
                          height: 0.04.sh,
                          borderRadius: 5.r,
                          textStyle: AppStyle.textStyle(
                              color: AppColor.white,
                              fontSize: 10.r,
                              fontWeight: FontWeight.bold),
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
                                          message: exceptionDetails.text)
                                      .then((value) {
                                    if (value.status) {
                                      SharedPr.setNotificationObj(
                                          notificationHelperObj:
                                              NotificationHelper(
                                                  sendTicket: true));
                                      Get.back();
                                      appSnackBar(
                                          message: 'success_send_ticket'.tr,
                                          messageType: MessageTypes.success);
                                      exceptionDetails.clear();
                                    } else {
                                      appSnackBar(
                                        message: value.message!,
                                      );
                                      exceptionDetails.clear();
                                    }
                                  });
                                } else {
                                  // if (kDebugMode) {
                                  //   // print(countErrors);
                                  // }
                                  appSnackBar(
                                    message: countErrors > 1
                                        ? 'enter_required_info'.tr
                                        : errorMessage!,
                                  );
                                }
                              },
                        ),
                        SizedBox(
                          height: 10.r,
                        ),
                        ButtonElevated(
                            text: 'cancel'.tr,
                            height: 0.04.sh,
                            borderColor: AppColor.paleAqua,
                            borderRadius: 5.r,
                            textStyle: AppStyle.textStyle(
                                color: AppColor.slateGray,
                                fontSize: 10.r,
                                fontWeight: FontWeight.bold),
                            onPressed: () async {
                              Get.back();
                            }),
                      ],
                    ),
                  )
                ],
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

  // CustomDialog.getInstance().dialog(
  //   icon: Icons.airplane_ticket_outlined,
  //   title: 'support_ticket',
  //   content: Center(
  //     child: Container(
  //       // width: Get.width * 0.4,
  //       width: 100.w,
  //       // height: Get.height * 0.5,
  //       padding: const EdgeInsets.all(8),
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ContainerTextField(
  //               // maxLength: 4,
  //               maxLines: 6,
  //               width: 100.w,
  //               isAddOrEdit: true,
  //               borderColor: AppColor.silverGray,
  //               iconcolor: AppColor.silverGray,
  //               hintcolor: AppColor.silverGray,
  //               borderRadius: 5.r,
  //               textAlign: TextAlign.start,
  //               controller: exceptionDetails,
  //               // prefixIcon: Icon(
  //               //   Icons.key,
  //               //   size: 4.sp,
  //               //   color: AppColor.black,
  //               // ),
  //               hintText: 'exception_details'.tr,
  //               labelText: 'exception_details'.tr,

  //               validator: (value) {
  //                 if (value == null || value.isEmpty) {
  //                   errorMessage = 'required_message_f'
  //                       .trParams({'field_name': 'exception_details'.tr});
  //                   countErrors++;
  //                   return "";
  //                 }
  //                 return null;
  //               },
  //             ),
  //             // SizedBox(
  //             //   height: Get.width * 0.01,
  //             // ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   ),
  //   primaryButtonText: 'send_ticket'.tr,
  //   buttonwidth: 97.w,
  //   onPressed: () async {
  //     countErrors = 0;
  //     if (_formKey.currentState!.validate()) {
  //       await databaseSettingController
  //           .sendTicket(
  //               subscriptionId:
  //                   SharedPr.subscriptionDetailsObj!.subscriptionId.toString(),
  //               message: exceptionDetails.text)
  //           .then((value) {
  //         if (value.status) {
  //           SharedPr.setNotificationObj(
  //               notificationHelperObj: NotificationHelper(sendTicket: true));
  //           Get.back();
  //           appSnackBar(
  //               message: 'success_send_ticket'.tr,
  //               messageType: MessageTypes.success);
  //           exceptionDetails.clear();
  //         } else {
  //           appSnackBar(
  //             message: value.message!,
  //           );
  //           exceptionDetails.clear();
  //         }
  //       });
  //     } else {
  //       // if (kDebugMode) {
  //       //   // print(countErrors);
  //       // }
  //       appSnackBar(
  //         message: countErrors > 1 ? 'enter_required_info'.tr : errorMessage!,
  //       );
  //     }
  //   },
  //   message: 'exception_details_message'.tr,
  // );
}
