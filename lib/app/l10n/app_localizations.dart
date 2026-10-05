import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'CucoCare'**
  String get appTitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystemHelperLight.
  ///
  /// In en, this message translates to:
  /// **'Following your phone\'s setting (currently Light)'**
  String get themeSystemHelperLight;

  /// No description provided for @themeSystemHelperDark.
  ///
  /// In en, this message translates to:
  /// **'Following your phone\'s setting (currently Dark)'**
  String get themeSystemHelperDark;

  /// No description provided for @stateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get stateLoading;

  /// No description provided for @stateTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get stateTryAgain;

  /// No description provided for @stateSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get stateSaved;

  /// No description provided for @stateSavedOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone'**
  String get stateSavedOnPhone;

  /// No description provided for @stateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get stateUpToDate;

  /// No description provided for @stateOfflineWillSync.
  ///
  /// In en, this message translates to:
  /// **'Offline. Will sync later'**
  String get stateOfflineWillSync;

  /// No description provided for @stateCouldNotUpdate.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update. Showing saved data.'**
  String get stateCouldNotUpdate;

  /// No description provided for @statePendingSync.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone. Will sync when online'**
  String get statePendingSync;

  /// No description provided for @stateScreenFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on this screen'**
  String get stateScreenFailed;

  /// No description provided for @stateItemRemoved.
  ///
  /// In en, this message translates to:
  /// **'This item was removed'**
  String get stateItemRemoved;

  /// No description provided for @emptyTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing due today'**
  String get emptyTodayTitle;

  /// No description provided for @emptyTodayMessage.
  ///
  /// In en, this message translates to:
  /// **'Nice work. New tasks will show up here.'**
  String get emptyTodayMessage;

  /// No description provided for @emptyBatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No batches yet'**
  String get emptyBatchesTitle;

  /// No description provided for @emptyBatchesMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first flock to get a care schedule. This works offline.'**
  String get emptyBatchesMessage;

  /// No description provided for @emptyFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'No feed items yet'**
  String get emptyFeedTitle;

  /// No description provided for @emptyFeedMessage.
  ///
  /// In en, this message translates to:
  /// **'Add feed to track stock. This works offline.'**
  String get emptyFeedMessage;

  /// No description provided for @emptyRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'No health records yet'**
  String get emptyRecordsTitle;

  /// No description provided for @emptyRecordsMessage.
  ///
  /// In en, this message translates to:
  /// **'Incidents and vet requests will show up here after you add one.'**
  String get emptyRecordsMessage;

  /// No description provided for @emptyVetInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'No requests right now'**
  String get emptyVetInboxTitle;

  /// No description provided for @emptyVetInboxMessage.
  ///
  /// In en, this message translates to:
  /// **'New farmer requests will show up here.'**
  String get emptyVetInboxMessage;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
