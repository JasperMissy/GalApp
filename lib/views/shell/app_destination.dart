import 'package:flutter/material.dart';

/// Die fünf Ziele der unteren Navigationsleiste (Reihenfolge laut Skizze).
///
/// „Aufträge“ ist kein eigenes Ziel, sondern ein Bereich innerhalb von
/// „Kunden“.
enum AppDestination {
  customers('Kunden', Icons.people_outline, Icons.people),
  calendar('Kalender', Icons.calendar_month_outlined, Icons.calendar_month),
  home('Home', Icons.home_outlined, Icons.home),
  colleagues('Kollegen', Icons.groups_outlined, Icons.groups),
  extras('Extras', Icons.apps_outlined, Icons.apps);

  const AppDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
