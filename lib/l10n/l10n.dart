import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  // 이제 context.l10n 으로 AppLocalizations에 접근할 수 있습니다.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
