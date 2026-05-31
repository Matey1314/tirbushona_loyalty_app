import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global User State Controller
/// Manages reactive state for user data (name, phone, etc.)
/// Syncs changes to both SharedPreferences and Supabase automatically
class UserState {
  static final UserState _instance = UserState._internal();

  factory UserState() {
    return _instance;
  }

  UserState._internal();

  // User Name - Reactive and Persistent
  final ValueNotifier<String> userName = ValueNotifier<String>('Матей');

  // User Phone - Reactive and Persistent
  final ValueNotifier<String> userPhone = ValueNotifier<String>('0877537301');

  // User Physical Card - Reactive and Persistent
  final ValueNotifier<String> userPhysicalCard = ValueNotifier<String>('10010066');

  // User Logistic Number - Reactive and Persistent
  final ValueNotifier<String> userLogisticNumber = ValueNotifier<String>('0476');

  // User DOB - Reactive and Persistent
  final ValueNotifier<String> userDOB = ValueNotifier<String>('13 / 02 / 1986');

  // User ID for Supabase sync
  String? _userId;

  /// Initialize state from SharedPreferences and sync with Supabase
  /// Call this on app startup
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved values or use defaults
    userName.value = prefs.getString('userName') ?? userName.value;
    userPhone.value = prefs.getString('userPhone') ?? userPhone.value;
    userPhysicalCard.value =
        prefs.getString('userPhysicalCard') ?? userPhysicalCard.value;
    userLogisticNumber.value =
        prefs.getString('userLogisticNumber') ?? userLogisticNumber.value;
    userDOB.value = prefs.getString('userDOB') ?? userDOB.value;

    // Get user ID from Supabase session
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _userId = session.user.id;
      // Sync with Supabase to get latest data from server
      await _syncFromSupabase();
    }
  }

  /// Sync user data from Supabase to local state
  Future<void> _syncFromSupabase() async {
    try {
      if (_userId == null) return;

      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', _userId!)
          .single();

      userName.value = response['user_name'] ?? userName.value;
      userPhone.value = response['user_phone'] ?? userPhone.value;
      userPhysicalCard.value =
          response['user_physical_card'] ?? userPhysicalCard.value;
      userLogisticNumber.value =
          response['user_logistic_number'] ?? userLogisticNumber.value;
      userDOB.value = response['user_dob'] ?? userDOB.value;

      // Also update local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', userName.value);
      await prefs.setString('userPhone', userPhone.value);
      await prefs.setString('userPhysicalCard', userPhysicalCard.value);
      await prefs.setString('userLogisticNumber', userLogisticNumber.value);
      await prefs.setString('userDOB', userDOB.value);
        } catch (e) {
      if (kDebugMode) {
        print('Error syncing from Supabase: $e');
      }
    }
  }

  /// Update user name and sync to both SharedPreferences and Supabase
  Future<void> setUserName(String newName) async {
    userName.value = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);
    await _updateSupabase({'user_name': newName});
  }

  /// Update user phone and sync to both SharedPreferences and Supabase
  Future<void> setUserPhone(String newPhone) async {
    userPhone.value = newPhone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhone', newPhone);
    await _updateSupabase({'user_phone': newPhone});
  }

  /// Update physical card number and sync to both SharedPreferences and Supabase
  Future<void> setUserPhysicalCard(String newCard) async {
    userPhysicalCard.value = newCard;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhysicalCard', newCard);
    await _updateSupabase({'user_physical_card': newCard});
  }

  /// Update logistic number and sync to both SharedPreferences and Supabase
  Future<void> setUserLogisticNumber(String newNumber) async {
    userLogisticNumber.value = newNumber;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userLogisticNumber', newNumber);
    await _updateSupabase({'user_logistic_number': newNumber});
  }

  /// Update user DOB and sync to both SharedPreferences and Supabase
  Future<void> setUserDOB(String newDOB) async {
    userDOB.value = newDOB;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userDOB', newDOB);
    await _updateSupabase({'user_dob': newDOB});
  }

  /// Update user data in Supabase
  Future<void> _updateSupabase(Map<String, dynamic> data) async {
    try {
      if (_userId == null) return;

      await Supabase.instance.client
          .from('users')
          .update(data)
          .eq('id', _userId!);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating Supabase: $e');
      }
    }
  }

  /// Clear all user data from local storage and Supabase
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userName.value = 'Матей';
    userPhone.value = '0877537301';
    userPhysicalCard.value = '10010066';
    userLogisticNumber.value = '0476';
    userDOB.value = '13 / 02 / 1986';

    // Clear from Supabase
    if (_userId != null) {
      try {
        await Supabase.instance.client
            .from('users')
            .update({
              'user_name': userName.value,
              'user_phone': userPhone.value,
              'user_physical_card': userPhysicalCard.value,
              'user_logistic_number': userLogisticNumber.value,
              'user_dob': userDOB.value,
            })
            .eq('id', _userId!);
      } catch (e) {
        if (kDebugMode) {
          print('Error clearing Supabase data: $e');
        }
      }
    }
  }
}
