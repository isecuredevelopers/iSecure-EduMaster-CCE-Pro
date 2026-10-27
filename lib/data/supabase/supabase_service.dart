import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/school_model.dart';
import '../models/student_model.dart';
import '../models/evaluation_model.dart';
import '../models/descriptive_note_model.dart';
import '../models/attendance_model.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  static bool get isConfigured => _isInitialized && _client != null;

  static Future<bool> initialize({required String url, required String anonKey}) async {
    try {
      if (url.trim().isEmpty || anonKey.trim().isEmpty) return false;
      await Supabase.initialize(
        url: url.trim(),
        anonKey: anonKey.trim(),
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      return true;
    } catch (e) {
      // Offline fallback
      return false;
    }
  }

  static SupabaseClient? get client => _client;

  // Cloud sync methods
  static Future<bool> saveSchoolToCloud(SchoolModel school) async {
    if (!isConfigured) return false;
    try {
      await _client!.from('schools').upsert(school.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> saveStudentToCloud(StudentModel student) async {
    if (!isConfigured) return false;
    try {
      await _client!.from('students').upsert(student.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> saveEvaluationToCloud(EvaluationModel eval) async {
    if (!isConfigured) return false;
    try {
      await _client!.from('evaluations').upsert(eval.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> saveDescriptiveNoteToCloud(DescriptiveNoteModel note) async {
    if (!isConfigured) return false;
    try {
      await _client!.from('descriptive_notes').upsert(note.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> saveAttendanceToCloud(AttendanceModel att) async {
    if (!isConfigured) return false;
    try {
      await _client!.from('student_attendance').upsert(att.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}
