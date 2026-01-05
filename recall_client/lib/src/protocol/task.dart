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

abstract class Task implements _i1.SerializableModel {
  Task._({
    this.id,
    required this.ownerId,
    required this.title,
    this.description,
    required this.isCompleted,
    this.dueDate,
    required this.relatedContactId,
    this.relatedContact,
    required this.createdAt,
  });

  factory Task({
    int? id,
    required int ownerId,
    required String title,
    String? description,
    required bool isCompleted,
    DateTime? dueDate,
    required int relatedContactId,
    _i2.Contact? relatedContact,
    required DateTime createdAt,
  }) = _TaskImpl;

  factory Task.fromJson(Map<String, dynamic> jsonSerialization) {
    return Task(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as int,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      isCompleted: jsonSerialization['isCompleted'] as bool,
      dueDate: jsonSerialization['dueDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['dueDate']),
      relatedContactId: jsonSerialization['relatedContactId'] as int,
      relatedContact: jsonSerialization['relatedContact'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Contact>(
              jsonSerialization['relatedContact'],
            ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int ownerId;

  String title;

  String? description;

  bool isCompleted;

  DateTime? dueDate;

  int relatedContactId;

  _i2.Contact? relatedContact;

  DateTime createdAt;

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Task copyWith({
    int? id,
    int? ownerId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    int? relatedContactId,
    _i2.Contact? relatedContact,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Task',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'title': title,
      if (description != null) 'description': description,
      'isCompleted': isCompleted,
      if (dueDate != null) 'dueDate': dueDate?.toJson(),
      'relatedContactId': relatedContactId,
      if (relatedContact != null) 'relatedContact': relatedContact?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaskImpl extends Task {
  _TaskImpl({
    int? id,
    required int ownerId,
    required String title,
    String? description,
    required bool isCompleted,
    DateTime? dueDate,
    required int relatedContactId,
    _i2.Contact? relatedContact,
    required DateTime createdAt,
  }) : super._(
         id: id,
         ownerId: ownerId,
         title: title,
         description: description,
         isCompleted: isCompleted,
         dueDate: dueDate,
         relatedContactId: relatedContactId,
         relatedContact: relatedContact,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Task copyWith({
    Object? id = _Undefined,
    int? ownerId,
    String? title,
    Object? description = _Undefined,
    bool? isCompleted,
    Object? dueDate = _Undefined,
    int? relatedContactId,
    Object? relatedContact = _Undefined,
    DateTime? createdAt,
  }) {
    return Task(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate is DateTime? ? dueDate : this.dueDate,
      relatedContactId: relatedContactId ?? this.relatedContactId,
      relatedContact: relatedContact is _i2.Contact?
          ? relatedContact
          : this.relatedContact?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
