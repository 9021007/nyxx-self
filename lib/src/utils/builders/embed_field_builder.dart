import 'package:nyxx_self/src/internal/exceptions/embed_builder_argument_exception.dart';
import 'package:nyxx_self/src/typedefs.dart';
import 'package:nyxx_self/src/utils/builders/builder.dart';

/// Builder for embed Field.
class EmbedFieldBuilder extends Builder {
  /// Field name/title
  Object? name;

  /// Field content
  Object? content;

  /// Whether or not this field should display inline
  bool? inline;

  /// Constructs new instance of Field
  EmbedFieldBuilder([this.name, this.content, this.inline]);

  /// Constructs new instance of Field
  EmbedFieldBuilder.named({this.name, this.content, this.inline});

  /// Length of current field
  int get length => name.toString().length + content.toString().length;

  @override

  /// Builds object to Map() instance;
  RawApiMap build() {
    if (name.toString().length > 256) {
      throw EmbedBuilderArgumentException("Field name is too long. (256 characters limit)");
    }

    if (content.toString().length > 1024) {
      throw EmbedBuilderArgumentException("Field content is too long. (1024 characters limit)");
    }

    return <String, dynamic>{
      "name": name != null ? name.toString() : "\u200B",
      "value": content != null ? content.toString() : "\u200B",
      "inline": inline ?? false,
    };
  }
}
