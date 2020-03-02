import 'package:i18n_extension/i18n_extension.dart';

extension Localizations on String {
  static var _t = Translations('en') +
      {
        'en': 'Issue Details',
        'bg': 'Детайли за проблема',
      };
  get i18n => localize(this, _t);
}
