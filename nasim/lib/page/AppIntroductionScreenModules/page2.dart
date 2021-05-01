import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

PageViewModel page2(BuildContext context, PageDecoration decoration) {
  Widget buildImage(String path) => Center(child: Image.asset(path, width: 350));

  return PageViewModel(
      title: AppLocalizations.of(context)!.introPage2Title,
      body: AppLocalizations.of(context)!.introPage2body,
      image: buildImage("assets/monster.png"),
      decoration: decoration);
}
