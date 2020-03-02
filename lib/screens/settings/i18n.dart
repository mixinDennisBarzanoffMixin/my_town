import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en') +
      {
        'en': 'Settings',
        'bg': 'Настройки',
      }+ {
        'en': 'Show the issues map',
        'bg': 'Покажи проблемите на картата'
      };

  String get i18n => localize(this, _t);
}
