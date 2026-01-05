/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class UserConfig implements _i1.SerializableModel {
  UserConfig._({
    this.id,
    required this.userInfoId,
    this.googleRefreshToken,
    this.lastGmailHistoryId,
    this.lastSyncTime,
    required this.dailyBriefingTime,
    required this.isPro,
    this.subscriptionDate,
    required this.driftingAlertsEnabled,
    required this.weeklyDigestEnabled,
    required this.newMemoryAlertsEnabled,
  });

  factory UserConfig({
    int? id,
    required int userInfoId,
    String? googleRefreshToken,
    String? lastGmailHistoryId,
    DateTime? lastSyncTime,
    required int dailyBriefingTime,
    required bool isPro,
    DateTime? subscriptionDate,
    required bool driftingAlertsEnabled,
    required bool weeklyDigestEnabled,
    required bool newMemoryAlertsEnabled,
  }) = _UserConfigImpl;

  factory UserConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserConfig(
      id: jsonSerialization['id'] as int?,
      userInfoId: jsonSerialization['userInfoId'] as int,
      googleRefreshToken: jsonSerialization['googleRefreshToken'] as String?,
      lastGmailHistoryId: jsonSerialization['lastGmailHistoryId'] as String?,
      lastSyncTime: jsonSerialization['lastSyncTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncTime'],
            ),
      dailyBriefingTime: jsonSerialization['dailyBriefingTime'] as int,
      isPro: jsonSerialization['isPro'] as bool,
      subscriptionDate: jsonSerialization['subscriptionDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['subscriptionDate'],
            ),
      driftingAlertsEnabled: jsonSerialization['driftingAlertsEnabled'] as bool,
      weeklyDigestEnabled: jsonSerialization['weeklyDigestEnabled'] as bool,
      newMemoryAlertsEnabled:
          jsonSerialization['newMemoryAlertsEnabled'] as bool,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userInfoId;

  String? googleRefreshToken;

  String? lastGmailHistoryId;

  DateTime? lastSyncTime;

  int dailyBriefingTime;

  bool isPro;

  DateTime? subscriptionDate;

  bool driftingAlertsEnabled;

  bool weeklyDigestEnabled;

  bool newMemoryAlertsEnabled;

  bool? isSyncing;

  /// Returns a shallow copy of this [UserConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserConfig copyWith({
    int? id,
    int? userInfoId,
    String? googleRefreshToken,
    String? lastGmailHistoryId,
    DateTime? lastSyncTime,
    int? dailyBriefingTime,
    bool? isPro,
    DateTime? subscriptionDate,
    bool? driftingAlertsEnabled,
    bool? weeklyDigestEnabled,
    bool? newMemoryAlertsEnabled,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserConfig',
      if (id != null) 'id': id,
      'userInfoId': userInfoId,
      if (googleRefreshToken != null) 'googleRefreshToken': googleRefreshToken,
      if (lastGmailHistoryId != null) 'lastGmailHistoryId': lastGmailHistoryId,
      if (lastSyncTime != null) 'lastSyncTime': lastSyncTime?.toJson(),
      'dailyBriefingTime': dailyBriefingTime,
      'isPro': isPro,
      if (subscriptionDate != null)
        'subscriptionDate': subscriptionDate?.toJson(),
      'driftingAlertsEnabled': driftingAlertsEnabled,
      'weeklyDigestEnabled': weeklyDigestEnabled,
      'newMemoryAlertsEnabled': newMemoryAlertsEnabled,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserConfigImpl extends UserConfig {
  _UserConfigImpl({
    int? id,
    required int userInfoId,
    String? googleRefreshToken,
    String? lastGmailHistoryId,
    DateTime? lastSyncTime,
    required int dailyBriefingTime,
    required bool isPro,
    DateTime? subscriptionDate,
    required bool driftingAlertsEnabled,
    required bool weeklyDigestEnabled,
    required bool newMemoryAlertsEnabled,
  }) : super._(
         id: id,
         userInfoId: userInfoId,
         googleRefreshToken: googleRefreshToken,
         lastGmailHistoryId: lastGmailHistoryId,
         lastSyncTime: lastSyncTime,
         dailyBriefingTime: dailyBriefingTime,
         isPro: isPro,
         subscriptionDate: subscriptionDate,
         driftingAlertsEnabled: driftingAlertsEnabled,
         weeklyDigestEnabled: weeklyDigestEnabled,
         newMemoryAlertsEnabled: newMemoryAlertsEnabled,
       );

  /// Returns a shallow copy of this [UserConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserConfig copyWith({
    Object? id = _Undefined,
    int? userInfoId,
    Object? googleRefreshToken = _Undefined,
    Object? lastGmailHistoryId = _Undefined,
    Object? lastSyncTime = _Undefined,
    int? dailyBriefingTime,
    bool? isPro,
    Object? subscriptionDate = _Undefined,
    bool? driftingAlertsEnabled,
    bool? weeklyDigestEnabled,
    bool? newMemoryAlertsEnabled,
  }) {
    return UserConfig(
      id: id is int? ? id : this.id,
      userInfoId: userInfoId ?? this.userInfoId,
      googleRefreshToken: googleRefreshToken is String?
          ? googleRefreshToken
          : this.googleRefreshToken,
      lastGmailHistoryId: lastGmailHistoryId is String?
          ? lastGmailHistoryId
          : this.lastGmailHistoryId,
      lastSyncTime: lastSyncTime is DateTime?
          ? lastSyncTime
          : this.lastSyncTime,
      dailyBriefingTime: dailyBriefingTime ?? this.dailyBriefingTime,
      isPro: isPro ?? this.isPro,
      subscriptionDate: subscriptionDate is DateTime?
          ? subscriptionDate
          : this.subscriptionDate,
      driftingAlertsEnabled:
          driftingAlertsEnabled ?? this.driftingAlertsEnabled,
      weeklyDigestEnabled: weeklyDigestEnabled ?? this.weeklyDigestEnabled,
      newMemoryAlertsEnabled:
          newMemoryAlertsEnabled ?? this.newMemoryAlertsEnabled,
    );
  }
}
