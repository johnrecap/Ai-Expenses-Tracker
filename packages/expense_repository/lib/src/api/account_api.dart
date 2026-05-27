import 'vps_api_client.dart';

class BackendAccountProfile {
  final String id;
  final String firebaseUid;
  final String? email;
  final String? appDisplayName;

  const BackendAccountProfile({
    required this.id,
    required this.firebaseUid,
    this.email,
    this.appDisplayName,
  });

  factory BackendAccountProfile.fromJson(Map<String, Object?> json) {
    return BackendAccountProfile(
      id: json['id']?.toString() ?? '',
      firebaseUid: json['firebaseUid']?.toString() ?? '',
      email: json['email']?.toString(),
      appDisplayName: json['appDisplayName']?.toString(),
    );
  }
}

class AccountApi {
  final VpsApiClient _client;

  const AccountApi(this._client);

  Future<BackendAccountProfile> getCurrentUser() async {
    return BackendAccountProfile.fromJson(
      await _client.getJson('/v1/users/me'),
    );
  }

  Future<BackendAccountProfile> updateAppDisplayName(
      String? displayName) async {
    return BackendAccountProfile.fromJson(
      await _client.patchJson('/v1/users/me', {
        'appDisplayName': displayName,
      }),
    );
  }
}
