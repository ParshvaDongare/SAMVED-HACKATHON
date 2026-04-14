import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('mr')
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get navReport;

  /// No description provided for @navTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get navTrack;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @citizenRole.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get citizenRole;

  /// No description provided for @citizenZoneLine.
  ///
  /// In en, this message translates to:
  /// **'Citizen · Zone {zoneId}'**
  String citizenZoneLine(String zoneId);

  /// No description provided for @languageMarathi.
  ///
  /// In en, this message translates to:
  /// **'Language: Marathi'**
  String get languageMarathi;

  /// No description provided for @statusUpdates.
  ///
  /// In en, this message translates to:
  /// **'Status updates'**
  String get statusUpdates;

  /// No description provided for @jeDispatchedAlerts.
  ///
  /// In en, this message translates to:
  /// **'JE dispatched alerts'**
  String get jeDispatchedAlerts;

  /// No description provided for @complaintResolvedAlerts.
  ///
  /// In en, this message translates to:
  /// **'Complaint resolved alerts'**
  String get complaintResolvedAlerts;

  /// No description provided for @howToReport.
  ///
  /// In en, this message translates to:
  /// **'How to report'**
  String get howToReport;

  /// No description provided for @contactZoneOffice.
  ///
  /// In en, this message translates to:
  /// **'Contact zone office'**
  String get contactZoneOffice;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @preferenceSaved.
  ///
  /// In en, this message translates to:
  /// **'Preference saved'**
  String get preferenceSaved;

  /// No description provided for @notifPrefsHint.
  ///
  /// In en, this message translates to:
  /// **'We will use these when push/SMS alerts are enabled for your account.'**
  String get notifPrefsHint;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @howToReportTitle.
  ///
  /// In en, this message translates to:
  /// **'How to report road damage'**
  String get howToReportTitle;

  /// No description provided for @howToReportStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Open Report, allow camera and location.'**
  String get howToReportStep1;

  /// No description provided for @howToReportStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Take a clear photo of the pothole or damage.'**
  String get howToReportStep2;

  /// No description provided for @howToReportStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Confirm GPS and add address or landmark if you can.'**
  String get howToReportStep3;

  /// No description provided for @howToReportStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Submit — AI assists classification; SMC routes the complaint to your zone.'**
  String get howToReportStep4;

  /// No description provided for @contactZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Zone office & SMC'**
  String get contactZoneTitle;

  /// No description provided for @contactZoneBody.
  ///
  /// In en, this message translates to:
  /// **'For ward-wise contacts, visit the Solapur Municipal Corporation website or call the main civic helpline listed there. This app registers your complaint in the digital workflow so engineers can verify and assign work.'**
  String get contactZoneBody;

  /// No description provided for @openSmcWebsite.
  ///
  /// In en, this message translates to:
  /// **'Open SMC website'**
  String get openSmcWebsite;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'Road Nirman collects the information you submit with a complaint: photos, GPS location, optional address text, and your account phone number. Data is used to verify damage, assign jurisdiction, and process municipal records. Access is restricted by role (citizen, officer, contractor) under municipal security rules. Do not upload photos of people or private property unrelated to the road issue.'**
  String get privacyPolicyBody;

  /// No description provided for @greetingHello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get greetingHello;

  /// No description provided for @greetingNamaste.
  ///
  /// In en, this message translates to:
  /// **'Namaste'**
  String get greetingNamaste;

  /// No description provided for @citizenFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get citizenFallbackName;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @notificationsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get notificationsSheetTitle;

  /// No description provided for @notificationsSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Status changes appear under Track. Turn on notification types in Profile — delivery via push/SMS will follow your SMC rollout.'**
  String get notificationsSheetBody;

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReportsYet;

  /// No description provided for @noReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Report to log road issues near you.'**
  String get noReportsSubtitle;

  /// No description provided for @recentGrievances.
  ///
  /// In en, this message translates to:
  /// **'Recent grievances'**
  String get recentGrievances;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String totalCount(int count);

  /// No description provided for @quickAction.
  ///
  /// In en, this message translates to:
  /// **'Quick action'**
  String get quickAction;

  /// No description provided for @spotPothole.
  ///
  /// In en, this message translates to:
  /// **'Spot a pothole?'**
  String get spotPothole;

  /// No description provided for @reportUnderMinute.
  ///
  /// In en, this message translates to:
  /// **'Report it in under a minute'**
  String get reportUnderMinute;

  /// No description provided for @reportDamage.
  ///
  /// In en, this message translates to:
  /// **'Report damage'**
  String get reportDamage;

  /// No description provided for @citizenSummary.
  ///
  /// In en, this message translates to:
  /// **'Citizen summary'**
  String get citizenSummary;

  /// No description provided for @openComplaints.
  ///
  /// In en, this message translates to:
  /// **'Open complaints'**
  String get openComplaints;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @reportDamageTitle.
  ///
  /// In en, this message translates to:
  /// **'Report damage'**
  String get reportDamageTitle;

  /// No description provided for @citizenReportHeader.
  ///
  /// In en, this message translates to:
  /// **'Citizen report'**
  String get citizenReportHeader;

  /// No description provided for @citizenReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture damage, attach GPS, and submit instantly.'**
  String get citizenReportSubtitle;

  /// No description provided for @cameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied. Enable it in Settings to capture evidence.'**
  String get cameraDenied;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. GPS is mandatory for report routing.'**
  String get locationDenied;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get choosePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get retakePhoto;

  /// No description provided for @getGpsLocation.
  ///
  /// In en, this message translates to:
  /// **'Get GPS location'**
  String get getGpsLocation;

  /// No description provided for @gpsCoordinates.
  ///
  /// In en, this message translates to:
  /// **'GPS: {lat}, {lng}'**
  String gpsCoordinates(String lat, String lng);

  /// No description provided for @damageType.
  ///
  /// In en, this message translates to:
  /// **'Damage type'**
  String get damageType;

  /// No description provided for @addressArea.
  ///
  /// In en, this message translates to:
  /// **'Address / area'**
  String get addressArea;

  /// No description provided for @nearestLandmark.
  ///
  /// In en, this message translates to:
  /// **'Nearest landmark'**
  String get nearestLandmark;

  /// No description provided for @continueToAi.
  ///
  /// In en, this message translates to:
  /// **'Continue to AI review'**
  String get continueToAi;

  /// No description provided for @errorPhotoRequiredWeb.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo for the damage (browser testing uses gallery).'**
  String get errorPhotoRequiredWeb;

  /// No description provided for @errorPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Take or choose a photo of the damage.'**
  String get errorPhotoRequired;

  /// No description provided for @errorGpsRequired.
  ///
  /// In en, this message translates to:
  /// **'GPS location is required.'**
  String get errorGpsRequired;

  /// No description provided for @damagePothole.
  ///
  /// In en, this message translates to:
  /// **'Pothole'**
  String get damagePothole;

  /// No description provided for @damageCrack.
  ///
  /// In en, this message translates to:
  /// **'Crack'**
  String get damageCrack;

  /// No description provided for @damageSurfaceFailure.
  ///
  /// In en, this message translates to:
  /// **'Surface failure'**
  String get damageSurfaceFailure;

  /// No description provided for @myComplaintsTitle.
  ///
  /// In en, this message translates to:
  /// **'My complaints'**
  String get myComplaintsTitle;

  /// No description provided for @tabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAll;

  /// No description provided for @tabPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get tabPending;

  /// No description provided for @tabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get tabActive;

  /// No description provided for @tabResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get tabResolved;

  /// No description provided for @noComplaintsInFilter.
  ///
  /// In en, this message translates to:
  /// **'No complaints in this filter'**
  String get noComplaintsInFilter;

  /// No description provided for @profileAccountGreeting.
  ///
  /// In en, this message translates to:
  /// **'Citizen account'**
  String get profileAccountGreeting;

  /// No description provided for @profileToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile tools'**
  String get profileToolsTitle;

  /// No description provided for @profileToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open the Profile tab for Marathi, alert preferences, how to report, SMC contact, and privacy.'**
  String get profileToolsSubtitle;

  /// No description provided for @ticketRefPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get ticketRefPlaceholder;

  /// No description provided for @viewRepairProof.
  ///
  /// In en, this message translates to:
  /// **'View repair proof'**
  String get viewRepairProof;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
