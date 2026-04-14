import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_locale_provider.dart';
import '../../providers/providers.dart';
import 'citizen_profile_dialogs.dart';

class CitizenProfileScreen extends ConsumerStatefulWidget {
  const CitizenProfileScreen({super.key});

  @override
  ConsumerState<CitizenProfileScreen> createState() => _CitizenProfileScreenState();
}

class _CitizenProfileScreenState extends ConsumerState<CitizenProfileScreen> {
  bool _marathi = false;
  bool _notifStatus = true;
  bool _notifDispatch = true;
  bool _notifResolved = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _marathi = p.getBool('citizen_lang_mr') ?? false;
      _notifStatus = p.getBool('citizen_notif_status') ?? true;
      _notifDispatch = p.getBool('citizen_notif_dispatch') ?? true;
      _notifResolved = p.getBool('citizen_notif_resolved') ?? true;
    });
  }

  Future<void> _save(String key, bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, value);
  }

  void _snackSaved(AppLocalizations l10n) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.preferenceSaved}. ${l10n.notifPrefsHint}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppDesign.navyGradient),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppDesign.cardShadow(Theme.of(context).colorScheme),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.fullName ?? l10n.citizenFallbackName,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(profile?.phone ?? '-'),
                Text(
                  l10n.citizenZoneLine('${profile?.zoneId ?? '-'}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _tileCard(
            context,
            child: SwitchListTile(
              title: Text(l10n.languageMarathi),
              value: _marathi,
              onChanged: (v) {
                setState(() => _marathi = v);
                ref.read(appLocaleProvider.notifier).state =
                    v ? const Locale('mr') : const Locale('en');
                _save('citizen_lang_mr', v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.preferenceSaved),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
          _tileCard(
            context,
            child: SwitchListTile(
              title: Text(l10n.statusUpdates),
              value: _notifStatus,
              onChanged: (v) async {
                setState(() => _notifStatus = v);
                await _save('citizen_notif_status', v);
                _snackSaved(l10n);
              },
            ),
          ),
          _tileCard(
            context,
            child: SwitchListTile(
              title: Text(l10n.jeDispatchedAlerts),
              value: _notifDispatch,
              onChanged: (v) async {
                setState(() => _notifDispatch = v);
                await _save('citizen_notif_dispatch', v);
                _snackSaved(l10n);
              },
            ),
          ),
          _tileCard(
            context,
            child: SwitchListTile(
              title: Text(l10n.complaintResolvedAlerts),
              value: _notifResolved,
              onChanged: (v) async {
                setState(() => _notifResolved = v);
                await _save('citizen_notif_resolved', v);
                _snackSaved(l10n);
              },
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => showHowToReportSheet(context, l10n),
            child: Text(l10n.howToReport),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => showContactZoneDialog(context, l10n),
            child: Text(l10n.contactZoneOffice),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => showPrivacyDialog(context, l10n),
            child: Text(l10n.privacyPolicy),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (!context.mounted) return;
              context.go('/login');
            },
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  Widget _tileCard(BuildContext context, {required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppDesign.cardShadow(cs),
        ),
        child: child,
      ),
    );
  }
}
