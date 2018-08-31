part of nyxx;

/// A guild member.
class Member extends User {
  /// The member's nickname, null if not set.
  String nickname;

  /// The member's status, `offline`, `online`, `idle`, or `dnd`.
  String status;

  /// User's presence.
  /// https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-structure
  Game presence;

  /// When the member joined the guild.
  DateTime joinedAt;

  /// Weather or not the member is deafened.
  bool deaf;

  /// Weather or not the member is muted.
  bool mute;

  /// The member's game.
  Game game;

  /// A list of role IDs the member has.
  List<Role> roles;

  /// The guild that the member is a part of.
  Guild guild;

  /// Returs highest role for member
  Role get highestRole =>
      roles.reduce((f, s) => f.position > s.position ? f : s);

  Member._new(Client client, Map<String, dynamic> data, [Guild guild])
      : super._new(client, data) {
    this.nickname = data['nick'] as String;
    this.deaf = data['deaf'] as bool;
    this.mute = data['mute'] as bool;
    this.status = data['status'] as String;

    if (guild == null)
      this.guild = this.client.guilds[Snowflake(data['guild_id'] as String)];
    else
      this.guild = guild;

    if (data['roles'] != null) {
      roles = List();
      data['roles'].forEach((i) {
        roles.add(this.guild.roles[Snowflake(i as String)]);
      });
    }

    if (data['joined_at'] != null)
      this.joinedAt = DateTime.parse(data['joined_at'] as String);

    if (data['game'] != null)
      this.game = Game._new(this.client, data['game'] as Map<String, dynamic>);

    if (guild != null) this.guild.members[this.id] = this;
    client.users[this.id] = this;
  }

  /// Bans the member and optionally deletes [deleteMessageDays] days worth of messages.
  Future<void> ban({int deleteMessageDays = 0, String auditReason = ""}) async {
    await this.client.http.send(
        'PUT', "/guilds/${this.guild.id}/bans/${this.id}",
        body: {"delete-message-days": deleteMessageDays}, reason: auditReason);
  }

  /// Adds role to user
  ///
  /// ```
  /// var r = guild.roles.values.first;
  /// await member.addRole(r);
  /// ```
  Future<void> addRole(Role role, {String auditReason = ""}) async {
    await this.client.http.send(
        'PUT', '/guilds/${guild.id}/members/${this.id}/roles/${role.id}',
        reason: auditReason);
    return null;
  }

  /// Kicks the member
  Future<void> kick({String auditReason = ""}) async {
    await this.client.http.send(
        'DELETE', "/guilds/${this.guild.id}/members/${this.id}",
        reason: auditReason);
  }

  /// Returns total permissions of user.
  Future<Permissions> getTotalPermissions() async {
    var total = 0;
    for (var role in roles) total |= role.permissions.raw;

    return Permissions.fromInt(total);
  }

  @override
  String toString() => super.toString();
}

/*
class UserStatus {
  final String _value;
  const UserStatus._internal(this._value);

  @override
  String toString() => _value;

  static const offline = const UserStatus._internal("offline");
  static const online = const UserStatus._internal("online");
  static const idle = const UserStatus._internal("idle");
  static const dnd = const UserStatus._internal("dnd");

  static UserStatus fromStrig(String status) => UserStatus._internal(status);
}
*/
