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
import 'contact.dart' as _i2;
import 'package:recall_server/src/generated/protocol.dart' as _i3;

abstract class AgendaItem
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = AgendaItemTable();

  static const db = AgendaItemRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgendaItem',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'contactId': contactId,
      if (contact != null) 'contact': contact?.toJsonForProtocol(),
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

  static AgendaItemInclude include({_i2.ContactInclude? contact}) {
    return AgendaItemInclude._(contact: contact);
  }

  static AgendaItemIncludeList includeList({
    _i1.WhereExpressionBuilder<AgendaItemTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AgendaItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AgendaItemTable>? orderByList,
    AgendaItemInclude? include,
  }) {
    return AgendaItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgendaItem.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AgendaItem.t),
      include: include,
    );
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

class AgendaItemUpdateTable extends _i1.UpdateTable<AgendaItemTable> {
  AgendaItemUpdateTable(super.table);

  _i1.ColumnValue<int, int> ownerId(int value) => _i1.ColumnValue(
    table.ownerId,
    value,
  );

  _i1.ColumnValue<int, int> contactId(int value) => _i1.ColumnValue(
    table.contactId,
    value,
  );

  _i1.ColumnValue<int, int> interactionId(int? value) => _i1.ColumnValue(
    table.interactionId,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<String, String> description(String? value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> startTime(DateTime value) =>
      _i1.ColumnValue(
        table.startTime,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> endTime(DateTime? value) =>
      _i1.ColumnValue(
        table.endTime,
        value,
      );

  _i1.ColumnValue<String, String> priority(String value) => _i1.ColumnValue(
    table.priority,
    value,
  );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class AgendaItemTable extends _i1.Table<int?> {
  AgendaItemTable({super.tableRelation})
    : super(tableName: 'recall_agenda_item') {
    updateTable = AgendaItemUpdateTable(this);
    ownerId = _i1.ColumnInt(
      'ownerId',
      this,
    );
    contactId = _i1.ColumnInt(
      'contactId',
      this,
    );
    interactionId = _i1.ColumnInt(
      'interactionId',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    startTime = _i1.ColumnDateTime(
      'startTime',
      this,
    );
    endTime = _i1.ColumnDateTime(
      'endTime',
      this,
    );
    priority = _i1.ColumnString(
      'priority',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final AgendaItemUpdateTable updateTable;

  late final _i1.ColumnInt ownerId;

  late final _i1.ColumnInt contactId;

  _i2.ContactTable? _contact;

  late final _i1.ColumnInt interactionId;

  late final _i1.ColumnString title;

  late final _i1.ColumnString description;

  late final _i1.ColumnDateTime startTime;

  late final _i1.ColumnDateTime endTime;

  late final _i1.ColumnString priority;

  late final _i1.ColumnString status;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  _i2.ContactTable get contact {
    if (_contact != null) return _contact!;
    _contact = _i1.createRelationTable(
      relationFieldName: 'contact',
      field: AgendaItem.t.contactId,
      foreignField: _i2.Contact.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.ContactTable(tableRelation: foreignTableRelation),
    );
    return _contact!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    ownerId,
    contactId,
    interactionId,
    title,
    description,
    startTime,
    endTime,
    priority,
    status,
    createdAt,
    updatedAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'contact') {
      return contact;
    }
    return null;
  }
}

class AgendaItemInclude extends _i1.IncludeObject {
  AgendaItemInclude._({_i2.ContactInclude? contact}) {
    _contact = contact;
  }

  _i2.ContactInclude? _contact;

  @override
  Map<String, _i1.Include?> get includes => {'contact': _contact};

  @override
  _i1.Table<int?> get table => AgendaItem.t;
}

class AgendaItemIncludeList extends _i1.IncludeList {
  AgendaItemIncludeList._({
    _i1.WhereExpressionBuilder<AgendaItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AgendaItem.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => AgendaItem.t;
}

class AgendaItemRepository {
  const AgendaItemRepository._();

  final attachRow = const AgendaItemAttachRowRepository._();

  /// Returns a list of [AgendaItem]s matching the given query parameters.
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
  Future<List<AgendaItem>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AgendaItemTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AgendaItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AgendaItemTable>? orderByList,
    _i1.Transaction? transaction,
    AgendaItemInclude? include,
  }) async {
    return session.db.find<AgendaItem>(
      where: where?.call(AgendaItem.t),
      orderBy: orderBy?.call(AgendaItem.t),
      orderByList: orderByList?.call(AgendaItem.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [AgendaItem] matching the given query parameters.
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
  Future<AgendaItem?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AgendaItemTable>? where,
    int? offset,
    _i1.OrderByBuilder<AgendaItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AgendaItemTable>? orderByList,
    _i1.Transaction? transaction,
    AgendaItemInclude? include,
  }) async {
    return session.db.findFirstRow<AgendaItem>(
      where: where?.call(AgendaItem.t),
      orderBy: orderBy?.call(AgendaItem.t),
      orderByList: orderByList?.call(AgendaItem.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [AgendaItem] by its [id] or null if no such row exists.
  Future<AgendaItem?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    AgendaItemInclude? include,
  }) async {
    return session.db.findById<AgendaItem>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [AgendaItem]s in the list and returns the inserted rows.
  ///
  /// The returned [AgendaItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<AgendaItem>> insert(
    _i1.Session session,
    List<AgendaItem> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<AgendaItem>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [AgendaItem] and returns the inserted row.
  ///
  /// The returned [AgendaItem] will have its `id` field set.
  Future<AgendaItem> insertRow(
    _i1.Session session,
    AgendaItem row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AgendaItem>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AgendaItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AgendaItem>> update(
    _i1.Session session,
    List<AgendaItem> rows, {
    _i1.ColumnSelections<AgendaItemTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AgendaItem>(
      rows,
      columns: columns?.call(AgendaItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AgendaItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AgendaItem> updateRow(
    _i1.Session session,
    AgendaItem row, {
    _i1.ColumnSelections<AgendaItemTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<AgendaItem>(
      row,
      columns: columns?.call(AgendaItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AgendaItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AgendaItem?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<AgendaItemUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AgendaItem>(
      id,
      columnValues: columnValues(AgendaItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AgendaItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AgendaItem>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<AgendaItemUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AgendaItemTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AgendaItemTable>? orderBy,
    _i1.OrderByListBuilder<AgendaItemTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AgendaItem>(
      columnValues: columnValues(AgendaItem.t.updateTable),
      where: where(AgendaItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgendaItem.t),
      orderByList: orderByList?.call(AgendaItem.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AgendaItem]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AgendaItem>> delete(
    _i1.Session session,
    List<AgendaItem> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AgendaItem>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AgendaItem].
  Future<AgendaItem> deleteRow(
    _i1.Session session,
    AgendaItem row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AgendaItem>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AgendaItem>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<AgendaItemTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AgendaItem>(
      where: where(AgendaItem.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AgendaItemTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AgendaItem>(
      where: where?.call(AgendaItem.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class AgendaItemAttachRowRepository {
  const AgendaItemAttachRowRepository._();

  /// Creates a relation between the given [AgendaItem] and [Contact]
  /// by setting the [AgendaItem]'s foreign key `contactId` to refer to the [Contact].
  Future<void> contact(
    _i1.Session session,
    AgendaItem agendaItem,
    _i2.Contact contact, {
    _i1.Transaction? transaction,
  }) async {
    if (agendaItem.id == null) {
      throw ArgumentError.notNull('agendaItem.id');
    }
    if (contact.id == null) {
      throw ArgumentError.notNull('contact.id');
    }

    var $agendaItem = agendaItem.copyWith(contactId: contact.id);
    await session.db.updateRow<AgendaItem>(
      $agendaItem,
      columns: [AgendaItem.t.contactId],
      transaction: transaction,
    );
  }
}
