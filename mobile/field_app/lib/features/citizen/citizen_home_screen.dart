import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/citizen_ticket_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/profile_app_bar.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../providers/providers.dart';
import '../../providers/ticket_providers.dart';

class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({
    super.key,
    this.initialTrackOnly = false,
    this.initialProfileOnly = false,
  });

  final bool initialTrackOnly;
  final bool initialProfileOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(citizenPostSubmitBannerProvider, (previous, next) {
      if (next == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
        ref.read(citizenPostSubmitBannerProvider.notifier).state = null;
      });
    });

    final ticketsAsync = ref.watch(citizenTicketsProvider);
    final profileAsync = ref.watch(profileProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (initialProfileOnly) {
      final l10nP = AppLocalizations.of(context)!;
      return Scaffold(
        appBar: ProfileAppBar(
          greeting: l10nP.profileAccountGreeting,
          name: profileAsync.value?.fullName ?? l10nP.citizenFallbackName,
          subtitle: profileAsync.value?.phone ?? '',
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
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _CitizenSummaryCard(
              openCount: 0,
              resolvedCount: 0,
              l10n: l10nP,
            ),
            const SizedBox(height: 14),
            EmptyState(
              title: l10nP.profileToolsTitle,
              subtitle: l10nP.profileToolsSubtitle,
              icon: Icons.person_outline_rounded,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: ticketsAsync.when(
        loading: () => const ShimmerList(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(citizenTicketsProvider),
        ),
        data: (tickets) {
          final l10n = AppLocalizations.of(context)!;
          if (tickets.isEmpty) {
            return CustomScrollView(
              slivers: [
                _appBarSliver(context, ref),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: _HeroReportCard(onReport: () => context.push('/citizen/report')),
                      ),
                      Expanded(
                        child: EmptyState(
                          title: l10n.noReportsYet,
                          subtitle: l10n.noReportsSubtitle,
                          icon: Icons.map_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          final openCount = tickets
              .where((t) => !const {'resolved', 'rejected'}.contains(t.status))
              .length;
          final resolvedCount =
              tickets.where((t) => t.status == 'resolved').length;

          final markers = tickets
              .map(
                (t) => Marker(
                  point: LatLng(t.latitude, t.longitude),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => context.push('/citizen/tickets/${t.id}'),
                    child: Icon(
                      Icons.location_on,
                      color: AppDesign.severityColor(cs, t.severityTier),
                      size: 40,
                    ),
                  ),
                ),
              )
              .toList();

          final center = LatLng(tickets.first.latitude, tickets.first.longitude);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(citizenTicketsProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _appBarSliver(context, ref),
                if (!initialTrackOnly)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: _HeroReportCard(
                        onReport: () => context.push('/citizen/report'),
                      ),
                    ),
                  ),
                if (!initialTrackOnly)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _CitizenSummaryCard(
                        openCount: openCount,
                        resolvedCount: resolvedCount,
                        l10n: l10n,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.recentGrievances,
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/citizen/track'),
                          child: Text(
                            initialTrackOnly
                                ? l10n.totalCount(tickets.length)
                                : l10n.viewAll,
                            style: tt.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.primary.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!initialTrackOnly)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SizedBox(
                          height: 200,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: center,
                              initialZoom: 13,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'road_nirman_field',
                              ),
                              MarkerLayer(markers: markers),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList.separated(
                    itemCount: tickets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, i) {
                      final t = tickets[i];
                      return CitizenTicketCard(
                        ticket: t,
                        onTap: () => context.push('/citizen/tickets/${t.id}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _appBarSliver(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final loc = Localizations.localeOf(context);
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.value;
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: cs.primary.withValues(alpha: 0.12),
            child: Text(
              (profile?.fullName.isNotEmpty ?? false)
                  ? profile!.fullName.substring(0, 1).toUpperCase()
                  : 'C',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.languageCode == 'mr' ? l10n.greetingNamaste : l10n.greetingHello,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                Text(
                  profile?.fullName ?? l10n.citizenFallbackName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (ctx) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notificationsSheetTitle,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.notificationsSheetBody),
                  ],
                ),
              ),
            );
          },
          tooltip: l10n.notificationsTooltip,
        ),
      ],
    );
  }
}

class _HeroReportCard extends StatelessWidget {
  const _HeroReportCard({required this.onReport});

  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppDesign.accentOrange,
                    AppDesign.accentOrangeDeep,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -40,
            top: -40,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            right: 12,
            bottom: -8,
            child: Icon(
              Icons.construction,
              size: 120,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.quickAction.toUpperCase(),
                    style: tt.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.spotPothole,
                  style: tt.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.reportUnderMinute,
                  style: tt.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: onReport,
                  icon: const Icon(Icons.add_a_photo),
                  label: Text(l10n.reportDamage),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CitizenSummaryCard extends StatelessWidget {
  const _CitizenSummaryCard({
    required this.openCount,
    required this.resolvedCount,
    required this.l10n,
  });

  final int openCount;
  final int resolvedCount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          ...AppDesign.cardShadow(cs),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.citizenSummary.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.openComplaints,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$openCount',
                          style: tt.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.primary,
                            fontSize: 36,
                          ),
                        ),
                        if (openCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 56,
                color: cs.outlineVariant.withValues(alpha: 0.35),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.resolved,
                        style: tt.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$resolvedCount',
                        style: tt.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.tertiary,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
