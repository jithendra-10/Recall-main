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
import 'contact.dart' as _i2;
import 'package:recall_client/src/protocol/protocol.dart' as _i3;

abstract class Notification implements _i1.SerializableModel {
  Notification._({
    this.id,
    required this.ownerId,
    required this.type,
    required this.title,
    required this.message,
    required this.relatedContactId,
    this.relatedContact,
    required this.createdAt,
    required this.isRead,
    this.actionLabel,
    this.actionLink,
  });

  factory Notification({
    int? id,
    required int ownerId,
    required String type,
    required String title,
    required String message,
    required int relatedContactId,
    _i2.Contact? relatedContact,
    required DateTime createdAt,
    required bool isRead,
    String? actionLabel,
    String? actionLink,
  }) = _NotificationImpl;

  factory Notification.fromJson(Map<String, dynamic> jsonSerialization) {
    return Notification(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as int,
      type: jsonSerialization['type'] as String,
      title: jsonSerialization['title'] as String,
      message: jsonSerialization['message'] as String,
      relatedContactId: jsonSerialization['relatedContactId'] as int,
      relatedContact: jsonSerialization['relatedContact'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Contact>(
              jsonSerialization['relatedContact'],
            ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      isRead: jsonSerialization['isRead'] as bool,
      actionLabel: jsonSerialization['actionLabel'] as String?,
      actionLink: jsonSerialization['actionLink'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int ownerId;

  String type;

  String title;

  String message;

  int relatedContactId;

  _i2.Contact? relatedContact;

  DateTime createdAt;

  bool isRead;

  String? actionLabel;

  String? actionLink;

  /// Returns a shallow copy of this [Notification]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Notification copyWith({
    int? id,
    int? ownerId,
    String? type,
    String? title,
    String? message,
    int? relatedContactId,
    _i2.Contact? relatedContact,
    DateTime? createdAt,
    bool? isRead,
    String? actionLabel,
    String? actionLink,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Notification',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'type': type,
      'title': title,
      'message': message,
      'relatedContactId': relatedContactId,
      if (relatedContact != null) 'relatedContact': relatedContact?.toJson(),
      'createdAt': createdAt.toJson(),
      'isRead': isRead,
      if (actionLabel != null) 'actionLabel': actionLabel,
      if (actionLink != null) 'actionLink': actionLink,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NotificationImpl extends Notification {
  _NotificationImpl({
    int? id,
    required int ownerId,
    required String type,
    required String title,
    required String message,
    required int relatedContactId,
    _i2.Contact? relatedContact,
    required DateTime createdAt,
    required bool isRead,
    String? actionLabel,
    String? actionLink,
  }) : super._(
         id: id,
         ownerId: ownerId,
         type: type,
         title: title,
         message: message,
         relatedContactId: relatedContactId,
         relatedContact: relatedContact,
         createdAt: createdAt,
         isRead: isRead,
         actionLabel: actionLabel,
         actionLink: actionLink,
       );

  /// Returns a shallow copy of this [Notification]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Notification copyWith({
    Object? id = _Undefined,
    int? ownerId,
    String? type,
    String? title,
    String? message,
    int? relatedContactId,
    Object? relatedContact = _Undefined,
    DateTime? createdAt,
    bool? isRead,
    Object? actionLabel = _Undefined,
    Object? actionLink = _Undefined,
  }) {
    return Notification(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedContactId: relatedContactId ?? this.relatedContactId,
      relatedContact: relatedContact is _i2.Contact?
          ? relatedContact
          : this.relatedContact?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionLabel: actionLabel is String? ? actionLabel : this.actionLabel,
      actionLink: actionLink is String? ? actionLink : this.actionLink,
    );
  }
}
