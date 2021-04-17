import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nasim/provider/FirstTimeUsageChangeNotifier.dart';
import 'provider/ThemeChangeNotifer.dart';
import 'localizations/L10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() => runApp(RootView());

class RootView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeChangeNotifer>(
              create: (context) => ThemeChangeNotifer()),
          ChangeNotifierProvider<FirstTimeUsageChangeNotifier>(
              create: (context) => FirstTimeUsageChangeNotifier())
          // Provider<SomethingElse>(create: (_) => SomethingElse()),
          // Provider<AnotherThing>(create: (_) => AnotherThing()),
        ],
        child: MyApp(),
      );
}

class MyApp extends StatelessWidget {
  static final String title = 'Nasim';

  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: Provider.of<ThemeChangeNotifer>(context, listen: true).current,
      supportedLocales: L10n.all,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: sample());
}

class sample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // body: Center(child: Text(AppLocalizations.of(context)!.language)),
        body: FutureBuilder<bool>(
      future: Provider.of<FirstTimeUsageChangeNotifier>(context)
          .isFirstTime(), // a Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new Text('Press button to start');
          case ConnectionState.waiting:
            return new Text('Awaiting result...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else {
              // Provider.of<FirstTimeUsageChangeNotifier>(context, listen: false)
              //     .firstTimeEnded();
              return new Center(
                  child: Text('Result: ${snapshot.data == true ? "y" : "F"}'));
            }
        }
      },
    ));
  }
}
