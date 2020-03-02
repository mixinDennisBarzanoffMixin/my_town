import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations('en') +
      {
        'en': 'Issues in your area',
        'bg': 'Проблеми около теб',
      } +
      {
        'en': 'N issues'
            .zero(
              'No issues',
            )
            .one(
              'One issue',
            )
            .many('%d issues'),
        'bg': 'N проблеми'
            .zero(
              'Няма проблеми',
            )
            .one(
              'Един проблем',
            )
            .many(
              '%d проблема',
            ),
      } +
      {
        'en': 'Options',
        'bg': 'Опции',
      } +
      {
        'en': 'Delete',
        'bg': 'Изтрий',
      };

  String get i18n => localize(this, _t);

  String plural(int value) => localizePlural(value, this, _t);
}
