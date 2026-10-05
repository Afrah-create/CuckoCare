// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CucoCare';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystemHelperLight =>
      'Following your phone\'s setting (currently Light)';

  @override
  String get themeSystemHelperDark =>
      'Following your phone\'s setting (currently Dark)';

  @override
  String get stateLoading => 'Loading';

  @override
  String get stateTryAgain => 'Try again';

  @override
  String get stateSaved => 'Saved';

  @override
  String get stateSavedOnPhone => 'Saved on this phone';

  @override
  String get stateUpToDate => 'Up to date';

  @override
  String get stateOfflineWillSync => 'Offline. Will sync later';

  @override
  String get stateCouldNotUpdate => 'Couldn\'t update. Showing saved data.';

  @override
  String get statePendingSync => 'Saved on this phone. Will sync when online';

  @override
  String get stateScreenFailed => 'Something went wrong on this screen';

  @override
  String get stateItemRemoved => 'This item was removed';

  @override
  String get emptyTodayTitle => 'Nothing due today';

  @override
  String get emptyTodayMessage => 'Nice work. New tasks will show up here.';

  @override
  String get emptyBatchesTitle => 'No batches yet';

  @override
  String get emptyBatchesMessage =>
      'Add your first flock to get a care schedule. This works offline.';

  @override
  String get emptyFeedTitle => 'No feed items yet';

  @override
  String get emptyFeedMessage => 'Add feed to track stock. This works offline.';

  @override
  String get emptyRecordsTitle => 'No health records yet';

  @override
  String get emptyRecordsMessage =>
      'Incidents and vet requests will show up here after you add one.';

  @override
  String get emptyVetInboxTitle => 'No requests right now';

  @override
  String get emptyVetInboxMessage => 'New farmer requests will show up here.';
}
