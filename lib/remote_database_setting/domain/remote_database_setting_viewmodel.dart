import 'dart:io';

import 'package:get/get.dart';
import 'package:pos_shared_preferences/models/subscription_info.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/utils/response_result.dart';
import 'remote_database_setting_service.dart';

class DatabaseSettingController extends GetxController {
  static DatabaseSettingController? _instance;
  var isLoading = false.obs;
  late RemoteDatabaseSettingService databaseSettingService;

  DatabaseSettingController._() {
    databaseSettingService = RemoteDatabaseSettingService();
  }

  static DatabaseSettingController getInstance() {
    _instance ??= DatabaseSettingController._();
    return _instance!;
  }

  // ========================================== [ checkDatabase ] =============================================
  /*
  cheack key login
    if correct return RemoteDatabaseSetting
      cheack Connection to db and  url
        if true save to local
        if false retern Invalid Database name or URL , please submit a ticket for Server verification
    if Subscription ended return string
    if SocketException return You Don't have an Internet Connection
    else return Failed to connect with server
  */
  Future<ResponseResult> checkDatabase(String loginKey) async {
    isLoading.value = true;
    dynamic result;
    var databaseSettingResult =
        await databaseSettingService.checkKeyLogin(loginKey: loginKey);
    // print(databaseSettingResult);
    if (databaseSettingResult is SubscriptionInfo) {
      await SharedPr.setRemoteDatabaseInfo(
          subscriptionInfo: databaseSettingResult);

      var checkConnectionResult = await RemoteDatabaseSettingService()
          .checkConnection(databaseSettingModel: databaseSettingResult);

      if (checkConnectionResult is bool && checkConnectionResult == true) {
        result = ResponseResult(status: true);
      } else {
        result = ResponseResult(
            data: databaseSettingResult.subscriptionId,
            message: "send_ticket_message".tr);

        databaseSettingResult
          ..db
          ..url = null;
        await SharedPr.setRemoteDatabaseInfo(
            subscriptionInfo: databaseSettingResult);
      }
    } else if (databaseSettingResult is String) {
      result = ResponseResult(message: databaseSettingResult);
    } else if (databaseSettingResult is SocketException) {
      result = ResponseResult(message: "no_connection".tr);
    } else {
      result = ResponseResult(message: databaseSettingResult.toString());
    }
    isLoading.value = false;
    return result!;
  }

  // ========================================== [ checkDatabase ] =============================================

  // ========================================== [ Send Ticket ] =============================================
  /*
  send Ticket with subscriptionId
    if true its send successfully
    if false Failed to connect with server
    else return error catch message
  */
  Future<ResponseResult> sendTicket(
      {required String subscriptionId,
      required String message,
      bool sendToMyCompany = true}) async {
    isLoading.value = true;
    dynamic result;
    var resultSendTicket = await databaseSettingService.sendTicket(
        subscriptionId: subscriptionId,
        message: message,
        sendToMyCompany: sendToMyCompany);
    if (resultSendTicket is bool) {
      if (resultSendTicket) {
        // SharedPr.setStatus(state: true);
        // RemoteDatabaseSetting remoteDatabaseSetting=RemoteDatabaseSetting(
        //  url: SharedPr.url!,
        //  db: SharedPr.db!,
        //  clientKey:SharedPr.clientKey!,
        //  clientId:SharedPr.clientId!,
        //  subscriptionId: SharedPr.subscriptionId!
        // );
        //var addSubscriptionResult =   await databaseSettingService.addSubscriptionDetail(remoteDatabaseSetting: remoteDatabaseSetting)
        // if(addSubscriptionResult is int){
        //   result = ResponseResult(status: true);
        // }
        // else{
        //   result = ResponseResult(message: addSubscriptionResult);
        // }
        result = ResponseResult(status: true);
        // for listen notification

        // TODO: Initialize background tasks after build notfiction package
        // BackgroundTask.init();

        // SharedPr.setNotificationObj(notificationHelperObj:NotificationHelper(accountLock: true, sendTicket: true));
      } else {
        result = ResponseResult(message: "failed_connect_server".tr);
      }
    } else {
      result = ResponseResult(message: resultSendTicket);
    }

    isLoading.value = false;
    return result;
  }

// ========================================== [ Send Ticket ] =============================================

  // ========================================== [ get Support Ticket ] =============================================
  Future<ResponseResult> getSupportTicket() async {
    var supportTicket = await databaseSettingService.getSupportTicket();
    // if (supportTicket is RemoteSupportTicket) {
    //   return ResponseResult(status: true, data: supportTicket);
    // }
    if (supportTicket is List) {
      return ResponseResult(status: true, data: supportTicket);
    } else if (supportTicket == null) {
      return ResponseResult(status: false, message: "no_respons_ticket".tr);
    } else if (supportTicket is SocketException) {
      return ResponseResult(status: false, message: "no_connection".tr);
    } else {
      return ResponseResult(message: supportTicket);
    }
  }

// ========================================== [ get Support Ticket ] =============================================
  // ========================================== [ get Support Ticket ] =============================================
  Future<ResponseResult> updateStautSupportTicket(
      {required int supportTicketId}) async {
    var stauts = await databaseSettingService.updateStautSupportTicket(
        supportTicketId: supportTicketId);
    if (stauts is bool) {
      return ResponseResult(status: true, data: stauts);
    } else if (stauts is SocketException) {
      return ResponseResult(message: "no_connection".tr);
    } else {
      return ResponseResult(message: stauts);
    }
  }
// ========================================== [ get Support Ticket ] =============================================

  // ========================================== [ get Support Ticket ] =============================================
  Future<ResponseResult> getIsDeletedOrIsAddedItemsFromHistory() async {
    var result =
        await databaseSettingService.getIsDeletedOrIsAddedItemsFromHistory();
    if (result is List) {
      return ResponseResult(status: true, data: result);
    } else {
      return ResponseResult(message: result);
    }
  }
}
