import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class UpdateChecker {
  static const String _apiUrl =
      'https://api.github.com/repos/amplitudemodulada/radar-monitor/releases/latest';

  Future<UpdateInfo> checkForUpdate(String currentVersion) async {
    try {
      final response = await http
          .get(
            Uri.parse(_apiUrl),
            headers: {'Accept': 'application/vnd.github.v3+json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final latestVersion = (data['tag_name'] as String).replaceAll('v', '');
        final assets = data['assets'] as List<dynamic>?;
        String? downloadUrl;
        if (assets != null && assets.isNotEmpty) {
          downloadUrl = assets.first['browser_download_url'] as String?;
        }
        final releaseUrl = data['html_url'] as String?;

        final hasUpdate = _compareVersions(latestVersion, currentVersion) > 0;

        return UpdateInfo(
          hasUpdate: hasUpdate,
          latestVersion: latestVersion,
          currentVersion: currentVersion,
          downloadUrl: downloadUrl,
          releaseUrl: releaseUrl ?? 'https://github.com/amplitudemodulada/radar-monitor/releases',
          notes: data['body'] as String?,
        );
      }
    } on Exception catch (_) {}

    return UpdateInfo(
      hasUpdate: false,
      latestVersion: currentVersion,
      currentVersion: currentVersion,
      releaseUrl: 'https://github.com/amplitudemodulada/radar-monitor/releases',
    );
  }

  int _compareVersions(String a, String b) {
    final partsA = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final partsB = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final len = partsA.length > partsB.length ? partsA.length : partsB.length;

    for (int i = 0; i < len; i++) {
      final va = i < partsA.length ? partsA[i] : 0;
      final vb = i < partsB.length ? partsB[i] : 0;
      if (va != vb) return va - vb;
    }
    return 0;
  }
}

class UpdateInfo {
  final bool hasUpdate;
  final String latestVersion;
  final String currentVersion;
  final String? downloadUrl;
  final String releaseUrl;
  final String? notes;

  UpdateInfo({
    required this.hasUpdate,
    required this.latestVersion,
    required this.currentVersion,
    this.downloadUrl,
    required this.releaseUrl,
    this.notes,
  });
}
