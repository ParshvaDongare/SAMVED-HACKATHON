import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/connectivity_banner.dart';
import '../core/widgets/tickets_realtime_scope.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_locale_provider.dart';
import 'router.dart';
import 'theme.dart';

class RoadNirmanApp extends ConsumerWidget {
  const RoadNirmanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp.router(
      title: 'Road Nirman',
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: buildRoadNirmanTheme(),
      routerConfig: router,
      builder: (context, child) {
        return TicketsRealtimeScope(
          child: ConnectivityBanner(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
