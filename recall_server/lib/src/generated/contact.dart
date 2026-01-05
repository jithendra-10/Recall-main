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
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:recall_server/src/generated/protocol.dart' as _i2;

abstract class Contact
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = ContactTable();

  static const db = ContactRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static ContactInclude include() {
    return ContactInclude._();
  }

  static ContactIncludeList includeList({
    _i1.WhereExpressionBuilder<ContactTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ContactTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ContactTable>? orderByList,
    ContactInclude? include,
  }) {
    return ContactIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Contact.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Contact.t),
      include: include,
    );
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

class ContactUpdateTable extends _i1.UpdateTable<ContactTable> {
  ContactUpdateTable(super.table);

  _i1.ColumnValue<int, int> ownerId(int value) => _i1.ColumnValue(
    table.ownerId,
    value,
  );

  _i1.ColumnValue<String, String> email(String value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<String, String> name(String? value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> avatarUrl(String? value) => _i1.ColumnValue(
    table.avatarUrl,
    value,
  );

  _i1.ColumnValue<double, double> healthScore(double value) => _i1.ColumnValue(
    table.healthScore,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> lastContacted(DateTime? value) =>
      _i1.ColumnValue(
        table.lastContacted,
        value,
      );

  _i1.ColumnValue<List<String>, List<String>> tags(List<String>? value) =>
      _i1.ColumnValue(
        table.tags,
        value,
      );

  _i1.ColumnValue<String, String> summary(String? value) => _i1.ColumnValue(
    table.summary,
    value,
  );

  _i1.ColumnValue<String, String> bio(String? value) => _i1.ColumnValue(
    table.bio,
    value,
  );

  _i1.ColumnValue<String, String> location(String? value) => _i1.ColumnValue(
    table.location,
    value,
  );

  _i1.ColumnValue<String, String> organization(String? value) =>
      _i1.ColumnValue(
        table.organization,
        value,
      );

  _i1.ColumnValue<int, int> tier(int? value) => _i1.ColumnValue(
    table.tier,
    value,
  );
}

class ContactTable extends _i1.Table<int?> {
  ContactTable({super.tableRelation}) : super(tableName: 'recall_contact') {
    updateTable = ContactUpdateTable(this);
    ownerId = _i1.ColumnInt(
      'ownerId',
      this,
    );
    email = _i1.ColumnString(
      'email',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    avatarUrl = _i1.ColumnString(
      'avatarUrl',
      this,
    );
    healthScore = _i1.ColumnDouble(
      'healthScore',
      this,
    );
    lastContacted = _i1.ColumnDateTime(
      'lastContacted',
      this,
    );
    tags = _i1.ColumnSerializable<List<String>>(
      'tags',
      this,
    );
    summary = _i1.ColumnString(
      'summary',
      this,
    );
    bio = _i1.ColumnString(
      'bio',
      this,
    );
    location = _i1.ColumnString(
      'location',
      this,
    );
    organization = _i1.ColumnString(
      'organization',
      this,
    );
    tier = _i1.ColumnInt(
      'tier',
      this,
    );
  }

  late final ContactUpdateTable updateTable;

  late final _i1.ColumnInt ownerId;

  late final _i1.ColumnString email;

  late final _i1.ColumnString name;

  late final _i1.ColumnString avatarUrl;

  late final _i1.ColumnDouble healthScore;

  late final _i1.ColumnDateTime lastContacted;

  late final _i1.ColumnSerializable<List<String>> tags;

  late final _i1.ColumnString summary;

  late final _i1.ColumnString bio;

  late final _i1.ColumnString location;

  late final _i1.ColumnString organization;

  late final _i1.ColumnInt tier;

  @override
  List<_i1.Column> get columns => [
    id,
    ownerId,
    email,
    name,
    avatarUrl,
    healthScore,
    lastContacted,
    tags,
    summary,
    bio,
    location,
    organization,
    tier,
  ];
}

class ContactInclude extends _i1.IncludeObject {
  ContactInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Contact.t;
}

class ContactIncludeList extends _i1.IncludeList {
  ContactIncludeList._({
    _i1.WhereExpressionBuilder<ContactTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Contact.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Contact.t;
}

class ContactRepository {
  const ContactRepository._();

  /// Returns a list of [Contact]s matching the given query parameters.
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
  Future<List<Contact>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ContactTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ContactTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ContactTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Contact>(
      where: where?.call(Contact.t),
      orderBy: orderBy?.call(Contact.t),
      orderByList: orderByList?.call(Contact.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Contact] matching the given query parameters.
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
  Future<Contact?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ContactTable>? where,
    int? offset,
    _i1.OrderByBuilder<ContactTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ContactTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Contact>(
      where: where?.call(Contact.t),
      orderBy: orderBy?.call(Contact.t),
      orderByList: orderByList?.call(Contact.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Contact] by its [id] or null if no such row exists.
  Future<Contact?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Contact>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Contact]s in the list and returns the inserted rows.
  ///
  /// The returned [Contact]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Contact>> insert(
    _i1.Session session,
    List<Contact> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Contact>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Contact] and returns the inserted row.
  ///
  /// The returned [Contact] will have its `id` field set.
  Future<Contact> insertRow(
    _i1.Session session,
    Contact row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Contact>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Contact]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Contact>> update(
    _i1.Session session,
    List<Contact> rows, {
    _i1.ColumnSelections<ContactTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Contact>(
      rows,
      columns: columns?.call(Contact.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Contact]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Contact> updateRow(
    _i1.Session session,
    Contact row, {
    _i1.ColumnSelections<ContactTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Contact>(
      row,
      columns: columns?.call(Contact.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Contact] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Contact?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<ContactUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Contact>(
      id,
      columnValues: columnValues(Contact.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Contact]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Contact>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<ContactUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ContactTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ContactTable>? orderBy,
    _i1.OrderByListBuilder<ContactTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Contact>(
      columnValues: columnValues(Contact.t.updateTable),
      where: where(Contact.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Contact.t),
      orderByList: orderByList?.call(Contact.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Contact]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Contact>> delete(
    _i1.Session session,
    List<Contact> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Contact>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Contact].
  Future<Contact> deleteRow(
    _i1.Session session,
    Contact row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Contact>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Contact>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ContactTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Contact>(
      where: where(Contact.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ContactTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Contact>(
      where: where?.call(Contact.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
