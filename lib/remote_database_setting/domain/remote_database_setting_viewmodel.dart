import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:pos_shared_preferences/models/subscription_info.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/background_task.dart';
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
  /// ================================================ [ CHECK DATABASE CONNECTION ] =================================================
  /// Functionality:
  /// - Verifies the provided login key and checks database connection settings.
  /// - Stores database information in local storage if the key is valid.
  /// - Determines whether a remote database connection is possible.
  ///
  /// Process:
  /// 1. Calls `databaseSettingService.checkKeyLogin` to validate the login key.
  /// 2. If the result is a valid `SubscriptionInfo`:
  ///    - Stores the remote database information in local storage.
  ///    - Calls `RemoteDatabaseSettingService().checkConnection` to test connectivity.
  ///      - If the connection is successful, returns a success response.
  ///      - If the connection fails, prompts the user to submit a support ticket.
  /// 3. If the result is a failure message (`String`), returns an error response.
  /// 4. If a `SocketException` occurs (no internet connection), returns a network error message.
  /// 5. Updates the `isLoading` flag appropriately throughout the process.
  ///
  /// Input:
  /// - `loginKey`: A unique key used to verify and access the database settings.
  ///
  /// Raises:
  /// - None explicitly.
  ///
  /// Returns:
  /// - `ResponseResult`: Indicates whether the process succeeded, failed, or requires user action.
  /// ==============================================================================================================================

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
       var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return ResponseResult(message: "no_connection".tr);
      }
      if (databaseSettingResult.toString().contains("timeout period has expired") ||
          databaseSettingResult
              .toString()
              .contains("The remote computer refused the network connection") || databaseSettingResult.toString().contains("Failed to connect with server") ) {
        return ResponseResult(message: 'failed_connect_server'.tr);
      }
      return ResponseResult(message: "no_connection".tr);
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
  /// ================================================ [ SEND SUPPORT TICKET ] =================================================
  /// Functionality:
  /// - Sends a support ticket to the database service.
  /// - Allows the user to send the ticket to their company or service provider.
  /// - Handles responses to determine whether the ticket was successfully submitted.
  ///
  /// Process:
  /// 1. Calls `databaseSettingService.sendTicket` with the provided subscription ID, message, and target recipient.
  /// 2. If the result is a `bool`:
  ///    - If `true`, the ticket was sent successfully:
  ///      - Initializes background tasks for notification handling.
  ///      - Returns a successful `ResponseResult`.
  ///    - If `false`, returns a failure message indicating a server connection issue.
  /// 3. If the result is not a `bool`, it is treated as an error message and returned as a `ResponseResult`.
  /// 4. Updates the `isLoading` flag to indicate the process has completed.
  ///
  /// Input:
  /// - `subscriptionId`: The ID of the user's subscription.
  /// - `message`: The message content for the support ticket.
  /// - `sendToMyCompany` (optional, default: `true`): Determines whether the ticket is sent to the user's company.
  ///
  /// Raises:
  /// - None explicitly.
  ///
  /// Returns:
  /// - `ResponseResult`: Indicates whether the ticket submission was successful or failed.
  /// ==========================================================================================================================

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
        BackgroundTask.init();
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
  /// ================================================ [ FETCH SUPPORT TICKETS ] =================================================
  /// Functionality:
  /// - Retrieves a list of support tickets from the database service.
  /// - Handles different response types to determine the appropriate outcome.
  ///
  /// Process:
  /// 1. Calls `databaseSettingService.getSupportTicket()` to fetch support tickets.
  /// 2. If the result is a `List`, it is returned as a successful `ResponseResult` with ticket data.
  /// 3. If the result is `null`, returns a failure message indicating no response for support tickets.
  /// 4. If the result is a `SocketException`, returns a failure message indicating no internet connection.
  /// 5. If the result is of any other type, it is treated as an error message and returned as a `ResponseResult`.
  ///
  /// Input:
  /// - None.
  ///
  /// Raises:
  /// - None explicitly.
  ///
  /// Returns:
  /// - `ResponseResult`: Contains the status and fetched ticket data if successful, or an error message if failed.
  /// ==========================================================================================================================

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
       var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return ResponseResult(message: "no_connection".tr);
      }
      if (supportTicket.toString().contains("timeout period has expired") ||
          supportTicket
              .toString()
              .contains("The remote computer refused the network connection") || supportTicket.toString().contains("Failed to connect with server") ) {
        return ResponseResult(message: 'failed_connect_server'.tr);
      }
      return ResponseResult(message: "no_connection".tr);
    } else {
      return ResponseResult(message: supportTicket);
    }
  }

// ========================================== [ get Support Ticket ] =============================================
  // ========================================== [ get Support Ticket ] =============================================
  /// =========================================== [ UPDATE SUPPORT TICKET STATUS ] ===========================================
  /// Functionality:
  /// - Updates the status of a specific support ticket in the system.
  ///
  /// Process:
  /// 1. Calls `databaseSettingService.updateStautSupportTicket()` with the provided `supportTicketId`.
  /// 2. If the response is a `bool`, it returns a successful `ResponseResult` with the status update.
  /// 3. If the response is a `SocketException`, it returns a failure message indicating no internet connection.
  /// 4. If the response is of any other type, it is treated as an error message and returned as a `ResponseResult`.
  ///
  /// Input:
  /// - `supportTicketId`: The ID of the support ticket to update.
  ///
  /// Raises:
  /// - None explicitly.
  ///
  /// Returns:
  /// - `ResponseResult`: Contains the success status and updated status if successful, or an error message if failed.
  /// ========================================================================================================================

  Future<ResponseResult> updateStautSupportTicket(
      {required int supportTicketId}) async {
    var stauts = await databaseSettingService.updateStautSupportTicket(
        supportTicketId: supportTicketId);
    if (stauts is bool) {
      return ResponseResult(status: true, data: stauts);
    } else if (stauts is SocketException) {
       var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return ResponseResult(message: "no_connection".tr);
      }
      if (stauts.toString().contains("timeout period has expired") ||
          stauts
              .toString()
              .contains("The remote computer refused the network connection") || stauts.toString().contains("Failed to connect with server") ) {
        return ResponseResult(message: 'failed_connect_server'.tr);
      }
      return ResponseResult(message: "no_connection".tr);
    } else {
      return ResponseResult(message: stauts);
    }
  }

  /// =========================================== [ UPDATE SUPPORT TICKET STATUS ] ===========================================

// ========================================== [ get Support Ticket ] =============================================

  // ========================================== [ get Support Ticket ] =============================================
  /// ============================= [ FETCH DELETED OR ADDED ITEMS FROM HISTORY ] =============================
  /// Functionality:
  /// - Retrieves a list of items that have been either deleted or added from the system history.
  ///
  /// Process:
  /// 1. Calls `databaseSettingService.getIsDeletedOrIsAddedItemsFromHistory()` to fetch the item history.
  /// 2. If the result is a `List`, it returns a successful `ResponseResult` containing the retrieved data.
  /// 3. If the result is of any other type, it returns a failure message indicating an issue with fetching data.
  ///
  /// Input:
  /// - None.
  ///
  /// Raises:
  /// - None explicitly.
  ///
  /// Returns:
  /// - `ResponseResult`: Contains the success status and a list of deleted/added items if successful, or an error message if failed.
  /// =========================================================================================================

  Future<ResponseResult> getIsDeletedOrIsAddedItemsFromHistory() async {
    var result =
        await databaseSettingService.getIsDeletedOrIsAddedItemsFromHistory();
    if (result is List) {
      return ResponseResult(status: true, data: result);
    } else {
      return ResponseResult(message: result);
    }
  }

  /// ============================= [ FETCH DELETED OR ADDED ITEMS FROM HISTORY ] =============================
}
