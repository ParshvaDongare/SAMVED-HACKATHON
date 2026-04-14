import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/profile_app_bar.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/ticket.dart';
import '../../providers/providers.dart';
import '../../providers/ticket_providers.dart';

class JeHomeScreen extends ConsumerStatefulWidget {
  const JeHomeScreen({
    super.key,
    this.initialMapOnly = false,
    this.initialRoutesOnly = false,
    this.initialProfileOnly = false,
  });

  final bool initialMapOnly;
  final bool initialRoutesOnly;
  final bool initialProfileOnly;

  @override
  ConsumerState<JeHomeScreen> createState() => _JeHomeScreenState();
}

class _JeHomeScreenState extends ConsumerState<JeHomeScreen> {
  String _statusFilter = 'all';
  bool _mapFirst = true;
  (double lat, double lng)? _myPoint;

  @override
  void initState() {
    super.initState();
    _resolveCurrentPoint();
  }

  Future<void> _resolveCurrentPoint() async {
    final loc = ref.read(locationServiceProvider);
    final ok = await loc.ensureLocationPermission();
    if (!ok) return;
    final pos = await loc.currentPosition();
    if (pos == null || !mounted) return;
    setState(() => _myPoint = (pos.latitude, pos.longitude));
  }

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(jeInboxProvider);
    final allAsync = ref.watch(jeZoneAllTicketsProvider);
    final profileAsync = ref.watch(profileProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: ProfileAppBar(
        greeting: widget.initialMapOnly
            ? 'Zone map'
            : widget.initialRoutesOnly
                ? 'Route plan'
                : 'Zone tasks',
        name: profileAsync.value?.fullName ?? 'JE',
        subtitle: profileAsync.value?.zoneId != null
            ? 'Zone ${profileAsync.value!.zoneId}'
            : null,
        actions: [
          if (!widget.initialMapOnly)
            IconButton(
              icon: Icon(_mapFirst ? Icons.list_alt_rounded : Icons.map_outlined),
              tooltip: _mapFirst ? 'List first' : 'Map first',
              onPressed: () => setState(() => _mapFirst = !_mapFirst),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: activeAsync.when(
        loading: () => const ShimmerList(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(jeInboxProvider),
        ),
        data: (activeTickets) => allAsync.when(
          loading: () => const ShimmerList(),
          error: (e, _) => ErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(jeZoneAllTicketsProvider),
          ),
          data: (allTickets) {
            if (widget.initialProfileOnly) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: const [
                  EmptyState(
                    title: 'JE profile',
                    subtitle: 'Profile and settings controls will appear here.',
                    icon: Icons.person_outline_rounded,
                  ),
                ],
              );
            }
            if (widget.initialRoutesOnly) {
              final plannedStops = _buildRouteStops(activeTickets, allTickets);
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(jeInboxProvider);
                  ref.invalidate(jeZoneAllTicketsProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _RoutePlannerSection(
                      stops: plannedStops,
                      onOpenTicket: (ticket) => context.push('/je/tickets/${ticket.id}'),
                      onNavigate: _openExternalNavigation,
                    ),
                  ],
                ),
              );
            }
            if (widget.initialMapOnly) {
              final filteredZone = _applyFilter(allTickets, _statusFilter);
              final drawable = filteredZone
                  .where((t) => t.latitude != 0 && t.longitude != 0)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Complaints in your zone',
                                style: tt.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${drawable.length} on map · ${_FilterRow.labelFor(_statusFilter)}',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh',
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            ref.invalidate(jeInboxProvider);
                            ref.invalidate(jeZoneAllTicketsProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _FilterRow(
                      selected: _statusFilter,
                      onSelected: (v) => setState(() => _statusFilter = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _JeFullZoneMap(
                        tickets: drawable,
                        myLocation: _myPoint,
                      ),
                    ),
                  ),
                ],
              );
            }
            final open = allTickets.where((t) => t.status == 'open').length;
            final verified = allTickets.where((t) => t.status == 'verified').length;
            final assigned = allTickets.where((t) => t.status == 'assigned').length;
            final inProgress = allTickets.where((t) => t.status == 'in_progress').length;
            final qualityCheck =
                allTickets.where((t) => t.status == 'audit_pending').length;
            final resolved = allTickets.where((t) => t.status == 'resolved').length;

            final filtered = _applyFilter(activeTickets, _statusFilter);
            final mapSource = filtered.isNotEmpty ? filtered : activeTickets;
            final recentFallback = allTickets.take(8).toList();
            final showEmpty = activeTickets.isEmpty && recentFallback.isEmpty;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(jeInboxProvider);
                ref.invalidate(jeZoneAllTicketsProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: const [
                          AppDesign.primaryNavy,
                          AppDesign.primaryContainerNavy,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'JUNIOR ENGINEER',
                                style: tt.labelLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Zone work inbox',
                                style: tt.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${activeTickets.length} active · $open new',
                                style: tt.titleMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.engineering, color: Colors.white, size: 34),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SummaryChips(
                    values: {
                      'Open': open,
                      'Verified': verified,
                      'Assigned': assigned,
                      'In Progress': inProgress,
                      'Quality': qualityCheck,
                      'Resolved': resolved,
                    },
                  ),
                  const SizedBox(height: 12),
                  _FilterRow(
                    selected: _statusFilter,
                    onSelected: (v) => setState(() => _statusFilter = v),
                  ),
                  const SizedBox(height: 14),
                  if (widget.initialMapOnly || _mapFirst) ...[
                    _MapSection(tickets: mapSource),
                    if (!widget.initialMapOnly) ...[
                      const SizedBox(height: 16),
                      _listSection(
                        context,
                        title: 'Nearby tickets',
                        items: filtered,
                        emptyTitle: 'No tickets in selected filter',
                        emptySubtitle: 'Try switching status chips above.',
                      ),
                    ],
                  ] else ...[
                    _listSection(
                      context,
                      title: 'Nearby tickets',
                      items: filtered,
                      emptyTitle: 'No tickets in selected filter',
                      emptySubtitle: 'Try switching status chips above.',
                    ),
                    const SizedBox(height: 16),
                    _MapSection(tickets: mapSource),
                  ],
                  if (showEmpty) ...[
                    const SizedBox(height: 18),
                    const EmptyState(
                      title: 'No zone tickets yet',
                      subtitle: 'When citizens report in this zone, they appear here automatically.',
                      icon: Icons.inventory_2_outlined,
                    ),
                  ] else if (activeTickets.isEmpty && recentFallback.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Recent zone history',
                      style: tt.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...recentFallback
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _JeTicketTile(
                                ticket: t,
                                distanceText: _distanceText(t),
                              ),
                        )),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Ticket> _applyFilter(List<Ticket> items, String filter) {
    if (filter == 'all') return items;
    return items.where((t) => t.status == filter).toList();
  }

  String? _distanceText(Ticket ticket) {
    final p = _myPoint;
    if (p == null) return null;
    final d = ref.read(ticketServiceProvider).distanceMeters(
          fromLat: p.$1,
          fromLng: p.$2,
          toLat: ticket.latitude,
          toLng: ticket.longitude,
        );
    if (d >= 1000) return '${(d / 1000).toStringAsFixed(1)} km away';
    return '${d.toStringAsFixed(0)} m away';
  }

  List<_RouteStop> _buildRouteStops(List<Ticket> activeTickets, List<Ticket> allTickets) {
    final source = activeTickets.isNotEmpty ? activeTickets : allTickets;
    final sortable = source
        .where((ticket) =>
            ticket.status != 'resolved' &&
            ticket.status != 'rejected' &&
            ticket.latitude != 0 &&
            ticket.longitude != 0)
        .toList();

    sortable.sort((a, b) {
      final severityCompare =
          _severityRank(b.severityTier).compareTo(_severityRank(a.severityTier));
      if (severityCompare != 0) return severityCompare;

      final distanceA = _distanceMeters(a) ?? double.infinity;
      final distanceB = _distanceMeters(b) ?? double.infinity;
      return distanceA.compareTo(distanceB);
    });

    return sortable
        .take(8)
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => _RouteStop(
            order: entry.key + 1,
            ticket: entry.value,
            distanceMeters: _distanceMeters(entry.value),
          ),
        )
        .toList();
  }

  double? _distanceMeters(Ticket ticket) {
    final p = _myPoint;
    if (p == null) return null;
    return ref.read(ticketServiceProvider).distanceMeters(
          fromLat: p.$1,
          fromLng: p.$2,
          toLat: ticket.latitude,
          toLng: ticket.longitude,
        );
  }

  int _severityRank(String? severity) {
    switch ((severity ?? '').toUpperCase()) {
      case 'CRITICAL':
        return 4;
      case 'HIGH':
        return 3;
      case 'MEDIUM':
        return 2;
      case 'LOW':
        return 1;
      default:
        return 0;
    }
  }

  Future<void> _openExternalNavigation(Ticket ticket) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${ticket.latitude},${ticket.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _listSection(
    BuildContext context, {
    required String title,
    required List<Ticket> items,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    final tt = Theme.of(context).textTheme;
    if (items.isEmpty) {
      return EmptyState(
        title: emptyTitle,
        subtitle: emptySubtitle,
        icon: Icons.filter_alt_off_outlined,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ...items
            .map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _JeTicketTile(
                    ticket: t,
                    distanceText: _distanceText(t),
                  ),
                )),
      ],
    );
  }
}

class _RouteStop {
  const _RouteStop({
    required this.order,
    required this.ticket,
    required this.distanceMeters,
  });

  final int order;
  final Ticket ticket;
  final double? distanceMeters;
}

class _RoutePlannerSection extends StatelessWidget {
  const _RoutePlannerSection({
    required this.stops,
    required this.onOpenTicket,
    required this.onNavigate,
  });

  final List<_RouteStop> stops;
  final ValueChanged<Ticket> onOpenTicket;
  final ValueChanged<Ticket> onNavigate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (stops.isEmpty) {
      return const EmptyState(
        title: 'No route to plan yet',
        subtitle:
            'Open or assigned zone tickets will appear here once there is field work to visit.',
        icon: Icons.route_outlined,
      );
    }

    final plannedDistance = stops.fold<double>(
      0,
      (sum, stop) => sum + (stop.distanceMeters ?? 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Field route plan',
                style: tt.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${stops.length} suggested stops ordered by urgency and proximity.',
                style: tt.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _RouteMetricChip(label: 'Stops', value: '${stops.length}'),
                  _RouteMetricChip(
                    label: 'Approx. distance',
                    value: plannedDistance >= 1000
                        ? '${(plannedDistance / 1000).toStringAsFixed(1)} km'
                        : '${plannedDistance.toStringAsFixed(0)} m',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Suggested visit order',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'This is a practical field sequence, not a dispatch engine. Use it to reach urgent nearby tickets faster.',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        ...stops.map(
          (stop) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _RouteStopCard(
              stop: stop,
              onOpenTicket: () => onOpenTicket(stop.ticket),
              onNavigate: () => onNavigate(stop.ticket),
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteMetricChip extends StatelessWidget {
  const _RouteMetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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

class _RouteStopCard extends StatelessWidget {
  const _RouteStopCard({
    required this.stop,
    required this.onOpenTicket,
    required this.onNavigate,
  });

  final _RouteStop stop;
  final VoidCallback onOpenTicket;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ticket = stop.ticket;
    final distanceLabel = stop.distanceMeters == null
        ? 'Distance unavailable'
        : stop.distanceMeters! >= 1000
            ? '${(stop.distanceMeters! / 1000).toStringAsFixed(1)} km away'
            : '${stop.distanceMeters!.toStringAsFixed(0)} m away';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppDesign.cardShadow(cs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.primaryContainer.withValues(alpha: 0.35),
                child: Text(
                  '${stop.order}',
                  style: tt.titleSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.ticketRef.isEmpty
                          ? ticket.id.substring(0, 8)
                          : ticket.ticketRef,
                      style: AppDesign.mono(
                        tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.addressText ??
                          ticket.roadName ??
                          'Lat/Lng ${ticket.latitude.toStringAsFixed(4)}, ${ticket.longitude.toStringAsFixed(4)}',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(status: ticket.status),
              if (ticket.severityTier != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _MapSection._severityColor(cs, ticket.severityTier)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    ticket.severityTier!,
                    style: tt.labelMedium?.copyWith(
                      color: _MapSection._severityColor(cs, ticket.severityTier),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  distanceLabel,
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenTicket,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Open ticket'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.navigation_outlined),
                  label: const Text('Navigate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChips extends StatelessWidget {
  const _SummaryChips({required this.values});

  final Map<String, int> values;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.entries
          .map(
            (e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(999),
                boxShadow: AppDesign.cardShadow(cs),
              ),
              child: Text(
                '${e.key}: ${e.value}',
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  static const _filters = {
    'all': 'All',
    'open': 'Open',
    'verified': 'Verified',
    'assigned': 'Assigned',
    'in_progress': 'In Progress',
    'audit_pending': 'Quality check',
  };

  static String labelFor(String key) => _filters[key] ?? key;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _filters.entries.map((f) {
          final active = selected == f.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f.value),
              selected: active,
              onSelected: (_) => onSelected(f.key),
              selectedColor: cs.primaryContainer.withValues(alpha: 0.2),
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: active ? cs.primary : cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: cs.surface,
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.35)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Full-viewport zone map for the dedicated Map tab (all zone complaints, filterable).
class _JeFullZoneMap extends StatefulWidget {
  const _JeFullZoneMap({
    required this.tickets,
    this.myLocation,
  });

  final List<Ticket> tickets;
  final (double lat, double lng)? myLocation;

  @override
  State<_JeFullZoneMap> createState() => _JeFullZoneMapState();
}

class _JeFullZoneMapState extends State<_JeFullZoneMap> {
  static const LatLng _defaultCenter = LatLng(17.6799, 75.9064);

  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitCamera() {
    final pts = <LatLng>[
      ...widget.tickets.map((t) => LatLng(t.latitude, t.longitude)),
    ];
    final my = widget.myLocation;
    if (my != null) {
      pts.add(LatLng(my.$1, my.$2));
    }
    if (pts.isEmpty) {
      _mapController.move(_defaultCenter, 12);
      return;
    }
    if (pts.length == 1) {
      _mapController.move(pts.first, 15);
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: pts,
        padding: const EdgeInsets.only(left: 40, right: 40, top: 32, bottom: 56),
        maxZoom: 16,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _JeFullZoneMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.tickets.map((e) => e.id).join('\u001e');
    final newIds = widget.tickets.map((e) => e.id).join('\u001e');
    if (oldIds != newIds || oldWidget.myLocation != widget.myLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitCamera());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final markers = <Marker>[];
    final my = widget.myLocation;
    if (my != null) {
      markers.add(
        Marker(
          point: LatLng(my.$1, my.$2),
          width: 28,
          height: 28,
          child: Icon(Icons.my_location, color: cs.primary, size: 28),
        ),
      );
    }
    for (final t in widget.tickets) {
      markers.add(
        Marker(
          point: LatLng(t.latitude, t.longitude),
          width: 38,
          height: 38,
          child: GestureDetector(
            onTap: () => context.push('/je/tickets/${t.id}'),
            child: Icon(
              Icons.place,
              color: _MapSection._severityColor(cs, t.severityTier),
              size: 38,
            ),
          ),
        ),
      );
    }

    final initial = widget.tickets.isNotEmpty
        ? LatLng(widget.tickets.first.latitude, widget.tickets.first.longitude)
        : _defaultCenter;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initial,
              initialZoom: 13,
              onMapReady: _fitCamera,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'road_nirman_field',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          if (widget.tickets.isEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.04),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No complaints to show',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try another status filter, or refresh when new reports arrive.',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection({required this.tickets});

  final List<Ticket> tickets;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const SizedBox.shrink();
    }
    final cs = Theme.of(context).colorScheme;
    final markers = tickets
        .map(
          (t) => Marker(
            point: LatLng(t.latitude, t.longitude),
            width: 36,
            height: 36,
            child: GestureDetector(
              onTap: () => context.push('/je/tickets/${t.id}'),
              child: Icon(
                Icons.place,
                color: _severityColor(cs, t.severityTier),
                size: 36,
              ),
            ),
          ),
        )
        .toList();
    final c = LatLng(tickets.first.latitude, tickets.first.longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 230,
        child: FlutterMap(
          options: MapOptions(initialCenter: c, initialZoom: 12.5),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'road_nirman_field',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );
  }

  static Color _severityColor(ColorScheme cs, String? severity) {
    switch ((severity ?? '').toUpperCase()) {
      case 'CRITICAL':
        return cs.error;
      case 'HIGH':
        return cs.tertiary;
      case 'MEDIUM':
        return AppDesign.severityColor(cs, 'medium');
      default:
        return cs.primary;
    }
  }
}

class _JeTicketTile extends StatelessWidget {
  const _JeTicketTile({
    required this.ticket,
    this.distanceText,
  });

  final Ticket ticket;
  final String? distanceText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sevColor = _MapSection._severityColor(cs, ticket.severityTier);
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push('/je/tickets/${ticket.id}'),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 120,
              decoration: BoxDecoration(
                color: sevColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.ticketRef.isEmpty
                                ? ticket.id.substring(0, 8)
                                : ticket.ticketRef,
                            style: AppDesign.mono(
                              tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket.addressText ?? 'Lat/Lng ${ticket.latitude.toStringAsFixed(4)}, ${ticket.longitude.toStringAsFixed(4)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (distanceText != null)
                            Text(
                              distanceText!,
                              style: tt.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          if (distanceText != null) const SizedBox(height: 6),
                          Row(
                            children: [
                              if (ticket.severityTier != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: sevColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    ticket.severityTier!,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: sevColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Flexible(child: StatusBadge(status: ticket.status)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, color: cs.outline),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
