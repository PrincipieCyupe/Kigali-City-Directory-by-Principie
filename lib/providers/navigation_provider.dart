import 'package:flutter_riverpod/flutter_riverpod.dart';

// Navigation state notifier for bottom navigation
class NavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

// Provider for bottom navigation index
final bottomNavIndexProvider = NotifierProvider<NavigationNotifier, int>(() {
  return NavigationNotifier();
});

