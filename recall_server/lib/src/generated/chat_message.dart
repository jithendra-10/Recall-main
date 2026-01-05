/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'chat_session.dart' as _i2;
import 'package:recall_server/src/generated/protocol.dart' as _i3;

abstract class ChatMessage
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = ChatMessageTable();

  static const db = ChatMessageRepository._();

  @override
  int? id;

  int chatSessionId;

  _i2.ChatSession? chatSession;

  int ownerId;

  String role;

  String content;

  DateTime timestamp;

  List<String>? sources;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatMessage',
      if (id != null) 'id': id,
      'chatSessionId': chatSessionId,
      if (chatSession != null) 'chatSession': chatSession?.toJsonForProtocol(),
      'ownerId': ownerId,
      'role': role,
      'content': content,
      'timestamp': timestamp.toJson(),
      if (sources != null) 'sources': sources?.toJson(),
    };
  }

  static ChatMessageInclude include({_i2.ChatSessionInclude? chatSession}) {
    return ChatMessageInclude._(chatSession: chatSession);
  }

  static ChatMessageIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatMessageTable>? orderByList,
    ChatMessageInclude? include,
  }) {
    return ChatMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatMessage.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatMessage.t),
      include: include,
    );
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

class ChatMessageUpdateTable extends _i1.UpdateTable<ChatMessageTable> {
  ChatMessageUpdateTable(super.table);

  _i1.ColumnValue<int, int> chatSessionId(int value) => _i1.ColumnValue(
    table.chatSessionId,
    value,
  );

  _i1.ColumnValue<int, int> ownerId(int value) => _i1.ColumnValue(
    table.ownerId,
    value,
  );

  _i1.ColumnValue<String, String> role(String value) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<String, String> content(String value) => _i1.ColumnValue(
    table.content,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> timestamp(DateTime value) =>
      _i1.ColumnValue(
        table.timestamp,
        value,
      );

  _i1.ColumnValue<List<String>, List<String>> sources(List<String>? value) =>
      _i1.ColumnValue(
        table.sources,
        value,
      );
}

class ChatMessageTable extends _i1.Table<int?> {
  ChatMessageTable({super.tableRelation})
    : super(tableName: 'recall_chat_message') {
    updateTable = ChatMessageUpdateTable(this);
    chatSessionId = _i1.ColumnInt(
      'chatSessionId',
      this,
    );
    ownerId = _i1.ColumnInt(
      'ownerId',
      this,
    );
    role = _i1.ColumnString(
      'role',
      this,
    );
    content = _i1.ColumnString(
      'content',
      this,
    );
    timestamp = _i1.ColumnDateTime(
      'timestamp',
      this,
    );
    sources = _i1.ColumnSerializable<List<String>>(
      'sources',
      this,
    );
  }

  late final ChatMessageUpdateTable updateTable;

  late final _i1.ColumnInt chatSessionId;

  _i2.ChatSessionTable? _chatSession;

  late final _i1.ColumnInt ownerId;

  late final _i1.ColumnString role;

  late final _i1.ColumnString content;

  late final _i1.ColumnDateTime timestamp;

  late final _i1.ColumnSerializable<List<String>> sources;

  _i2.ChatSessionTable get chatSession {
    if (_chatSession != null) return _chatSession!;
    _chatSession = _i1.createRelationTable(
      relationFieldName: 'chatSession',
      field: ChatMessage.t.chatSessionId,
      foreignField: _i2.ChatSession.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.ChatSessionTable(tableRelation: foreignTableRelation),
    );
    return _chatSession!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    chatSessionId,
    ownerId,
    role,
    content,
    timestamp,
    sources,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'chatSession') {
      return chatSession;
    }
    return null;
  }
}

class ChatMessageInclude extends _i1.IncludeObject {
  ChatMessageInclude._({_i2.ChatSessionInclude? chatSession}) {
    _chatSession = chatSession;
  }

  _i2.ChatSessionInclude? _chatSession;

  @override
  Map<String, _i1.Include?> get includes => {'chatSession': _chatSession};

  @override
  _i1.Table<int?> get table => ChatMessage.t;
}

class ChatMessageIncludeList extends _i1.IncludeList {
  ChatMessageIncludeList._({
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatMessage.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ChatMessage.t;
}

class ChatMessageRepository {
  const ChatMessageRepository._();

  final attachRow = const ChatMessageAttachRowRepository._();

  /// Returns a list of [ChatMessage]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<ChatMessage>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatMessageTable>? orderByList,
    _i1.Transaction? transaction,
    ChatMessageInclude? include,
  }) async {
    return session.db.find<ChatMessage>(
      where: where?.call(ChatMessage.t),
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [ChatMessage] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<ChatMessage?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatMessageTable>? orderByList,
    _i1.Transaction? transaction,
    ChatMessageInclude? include,
  }) async {
    return session.db.findFirstRow<ChatMessage>(
      where: where?.call(ChatMessage.t),
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [ChatMessage] by its [id] or null if no such row exists.
  Future<ChatMessage?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    ChatMessageInclude? include,
  }) async {
    return session.db.findById<ChatMessage>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [ChatMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ChatMessage>> insert(
    _i1.Session session,
    List<ChatMessage> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ChatMessage>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ChatMessage] and returns the inserted row.
  ///
  /// The returned [ChatMessage] will have its `id` field set.
  Future<ChatMessage> insertRow(
    _i1.Session session,
    ChatMessage row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatMessage>> update(
    _i1.Session session,
    List<ChatMessage> rows, {
    _i1.ColumnSelections<ChatMessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatMessage>(
      rows,
      columns: columns?.call(ChatMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatMessage> updateRow(
    _i1.Session session,
    ChatMessage row, {
    _i1.ColumnSelections<ChatMessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatMessage>(
      row,
      columns: columns?.call(ChatMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatMessage?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ChatMessageUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatMessage>(
      id,
      columnValues: columnValues(ChatMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ChatMessage>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ChatMessageUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ChatMessageTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatMessageTable>? orderBy,
    _i1.OrderByListBuilder<ChatMessageTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ChatMessage>(
      columnValues: columnValues(ChatMessage.t.updateTable),
      where: where(ChatMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ChatMessage]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatMessage>> delete(
    _i1.Session session,
    List<ChatMessage> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatMessage>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatMessage].
  Future<ChatMessage> deleteRow(
    _i1.Session session,
    ChatMessage row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatMessage>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ChatMessageTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatMessage>(
      where: where(ChatMessage.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatMessage>(
      where: where?.call(ChatMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class ChatMessageAttachRowRepository {
  const ChatMessageAttachRowRepository._();

  /// Creates a relation between the given [ChatMessage] and [ChatSession]
  /// by setting the [ChatMessage]'s foreign key `chatSessionId` to refer to the [ChatSession].
  Future<void> chatSession(
    _i1.Session session,
    ChatMessage chatMessage,
    _i2.ChatSession chatSession, {
    _i1.Transaction? transaction,
  }) async {
    if (chatMessage.id == null) {
      throw ArgumentError.notNull('chatMessage.id');
    }
    if (chatSession.id == null) {
      throw ArgumentError.notNull('chatSession.id');
    }

    var $chatMessage = chatMessage.copyWith(chatSessionId: chatSession.id);
    await session.db.updateRow<ChatMessage>(
      $chatMessage,
      columns: [ChatMessage.t.chatSessionId],
      transaction: transaction,
    );
  }
}
