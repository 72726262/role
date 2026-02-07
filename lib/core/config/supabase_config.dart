/// Supabase Configuration
/// IMPORTANT: Set your actual values in .env file
class SupabaseConfig {
  // Supabase credentials - Replace with your own!
  // Get from: Supabase Dashboard → Project Settings → API
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mwruqqjbaqqdygbrggmd.supabase.co', // Replace this!
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'sb_publishable_1MaRHmBDHUmg_TkyvsyuLQ_9p0ci1HW', // Replace this!
  );

  // Storage buckets
  static const String documentsBucket = 'documents';
  static const String imagesBucket = 'images';
  static const String videosBucket = 'videos';
}
