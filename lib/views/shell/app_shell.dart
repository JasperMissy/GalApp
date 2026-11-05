import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/views/calendar/calendar_view.dart';
import 'package:galabau_app/views/colleagues/colleagues_view.dart';
import 'package:galabau_app/views/customers/customers_view.dart';
import 'package:galabau_app/views/extras/extras_view.dart';
import 'package:galabau_app/views/home/home_view.dart';
import 'package:galabau_app/views/shell/app_destination.dart';
import 'package:galabau_app/views/shell/navigation_provider.dart';

/// Rahmen der App: Inhalt des gewählten Ziels plus untere Navigationsleiste.
///
/// Die Ziele bleiben in einem [IndexedStack] erhalten, damit ihr Zustand beim
/// Wechsel nicht verloren geht.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppDestination selected = ref.watch(selectedDestinationProvider);

    return Scaffold(
      body: IndexedStack(
        index: selected.index,
        children: <Widget>[
          for (final AppDestination destination in AppDestination.values)
            _viewFor(destination),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected.index,
        onDestinationSelected: (int index) {
          ref
              .read(selectedDestinationProvider.notifier)
              .select(AppDestination.values[index]);
        },
        destinations: <Widget>[
          for (final AppDestination destination in AppDestination.values)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }

  Widget _viewFor(AppDestination destination) {
    return switch (destination) {
      AppDestination.customers => const CustomersView(),
      AppDestination.calendar => const CalendarView(),
      AppDestination.home => const HomeView(),
      AppDestination.colleagues => const ColleaguesView(),
      AppDestination.extras => const ExtrasView(),
    };
  }
}
