/// Lets screens opened above the tab shell switch the main bottom nav
/// without pushing a second copy of Home, Studies, or Events.
class MainTabs {
  static void Function(int index)? _select;

  static const int home = 0;
  static const int studies = 1;
  static const int events = 2;
  static const int about = 3;
  static const int games = 4;

  static void register(void Function(int index) select) {
    _select = select;
  }

  static void unregister(void Function(int index) select) {
    if (identical(_select, select)) {
      _select = null;
    }
  }

  static void select(int index) {
    _select?.call(index);
  }
}
