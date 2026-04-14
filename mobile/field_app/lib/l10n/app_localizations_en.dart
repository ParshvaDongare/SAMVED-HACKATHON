// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navReport => 'Report';

  @override
  String get navTrack => 'Track';

  @override
  String get navProfile => 'Profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String get citizenRole => 'Citizen';

  @override
  String citizenZoneLine(String zoneId) {
    return 'Citizen · Zone $zoneId';
  }

  @override
  String get languageMarathi => 'Language: Marathi';

  @override
  String get statusUpdates => 'Status updates';

  @override
  String get jeDispatchedAlerts => 'JE dispatched alerts';

  @override
  String get complaintResolvedAlerts => 'Complaint resolved alerts';

  @override
  String get howToReport => 'How to report';

  @override
  String get contactZoneOffice => 'Contact zone office';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get signOut => 'Sign out';

  @override
  String get preferenceSaved => 'Preference saved';

  @override
  String get notifPrefsHint =>
      'We will use these when push/SMS alerts are enabled for your account.';

  @override
  String get close => 'Close';

  @override
  String get howToReportTitle => 'How to report road damage';

  @override
  String get howToReportStep1 => '1. Open Report, allow camera and location.';

  @override
  String get howToReportStep2 =>
      '2. Take a clear photo of the pothole or damage.';

  @override
  String get howToReportStep3 =>
      '3. Confirm GPS and add address or landmark if you can.';

  @override
  String get howToReportStep4 =>
      '4. Submit — AI assists classification; SMC routes the complaint to your zone.';

  @override
  String get contactZoneTitle => 'Zone office & SMC';

  @override
  String get contactZoneBody =>
      'For ward-wise contacts, visit the Solapur Municipal Corporation website or call the main civic helpline listed there. This app registers your complaint in the digital workflow so engineers can verify and assign work.';

  @override
  String get openSmcWebsite => 'Open SMC website';

  @override
  String get privacyPolicyTitle => 'Privacy';

  @override
  String get privacyPolicyBody =>
      'Road Nirman collects the information you submit with a complaint: photos, GPS location, optional address text, and your account phone number. Data is used to verify damage, assign jurisdiction, and process municipal records. Access is restricted by role (citizen, officer, contractor) under municipal security rules. Do not upload photos of people or private property unrelated to the road issue.';

  @override
  String get greetingHello => 'Hello';

  @override
  String get greetingNamaste => 'Namaste';

  @override
  String get citizenFallbackName => 'Citizen';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get notificationsSheetTitle => 'Alerts';

  @override
  String get notificationsSheetBody =>
      'Status changes appear under Track. Turn on notification types in Profile — delivery via push/SMS will follow your SMC rollout.';

  @override
  String get noReportsYet => 'No reports yet';

  @override
  String get noReportsSubtitle => 'Use Report to log road issues near you.';

  @override
  String get recentGrievances => 'Recent grievances';

  @override
  String get viewAll => 'View all';

  @override
  String totalCount(int count) {
    return '$count total';
  }

  @override
  String get quickAction => 'Quick action';

  @override
  String get spotPothole => 'Spot a pothole?';

  @override
  String get reportUnderMinute => 'Report it in under a minute';

  @override
  String get reportDamage => 'Report damage';

  @override
  String get citizenSummary => 'Citizen summary';

  @override
  String get openComplaints => 'Open complaints';

  @override
  String get resolved => 'Resolved';

  @override
  String get reportDamageTitle => 'Report damage';

  @override
  String get citizenReportHeader => 'Citizen report';

  @override
  String get citizenReportSubtitle =>
      'Capture damage, attach GPS, and submit instantly.';

  @override
  String get cameraDenied =>
      'Camera permission denied. Enable it in Settings to capture evidence.';

  @override
  String get locationDenied =>
      'Location permission denied. GPS is mandatory for report routing.';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get retakePhoto => 'Retake photo';

  @override
  String get getGpsLocation => 'Get GPS location';

  @override
  String gpsCoordinates(String lat, String lng) {
    return 'GPS: $lat, $lng';
  }

  @override
  String get damageType => 'Damage type';

  @override
  String get addressArea => 'Address / area';

  @override
  String get nearestLandmark => 'Nearest landmark';

  @override
  String get continueToAi => 'Continue to AI review';

  @override
  String get errorPhotoRequiredWeb =>
      'Choose a photo for the damage (browser testing uses gallery).';

  @override
  String get errorPhotoRequired => 'Take or choose a photo of the damage.';

  @override
  String get errorGpsRequired => 'GPS location is required.';

  @override
  String get damagePothole => 'Pothole';

  @override
  String get damageCrack => 'Crack';

  @override
  String get damageSurfaceFailure => 'Surface failure';

  @override
  String get myComplaintsTitle => 'My complaints';

  @override
  String get tabAll => 'All';

  @override
  String get tabPending => 'Pending';

  @override
  String get tabActive => 'Active';

  @override
  String get tabResolved => 'Resolved';

  @override
  String get noComplaintsInFilter => 'No complaints in this filter';

  @override
  String get profileAccountGreeting => 'Citizen account';

  @override
  String get profileToolsTitle => 'Profile tools';

  @override
  String get profileToolsSubtitle =>
      'Open the Profile tab for Marathi, alert preferences, how to report, SMC contact, and privacy.';

  @override
  String get ticketRefPlaceholder => 'Complaint';

  @override
  String get viewRepairProof => 'View repair proof';
}
