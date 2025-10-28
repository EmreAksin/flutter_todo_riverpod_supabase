import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_config.g.dart';

/// Your Supabase project URL
/// Get this from: Supabase Dashboard > Settings > API
const supabaseUrl = 'YOUR_SUPABASE_URL';

/// Your Supabase public API key
/// Get this from: Supabase Dashboard > Settings > API
const supabaseKey = 'YOUR_SUPABASE_ANON_KEY';

/// Provider for Supabase client instance
@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

/// Initialize Supabase with configuration
Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
      eventsPerSecond: 10,
    ),
  );
}
