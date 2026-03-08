import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings state
class SettingsState {
  final bool notificationsEnabled;
  final bool isLoading;

  SettingsState({this.notificationsEnabled = false, this.isLoading = false});

  SettingsState copyWith({bool? notificationsEnabled, bool? isLoading}) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Settings notifier
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _loadSettings();
    return SettingsState();
  }

  static const String _notificationsKey = 'notifications_enabled';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool(_notificationsKey) ?? false;
      state = state.copyWith(notificationsEnabled: notificationsEnabled);
    } catch (e) {
      // Keep default settings if loading fails
    }
  }

  Future<void> toggleNotifications() async {
    try {
      final newValue = !state.notificationsEnabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, newValue);
      state = state.copyWith(notificationsEnabled: newValue);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setNotifications(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, value);
      state = state.copyWith(notificationsEnabled: value);
    } catch (e) {
      // Handle error silently
    }
  }
}

// Settings provider
final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(() {
      return SettingsNotifier();
    });

