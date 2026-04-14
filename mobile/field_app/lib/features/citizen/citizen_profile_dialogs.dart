import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

const _smcWebsite = 'https://solapurmc.gov.in';

Future<void> showHowToReportSheet(BuildContext context, AppLocalizations l10n) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final bottom = MediaQuery.paddingOf(ctx).bottom;
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.howToReportTitle,
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            Text(l10n.howToReportStep1, style: Theme.of(ctx).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(l10n.howToReportStep2, style: Theme.of(ctx).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(l10n.howToReportStep3, style: Theme.of(ctx).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text(l10n.howToReportStep4, style: Theme.of(ctx).textTheme.bodyLarge),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showContactZoneDialog(BuildContext context, AppLocalizations l10n) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.contactZoneTitle),
      content: SingleChildScrollView(
        child: Text(l10n.contactZoneBody),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.close),
        ),
        FilledButton(
          onPressed: () async {
            final uri = Uri.parse(_smcWebsite);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: Text(l10n.openSmcWebsite),
        ),
      ],
    ),
  );
}

Future<void> showPrivacyDialog(BuildContext context, AppLocalizations l10n) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.privacyPolicyTitle),
      content: SingleChildScrollView(
        child: Text(l10n.privacyPolicyBody),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}
