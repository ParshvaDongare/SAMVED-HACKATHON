// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get navHome => 'मुख्यपृष्ठ';

  @override
  String get navReport => 'तक्रार';

  @override
  String get navTrack => 'मागोवा';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get profileTitle => 'प्रोफाइल';

  @override
  String get citizenRole => 'नागरिक';

  @override
  String citizenZoneLine(String zoneId) {
    return 'नागरिक · झोन $zoneId';
  }

  @override
  String get languageMarathi => 'भाषा: मराठी';

  @override
  String get statusUpdates => 'स्थिती अद्यतने';

  @override
  String get jeDispatchedAlerts => 'कनिष्ठ अभियंता रवाना सूचना';

  @override
  String get complaintResolvedAlerts => 'तक्रार निवारण सूचना';

  @override
  String get howToReport => 'तक्रार कशी करावी';

  @override
  String get contactZoneOffice => 'झोन कार्यालयाशी संपर्क';

  @override
  String get privacyPolicy => 'गोपनीयता धोरण';

  @override
  String get signOut => 'बाहेर पडा';

  @override
  String get preferenceSaved => 'सेटिंग जतन केली';

  @override
  String get notifPrefsHint =>
      'पुश/एसएमएस सुरू झाल्यावर या पर्यायांनुसार सूचना पाठवल्या जातील.';

  @override
  String get close => 'बंद';

  @override
  String get howToReportTitle => 'रस्त्याची तक्रार कशी नोंदवावी';

  @override
  String get howToReportStep1 =>
      '१. तक्रार उघडा, कॅमेरा व ठिकाणाची परवानगी द्या.';

  @override
  String get howToReportStep2 =>
      '२. खड्डा किंवा नुकसान स्पष्ट दिसेल असे फोटो काढा.';

  @override
  String get howToReportStep3 =>
      '३. जीपीएस तपासा; शक्य असल्यास पत्ता किंवा जवळची खूण लिहा.';

  @override
  String get howToReportStep4 =>
      '४. सबमिट करा — एआय मदत करते; एसएमसी तक्रार आपल्या झोनकडे पाठवते.';

  @override
  String get contactZoneTitle => 'झोन कार्यालय व एसएमसी';

  @override
  String get contactZoneBody =>
      'प्रभागनिहाय संपर्कासाठी सोलापूर महानगरपालिकेची अधिकृत वेबसाइट पहा किंवा तिथे दिलेला हेल्पलाइन वापरा. या अॅपमधून तक्रार डिजिटल प्रणालीत नोंदते, जेणेकरून अभियंते तपास व काम वाटप करू शकतील.';

  @override
  String get openSmcWebsite => 'एसएमसी वेबसाइट उघडा';

  @override
  String get privacyPolicyTitle => 'गोपनीयता';

  @override
  String get privacyPolicyBody =>
      'रोड निर्माण तक्रारीसोबत आपण दिलेली माहिती गोळा करते: फोटो, जीपीएस ठिकाण, ऐच्छिक पत्ता आणि खात्याचा फोन. ही माहिती नुकसान तपासणी, कार्यक्षेत्र ठरवणी व नगरपालिका नोंदीसाठी वापरली जाते. प्रवेश नागरिक, अधिकारी, कंत्राटदार या भूमिकेनुसार मर्यादित आहे. रस्त्याशी संबंध नसलेले लोक किंवा खाजगी मालमत्तेचे फोटो अपलोड करू नका.';

  @override
  String get greetingHello => 'नमस्कार';

  @override
  String get greetingNamaste => 'नमस्कार';

  @override
  String get citizenFallbackName => 'नागरिक';

  @override
  String get notificationsTooltip => 'सूचना';

  @override
  String get notificationsSheetTitle => 'सूचना';

  @override
  String get notificationsSheetBody =>
      'स्थिती बदल \'मागोवा\' मध्ये दिसतात. प्रोफाइलमधील सूचना पर्याय चालू ठेवा — पुश/एसएमएस एसएमसी तैनातीनुसार सुरू होईल.';

  @override
  String get noReportsYet => 'अद्याप कोणतीही तक्रार नाही';

  @override
  String get noReportsSubtitle =>
      'जवळच्या रस्त्यावरील समस्या नोंदवण्यास \'तक्रार\' वापरा.';

  @override
  String get recentGrievances => 'अलीकडील तक्रारी';

  @override
  String get viewAll => 'सर्व पहा';

  @override
  String totalCount(int count) {
    return 'एकूण $count';
  }

  @override
  String get quickAction => 'त्वरित कृती';

  @override
  String get spotPothole => 'खड्डा दिसतो आहे का?';

  @override
  String get reportUnderMinute => 'एक मिनिटात नोंदवा';

  @override
  String get reportDamage => 'तक्रार नोंदवा';

  @override
  String get citizenSummary => 'नागरिक सारांश';

  @override
  String get openComplaints => 'प्रलंबित तक्रारी';

  @override
  String get resolved => 'निवारित';

  @override
  String get reportDamageTitle => 'रस्त्याची तक्रार';

  @override
  String get citizenReportHeader => 'नागरिक तक्रार';

  @override
  String get citizenReportSubtitle => 'फोटो, जीपीएस जोडा आणि त्वरित सबमिट करा.';

  @override
  String get cameraDenied => 'कॅमेरा परवानगी नाकारली. सेटिंगमध्ये सुरू करा.';

  @override
  String get locationDenied =>
      'ठिकाण परवानगी नाकारली. तक्रारीस जीपीएस आवश्यक आहे.';

  @override
  String get choosePhoto => 'फोटो निवडा';

  @override
  String get takePhoto => 'फोटो काढा';

  @override
  String get changePhoto => 'फोटो बदला';

  @override
  String get retakePhoto => 'पुन्हा काढा';

  @override
  String get getGpsLocation => 'जीपीएस मिळवा';

  @override
  String gpsCoordinates(String lat, String lng) {
    return 'जीपीएस: $lat, $lng';
  }

  @override
  String get damageType => 'नुकसानाचा प्रकार';

  @override
  String get addressArea => 'पत्ता / परिसर';

  @override
  String get nearestLandmark => 'जवळची खूण';

  @override
  String get continueToAi => 'एआय तपासाकडे पुढे जा';

  @override
  String get errorPhotoRequiredWeb =>
      'नुकसानाचा फोटो निवडा (ब्राउझरसाठी गॅलरी).';

  @override
  String get errorPhotoRequired => 'नुकसानाचा फोटो काढा किंवा निवडा.';

  @override
  String get errorGpsRequired => 'जीपीएस ठिकाण आवश्यक आहे.';

  @override
  String get damagePothole => 'खड्डा';

  @override
  String get damageCrack => 'भेग';

  @override
  String get damageSurfaceFailure => 'पृष्ठभाग खराबी';

  @override
  String get myComplaintsTitle => 'माझ्या तक्रारी';

  @override
  String get tabAll => 'सर्व';

  @override
  String get tabPending => 'प्रलंबित';

  @override
  String get tabActive => 'सुरू';

  @override
  String get tabResolved => 'निवारित';

  @override
  String get noComplaintsInFilter => 'या फिल्टरमध्ये तक्रार नाही';

  @override
  String get profileAccountGreeting => 'नागरिक खाते';

  @override
  String get profileToolsTitle => 'प्रोफाइल साधने';

  @override
  String get profileToolsSubtitle =>
      'मराठी, सूचना, तक्रार पद्धत, एसएमसी संपर्क व गोपनीयतेसाठी \'प्रोफाइल\' टॅब उघडा.';

  @override
  String get ticketRefPlaceholder => 'तक्रार';

  @override
  String get viewRepairProof => 'दुरुस्ती पुरावा पहा';
}
