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
import 'agenda_item.dart' as _i2;
import 'chat_message.dart' as _i3;
import 'chat_session.dart' as _i4;
import 'contact.dart' as _i5;
import 'dashboard_data.dart' as _i6;
import 'greetings/greeting.dart' as _i7;
import 'interaction.dart' as _i8;
import 'interaction_summary.dart' as _i9;
import 'notification.dart' as _i10;
import 'setup_status.dart' as _i11;
import 'task.dart' as _i12;
import 'user_config.dart' as _i13;
import 'package:recall_client/src/protocol/contact.dart' as _i14;
import 'package:recall_client/src/protocol/interaction_summary.dart' as _i15;
import 'package:recall_client/src/protocol/agenda_item.dart' as _i16;
import 'package:recall_client/src/protocol/chat_session.dart' as _i17;
import 'package:recall_client/src/protocol/chat_message.dart' as _i18;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i19;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i20;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i21;
export 'agenda_item.dart';
export 'chat_message.dart';
export 'chat_session.dart';
export 'contact.dart';
export 'dashboard_data.dart';
export 'greetings/greeting.dart';
export 'interaction.dart';
export 'interaction_summary.dart';
export 'notification.dart';
export 'setup_status.dart';
export 'task.dart';
export 'user_config.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.AgendaItem) {
      return _i2.AgendaItem.fromJson(data) as T;
    }
    if (t == _i3.ChatMessage) {
      return _i3.ChatMessage.fromJson(data) as T;
    }
    if (t == _i4.ChatSession) {
      return _i4.ChatSession.fromJson(data) as T;
    }
    if (t == _i5.Contact) {
      return _i5.Contact.fromJson(data) as T;
    }
    if (t == _i6.DashboardData) {
      return _i6.DashboardData.fromJson(data) as T;
    }
    if (t == _i7.Greeting) {
      return _i7.Greeting.fromJson(data) as T;
    }
    if (t == _i8.Interaction) {
      return _i8.Interaction.fromJson(data) as T;
    }
    if (t == _i9.InteractionSummary) {
      return _i9.InteractionSummary.fromJson(data) as T;
    }
    if (t == _i10.Notification) {
      return _i10.Notification.fromJson(data) as T;
    }
    if (t == _i11.SetupStatus) {
      return _i11.SetupStatus.fromJson(data) as T;
    }
    if (t == _i12.Task) {
      return _i12.Task.fromJson(data) as T;
    }
    if (t == _i13.UserConfig) {
      return _i13.UserConfig.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AgendaItem?>()) {
      return (data != null ? _i2.AgendaItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ChatMessage?>()) {
      return (data != null ? _i3.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ChatSession?>()) {
      return (data != null ? _i4.ChatSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Contact?>()) {
      return (data != null ? _i5.Contact.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.DashboardData?>()) {
      return (data != null ? _i6.DashboardData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Greeting?>()) {
      return (data != null ? _i7.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Interaction?>()) {
      return (data != null ? _i8.Interaction.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.InteractionSummary?>()) {
      return (data != null ? _i9.InteractionSummary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Notification?>()) {
      return (data != null ? _i10.Notification.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.SetupStatus?>()) {
      return (data != null ? _i11.SetupStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Task?>()) {
      return (data != null ? _i12.Task.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.UserConfig?>()) {
      return (data != null ? _i13.UserConfig.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i9.InteractionSummary>) {
      return (data as List)
              .map((e) => deserialize<_i9.InteractionSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i5.Contact>) {
      return (data as List).map((e) => deserialize<_i5.Contact>(e)).toList()
          as T;
    }
    if (t == List<_i14.Contact>) {
      return (data as List).map((e) => deserialize<_i14.Contact>(e)).toList()
          as T;
    }
    if (t == List<_i15.InteractionSummary>) {
      return (data as List)
              .map((e) => deserialize<_i15.InteractionSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i16.AgendaItem>) {
      return (data as List).map((e) => deserialize<_i16.AgendaItem>(e)).toList()
          as T;
    }
    if (t == List<_i17.ChatSession>) {
      return (data as List)
              .map((e) => deserialize<_i17.ChatSession>(e))
              .toList()
          as T;
    }
    if (t == List<_i18.ChatMessage>) {
      return (data as List)
              .map((e) => deserialize<_i18.ChatMessage>(e))
              .toList()
          as T;
    }
    try {
      return _i19.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i20.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i21.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AgendaItem => 'AgendaItem',
      _i3.ChatMessage => 'ChatMessage',
      _i4.ChatSession => 'ChatSession',
      _i5.Contact => 'Contact',
      _i6.DashboardData => 'DashboardData',
      _i7.Greeting => 'Greeting',
      _i8.Interaction => 'Interaction',
      _i9.InteractionSummary => 'InteractionSummary',
      _i10.Notification => 'Notification',
      _i11.SetupStatus => 'SetupStatus',
      _i12.Task => 'Task',
      _i13.UserConfig => 'UserConfig',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('recall.', '');
    }

    switch (data) {
      case _i2.AgendaItem():
        return 'AgendaItem';
      case _i3.ChatMessage():
        return 'ChatMessage';
      case _i4.ChatSession():
        return 'ChatSession';
      case _i5.Contact():
        return 'Contact';
      case _i6.DashboardData():
        return 'DashboardData';
      case _i7.Greeting():
        return 'Greeting';
      case _i8.Interaction():
        return 'Interaction';
      case _i9.InteractionSummary():
        return 'InteractionSummary';
      case _i10.Notification():
        return 'Notification';
      case _i11.SetupStatus():
        return 'SetupStatus';
      case _i12.Task():
        return 'Task';
      case _i13.UserConfig():
        return 'UserConfig';
    }
    className = _i19.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i20.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    className = _i21.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AgendaItem') {
      return deserialize<_i2.AgendaItem>(data['data']);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i3.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatSession') {
      return deserialize<_i4.ChatSession>(data['data']);
    }
    if (dataClassName == 'Contact') {
      return deserialize<_i5.Contact>(data['data']);
    }
    if (dataClassName == 'DashboardData') {
      return deserialize<_i6.DashboardData>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i7.Greeting>(data['data']);
    }
    if (dataClassName == 'Interaction') {
      return deserialize<_i8.Interaction>(data['data']);
    }
    if (dataClassName == 'InteractionSummary') {
      return deserialize<_i9.InteractionSummary>(data['data']);
    }
    if (dataClassName == 'Notification') {
      return deserialize<_i10.Notification>(data['data']);
    }
    if (dataClassName == 'SetupStatus') {
      return deserialize<_i11.SetupStatus>(data['data']);
    }
    if (dataClassName == 'Task') {
      return deserialize<_i12.Task>(data['data']);
    }
    if (dataClassName == 'UserConfig') {
      return deserialize<_i13.UserConfig>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i19.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i20.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i21.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
