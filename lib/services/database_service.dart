import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/news_model.dart';
import '../models/event_model.dart';
import '../models/mood_model.dart';
import '../models/hr_policy_model.dart';
import '../models/training_course_model.dart';
import '../models/it_policy_model.dart';
import '../models/management_message_model.dart';
import '../models/navigation_link_model.dart';
import '../models/employee_profile_model.dart';
import '../models/user_model.dart';

/// Database Service - handles all database operations with offline support
class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Connectivity _connectivity = Connectivity();

  // Hive boxes for caching
  static const String _newsBoxName = 'news_cache';
  static const String _eventsBoxName = 'events_cache';
  static const String _moodsBoxName = 'moods_cache';
  static const String _linksBoxName = 'links_cache';

  /// Initialize Hive for offline caching
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Open boxes for caching
    await Hive.openBox(_newsBoxName);
    await Hive.openBox(_eventsBoxName);
    await Hive.openBox(_moodsBoxName);
    await Hive.openBox(_linksBoxName);
  }

  /// Check if device is online
  Future<bool> get isOnline async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // ============================================
  // NEWS OPERATIONS
  // ============================================

  /// Get all published news (with offline support)
  Future<List<NewsModel>> getNews() async {
    try {
      final Box newsBox = Hive.box(_newsBoxName);
      final online = await isOnline;

      if (online) {
        // Fetch from Supabase
        final response = await _supabase
            .from('news')
            .select()
            .eq('is_published', true)
            .order('published_at', ascending: false);

        final news = (response as List)
            .map((json) => NewsModel.fromJson(json))
            .toList();

        // Cache the data
        await newsBox.clear();
        for (var item in news) {
          await newsBox.put(item.id, item.toJson());
        }

        return news;
      } else {
        // Load from cache
        final cachedNews = newsBox.values
            .map((json) => NewsModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        return cachedNews;
      }
    } catch (e) {
      // On error, try to load from cache
      final Box newsBox = Hive.box(_newsBoxName);
      final cachedNews = newsBox.values
          .map((json) => NewsModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return cachedNews;
    }
  }

  /// Get news by ID
  Future<NewsModel?> getNewsById(String id) async {
    try {
      final response = await _supabase
          .from('news')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return NewsModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Create news (Admin/Management only)
  Future<NewsModel> createNews(NewsModel news) async {
    try {
      final response = await _supabase
          .from('news')
          .insert(news.toJson())
          .select()
          .single();

      return NewsModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update news
  Future<NewsModel> updateNews(NewsModel news) async {
    try {
      final response = await _supabase
          .from('news')
          .update(news.toJson())
          .eq('id', news.id)
          .select()
          .single();

      return NewsModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete news
  Future<void> deleteNews(String id) async {
    try {
      await _supabase.from('news').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // EVENTS OPERATIONS  
  // ============================================

  /// Get all active events (with offline support)
  Future<List<EventModel>> getEvents() async {
    try {
      final Box eventsBox = Hive.box(_eventsBoxName);
      final online = await isOnline;

      if (online) {
        final response = await _supabase
            .from('events')
            .select()
            .eq('is_active', true)
            .order('event_date', ascending: true);

        final events = (response as List)
            .map((json) => EventModel.fromJson(json))
            .toList();

        // Cache the data
        await eventsBox.clear();
        for (var item in events) {
          await eventsBox.put(item.id, item.toJson());
        }

        return events;
      } else {
        final cachedEvents = eventsBox.values
            .map((json) => EventModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        return cachedEvents;
      }
    } catch (e) {
      final Box eventsBox = Hive.box(_eventsBoxName);
      final cachedEvents = eventsBox.values
          .map((json) => EventModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return cachedEvents;
    }
  }

  /// Create event
  Future<EventModel> createEvent(EventModel event) async {
    try {
      final response = await _supabase
          .from('events')
          .insert(event.toJson())
          .select()
          .single();

      return EventModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update event
  Future<EventModel> updateEvent(EventModel event) async {
    try {
      final response = await _supabase
          .from('events')
          .update(event.toJson())
          .eq('id', event.id)
          .select()
          .single();

      return EventModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete event
  Future<void> deleteEvent(String id) async {
    try {
      await _supabase.from('events').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // MOOD OPERATIONS
  // ============================================

  /// Submit daily mood
  Future<MoodModel> submitMood(MoodModel mood) async {
    try {
      final response = await _supabase
          .from('moods')
          .insert(mood.toJson())
          .select()
          .single();

      return MoodModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user submitted mood today
  Future<bool> hasMoodToday(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final response = await _supabase
          .from('moods')
          .select()
          .eq('user_id', userId)
          .gte('recorded_at', startOfDay.toIso8601String())
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // GENERIC CRUD OPERATIONS
  // ============================================

  /// Get all records from a table
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    try {
      final response = await _supabase.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a single record by ID
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new record
  Future<Map<String, dynamic>?> create(String table, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(table)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Update a record by ID
  Future<Map<String, dynamic>?> update(String table, String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(table)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a record by ID
  Future<void> delete(String table, String id) async {
    try {
      await _supabase
          .from(table)
          .delete()
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
  /// Alias for hasMoodToday - used by employee_dashboard_cubit
  Future<bool> checkMoodSubmittedToday(String userId) async {
    return hasMoodToday(userId);
  }

  /// Create mood - simple interface for mood submission
  Future<void> createMood({
    required String userId,
    required String moodType,
    String? notes,
  }) async {
    final mood = MoodModel(
      id: '', // Will be generated by Supabase
      userId: userId,
      moodType: moodType,
      notes: notes,
      recordedAt: DateTime.now(),
    );
    await submitMood(mood);
  }

  /// Get mood statistics (for HR/Management)
  Future<Map<String, int>> getMoodStatistics() async {
    try {
      final response = await _supabase
          .from('moods')
          .select('mood_type');

      final moods = response as List;
      final stats = <String, int>{
        'happy': 0,
        'normal': 0,
        'tired': 0,
        'need_support': 0,
      };

      for (var mood in moods) {
        final type = mood['mood_type'] as String;
        stats[type] = (stats[type] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // HR POLICIES OPERATIONS
  // ============================================

  /// Get all active HR policies
  Future<List<HRPolicyModel>> getHRPolicies() async {
    try {
      final response = await _supabase
          .from('hr_policies')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => HRPolicyModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create HR policy
  Future<HRPolicyModel> createHRPolicy(HRPolicyModel policy) async {
    try {
      final response = await _supabase
          .from('hr_policies')
          .insert(policy.toJson())
          .select()
          .single();

      return HRPolicyModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update HR policy
  Future<HRPolicyModel> updateHRPolicy(HRPolicyModel policy) async {
    try {
      final response = await _supabase
          .from('hr_policies')
          .update(policy.toJson())
          .eq('id', policy.id)
          .select()
          .single();

      return HRPolicyModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete HR policy
  Future<void> deleteHRPolicy(String id) async {
    try {
      await _supabase.from('hr_policies').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // TRAINING COURSES OPERATIONS
  // ============================================

  /// Get all active training courses
  Future<List<TrainingCourseModel>> getTrainingCourses() async {
    try {
      final response = await _supabase
          .from('training_courses')
          .select()
          .eq('is_active', true)
          .order('start_date', ascending: true);

      return (response as List)
          .map((json) => TrainingCourseModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create training course
  Future<TrainingCourseModel> createTrainingCourse(TrainingCourseModel course) async {
    try {
      final response = await _supabase
          .from('training_courses')
          .insert(course.toJson())
          .select()
          .single();

      return TrainingCourseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update training course
  Future<TrainingCourseModel> updateTrainingCourse(TrainingCourseModel course) async {
    try {
      final response = await _supabase
          .from('training_courses')
          .update(course.toJson())
          .eq('id', course.id)
          .select()
          .single();

      return TrainingCourseModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete training course
  Future<void> deleteTrainingCourse(String id) async {
    try {
      await _supabase.from('training_courses').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // IT POLICIES OPERATIONS
  // ============================================

  /// Get all active IT policies
  Future<List<ITPolicyModel>> getITPolicies() async {
    try {
      final response = await _supabase
          .from('it_policies')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ITPolicyModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create IT policy
  Future<ITPolicyModel> createITPolicy(ITPolicyModel policy) async {
    try {
      final response = await _supabase
          .from('it_policies')
          .insert(policy.toJson())
          .select()
          .single();

      return ITPolicyModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update IT policy
  Future<ITPolicyModel> updateITPolicy(ITPolicyModel policy) async {
    try {
      final response = await _supabase
          .from('it_policies')
          .update(policy.toJson())
          .eq('id', policy.id)
          .select()
          .single();

      return ITPolicyModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete IT policy
  Future<void> deleteITPolicy(String id) async {
    try {
      await _supabase.from('it_policies').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // MANAGEMENT MESSAGES OPERATIONS
  // ============================================

  /// Get visible management messages
  Future<List<ManagementMessageModel>> getManagementMessages() async {
    try {
      final response = await _supabase
          .from('management_messages')
          .select()
          .eq('is_visible', true)
          .order('published_at', ascending: false);

      return (response as List)
          .map((json) => ManagementMessageModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create management message
  Future<ManagementMessageModel> createManagementMessage(ManagementMessageModel message) async {
    try {
      final response = await _supabase
          .from('management_messages')
          .insert(message.toJson())
          .select()
          .single();

      return ManagementMessageModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update management message
  Future<ManagementMessageModel> updateManagementMessage(ManagementMessageModel message) async {
    try {
      final response = await _supabase
          .from('management_messages')
          .update(message.toJson())
          .eq('id', message.id)
          .select()
          .single();

      return ManagementMessageModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // NAVIGATION LINKS OPERATIONS
  // ============================================

  /// Get all active navigation links (with offline support)
  Future<List<NavigationLinkModel>> getNavigationLinks() async {
    try {
      final Box linksBox = Hive.box(_linksBoxName);
      final online = await isOnline;

      if (online) {
        final response = await _supabase
            .from('navigation_links')
            .select()
            .eq('is_active', true)
            .order('display_order', ascending: true);

        final links = (response as List)
            .map((json) => NavigationLinkModel.fromJson(json))
            .toList();

        // Cache the data
        await linksBox.clear();
        for (var item in links) {
          await linksBox.put(item.id, item.toJson());
        }

        return links;
      } else {
        final cachedLinks = linksBox.values
            .map((json) => NavigationLinkModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        return cachedLinks;
      }
    } catch (e) {
      final Box linksBox = Hive.box(_linksBoxName);
      final cachedLinks = linksBox.values
          .map((json) => NavigationLinkModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return cachedLinks;
    }
  }

  /// Create navigation link
  Future<NavigationLinkModel> createNavigationLink(NavigationLinkModel link) async {
    try {
      final response = await _supabase
          .from('navigation_links')
          .insert(link.toJson())
          .select()
          .single();

      return NavigationLinkModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update navigation link
  Future<NavigationLinkModel> updateNavigationLink(NavigationLinkModel link) async {
    try {
      final response = await _supabase
          .from('navigation_links')
          .update(link.toJson())
          .eq('id', link.id)
          .select()
          .single();

      return NavigationLinkModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete navigation link
  Future<void> deleteNavigationLink(String id) async {
    try {
      await _supabase.from('navigation_links').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // EMPLOYEE PROFILE OPERATIONS
  // ============================================

  /// Get employee profile by user ID
  Future<EmployeeProfileModel?> getEmployeeProfile(String userId) async {
    try {
      final response = await _supabase
          .from('employee_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return EmployeeProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update employee profile
  Future<EmployeeProfileModel> updateEmployeeProfile(EmployeeProfileModel profile) async {
    try {
      final response = await _supabase
          .from('employee_profiles')
          .update(profile.toJson())
          .eq('user_id', profile.userId)
          .select()
          .single();

      return EmployeeProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // USER OPERATIONS
  // ============================================

  /// Get total employees count (for dashboards)
  Future<int> getTotalEmployeesCount() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .count(CountOption.exact);
      
      // Count is in the response metadata
      return response.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*, roles:role_id(role_name, id)')
          .order('full_name', ascending: true);

      return (response as List).map((json) {
        // Flatten the role data
        if (json['roles'] != null) {
          json['role_name'] = json['roles']['role_name'];
        }
        return UserModel.fromJson(json);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create user
  Future<UserModel> createUser(UserModel user) async {
    try {
      final response = await _supabase
          .from('users')
          .insert(user.toJson())
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final response = await _supabase
          .from('users')
          .update(user.toJson())
          .eq('id', user.id)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    try {
      await _supabase.from('users').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  /// Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*, roles:role_id(role_name, id)')
          .or('full_name.ilike.%$query%,email.ilike.%$query%')
          .order('full_name');

      return (response as List).map((json) {
        if (json['roles'] != null) {
          json['role_name'] = json['roles']['role_name'];
        }
        return UserModel.fromJson(json);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get users by role
  Future<List<UserModel>> getUsersByRole(String roleName) async {
    try {
      // First get the role ID
      final roleResponse = await _supabase
          .from('roles')
          .select('id')
          .eq('role_name', roleName)
          .maybeSingle();

      if (roleResponse == null) {
        return [];
      }

      final roleId = roleResponse['id'] as String;

      final response = await _supabase
          .from('users')
          .select('*, roles:role_id(role_name, id)')
          .eq('role_id', roleId)
          .order('full_name');

      return (response as List).map((json) {
        if (json['roles'] != null) {
          json['role_name'] = json['roles']['role_name'];
        }
        return UserModel.fromJson(json);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle user active status
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _supabase
          .from('users')
          .update({'is_active': isActive})
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
