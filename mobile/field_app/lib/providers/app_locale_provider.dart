import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/locale/locale_bootstrap.dart';

/// Synced with [LocaleBootstrap.initial] at startup; updated when the citizen toggles Marathi.
final appLocaleProvider = StateProvider<Locale>(
  (ref) => LocaleBootstrap.initial,
);
