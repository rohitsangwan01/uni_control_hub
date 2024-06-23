import 'package:uni_control_hub/app/models/screen_alias.dart';
import 'package:uni_control_hub/app/models/screen_config.dart';
import 'package:uni_control_hub/app/models/screen_link.dart';
import 'package:uni_control_hub/app/models/screen_options.dart';

class SynergyConfig {
  final List<ScreenConfig> screens;
  final List<ScreenAlias> aliases;
  final List<ScreenLink> links;
  final ScreenOptions? options;

  SynergyConfig({
    required this.screens,
    required this.links,
    this.aliases = const [],
    this.options,
  });

  String getConfigText() {
    Map<String, Map<String, dynamic>> data = {};

    // Add screens
    if (screens.isNotEmpty) {
      Map<String, dynamic> screenJson = {};
      for (var screen in screens) {
        screenJson.addAll(screen.toJson());
      }
      data['screens'] = screenJson;
    }

    // Add aliases
    if (aliases.isNotEmpty) {
      Map<String, dynamic> aliasJson = {};
      for (var alias in aliases) {
        aliasJson.addAll(alias.toJson());
      }
      data['aliases'] = aliasJson;
    }

    // Add links
    if (links.isNotEmpty) {
      Map<String, dynamic> linkJson = {};
      for (var link in links) {
        linkJson.addAll(link.toJson());
      }
      data['links'] = linkJson;
    }

    // Add options
    if (options != null) {
      data['options'] = options!.toJson();
    }

    // print(data);
    return _formatData(data);
  }

  /// Format json into config file
  String _formatData(Map<String, dynamic> data) {
    String config = '';
    data.forEach((section, subsections) {
      config += '\nsection: $section';
      if (subsections is Map<String, dynamic>) {
        subsections.forEach((subsection, properties) {
          if (properties is Map<String, dynamic>) {
            config += '\n\t$subsection:';
            properties.forEach((key, value) {
              config += '\n\t\t$key = $value';
            });
          } else if (properties is List<String>) {
            config += '\n\t$subsection:';
            for (var item in properties) {
              config += '\n\t\t$item';
            }
          } else {
            config += '\n\t$subsection = $properties';
          }
        });
      }
      config += '\nend\n';
    });
    return config;
  }
}
