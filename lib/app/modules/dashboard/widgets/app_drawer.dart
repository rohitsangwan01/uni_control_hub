import 'package:flutter/material.dart';
import 'package:uni_control_hub/app/data/app_data.dart';
import 'package:uni_control_hub/app/modules/debug/debug_view.dart';
import 'package:uni_control_hub/app/modules/setting/settings_view.dart';
import 'package:uni_control_hub/app/services/app_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              AppImages.iconCircle,
              height: 100,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsView()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text("Send Feedback"),
            onTap: () async {
              launchUrlString(AppData.gitIssueUrl);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text("Debug Logs"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebugView()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About App"),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AboutDialog(
                  applicationIcon: const Image(
                    image: AssetImage(AppImages.iconCircle),
                    height: 50,
                  ),
                  applicationName: "Uni Control Hub",
                  applicationVersion: "v${AppService.to.appVersion}",
                  applicationLegalese: "© 2024 Uni Control Hub",
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
