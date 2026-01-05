import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart';
import '../utils/encryption_helper.dart';

class GoogleAuthEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<bool> exchangeCode(Session session, String authCode) async {
    final authenticationInfo = session.authenticated;
    if (authenticationInfo == null) return false;

    final userId = int.tryParse(authenticationInfo.userIdentifier);
    if (userId == null) return false;

    // Load secrets from config file
    String clientId;
    String clientSecret;
    
    try {
       final configStr = await File('config/google_client_secret.json').readAsString();
       final config = jsonDecode(configStr);
       // Handle both "installed" and "web" formats
       final data = config['installed'] ?? config['web'];
       clientId = data['client_id'];
       clientSecret = data['client_secret'];
    } catch (e) {
       session.log('Failed to load Google credentials', level: LogLevel.error, exception: e);
       return false;
    }

    // Exchange for tokens
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      body: {
        'code': authCode,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': '', // Empty for installed apps/programmatic flow
        'grant_type': 'authorization_code',
      },
    );

    if (response.statusCode != 200) {
      session.log('Failed to exchange code: ${response.body}', level: LogLevel.error);
      return false;
    }

    final data = jsonDecode(response.body);
    final refreshToken = data['refresh_token'];
    
    // Refresh tokens are only returned on the FIRST consent (offline access).
    if (refreshToken != null) {
        // Encrypt the token
        final encryptedToken = EncryptionHelper.encrypt(refreshToken);
        
        var userConfig = await UserConfig.db.findFirstRow(
          session,
          where: (t) => t.userInfoId.equals(userId),
        );

        if (userConfig != null) {
          userConfig.googleRefreshToken = encryptedToken;
          await UserConfig.db.updateRow(session, userConfig);
        } else {
          // Initialize with default values
          userConfig = UserConfig(
            userInfoId: userId,
            googleRefreshToken: encryptedToken,
            dailyBriefingTime: 8,
            isPro: false,
            driftingAlertsEnabled: true,
            weeklyDigestEnabled: true,
            newMemoryAlertsEnabled: true,
          );
          await UserConfig.db.insertRow(session, userConfig);
        }
        session.log('Successfully stored refresh token for user $userId', level: LogLevel.info);
    } else {
       session.log('No refresh token returned (already granted?)', level: LogLevel.warning);
    }

    return true;
  }
}
