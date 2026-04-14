import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/status_labels.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/profile_app_bar.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/ticket.dart';
import '../../providers/providers.dart';
import '../../providers/ticket_providers.dart';

class ContractorHomeScreen extends ConsumerWidget {
  const ContractorHomeScreen({
    super.key,
    this.initialBillsOnly = false,
    this.initialProfileOnly = false,
  });

  final bool initialBillsOnly;
  final bool initialProfileOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapAsync = ref.watch(contractorHomeProvider);
    final profileAsync = ref.watch(profileProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: ProfileAppBar(
        greeting: 'My work orders',
        name: profileAsync.value?.fullName ?? 'Contractor',
        subtitle: 'Private contractor',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: snapAsync.when(
        loading: () => const ShimmerList(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(contractorHomeProvider),
        ),
        data: (snap) {
          final tickets = snap.rows
              .map((e) => Ticket.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          if (initialBillsOnly) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(contractorHomeProvider);
                ref.invalidate(contractorInboxProvider);
              },
              child: _BillsView(
                tickets: tickets,
                pendingCount: snap.pendingCount,
                pendingAmount: snap.pendingAmount,
              ),
            );
          }
          if (initialProfileOnly) {
            return const EmptyState(
              title: 'Contractor profile',
              subtitle: 'Company and profile settings will be available here.',
              icon: Icons.person_outline_rounded,
            );
          }

          if (tickets.isEmpty) {
            return const EmptyState(
              title: 'No contractor assignments',
              subtitle: 'JE will assign private jobs to you when ready.',
            );
          }

          final assignedCount = tickets.where((t) => t.status == 'assigned').length;
          final inProgressCount =
              tickets.where((t) => t.status == 'in_progress').length;
          final resolvedCount = tickets.where((t) => t.status == 'resolved').length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(contractorHomeProvider);
              ref.invalidate(contractorInboxProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppDesign.primaryNavy,
                        AppDesign.primaryContainerNavy,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Contractor work orders\n${tickets.length} active jobs',
                          style: tt.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const Icon(Icons.engineering, color: Colors.white, size: 32),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(context, 'Assigned: $assignedCount', cs.primary),
                    _chip(context, 'In Progress: $inProgressCount', cs.tertiary),
                    _chip(
                      context,
                      'Pending Payment: ${snap.pendingCount}',
                      AppDesign.accentOrange,
                    ),
                    _chip(
                      context,
                      'Pending Amount: Rs ${snap.pendingAmount.toStringAsFixed(0)}',
                      AppDesign.accentOrangeDeep,
                    ),
                    _chip(
                      context,
                      'Done: $resolvedCount',
                      AppDesign.severityColor(cs, 'low'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...tickets.map((t) {
                  final jeName =
                      t.assignedJe == null ? '' : (snap.jeNames[t.assignedJe!] ?? '');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _Tile(ticket: t, jeName: jeName),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chip(BuildContext context, String label, Color color) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: tt.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.ticket,
    required this.jeName,
  });

  final Ticket ticket;
  final String jeName;

  @override
  Widget build(BuildContext context) {
    final rate = ticket.ratePerUnit;
    final cost = ticket.estimatedCost;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppDesign.cardShadow(cs),
      ),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => context.push('/contractor/jobs/${ticket.id}'),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ticket.ticketRef.isEmpty ? 'Job' : ticket.ticketRef,
                        style: AppDesign.mono(
                          tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    StatusBadge(status: ticket.status),
                  ],
                ),
                const SizedBox(height: 6),
                if (ticket.jobOrderRef != null)
                  Text('JO: ${ticket.jobOrderRef}', style: tt.bodyMedium),
                if (jeName.isNotEmpty)
                  Text(
                    'Assigned by JE $jeName',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                if (rate != null)
                  Text(
                    'Locked rate: Rs ${rate.toStringAsFixed(2)} / unit',
                    style: AppDesign.mono(
                      tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                if (cost != null)
                  Text(
                    'Payable (estimate): Rs ${cost.toStringAsFixed(2)}',
                    style: AppDesign.mono(
                      tt.titleSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  ticketStatusLabelForRole(ticket.status, 'contractor'),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BillsView extends StatelessWidget {
  const _BillsView({
    required this.tickets,
    required this.pendingCount,
    required this.pendingAmount,
  });

  final List<Ticket> tickets;
  final int pendingCount;
  final double pendingAmount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final auditPending = tickets.where((t) => t.status == 'audit_pending').toList();
    final resolved = tickets.where((t) => t.status == 'resolved').toList();
    final totalResolvedAmount = resolved.fold<double>(
      0,
      (sum, ticket) => sum + (ticket.estimatedCost ?? 0),
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppDesign.primaryNavy,
                AppDesign.primaryContainerNavy,
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Billing summary',
                style: tt.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Read-only payment readiness from your current work orders.',
                style: tt.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _billMetric(
                    context,
                    label: 'Awaiting QA',
                    value: '$pendingCount',
                  ),
                  _billMetric(
                    context,
                    label: 'Pending value',
                    value: '₹${pendingAmount.toStringAsFixed(0)}',
                  ),
                  _billMetric(
                    context,
                    label: 'Resolved value',
                    value: '₹${totalResolvedAmount.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (auditPending.isEmpty)
          const EmptyState(
            title: 'No pending bills right now',
            subtitle:
                'Once after-photos are submitted and jobs move to quality check, they will appear here.',
            icon: Icons.receipt_long_outlined,
          )
        else ...[
          Text(
            'Awaiting quality approval',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...auditPending.map(
            (ticket) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BillTile(
                ticket: ticket,
                title: 'Under review',
                subtitle:
                    'After photo submitted. Accounts and JE verification are still pending.',
                tone: AppDesign.accentOrange,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        if (resolved.isNotEmpty) ...[
          Text(
            'Recently resolved work',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...resolved.take(6).map(
            (ticket) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BillTile(
                ticket: ticket,
                title: 'Resolved',
                subtitle:
                    'Work completed. Final billing depends on municipal finance workflow.',
                tone: AppDesign.severityColor(cs, 'low'),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _billMetric(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.84),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _BillTile extends StatelessWidget {
  const _BillTile({
    required this.ticket,
    required this.title,
    required this.subtitle,
    required this.tone,
  });

  final Ticket ticket;
  final String title;
  final String subtitle;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final amount = ticket.estimatedCost ?? 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppDesign.cardShadow(cs),
      ),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => context.push('/contractor/jobs/${ticket.id}'),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ticket.ticketRef.isEmpty ? 'Work order' : ticket.ticketRef,
                        style: AppDesign.mono(
                          tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: tone.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        title,
                        style: tt.labelMedium?.copyWith(
                          color: tone,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  ticket.jobOrderRef ?? 'Job order will be generated by the JE workflow',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Text(
                  'Estimated value: ₹${amount.toStringAsFixed(2)}',
                  style: AppDesign.mono(
                    tt.titleSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
