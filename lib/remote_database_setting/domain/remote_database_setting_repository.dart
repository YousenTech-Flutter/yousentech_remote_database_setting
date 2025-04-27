
import 'package:pos_shared_preferences/models/subscription_info.dart';

abstract class RemoteDatabaseSettingRepository {
  Future checkKeyLogin({required String loginKey});
  Future checkConnection({required SubscriptionInfo databaseSettingModel});
  Future sendTicket({required String subscriptionId, required String message});
  Future<dynamic> getSupportTicket();
  Future<dynamic> updateStautSupportTicket({required int supportTicketId});
}


