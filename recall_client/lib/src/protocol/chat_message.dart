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
import 'chat_session.dart' as _i2;
import 'package:recall_client/src/protocol/protocol.dart' as _i3;

abstract class ChatMessage implements _i1.SerializableModel {
  ChatMessage._({
    this.id,
    required this.chatSessionId,
    this.chatSession,
    required this.ownerId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.sources,
  });

  factory ChatMessage({
    int? id,
    required int chatSessionId,
    _i2.ChatSession? chatSession,
    required int ownerId,
    required String role,
    required String content,
    required DateTime timestamp,
    List<String>? sources,
  }) = _ChatMessageImpl;

  factory ChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMessage(
      id: jsonSerialization['id'] as int?,
      chatSessionId: jsonSerialization['chatSessionId'] as int,
      chatSession: jsonSerialization['chatSession'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.ChatSession>(
              jsonSerialization['chatSession'],
            ),
      ownerId: jsonSerialization['ownerId'] as int,
      role: jsonSerialization['role'] as String,
      content: jsonSerialization['content'] as String,
      timestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
      sources: jsonSerialization['sources'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(
              jsonSerialization['sources'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int chatSessionId;

  _i2.ChatSession? chatSession;

  int ownerId;

  String role;

  String content;

  DateTime timestamp;

  List<String>? sources;

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMessage copyWith({
    int? id,
    int? chatSessionId,
    _i2.ChatSession? chatSession,
    int? ownerId,
    String? role,
    String? content,
    DateTime? timestamp,
    List<String>? sources,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatMessage',
      if (id != null) 'id': id,
      'chatSessionId': chatSessionId,
      if (chatSession != null) 'chatSession': chatSession?.toJson(),
      'ownerId': ownerId,
      'role': role,
      'content': content,
      'timestamp': timestamp.toJson(),
      if (sources != null) 'sources': sources?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMessageImpl extends ChatMessage {
  _ChatMessageImpl({
    int? id,
    required int chatSessionId,
    _i2.ChatSession? chatSession,
    required int ownerId,
    required String role,
    required String content,
    required DateTime timestamp,
    List<String>? sources,
  }) : super._(
         id: id,
         chatSessionId: chatSessionId,
         chatSession: chatSession,
         ownerId: ownerId,
         role: role,
         content: content,
         timestamp: timestamp,
         sources: sources,
       );

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMessage copyWith({
    Object? id = _Undefined,
    int? chatSessionId,
    Object? chatSession = _Undefined,
    int? ownerId,
    String? role,
    String? content,
    DateTime? timestamp,
    Object? sources = _Undefined,
  }) {
    return ChatMessage(
      id: id is int? ? id : this.id,
      chatSessionId: chatSessionId ?? this.chatSessionId,
      chatSession: chatSession is _i2.ChatSession?
          ? chatSession
          : this.chatSession?.copyWith(),
      ownerId: ownerId ?? this.ownerId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      sources: sources is List<String>?
          ? sources
          : this.sources?.map((e0) => e0).toList(),
    );
  }
}
