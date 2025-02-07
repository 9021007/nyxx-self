import 'package:nyxx_self/src/core/application/app_team.dart';
import 'package:nyxx_self/src/core/snowflake.dart';
import 'package:nyxx_self/src/core/snowflake_entity.dart';
import 'package:nyxx_self/src/nyxx.dart';
import 'package:nyxx_self/src/typedefs.dart';

abstract class IOAuth2Application implements SnowflakeEntity {
  /// The app's description.
  String get description;

  /// The app's icon hash.
  String? get icon;

  /// The app's cover hash.
  String? get coverImage;

  /// The app's name.
  String get name;

  /// The app's RPC origins.
  List<String>? get rpcOrigins;

  /// Reference to [INyxx].
  INyxx get client;

  /// If the application belongs to a team, this will be a list of the members of that team.
  IAppTeam? get team;

  /// The url of the app's terms of service.
  String? get termsOfServiceUrl;

  /// The url of the app's privacy policy.
  String? get privacyPolicyUrl;

  /// The hex encoded key for verification in interactions and the GameSDK's [GetTicket](https://discord.com/developers/docs/game-sdk/applications#getticket)
  String get verifyKey;

  /// If this application is a game sold on Discord, this field will be the guild to which it has been linked.
  Snowflake? get guildId;

  /// If this application is a game sold on Discord, this field will be the id of the "Game SKU" that is created, if exists.
  Snowflake? get primarySkuId;

  /// If this application is a game sold on Discord, this field will be the URL slug that links to the store page.
  String? get slug;

  /// Returns URL to app's icon.
  String? iconUrl({String format = 'webp', int? size});

  /// Returns the cover image URL of the app.
  String? coverImageUrl({String format = 'webp', int? size});
}

/// An OAuth2 application.
class OAuth2Application extends SnowflakeEntity implements IOAuth2Application {
  /// The app's description.
  @override
  late final String description;

  /// The app's icon hash.
  @override
  late final String? icon;

  /// The app's name.
  @override
  late final String name;

  /// The app's RPC origins.
  @override
  late final List<String>? rpcOrigins;

  @override
  late final String? coverImage;

  @override
  final INyxx client;

  @override
  late final IAppTeam? team;

  @override
  late final String? termsOfServiceUrl;

  @override
  late final String? privacyPolicyUrl;

  @override
  late final String verifyKey;

  @override
  late final Snowflake? guildId;

  @override
  late final Snowflake? primarySkuId;

  @override
  late final String? slug;

  /// Creates an instance of [OAuth2Application]
  OAuth2Application(RawApiMap raw, this.client) : super(Snowflake(raw["id"])) {
    description = "";
    name = "";

    icon = null;
    rpcOrigins = null;
    coverImage = null;
    team = null;

    termsOfServiceUrl = null;
    privacyPolicyUrl = null;
    verifyKey = "";
    guildId = null;
    primarySkuId = null;
    slug = null;
  }

  /// Returns url to apps icon
  @override
  String? iconUrl({String format = 'webp', int? size}) {
    if (icon == null) {
      return null;
    }

    return client.cdnHttpEndpoints.appIcon(id, icon!, format: format, size: size);
  }

  @override
  String? coverImageUrl({String format = 'webp', int? size}) {
    if (coverImage == null) {
      return null;
    }

    return client.cdnHttpEndpoints.appIcon(id, coverImage!, format: format, size: size);
  }
}
