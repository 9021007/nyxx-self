import 'package:nyxx_self/src/nyxx.dart';
import 'package:nyxx_self/src/core/snowflake.dart';
import 'package:nyxx_self/src/core/channel/cacheable_text_channel.dart';
import 'package:nyxx_self/src/core/channel/text_channel.dart';
import 'package:nyxx_self/src/core/guild/guild.dart';
import 'package:nyxx_self/src/core/user/member.dart';
import 'package:nyxx_self/src/core/user/user.dart';
import 'package:nyxx_self/src/internal/cache/cacheable.dart';
import 'package:nyxx_self/src/typedefs.dart';

abstract class ITypingEvent {
  /// The channel that the user is typing in.
  CacheableTextChannel<ITextChannel> get channel;

  /// The user that is typing.
  Cacheable<Snowflake, IUser> get user;

  /// The member who started typing if this happened in a guild
  IMember? get member;

  /// Timestamp when the user started typing
  DateTime get timestamp;

  /// Reference to guild where typing occurred
  Cacheable<Snowflake, IGuild>? get guild;
}

/// Sent when a user starts typing.
class TypingEvent implements ITypingEvent {
  /// The channel that the user is typing in.
  @override
  late final CacheableTextChannel<ITextChannel> channel;

  /// The user that is typing.
  @override
  late final Cacheable<Snowflake, IUser> user;

  /// The member who started typing if this happened in a guild
  @override
  late final IMember? member;

  /// Timestamp when the user started typing
  @override
  late final DateTime timestamp;

  /// Reference to guild where typing occurred
  @override
  late final Cacheable<Snowflake, IGuild>? guild;

  /// Creates an instance of [TypingEvent]
  TypingEvent(RawApiMap raw, INyxx client) {
    channel = CacheableTextChannel(client, Snowflake(raw["d"]["channel_id"]));
    user = UserCacheable(client, Snowflake(raw["d"]["user_id"]));
    timestamp = DateTime.fromMillisecondsSinceEpoch(raw["d"]["timestamp"] as int);

    if (raw["d"]["guild_id"] != null) {
      guild = GuildCacheable(client, Snowflake(raw["d"]["guild_id"]));
    } else {
      guild = null;
    }

    if (raw["d"]["member"] == null) {
      member = null;
      return;
    }

    member = Member(client, raw["d"]["member"] as RawApiMap, guild!.id);
    if (client.cacheOptions.memberCachePolicyLocation.event && client.cacheOptions.memberCachePolicy.canCache(member!)) {
      member!.guild.getFromCache()?.members[member!.id] = member!;
    }
  }
}
