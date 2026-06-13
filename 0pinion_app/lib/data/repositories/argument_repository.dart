import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/providers/supabase_provider.dart';
import '../models/argument.dart';

final argumentRepositoryProvider = Provider<ArgumentRepository>((ref) {
  return ArgumentRepository(ref.watch(supabaseClientProvider));
});

class ArgumentRepository {
  final SupabaseClient _supabase;

  ArgumentRepository(this._supabase);

  Stream<List<Argument>> watchArguments(String opinionId) {
    return _supabase
        .from('arguments')
        .stream(primaryKey: ['id'])
        .eq('opinion_id', opinionId)
        .order('created_at', ascending: true)
        .asyncMap((data) async {
          // Because stream() doesn't support joined selects directly, fetch relations manually via select
          final res = await _supabase.from('arguments').select(
              '*, profiles!arguments_author_id_fkey(username)'
          ).eq('opinion_id', opinionId).order('created_at', ascending: true);
          return res.map((json) => Argument.fromJson(json)).toList();
        });
  }

  Future<void> createArgument({
    required String opinionId,
    required String authorId,
    required String type,
    required String content,
    required bool isAnonymous,
  }) async {
    await _supabase.from('arguments').insert({
      'opinion_id': opinionId,
      'author_id': authorId,
      'type': type,
      'content': content,
      'is_anonymous': isAnonymous,
    });
  }

  Future<void> deleteArgument(String argumentId) async {
    await _supabase.from('arguments').delete().eq('id', argumentId);
  }
}
