import 'package:nyxx_self/src/core/channel/text_channel.dart';
import 'package:nyxx_self/src/core/guild/auto_moderation.dart';
import 'package:nyxx_self/src/core/guild/status.dart';
import 'package:nyxx_self/src/core/permissions/permissions.dart';
import 'package:nyxx_self/src/core/snowflake.dart';
import 'package:nyxx_self/src/core/user/presence.dart';
import 'package:nyxx_self/src/internal/cache/cacheable.dart';
import 'package:nyxx_self/src/utils/builders/attachment_builder.dart';
import 'package:nyxx_self/src/utils/builders/auto_moderation_builder.dart';
import 'package:nyxx_self/src/utils/builders/channel_builder.dart';
import 'package:nyxx_self/src/utils/builders/embed_builder.dart';
import 'package:nyxx_self/src/utils/builders/forum_thread_builder.dart';
import 'package:nyxx_self/src/utils/builders/member_builder.dart';
import 'package:nyxx_self/src/utils/builders/message_builder.dart';
import 'package:nyxx_self/src/utils/builders/permissions_builder.dart';
import 'package:nyxx_self/src/utils/builders/presence_builder.dart';
import 'package:nyxx_self/src/utils/builders/reply_builder.dart';
import 'package:nyxx_self/src/utils/builders/sticker_builder.dart';
import 'package:nyxx_self/src/utils/builders/thread_builder.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../mocks/member.mock.dart';
import '../mocks/message.mock.dart';
import '../mocks/nyxx_rest.mock.dart';

main() {
  test("ThreadBuilder", () {
    final publicBuilder = ThreadBuilder('test name')
      ..archiveAfter = ThreadArchiveTime.threeDays
      ..private = false;
    expect(publicBuilder.build(), equals({"auto_archive_duration": ThreadArchiveTime.threeDays.value, "name": 'test name', "type": 11}));

    final privateBuilder = ThreadBuilder("second name")..private = true;
    expect(privateBuilder.build(), equals({"name": 'second name', "type": 12}));
  });

  test('StickerBuilder', () {
    final builder = StickerBuilder(file: AttachmentBuilder.bytes([], 'foo'))
      ..name = "this is name"
      ..description = "this is description"
      ..tags = "tags";

    expect(builder.build(), equals({"name": "this is name", "description": "this is description", "tags": "tags", 'file': 'data:image/png;base64,'}));
  });

  test("ReplyBuilder", () {
    final basicBuilder = ReplyBuilder(Snowflake.zero());
    expect(basicBuilder.build(), equals({"message_id": '0', "fail_if_not_exists": false}));

    final messageBuilder = ReplyBuilder.fromMessage(MockMessage({"content": "content"}, Snowflake(123)));
    expect(messageBuilder.build(), equals({"message_id": '123', "fail_if_not_exists": false}));

    final messageCacheable = MessageCacheable(NyxxRestEmptyMock(), Snowflake(123), ChannelCacheable<ITextChannel>(NyxxRestEmptyMock(), Snowflake(456)));
    final cacheableBuilder = ReplyBuilder.fromCacheable(messageCacheable, true);
    expect(cacheableBuilder.build(), equals({"message_id": '123', "fail_if_not_exists": true}));
  });

  group("channel builder", () {
    test('ChannelBuilder', () {
      final builder = TextChannelBuilder.create("test");
      builder.permissionOverrides = [PermissionOverrideBuilder.from(0, Snowflake.zero(), Permissions.empty())];

      final expectedResult = {
        'permission_overwrites': [
          {'allow': "0", 'deny': "1649267441663", 'id': '0', 'type': 0}
        ],
        'type': 0,
        'name': 'test'
      };
      expect(builder.build(), expectedResult);
    });
  });

  group('presence_builder.dart', () {
    test('PresenceBuilder', () {
      final activityBuilder = ActivityBuilder.game("test game name");

      final ofBuilder = PresenceBuilder.of(status: UserStatus.dnd, activity: activityBuilder);
      expect(
          ofBuilder.build(),
          equals({
            'status': UserStatus.dnd.toString(),
            'activities': [
              {
                "name": "test game name",
                "type": ActivityType.game.value,
              }
            ],
            'afk': false,
            'since': null,
          }));

      final now = DateTime.now();
      final idleBuilder = PresenceBuilder.idle(since: now);

      expect(
          idleBuilder.build(),
          equals({
            'status': UserStatus.idle.toString(),
            'afk': true,
            'since': now.millisecondsSinceEpoch,
          }));
    });

    test('ActivityBuilder', () {
      final streamingBuilder = ActivityBuilder.streaming("test game name", 'https://twitch.tv');
      expect(streamingBuilder.build(), equals({"name": "test game name", "type": ActivityType.streaming.value, "url": 'https://twitch.tv'}));

      final listeningBuilder = ActivityBuilder.listening("test listening name");
      expect(
          listeningBuilder.build(),
          equals({
            "name": "test listening name",
            "type": ActivityType.listening.value,
          }));
    });
  });

  test('PermissionOverrideBuilder', () {
    final builder = PermissionOverrideBuilder(0, Snowflake.zero());
    expect(builder.build(), equals({"allow": "0", "deny": "0", 'id': '0', 'type': 0}));

    final fromBuilder = PermissionOverrideBuilder.from(0, Snowflake.zero(), Permissions.empty());
    expect(fromBuilder.build(), equals({"allow": "0", "deny": "1649267441663", 'id': '0', 'type': 0}));
    expect(fromBuilder.calculatePermissionValue(), equals(0));

    final ofBuilder = PermissionOverrideBuilder.of(MockMember(Snowflake.zero()))
      ..sendMessages = true
      ..addReactions = false;

    expect(ofBuilder.build(), equals({"allow": (1 << 11).toString(), "deny": (1 << 6).toString(), 'id': '0', 'type': 1}));
    expect(ofBuilder.calculatePermissionValue(), equals(1 << 11));
  });

  group('MemberBuilder', () {
    test('channel empty', () {
      final builder = MemberBuilder()..channel = Snowflake.zero();

      expect({}, builder.build());
    });

    test('channel with value', () {
      final builder = MemberBuilder()..channel = Snowflake(123);

      expect({'channel_id': '123'}, builder.build());
    });

    test('timeout empty', () {
      final now = DateTime.now();

      final builder = MemberBuilder()..timeoutUntil = now;

      expect({'communication_disabled_until': now.toIso8601String()}, builder.build());
    });

    test('roles serialization', () {
      final builder = MemberBuilder()..roles = [Snowflake(1), Snowflake(2)];

      expect({
        'roles': ['1', '2']
      }, builder.build());
    });
  });

  group('MessageBuilder', () {
    test('clear character', () {
      final builder = MessageBuilder.empty();
      expect(builder.content, equals(MessageBuilder.clearCharacter));
    });

    test('embeds', () async {
      final builder = MessageBuilder.embed(EmbedBuilder()..description = 'test1')
        ..flags = (MessageFlagBuilder()
          ..suppressEmbeds = true
          ..suppressNotifications = true);
      await builder.addEmbed((embed) => embed.description = 'test2');

      final result = builder.build();

      expect(
          result,
          equals({
            'content': '',
            'embeds': [
              {'description': 'test1'},
              {'description': 'test2'}
            ],
            'flags': 1 << 2 | 1 << 12
          }));
    });

    test('text', () {
      final dateTime = DateTime(2000);

      final builder = MessageBuilder()
        ..appendSpoiler('spoiler')
        ..appendNewLine()
        ..appendItalics('italics')
        ..appendBold('bold')
        ..appendStrike('strike')
        ..appendCodeSimple('this is code simple')
        ..appendMention(MockMember(Snowflake.zero()))
        ..appendTimestamp(dateTime)
        ..appendCode('dart', 'final int = 124;');

      expect(
          builder.build(),
          equals({
            'content': '||spoiler||\n'
                '*italics***bold**~~strike~~`this is code simple`<@0><t:${dateTime.millisecondsSinceEpoch ~/ 1000}:f>\n'
                '```dart\n'
                'final int = 124;```'
          }));

      expect(builder.getMappedFiles(), isEmpty);
      expect(builder.canBeUsedAsNewMessage(), isTrue);

      expect(MessageDecoration.bold.format('test'), equals('**test**'));
    });

    test('limitLength', () {
      final builder = MessageBuilder.content('abc' * 1000)..limitLength(ellipsis: null);

      expect(builder.content, equals(('abc' * 1000).substring(0, 2000)));

      builder.limitLength(length: 10, ellipsis: '...');

      expect(builder.content, equals('abcabca...'));
    });

    test("ForumThreadBuilder", () {
      final builder = ForumThreadBuilder("test", message: MessageBuilder.content("test"));

      expect(
          builder.build(),
          equals({
            'name': 'test',
            'message': {'content': 'test'}
          }));
    });
  });

  test('AutoModerationRuleBuilder', () {
    final rb = AutoModerationRuleBuilder(
      'Super cool rule',
      eventType: EventTypes.messageSend,
      triggerType: TriggerTypes.keyword,
      actions: [
        ActionStructureBuilder(
          ActionTypes.timeout,
          ActionMetadataBuilder(
            duration: Duration(
              days: 1,
            ),
          ),
        ),
      ],
    )
      ..triggerMetadata = (TriggerMetadataBuilder()
        ..keywordFilter = ['hey', '*looks', 'wildcards!!*']
        ..allowList = ['wow*', 'im', 'allowed!']
        ..presets = [KeywordPresets.slurs])
      ..ignoredChannels = [Snowflake.zero()]
      ..ignoredRoles = [Snowflake.zero()]
      ..enabled = true;

    expect(rb.build(), {
      'name': 'Super cool rule',
      'event_type': 1,
      'trigger_type': 1,
      'actions': [
        {
          'type': 3,
          'metadata': {
            'duration_seconds': 86400,
          }
        }
      ],
      'trigger_metadata': {
        'keyword_filter': ['hey', '*looks', 'wildcards!!*'],
        'presets': [3],
        'allow_list': ['wow*', 'im', 'allowed!']
      },
      'enabled': true,
      'exempt_channels': ['0'],
      'exempt_roles': ['0']
    });
  });
}
