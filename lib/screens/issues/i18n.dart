import 'package:i18n_extension/i18n_extension.dart';

var _t = Translations('en') +
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
    } +
    {
      'en': 'Achievement Made',
      'bg': 'Ново постижение',
    } +
    {
      'en': 'You got an achievement for reporting your first issue',
      'bg': 'Ново постижение за съобщаване на първата Ви нередност'
    };

extension Localization on String {
  String get i18n => localize(this, _t);

  String plural(int value) => localizePlural(value, this, _t);
}

String dynamicI18n(String s) => localize(s, _t);
