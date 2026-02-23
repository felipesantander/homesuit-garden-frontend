import 'package:hooks_riverpod/legacy.dart';

final sidebarCollapsedProvider =
    StateNotifierProvider<SidebarCollapsedNotifier, bool>((ref) {
      return SidebarCollapsedNotifier();
    });

class SidebarCollapsedNotifier extends StateNotifier<bool> {
  SidebarCollapsedNotifier()
    : super(
        true,
      ); // Default to collapsed as requested? "debe estar como collapsible"

  void toggle() => state = !state;
  void expand() => state = false;
  void collapse() => state = true;
}
