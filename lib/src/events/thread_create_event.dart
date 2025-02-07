import 'package:nyxx_self/src/nyxx.dart';
import 'package:nyxx_self/src/core/channel/thread_channel.dart';
import 'package:nyxx_self/src/typedefs.dart';

abstract class IThreadCreateEvent {
  /// The thread that was just created
  IThreadChannel get thread;

  /// True if thread is created
  bool get newlyCreated;

  /// Set when bot joining private thread
  IThreadMember? get member;
}

/// Fired when a thread is created or when bot joins thread
class ThreadCreateEvent implements IThreadCreateEvent {
  /// The thread that was just created
  @override
  late final IThreadChannel thread;

  @override
  late final bool newlyCreated;

  @override
  late final IThreadMember? member;

  /// Creates an instance of [ThreadCreateEvent]
  ThreadCreateEvent(RawApiMap raw, INyxx client) {
    thread = ThreadChannel(client, raw["d"] as RawApiMap);
    newlyCreated = raw['d']['newly_created'] as bool? ?? false;
    member = raw['d']['member'] != null ? ThreadMember(client, raw['d']['member'] as RawApiMap, thread.guild) : null;

    if (client.cacheOptions.channelCachePolicyLocation.event && client.cacheOptions.channelCachePolicy.canCache(thread)) {
      client.channels[thread.id] = thread;
    }
  }
}

abstract class IThreadUpdateEvent {
  /// The thread that was just updated
  IThreadChannel get thread;

  /// The thread as it was before it was updated, if it was cached.
  IThreadChannel? get oldThread;
}

class ThreadUpdateEvent implements IThreadUpdateEvent {
  @override
  late final IThreadChannel thread;

  @override
  late final IThreadChannel? oldThread;

  ThreadUpdateEvent(RawApiMap raw, INyxx client) {
    thread = ThreadChannel(client, raw["d"] as RawApiMap);
    oldThread = client.channels[thread.id] as IThreadChannel?;

    if (client.cacheOptions.channelCachePolicyLocation.event && client.cacheOptions.channelCachePolicy.canCache(thread)) {
      client.channels[thread.id] = thread;
    }
  }
}
