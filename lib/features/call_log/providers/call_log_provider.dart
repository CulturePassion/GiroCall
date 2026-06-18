import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase_provider.dart';
import '../../../shared/models/call_log.dart';

/// Repository for call logs.
class CallLogRepository {
  final SupabaseClient _client;

  const CallLogRepository(this._client);

  String? get userId => _client.auth.currentUser?.id;

  Future<List<CallLog>> fetchLogs({String? contactId}) async {
    final userId = this.userId;  // Changed from _userId to this.userId to follow encapsulation rules
    if (userId == null) return [];

    var query = _client.from('call_logs').select().eq('user_id', userId);

    if (contactId != null) {
      query = query.eq('contact_id', contactId);
    }

    final response = await query.order('called_at', ascending: false);
    return (response as List)
        .map((json) => CallLog.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<CallLog> addLog(CallLog log) async {
    final userId = this.userId;  // Changed from _userId to this.userId to follow encapsulation rules
    if (userId == null) throw Exception('User not authenticated');

    final payload = log.copyWith(userId: userId).toJson();
    final response =
        await _client.from('call_logs').insert(payload).select().single();

    return CallLog.fromJson(response);
  }

  Future<void> deleteLog(String id) async {
    final userId = this.userId;  // Changed from _userId to this.userId to follow encapsulation rules
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('call_logs').delete().eq('id', id).eq('user_id', userId);
  }

  Stream<List<CallLog>> watchLogs() {
    final userId = this.userId;  // Changed from _userId to this.userId to follow encapsulation rules
    if (userId == null) return Stream.value([]);

    return _client
        .from('call_logs')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) {
          final logs = rows.map(CallLog.fromJson).toList();
          logs.sort((a, b) => b.calledAt.compareTo(a.calledAt));
          return logs;
        });
  }
}

final callLogRepositoryProvider = Provider<CallLogRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CallLogRepository(client);
});