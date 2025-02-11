// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:pos_shared_preferences/models/basic_item_history.dart';
import 'package:pos_shared_preferences/models/remote_support_ticket.dart';
import 'package:pos_shared_preferences/models/subscription_info.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_odoo_models.dart';
import 'package:shared_widgets/config/app_urls.dart';
import 'package:shared_widgets/shared_widgets/handle_exception_helper.dart';
import 'package:shared_widgets/shared_widgets/odoo_connection_helper.dart';
import 'remote_database_setting_repository.dart';

class RemoteDatabaseSettingService implements RemoteDatabaseSettingRepository {
  static late OdooClient odooClient;
  static late OdooSession odooSession;

  static Future instantiateOdooConnection({url, db, username, password}) async {
    try {
      odooClient = OdooClient(url ?? hudaUrl);
      odooSession = await odooClient.authenticate(
          db ?? "demo", username ?? "demo", password ?? "demo");
      // odooClient = OdooClient(url ?? hudaUrl);
      // odooSession = await odooClient.authenticate(
      //     db ?? "mydb", username ?? "admin", password ?? "123456");

      // odooClient = OdooClient(url ?? amalUrl2);
      // odooSession = await odooClient.authenticate(
      //     db ?? "mydb", username ?? "admin", password ?? "admin");

      // odooClient = OdooClient(url ?? sanaaUrl);
      // odooSession = await odooClient.authenticate(
      //     db ?? sanaaDB, username ?? sanaaAccountUserName, password ?? sanaaAccountPassword);

      // odooClient = OdooClient(url ?? remoteURL);
      // odooSession = await odooClient.authenticate(db ?? remotedB,
      //     username ?? remoteUsername, password ?? remotePassword);

      await SharedPr.setSessionId(
          sessionId: "session_id=${odooSession.id}"); // output OdooSession
      return true;
      // } on OdooException {
      //   if (kDebugMode) {
      //     print('OdooException');
      //   }
      //   return 'login_information_incorrect'.tr;
    } catch (e) {
      if (kDebugMode) {
        print('Exception### : ${e.toString()}');
      }
      return '${'failed_connect_server'.tr} - ${odooClient.baseURL}';
      // throw Exception('${'failed_connect_server'.tr} - ${odooClient.baseURL}');

      // return 'exception'.tr;
      // return '${'failed_connect_server'.tr} - ${odooClient.baseURL}';
    }
  }

  // ========================================== [ Cheack Key Login ] =============================================

  @override
  Future checkKeyLogin({
    required String loginKey,
  }) async {
    try {
      print("odoo clint ${odooClient}");
      dynamic result = await odooClient.callKw({
        'model': OdooModels.subscriptionDetails,
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['client_key', '=', loginKey]
          ],
        },
      });
      // print(result);
      // print(result);
      if (result is List && result.isEmpty) {
        return 'key_not_found'.tr;
      }
      var subscriptionInfo = SubscriptionInfo.fromJson(result.first);
      if (subscriptionInfo.subscriptionStatus) {
        result = subscriptionInfo;
      } else {
        result = "subscription_ended".tr;
      }
      return result;
    } catch (e) {
      return handleException(
          exception: e, navigation: false, methodName: "checkKeyLogin");
      // return e.toString().replaceFirst('Exception: ', '');
    }
  }

  // ========================================== [ Check Key Login ] =============================================

  // ========================================== [ Check Connection ] =============================================

  @override
  Future checkConnection(
      {required SubscriptionInfo databaseSettingModel}) async {
    try {
      http.Response resBody = await http.get(Uri.parse(
          '${databaseSettingModel.url}/web?db=${databaseSettingModel.db}'));
      if (resBody.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return handleException(
          exception: e, navigation: false, methodName: "checkConnection");
    }
  }

  // ========================================== [ Check Connection ] =============================================

  // ========================================== [ Send Ticket ] =============================================
  @override
  Future sendTicket(
      {required String subscriptionId,
      required String message,
      bool sendToMyCompany = true}) async {
    try {
      dynamic result;
      OdooClient client = odooClient;
      OdooSession? session = odooSession;
      // to amal serve local
      result = await odooClient.callKw({
        'model': OdooModels.serverSubscriptionSupportTicket,
        'method': 'create',
        'args': [
          RemoteSupportTicket(
                  subscriptionDetailId: SharedPr.subscriptionDetailsObj!.id!,
                  exceptionDetails: message,
                  posId: null,
                  userId: null)
              .toJson()
        ],
        'kwargs': {},
      });

      // if (sendToMyCompany) {

      // to qimamhd server
      if (OdooProjectOwnerConnectionHelper.odooSession != null) {
        client = OdooProjectOwnerConnectionHelper.odooClient;
        session = OdooProjectOwnerConnectionHelper.odooSession;
      } else {
        await instantiateOdooConnection(
            url: SharedPr.subscriptionDetailsObj!.url,
            db: SharedPr.subscriptionDetailsObj!.db,
            username: supportAccountUsername,
            password: supportAccountPassword);
        client = odooClient;
        session = odooSession;
      }
      result = await client.callKw({
        'model': OdooModels.posSupportTicket,
        'method': 'create',
        'args': [
          RemoteSupportTicket(
                  subscriptionDetailId: null,
                  exceptionDetails: message,
                  posId: SharedPr.currentPosObject?.id,
                  userId: SharedPr.chosenUserObj?.id ?? session?.userId)
              .toJson()
        ],
        'kwargs': {},
      });
      await instantiateOdooConnection();
      return result is int ? true : false;
    } catch (e) {
      return handleException(
          exception: e, navigation: false, methodName: "sendTicket");
    }
  }

  // ========================================== [ Send Ticket ] =============================================

  // ========================================== [ get Support Ticket ] =============================================
  @override
  Future<dynamic> getSupportTicket({bool sendToMyCompany = true}) async {
    try {
      List result;
      if (SharedPr.chosenUserObj?.id == null) {
        // from admin server
        result = await odooClient.callKw({
          'model': OdooModels.serverSubscriptionSupportTicket,
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              [
                'subscription_detail_id',
                '=',
                SharedPr.subscriptionDetailsObj!.id!
              ],
              ['stauts', '=', false],
              ['ticket_reply', '!=', ''],
            ],
            'fields': [],
            'order': 'id'
          },
        });
      } else {
        result = await OdooProjectOwnerConnectionHelper.odooClient.callKw({
          'model': OdooModels.posSupportTicket,
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['user_id', '=', SharedPr.chosenUserObj?.id],
              ['pos_id', '=', SharedPr.currentPosObject?.id],
              ['stauts', '=', false],
              ['ticket_reply', '!=', ''],
            ],
            'fields': [],
            'order': 'id'
          },
        });
      }

      return result.isEmpty
          ? null
          : result
              .map((item) =>
                  RemoteSupportTicket.fromJson(item, fromLocal: false))
              .toList();
    } catch (e) {
      print("======================handleException $e");
      return handleException(
          exception: e, navigation: false, methodName: "getSupportTicket");
    }
  }
// ========================================== [ get Support Ticket ] =============================================

  // ========================================== [ get Support Ticket ] =============================================
  @override
  Future<dynamic> updateStautSupportTicket(
      {required int supportTicketId, bool sendToMyCompany = true}) async {
    try {
      if (SharedPr.chosenUserObj?.id != null) {
        return await OdooProjectOwnerConnectionHelper.odooClient.callKw({
          'model': OdooModels.posSupportTicket,
          'method': 'write',
          'args': [
            supportTicketId,
            {
              'stauts': true,
            },
          ],
          'kwargs': {},
        });
      } else {
        return await odooClient.callKw({
          'model': OdooModels.serverSubscriptionSupportTicket,
          'method': 'write',
          'args': [
            supportTicketId,
            {
              'stauts': true,
            },
          ],
          'kwargs': {},
        });
      }
    } catch (e) {
      return handleException(
          exception: e,
          navigation: false,
          methodName: "updateStautSupportTicket");
    }
  }
// ========================================== [ get Support Ticket ] =============================================

  // ========================================== [ get Support Ticket ] =============================================

  Future<dynamic> getIsDeletedOrIsAddedItemsFromHistory() async {
    try {
      var result = await OdooProjectOwnerConnectionHelper.odooClient.callKw({
        'model': OdooModels.itemsHistory,
        'method': 'get_is_deleted_or_is_added_items_from_history',
        'args': [
          <int>[SharedPr.currentPosObject!.id!]
        ],
        'kwargs': {},
      });
      return result.isEmpty || result == null
          ? <BasicItemHistory>[]
          : (result as List).map((e) => BasicItemHistory.fromJson(e)).toList();
    } catch (e) {
      return handleException(
          exception: e,
          navigation: false,
          methodName: "getIsDeletedOrIsAddedItemsFromHistory");
    }
  }
// ========================================== [ get Support Ticket ] =============================================
}
