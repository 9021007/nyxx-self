import 'package:nyxx_self/src/core/audit_logs/audit_log_entry.dart';
import 'package:nyxx_self/src/core/channel/thread_channel.dart';
import 'package:nyxx_self/src/core/guild/auto_moderation.dart';
import 'package:nyxx_self/src/core/guild/scheduled_event.dart';
import 'package:nyxx_self/src/core/guild/webhook.dart';
import 'package:nyxx_self/src/core/snowflake.dart';
import 'package:nyxx_self/src/core/user/user.dart';
import 'package:nyxx_self/src/nyxx.dart';
import 'package:nyxx_self/src/typedefs.dart';

abstract class IAuditLog {
  /// Map of webhooks found in the audit log.
  late final Map<Snowflake, IWebhook> webhooks;

  /// Map of users found in the audit log.
  late final Map<Snowflake, IUser> users;

  /// Map of audit log entries.
  late final Map<Snowflake, IAuditLogEntry> entries;

  /// Map of auto moderation rules referenced in the audit log.
  late final Map<Snowflake, IAutoModerationRule> autoModerationRules;

  /// Map of guild scheduled events referenced in the audit log.
  late final Map<Snowflake, IGuildEvent> events;

  /// Map of threads referenced in the audit log.
  late final Map<Snowflake, IThreadChannel> threads;

  /// Filters audit log by [users]
  Iterable<IAuditLogEntry> filter(bool Function(IAuditLogEntry) test);
}

/// Whenever an admin action is performed on the API, an entry is added to the respective guild's audit log.
///
/// [Look here for more](https://discordapp.com/developers/docs/resources/audit-log)
class AuditLog implements IAuditLog {
  /// Map of webhooks found in the audit log
  @override
  late final Map<Snowflake, IWebhook> webhooks;

  /// Map of users found in the audit log
  @override
  late final Map<Snowflake, IUser> users;

  /// Map of audit log entries
  @override
  late final Map<Snowflake, IAuditLogEntry> entries;

  /// Map of auto moderation rules referenced in the audit log
  @override
  late final Map<Snowflake, IAutoModerationRule> autoModerationRules;

  /// Map of guild scheduled events referenced in the audit log
  @override
  late final Map<Snowflake, IGuildEvent> events;

  /// Map of threads referenced in the audit log.
  @override
  late final Map<Snowflake, IThreadChannel> threads;

  /// Creates an instance of [AuditLog]
  AuditLog(RawApiMap raw, INyxx client) {
    webhooks = {};
    users = {};
    entries = {};
    autoModerationRules = {};
    events = {};
    threads = {};

    raw["webhooks"].forEach((o) {
      webhooks[Snowflake(o["id"])] = Webhook(o as RawApiMap, client);
    });

    raw["users"].forEach((o) {
      users[Snowflake(o["id"])] = User(client, o as RawApiMap);
    });

    raw["audit_log_entries"].forEach((o) {
      entries[Snowflake(o["id"])] = AuditLogEntry(o as RawApiMap, client);
    });

    raw['auto_moderation_rules'].forEach((o) {
      autoModerationRules[Snowflake(o['id'])] = AutoModerationRule(o as RawApiMap, client);
    });

    raw['guild_scheduled_events'].forEach((o) {
      events[Snowflake(o['id'])] = GuildEvent(o as RawApiMap, client);
    });

    raw['threads'].forEach((o) {
      threads[Snowflake(o['id'])] = ThreadChannel(client, o as RawApiMap);
    });
  }

  /// Filters audit log by [entries]
  @override
  Iterable<IAuditLogEntry> filter(bool Function(IAuditLogEntry) test) => entries.values.where(test);
}
