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

abstract class AgendaItem implements _i1.SerializableModel {
  AgendaItem._({
    this.id,
    required this.ownerId,
    required this.contactId,
    this.contact,
    this.interactionId,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgendaItem({
    int? id,
    required int ownerId,
    required int contactId,
    _i2.Contact? contact,
    int? interactionId,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    required String priority,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AgendaItemImpl;

  factory AgendaItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgendaItem(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as int,
      contactId: jsonSerialization['contactId'] as int,
      contact: jsonSerialization['contact'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Contact>(
              jsonSerialization['contact'],
            ),
      interactionId: jsonSerialization['interactionId'] as int?,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      startTime: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: jsonSerialization['endTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
      priority: jsonSerialization['priority'] as String,
      status: jsonSerialization['status'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int ownerId;

  int contactId;

  _i2.Contact? contact;

  int? interactionId;

  String title;

  String? description;

  DateTime startTime;

  DateTime? endTime;

  String priority;

  String status;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AgendaItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AgendaItem copyWith({
    int? id,
    int? ownerId,
    int? contactId,
    _i2.Contact? contact,
    int? interactionId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? priority,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgendaItem',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'contactId': contactId,
      if (contact != null) 'contact': contact?.toJson(),
      if (interactionId != null) 'interactionId': interactionId,
      'title': title,
      if (description != null) 'description': description,
      'startTime': startTime.toJson(),
      if (endTime != null) 'endTime': endTime?.toJson(),
      'priority': priority,
      'status': status,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AgendaItemImpl extends AgendaItem {
  _AgendaItemImpl({
    int? id,
    required int ownerId,
    required int contactId,
    _i2.Contact? contact,
    int? interactionId,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    required String priority,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         ownerId: ownerId,
         contactId: contactId,
         contact: contact,
         interactionId: interactionId,
         title: title,
         description: description,
         startTime: startTime,
         endTime: endTime,
         priority: priority,
         status: status,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AgendaItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AgendaItem copyWith({
    Object? id = _Undefined,
    int? ownerId,
    int? contactId,
    Object? contact = _Undefined,
    Object? interactionId = _Undefined,
    String? title,
    Object? description = _Undefined,
    DateTime? startTime,
    Object? endTime = _Undefined,
    String? priority,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgendaItem(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      contactId: contactId ?? this.contactId,
      contact: contact is _i2.Contact? ? contact : this.contact?.copyWith(),
      interactionId: interactionId is int? ? interactionId : this.interactionId,
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime is DateTime? ? endTime : this.endTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
