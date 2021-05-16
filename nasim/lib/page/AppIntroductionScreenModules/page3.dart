import 'package:nasim/IntroductionScreen/model/page_view_model.dart';
import 'package:nasim/IntroductionScreen/model/page_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

PageViewModel page3(BuildContext context, PageDecoration decoration) {
  Widget buildImage(String path) => Center(child: Image.asset(path, width: 350));

  return PageViewModel(
      title: AppLocalizations.of(context)!.introPage3Title,
      body: AppLocalizations.of(context)!.introPage3body,
      image: buildImage("assets/monster.png"),
      decoration: decoration);
}
