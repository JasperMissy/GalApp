import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/views/shell/app_destination.dart';

/// Hält das aktuell gewählte Ziel der unteren Navigationsleiste.
class SelectedDestinationNotifier extends Notifier<AppDestination> {
  @override
  AppDestination build() => AppDestination.home;

  void select(AppDestination destination) {
    state = destination;
  }
}

final NotifierProvider<SelectedDestinationNotifier, AppDestination>
    selectedDestinationProvider =
    NotifierProvider<SelectedDestinationNotifier, AppDestination>(
  SelectedDestinationNotifier.new,
);
