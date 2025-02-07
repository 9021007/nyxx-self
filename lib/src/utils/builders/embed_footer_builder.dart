import 'package:nyxx_self/src/internal/exceptions/embed_builder_argument_exception.dart';
import 'package:nyxx_self/src/typedefs.dart';
import 'package:nyxx_self/src/utils/builders/builder.dart';

/// Build new instance of Embed's footer
class EmbedFooterBuilder extends Builder {
  /// Footer text
  String? text;

  /// Url of footer icon. Supports only http(s) for now
  String? iconUrl;

  /// Length of footer
  int? get length => text?.length;

  /// Create empty [EmbedFooterBuilder]
  EmbedFooterBuilder({this.iconUrl, this.text});

  @override

  /// Builds object to Map() instance;
  RawApiMap build() {
    if (text != null && length! > 2048) {
      throw EmbedBuilderArgumentException("Footer text is too long. (1024 characters limit)");
    }

    return <String, dynamic>{if (text != null) "text": text, if (iconUrl != null) "icon_url": iconUrl};
  }
}
