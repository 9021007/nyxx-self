import 'package:nyxx_self/src/nyxx.dart';
import 'package:nyxx_self/src/core/user/user.dart';
import 'package:nyxx_self/src/typedefs.dart';

abstract class IBan {
  /// Reason of ban
  String? get reason;

  /// Banned user
  IUser get user;
}

/// Ban object. Has attached reason of ban and user who was banned.
class Ban implements IBan {
  /// Reason of ban
  @override
  late final String? reason;

  /// Banned user
  @override
  late final IUser user;

  /// Creates an instance of [Ban]
  Ban(RawApiMap raw, INyxx client) {
    reason = raw["reason"] as String;
    user = User(client, raw["user"] as RawApiMap);
  }
}
