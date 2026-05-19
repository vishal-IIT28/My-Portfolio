import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:portfolio_website/models/dynamic_project.dart';

/// Singleton SupabaseService for managing all database operations
/// Handles fetching projects, skills, and other portfolio data from Supabase
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  late final SupabaseClient _client;
  bool _isInitialized = false;

  SupabaseService._internal();

  /// Factory constructor returns the singleton instance
  factory SupabaseService() {
    return _instance;
  }

  /// Initialize Supabase client (call this in main.dart)
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    _isInitialized = true;
  }

  /// Whether Supabase has been successfully initialized
  bool get isInitialized => _isInitialized;

  /// Get Supabase client instance (only when initialized)
  SupabaseClient get client => _client;

  // ============================================================================
  // PROJECT OPERATIONS
  // ============================================================================

  /// Fetch all projects from Supabase
  /// Returns: List of project maps with fields: id, title, description, tech_stack,
  ///          image_url, pdf_url, github_url, objective, outcome, category
  Future<List<Map<String, dynamic>>> fetchProjects() async {
    if (!_isInitialized) return [];
    try {
      final response = await _client
          .from('projects')
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  /// Fetch all projects and return typed [DynamicProject] objects.
  /// Falls back to an empty list when Supabase is not initialized
  /// (e.g., during local dev without .env credentials).
  Future<List<DynamicProject>> fetchDynamicProjects() async {
    if (!_isInitialized) return [];
    try {
      final response = await _client
          .from('projects')
          .select(
            'id, title, subtitle, description, objective, outcome, '
            'tech_stack, image_url, pdf_url, github_url, category, '
            'achievement, created_at, code_snippet, code_language',
          )
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response)
          .map(DynamicProject.fromSupabase)
          .toList();
    } catch (e) {
      debugPrint('fetchDynamicProjects error: $e');
      return [];
    }
  }

  /// Fetch a single project by ID
  Future<Map<String, dynamic>?> fetchProjectById(String projectId) async {
    try {
      final response = await _client
          .from('projects')
          .select()
          .eq('id', projectId)
          .single();
      
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch project: $e');
    }
  }

  /// Fetch projects by category (e.g., 'software', 'electronics', 'robotics')
  Future<List<Map<String, dynamic>>> fetchProjectsByCategory(
    String category,
  ) async {
    try {
      final response = await _client
          .from('projects')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch projects by category: $e');
    }
  }

  /// Get signed download URL for PDF or image from Supabase Storage
  String getStorageUrl(String bucketName, String filePath) {
    return _client.storage.from(bucketName).getPublicUrl(filePath);
  }

  /// Get signed temporary URL for private files (valid for time_seconds)
  Future<String> getSignedStorageUrl(
    String bucketName,
    String filePath, {
    int expiresIn = 3600, // 1 hour default
  }) async {
    try {
      return _client.storage
          .from(bucketName)
          .createSignedUrl(filePath, expiresIn);
    } catch (e) {
      throw Exception('Failed to get signed URL: $e');
    }
  }

  // ============================================================================
  // SKILLS OPERATIONS
  // ============================================================================

  /// Fetch all skills grouped by category
  Future<Map<String, List<String>>> fetchSkillsByCategory() async {
    try {
      final response = await _client
          .from('skills')
          .select('category, skill_name')
          .order('category');
      
      final Map<String, List<String>> skillsByCategory = {};
      
      for (var row in response) {
        final category = row['category'] as String;
        final skillName = row['skill_name'] as String;
        
        if (!skillsByCategory.containsKey(category)) {
          skillsByCategory[category] = [];
        }
        skillsByCategory[category]!.add(skillName);
      }
      
      return skillsByCategory;
    } catch (e) {
      throw Exception('Failed to fetch skills: $e');
    }
  }

  // ============================================================================
  // AUTHENTICATION (for future admin panel)
  // ============================================================================

  /// Sign in admin user via email/password
  Future<AuthResponse> signInAdmin(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  /// Sign out admin user
  Future<void> signOutAdmin() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentSession != null;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  // ============================================================================
  // ADMIN OPERATIONS (Create/Update Projects)
  // ============================================================================

  /// Create a new project (requires authentication)
  Future<Map<String, dynamic>> createProject(
    Map<String, dynamic> projectData,
  ) async {
    try {
      if (!isAuthenticated) {
        throw Exception('Must be authenticated to create projects');
      }
      
      final response = await _client
          .from('projects')
          .insert(projectData)
          .select()
          .single();
      
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  /// Update an existing project (requires authentication)
  Future<Map<String, dynamic>> updateProject(
    String projectId,
    Map<String, dynamic> updates,
  ) async {
    try {
      if (!isAuthenticated) {
        throw Exception('Must be authenticated to update projects');
      }
      
      final response = await _client
          .from('projects')
          .update(updates)
          .eq('id', projectId)
          .select()
          .single();
      
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  /// Delete a project (requires authentication)
  Future<void> deleteProject(String projectId) async {
    try {
      if (!isAuthenticated) {
        throw Exception('Must be authenticated to delete projects');
      }
      
      await _client.from('projects').delete().eq('id', projectId);
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  /// Upload file to Supabase Storage
  Future<String> uploadFile(
    String bucketName,
    String filePath,
    List<int> fileBytes,
  ) async {
    try {
      if (!isAuthenticated) {
        throw Exception('Must be authenticated to upload files');
      }
      
      await _client.storage
          .from(bucketName)
          .uploadBinary(filePath, Uint8List.fromList(fileBytes));

      return getStorageUrl(bucketName, filePath);
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // ============================================================================
  // GENERIC CRUD OPERATIONS
  // ============================================================================

  Future<Map<String, dynamic>> createRecord(String table, Map<String, dynamic> data) async {
    try {
      if (!isAuthenticated) throw Exception('Must be authenticated');
      final response = await _client.from(table).insert(data).select().single();
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to create record in $table: $e');
    }
  }

  Future<Map<String, dynamic>> updateRecord(String table, String id, Map<String, dynamic> data) async {
    try {
      if (!isAuthenticated) throw Exception('Must be authenticated');
      final response = await _client.from(table).update(data).eq('id', id).select().single();
      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to update record in $table: $e');
    }
  }

  Future<void> deleteRecord(String table, String id) async {
    try {
      if (!isAuthenticated) throw Exception('Must be authenticated');
      await _client.from(table).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete record in $table: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTable(String table, {String orderBy = 'created_at'}) async {
    try {
      final response = await _client.from(table).select().order(orderBy, ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch $table: $e');
    }
  }
}
