import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/providers/supabase_provider.dart';
import '../models/opinion.dart';

final opinionRepositoryProvider = Provider<OpinionRepository>((ref) {
  return OpinionRepository(ref.watch(supabaseClientProvider));
});

class OpinionRepository {
  final SupabaseClient _supabase;

  OpinionRepository(this._supabase);

  Stream<List<Opinion>> watchFeedOpinions() {
    return _supabase
        .from('opinions')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          // Because stream() doesn't support joined selects directly, 
          // we fetch the relations manually, or we can use a raw select query.
          // Since it's a feed, let's just do a Future-based select with relations
          // and emit it when data changes.
          final res = await _supabase.from('opinions').select(
              '*, profiles!opinions_author_id_fkey(username), zeroes(name), arguments(id, type)'
          ).order('created_at', ascending: false);
          return res.map((json) => Opinion.fromJson(json)).toList();
        });
  }

  Future<void> createOpinion({
    required String title,
    required String content,
    required String authorId,
    required bool isAnonymous,
    String? zeroId,
  }) async {
    await _supabase.from('opinions').insert({
      'title': title,
      'content': content,
      'author_id': authorId,
      'is_anonymous': isAnonymous,
      'is_cooking': false,
      'zero_id': zeroId,
    });
  }

  Future<void> deleteOpinion(String opinionId) async {
    await _supabase.from('opinions').delete().eq('id', opinionId);
  }
}
