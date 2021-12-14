import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nasim/page/AppIntroductionScreenModules/page1.dart';
import 'package:nasim/page/AppIntroductionScreenModules/page2.dart';
import 'package:nasim/page/AppIntroductionScreenModules/page3.dart';
import 'package:nasim/provider/FirstTimeUsageChangeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nasim/IntroductionScreen/model/page_decoration.dart';
import 'package:nasim/IntroductionScreen/introduction_screen.dart';

class AppIntroductionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _decoration = PageDecoration(
        titleTextStyle: Theme.of(context).textTheme.headline4!,
        bodyTextStyle: Theme.of(context).textTheme.bodyText2!,
        descriptionPadding: EdgeInsets.all(16).copyWith(bottom: 0),
        imagePadding: EdgeInsets.all(24));
    void introEnded() {
      Provider.of<FirstTimeUsageChangeNotifier>(context, listen: false).firstTimeEnded();
    }

    return SafeArea(
        child: IntroductionScreen(
      onNext: (i) => true,
      onBack: (i) => true,
      pages: [page1(context, _decoration), page2(context, _decoration), page3(context, _decoration)],
      next: Icon(Icons.arrow_forward),
      done: Text(
        AppLocalizations.of(context)!.done,
        style: Theme.of(context).textTheme.headline5,
      ),
      showSkipButton: true,
      skip: Text(AppLocalizations.of(context)!.skip),
      onDone: introEnded,
      onSkip: introEnded,
      isProgressTap: false,
      nextFlex: 0,
      skipFlex: 0,
    ));
  }
}
