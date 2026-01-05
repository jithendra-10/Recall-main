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
import 'package:recall_client/src/protocol/protocol.dart' as _i2;

abstract class Contact implements _i1.SerializableModel {
  Contact._({
    this.id,
    required this.ownerId,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.healthScore,
    this.lastContacted,
    this.tags,
    this.summary,
    this.bio,
    this.location,
    this.organization,
    this.tier,
  });

  factory Contact({
    int? id,
    required int ownerId,
    required String email,
    String? name,
    String? avatarUrl,
    required double healthScore,
    DateTime? lastContacted,
    List<String>? tags,
    String? summary,
    String? bio,
    String? location,
    String? organization,
    int? tier,
  }) = _ContactImpl;

  factory Contact.fromJson(Map<String, dynamic> jsonSerialization) {
    return Contact(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as int,
      email: jsonSerialization['email'] as String,
      name: jsonSerialization['name'] as String?,
      avatarUrl: jsonSerialization['avatarUrl'] as String?,
      healthScore: (jsonSerialization['healthScore'] as num).toDouble(),
      lastContacted: jsonSerialization['lastContacted'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastContacted'],
            ),
      tags: jsonSerialization['tags'] == null
          ? null
          : _i2.Protocol().deserialize<List<String>>(jsonSerialization['tags']),
      summary: jsonSerialization['summary'] as String?,
      bio: jsonSerialization['bio'] as String?,
      location: jsonSerialization['location'] as String?,
      organization: jsonSerialization['organization'] as String?,
      tier: jsonSerialization['tier'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int ownerId;

  String email;

  String? name;

  String? avatarUrl;

  double healthScore;

  DateTime? lastContacted;

  List<String>? tags;

  String? summary;

  String? bio;

  String? location;

  String? organization;

  int? tier;

  /// Returns a shallow copy of this [Contact]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Contact copyWith({
    int? id,
    int? ownerId,
    String? email,
    String? name,
    String? avatarUrl,
    double? healthScore,
    DateTime? lastContacted,
    List<String>? tags,
    String? summary,
    String? bio,
    String? location,
    String? organization,
    int? tier,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Contact',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'email': email,
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'healthScore': healthScore,
      if (lastContacted != null) 'lastContacted': lastContacted?.toJson(),
      if (tags != null) 'tags': tags?.toJson(),
      if (summary != null) 'summary': summary,
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      if (organization != null) 'organization': organization,
      if (tier != null) 'tier': tier,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ContactImpl extends Contact {
  _ContactImpl({
    int? id,
    required int ownerId,
    required String email,
    String? name,
    String? avatarUrl,
    required double healthScore,
    DateTime? lastContacted,
    List<String>? tags,
    String? summary,
    String? bio,
    String? location,
    String? organization,
    int? tier,
  }) : super._(
         id: id,
         ownerId: ownerId,
         email: email,
         name: name,
         avatarUrl: avatarUrl,
         healthScore: healthScore,
         lastContacted: lastContacted,
         tags: tags,
         summary: summary,
         bio: bio,
         location: location,
         organization: organization,
         tier: tier,
       );

  /// Returns a shallow copy of this [Contact]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Contact copyWith({
    Object? id = _Undefined,
    int? ownerId,
    String? email,
    Object? name = _Undefined,
    Object? avatarUrl = _Undefined,
    double? healthScore,
    Object? lastContacted = _Undefined,
    Object? tags = _Undefined,
    Object? summary = _Undefined,
    Object? bio = _Undefined,
    Object? location = _Undefined,
    Object? organization = _Undefined,
    Object? tier = _Undefined,
  }) {
    return Contact(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      email: email ?? this.email,
      name: name is String? ? name : this.name,
      avatarUrl: avatarUrl is String? ? avatarUrl : this.avatarUrl,
      healthScore: healthScore ?? this.healthScore,
      lastContacted: lastContacted is DateTime?
          ? lastContacted
          : this.lastContacted,
      tags: tags is List<String>? ? tags : this.tags?.map((e0) => e0).toList(),
      summary: summary is String? ? summary : this.summary,
      bio: bio is String? ? bio : this.bio,
      location: location is String? ? location : this.location,
      organization: organization is String? ? organization : this.organization,
      tier: tier is int? ? tier : this.tier,
    );
  }
}
