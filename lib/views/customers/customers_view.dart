import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galabau_app/models/client.dart';
import 'package:galabau_app/models/order.dart';
import 'package:galabau_app/models/order_status.dart';
import 'package:galabau_app/services/customers/client_repository.dart';
import 'package:galabau_app/services/orders/order_repository.dart';
import 'package:galabau_app/views/customers/client_detail_sheet.dart';
import 'package:galabau_app/views/customers/client_form_dialog.dart';
import 'package:galabau_app/views/customers/order_detail_screen.dart';
import 'package:galabau_app/views/customers/order_form_dialog.dart';
import 'package:galabau_app/views/shared/empty_state.dart';
import 'package:galabau_app/views/shared/error_state.dart';
import 'package:galabau_app/views/theme/app_colors.dart';

/// Bereich „Kunden“ mit den beiden Ansichten „Kunden“ und „Aufträge“.
class CustomersView extends StatelessWidget {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kunden'),
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: 'Kunden'), Tab(text: 'Aufträge')],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[_ClientList(), _OrderList()],
        ),
      ),
    );
  }
}

/// Filter für die Auftragsliste (laut Vision 4.3: Offen, Erledigt,
/// wiederkehrend).
enum _OrderFilter { alle, offen, erledigt, wiederkehrend }

class _ClientList extends ConsumerStatefulWidget {
  const _ClientList();

  @override
  ConsumerState<_ClientList> createState() => _ClientListState();
}

class _ClientListState extends ConsumerState<_ClientList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Client>> clients = ref.watch(clientsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addClient(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Kunde'),
      ),
      body: clients.when(
        data: (List<Client> all) {
          final List<Client> filtered = _query.isEmpty
              ? all
              : all
                  .where((Client c) =>
                      c.name.toLowerCase().contains(_query.toLowerCase()))
                  .toList();
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (String value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Suchen …',
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_outline,
                        title: 'Noch keine Kunden',
                        message: 'Fügen Sie über „Kunde“ Ihren ersten Kunden hinzu.',
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Client client = filtered[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_outline),
                              ),
                              title: Text(client.name),
                              subtitle: Text(
                                  '${client.zip} ${client.city}'.trim()),
                              onTap: () => _showClient(context, client),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorState(onRetry: () => ref.invalidate(clientsProvider)),
      ),
    );
  }

  Future<void> _addClient(BuildContext context) async {
    final bool? created = await showDialog<bool>(
      context: context,
      builder: (_) => const ClientFormDialog(),
    );
    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kunde angelegt')),
      );
    }
  }

  void _showClient(BuildContext context, Client client) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ClientDetailSheet(client: client),
    );
  }
}

class _OrderList extends ConsumerStatefulWidget {
  const _OrderList();

  @override
  ConsumerState<_OrderList> createState() => _OrderListState();
}

class _OrderListState extends ConsumerState<_OrderList> {
  _OrderFilter _filter = _OrderFilter.alle;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Order>> orders = ref.watch(ordersProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrder(context),
        icon: const Icon(Icons.add),
        label: const Text('Auftrag'),
      ),
      body: orders.when(
        data: (List<Order> all) {
          final List<Order> filtered = all.where(_matchesFilter).toList();
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: <Widget>[
                    for (final _OrderFilter f in _OrderFilter.values)
                      ChoiceChip(
                        label: Text(_filterLabel(f)),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'Noch keine Aufträge',
                        message: 'Legen Sie über „Auftrag“ Ihren ersten Auftrag an.',
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Order order = filtered[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _statusColor(order),
                                child: Icon(
                                  order.status == OrderStatus.erledigt
                                      ? Icons.check
                                      : Icons.event,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(order.title),
                              subtitle: Text(_statusText(order)),
                              onTap: () => _openOrder(context, order),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ErrorState(onRetry: () => ref.invalidate(ordersProvider)),
      ),
    );
  }

  bool _matchesFilter(Order order) {
    return switch (_filter) {
      _OrderFilter.alle => true,
      _OrderFilter.offen => order.status == OrderStatus.offen,
      _OrderFilter.erledigt => order.status == OrderStatus.erledigt,
      _OrderFilter.wiederkehrend => order.recurring,
    };
  }

  String _filterLabel(_OrderFilter filter) {
    return switch (filter) {
      _OrderFilter.alle => 'Alle',
      _OrderFilter.offen => 'Offen',
      _OrderFilter.erledigt => 'Erledigt',
      _OrderFilter.wiederkehrend => 'Wiederkehrend',
    };
  }

  Color _statusColor(Order order) {
    if (order.recurring) return AppColors.statusRecurring;
    return order.status == OrderStatus.erledigt
        ? AppColors.statusDone
        : AppColors.statusOpen;
  }

  String _statusText(Order order) {
    final String status = order.status == OrderStatus.erledigt ? 'Erledigt' : 'Offen';
    return order.recurring ? '$status · wiederkehrend' : status;
  }

  void _openOrder(BuildContext context, Order order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => OrderDetailScreen(order: order)),
    );
  }

  Future<void> _addOrder(BuildContext context) async {
    final bool? created = await showDialog<bool>(
      context: context,
      builder: (_) => const OrderFormDialog(),
    );
    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auftrag angelegt')),
      );
    }
  }
}
