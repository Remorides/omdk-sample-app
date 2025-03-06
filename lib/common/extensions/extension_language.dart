import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';
import 'package:omdk_sample_app/common/common.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LanguageCodeHelper on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this)!;

  String get languageCode => Localizations.localeOf(this).languageCode;

  String? localizeLabel(List<JCultureDependentValue>? titles) {
    return (titles?.firstWhereOrNull(
              (e) =>
                  e.culture?.contains(
                    Localizations.localeOf(this).languageCode,
                  ) ??
                  false,
            ) ??
            titles?[0])
        ?.value;
  }
}

extension LocaleHelper on Language {
  Locale get locale => switch (this) {
        Language.English_US => const Locale('en'),
        Language.Italian => const Locale('it'),
        Language.French => const Locale('fr'),
        Language.Spanish => const Locale('es'),
      };
}

extension LanguageHelper on Locale {
  Language get language => switch (languageCode) {
        'en' => Language.English_US,
        'it' => Language.Italian,
        'es' => Language.Spanish,
        'fr' => Language.French,
        String() => throw UnimplementedError(),
      };
}
