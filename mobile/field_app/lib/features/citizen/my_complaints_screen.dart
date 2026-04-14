import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/status_labels.dart';
import '../../l10n/app_localizations.dart';
import '../../models/ticket.dart';
import '../../providers/ticket_providers.dart';

class MyComplaintsScreen extends ConsumerStatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  ConsumerState<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends ConsumerState<MyComplaintsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(citizenTicketsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myComplaintsTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (tickets) {
          final filtered = tickets.where(_acceptByTab).toList();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(citizenTicketsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 0, label: Text(l10n.tabAll)),
                    ButtonSegment(value: 1, label: Text(l10n.tabPending)),
                    ButtonSegment(value: 2, label: Text(l10n.tabActive)),
                    ButtonSegment(value: 3, label: Text(l10n.tabResolved)),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (v) => setState(() => _tab = v.first),
                ),
                const SizedBox(height: 14),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 36),
                    child: Center(child: Text(l10n.noComplaintsInFilter)),
                  ),
                ...filtered.map((t) => _ticketCard(context, l10n, t)),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _acceptByTab(Ticket t) {
    final pending = {'open', 'verified'};
    final active = {'assigned', 'in_progress', 'audit_pending'};
    switch (_tab) {
      case 1:
        return pending.contains(t.status);
      case 2:
        return active.contains(t.status);
      case 3:
        return t.status == 'resolved';
      default:
        return true;
    }
  }

  Widget _ticketCard(BuildContext context, AppLocalizations l10n, Ticket t) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/citizen/tickets/${t.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.ticketRef.isEmpty ? l10n.ticketRefPlaceholder : t.ticketRef,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(ticketStatusLabel(t.status)),
                  ],
                ),
                if (t.addressText != null) ...[
                  const SizedBox(height: 6),
                  Text(t.addressText!),
                ],
                const SizedBox(height: 8),
                _stepperMini(context, t.status),
                if (t.status == 'resolved') ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.push('/citizen/tickets/${t.id}'),
                      icon: Icon(
                        t.photoAfter != null ? Icons.photo_library_outlined : Icons.visibility_outlined,
                        size: 18,
                      ),
                      label: Text(l10n.viewRepairProof),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepperMini(BuildContext context, String status) {
    const order = ['open', 'verified', 'in_progress', 'resolved'];
    final idx = switch (status) {
      'open' => 0,
      'verified' => 1,
      'assigned' || 'in_progress' => 2,
      'audit_pending' || 'resolved' => 3,
      _ => 0,
    };
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(order.length, (i) {
        final done = i <= idx;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == order.length - 1 ? 0 : 4),
            height: 6,
            decoration: BoxDecoration(
              color: done ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}
