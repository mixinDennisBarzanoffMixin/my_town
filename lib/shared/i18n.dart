import 'package:i18n_extension/i18n_extension.dart';

extension Localisations on String {
  static var translations = Translations('en') +
      {
        'en': 'Toggle options',
        'bg': 'Превключете към опциите',
      } +
      {
        'en': 'Helpful citizen',
        'bg': 'Полезен гражданин',
      } +
      {
        'en': 'Settings',
        'bg': 'Настройки',
      } +
      {
        'en': 'Sign in',
        'bg': 'Влез',
      } +
      {
        'en': 'Sign out',
        'bg': 'Излез',
      } +
      {
        'en': 'Achievemnts',
        'bg': 'Постижения',
      };

  get i18n => localize(this, translations);
}
