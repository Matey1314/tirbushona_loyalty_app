import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global User State Controller
/// Manages reactive state for user data (name, phone, etc.)
/// Persists changes to SharedPreferences automatically
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

  /// Initialize state from SharedPreferences
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
  }

  /// Update user name and persist to SharedPreferences
  Future<void> setUserName(String newName) async {
    userName.value = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);
  }

  /// Update user phone and persist to SharedPreferences
  Future<void> setUserPhone(String newPhone) async {
    userPhone.value = newPhone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhone', newPhone);
  }

  /// Update physical card number and persist to SharedPreferences
  Future<void> setUserPhysicalCard(String newCard) async {
    userPhysicalCard.value = newCard;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhysicalCard', newCard);
  }

  /// Update logistic number and persist to SharedPreferences
  Future<void> setUserLogisticNumber(String newNumber) async {
    userLogisticNumber.value = newNumber;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userLogisticNumber', newNumber);
  }

  /// Update user DOB and persist to SharedPreferences
  Future<void> setUserDOB(String newDOB) async {
    userDOB.value = newDOB;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userDOB', newDOB);
  }

  /// Clear all user data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userName.value = 'Матей';
    userPhone.value = '0877537301';
    userPhysicalCard.value = '10010066';
    userLogisticNumber.value = '0476';
    userDOB.value = '13 / 02 / 1986';
  }
}
