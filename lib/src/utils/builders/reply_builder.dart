import 'package:nyxx_self/src/core/snowflake.dart';
import 'package:nyxx_self/src/core/message/message.dart';
import 'package:nyxx_self/src/internal/cache/cacheable.dart';
import 'package:nyxx_self/src/typedefs.dart';
import 'package:nyxx_self/src/utils/builders/builder.dart';

/// Builder for replying to message
class ReplyBuilder extends Builder {
  /// Id of message you reply to
  final Snowflake messageId;

  /// True if reply should fail if target message does not exist
  final bool failIfNotExists;

  /// Constructs reply builder for given message in channel
  ReplyBuilder(this.messageId, [this.failIfNotExists = false]);

  /// Constructs message reply from given message
  factory ReplyBuilder.fromMessage(IMessage message, [bool failIfNotExists = false]) => ReplyBuilder(message.id, failIfNotExists);

  /// Constructs message reply from cacheable of message and channel
  factory ReplyBuilder.fromCacheable(Cacheable<Snowflake, IMessage> messageCacheable, [bool failIfNotExists = false]) =>
      ReplyBuilder(messageCacheable.id, failIfNotExists);

  @override
  RawApiMap build() => {"message_id": messageId.id.toString(), "fail_if_not_exists": failIfNotExists};
}
