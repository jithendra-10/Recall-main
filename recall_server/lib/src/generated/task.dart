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

abstract class Task implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = TaskTable();

  static const db = TaskRepository._();

  @override
  int? id;

  int ownerId;

  String title;

  String? description;

  bool isCompleted;

  DateTime? dueDate;

  int relatedContactId;

  _i2.Contact? relatedContact;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Task',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'title': title,
      if (description != null) 'description': description,
      'isCompleted': isCompleted,
      if (dueDate != null) 'dueDate': dueDate?.toJson(),
      'relatedContactId': relatedContactId,
      if (relatedContact != null)
        'relatedContact': relatedContact?.toJsonForProtocol(),
      'createdAt': createdAt.toJson(),
    };
  }

  static TaskInclude include({_i2.ContactInclude? relatedContact}) {
    return TaskInclude._(relatedContact: relatedContact);
  }

  static TaskIncludeList includeList({
    _i1.WhereExpressionBuilder<TaskTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TaskTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TaskTable>? orderByList,
    TaskInclude? include,
  }) {
    return TaskIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Task.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Task.t),
      include: include,
    );
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

class TaskUpdateTable extends _i1.UpdateTable<TaskTable> {
  TaskUpdateTable(super.table);

  _i1.ColumnValue<int, int> ownerId(int value) => _i1.ColumnValue(
    table.ownerId,
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

  _i1.ColumnValue<bool, bool> isCompleted(bool value) => _i1.ColumnValue(
    table.isCompleted,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> dueDate(DateTime? value) =>
      _i1.ColumnValue(
        table.dueDate,
        value,
      );

  _i1.ColumnValue<int, int> relatedContactId(int value) => _i1.ColumnValue(
    table.relatedContactId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class TaskTable extends _i1.Table<int?> {
  TaskTable({super.tableRelation}) : super(tableName: 'recall_task') {
    updateTable = TaskUpdateTable(this);
    ownerId = _i1.ColumnInt(
      'ownerId',
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
    isCompleted = _i1.ColumnBool(
      'isCompleted',
      this,
    );
    dueDate = _i1.ColumnDateTime(
      'dueDate',
      this,
    );
    relatedContactId = _i1.ColumnInt(
      'relatedContactId',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final TaskUpdateTable updateTable;

  late final _i1.ColumnInt ownerId;

  late final _i1.ColumnString title;

  late final _i1.ColumnString description;

  late final _i1.ColumnBool isCompleted;

  late final _i1.ColumnDateTime dueDate;

  late final _i1.ColumnInt relatedContactId;

  _i2.ContactTable? _relatedContact;

  late final _i1.ColumnDateTime createdAt;

  _i2.ContactTable get relatedContact {
    if (_relatedContact != null) return _relatedContact!;
    _relatedContact = _i1.createRelationTable(
      relationFieldName: 'relatedContact',
      field: Task.t.relatedContactId,
      foreignField: _i2.Contact.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.ContactTable(tableRelation: foreignTableRelation),
    );
    return _relatedContact!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    ownerId,
    title,
    description,
    isCompleted,
    dueDate,
    relatedContactId,
    createdAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'relatedContact') {
      return relatedContact;
    }
    return null;
  }
}

class TaskInclude extends _i1.IncludeObject {
  TaskInclude._({_i2.ContactInclude? relatedContact}) {
    _relatedContact = relatedContact;
  }

  _i2.ContactInclude? _relatedContact;

  @override
  Map<String, _i1.Include?> get includes => {'relatedContact': _relatedContact};

  @override
  _i1.Table<int?> get table => Task.t;
}

class TaskIncludeList extends _i1.IncludeList {
  TaskIncludeList._({
    _i1.WhereExpressionBuilder<TaskTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Task.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Task.t;
}

class TaskRepository {
  const TaskRepository._();

  final attachRow = const TaskAttachRowRepository._();

  /// Returns a list of [Task]s matching the given query parameters.
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
  Future<List<Task>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TaskTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TaskTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TaskTable>? orderByList,
    _i1.Transaction? transaction,
    TaskInclude? include,
  }) async {
    return session.db.find<Task>(
      where: where?.call(Task.t),
      orderBy: orderBy?.call(Task.t),
      orderByList: orderByList?.call(Task.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [Task] matching the given query parameters.
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
  Future<Task?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TaskTable>? where,
    int? offset,
    _i1.OrderByBuilder<TaskTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TaskTable>? orderByList,
    _i1.Transaction? transaction,
    TaskInclude? include,
  }) async {
    return session.db.findFirstRow<Task>(
      where: where?.call(Task.t),
      orderBy: orderBy?.call(Task.t),
      orderByList: orderByList?.call(Task.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [Task] by its [id] or null if no such row exists.
  Future<Task?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    TaskInclude? include,
  }) async {
    return session.db.findById<Task>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [Task]s in the list and returns the inserted rows.
  ///
  /// The returned [Task]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Task>> insert(
    _i1.Session session,
    List<Task> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Task>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Task] and returns the inserted row.
  ///
  /// The returned [Task] will have its `id` field set.
  Future<Task> insertRow(
    _i1.Session session,
    Task row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Task>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Task]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Task>> update(
    _i1.Session session,
    List<Task> rows, {
    _i1.ColumnSelections<TaskTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Task>(
      rows,
      columns: columns?.call(Task.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Task]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Task> updateRow(
    _i1.Session session,
    Task row, {
    _i1.ColumnSelections<TaskTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Task>(
      row,
      columns: columns?.call(Task.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Task] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Task?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<TaskUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Task>(
      id,
      columnValues: columnValues(Task.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Task]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Task>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<TaskUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<TaskTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TaskTable>? orderBy,
    _i1.OrderByListBuilder<TaskTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Task>(
      columnValues: columnValues(Task.t.updateTable),
      where: where(Task.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Task.t),
      orderByList: orderByList?.call(Task.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Task]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Task>> delete(
    _i1.Session session,
    List<Task> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Task>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Task].
  Future<Task> deleteRow(
    _i1.Session session,
    Task row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Task>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Task>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<TaskTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Task>(
      where: where(Task.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TaskTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Task>(
      where: where?.call(Task.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class TaskAttachRowRepository {
  const TaskAttachRowRepository._();

  /// Creates a relation between the given [Task] and [Contact]
  /// by setting the [Task]'s foreign key `relatedContactId` to refer to the [Contact].
  Future<void> relatedContact(
    _i1.Session session,
    Task task,
    _i2.Contact relatedContact, {
    _i1.Transaction? transaction,
  }) async {
    if (task.id == null) {
      throw ArgumentError.notNull('task.id');
    }
    if (relatedContact.id == null) {
      throw ArgumentError.notNull('relatedContact.id');
    }

    var $task = task.copyWith(relatedContactId: relatedContact.id);
    await session.db.updateRow<Task>(
      $task,
      columns: [Task.t.relatedContactId],
      transaction: transaction,
    );
  }
}
