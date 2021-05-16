import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nasim/page/AppIntroductionScreen.dart';
import 'package:nasim/page/BarCodeScanPage.dart';
import 'package:nasim/page/DeviceMainPage.dart';
import 'package:nasim/page/DevicesListConnect.dart';
import 'package:nasim/page/SearchDevices.dart';
import 'package:nasim/page/Wizard/Wizardpage.dart';
import 'package:nasim/provider/FirstTimeUsageChangeNotifier.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'Model/menu_info.dart';
import 'enums.dart';
import 'provider/ThemeChangeNotifer.dart';
import 'localizations/L10n.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'splash.dart';

void main() {
  runApp(RootView());
  // runApp(splash());
}

class RootView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeChangeNotifer>(create: (context) => ThemeChangeNotifer()),

          ChangeNotifierProvider<FirstTimeUsageChangeNotifier>(create: (context) => FirstTimeUsageChangeNotifier()),
          ChangeNotifierProvider<MenuInfo>(create: (context) => MenuInfo(MenuType.Licenses, title: "Licenses")),
          ChangeNotifierProvider<ConnectionManager>(
            create: (context) => ConnectionManager(),
            lazy: false,
          ),
          ChangeNotifierProvider<SavedDevicesChangeNotifier>(
            create: (context) => SavedDevicesChangeNotifier(),
            lazy: false,
          )
          // Provider<SomethingElse>(create: (_) => SomethingElse()),
          // Provider<AnotherThing>(create: (_) => AnotherThing()),
        ],
        child: MyApp(),
      );
}

class MyApp extends StatelessWidget {
  static final String title = 'BREEZE';

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
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
      // home: sample(),,
      initialRoute: '/splash',
      // routes: {
      //   // When navigating to the "/" route, build the FirstScreen widget.
      //   '/': (context) => sample(),+
      //   // When navigating to the "/second" route, build the SecondScreen widget.
      //   '/search_devices': (context) => SearchDevices(),
      //   '/scan_barcode': (context) => BarcodeScanPage(),
      //   '/main_device': (context) => DeivceMainPage(),
      // },
      onGenerateRoute: (settings) {
        if (settings.name == "/search_devices") {
          return CupertinoPageRoute(builder: (context) => SearchDevices());
        }
        if (settings.name == "/scan_barcode") {
          return CupertinoPageRoute(builder: (context) => BarcodeScanPage());
        }
        if (settings.name == "/main_device") {
          return CupertinoPageRoute(builder: (context) => DeivceMainPage());
        }
        if (settings.name == "/wizard") {
          return CupertinoPageRoute(builder: (context) => WizardPage());
        }
        if (settings.name == "/splash") {
          return PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => splash(),
            transitionDuration: Duration(seconds: 0),
          );
        }
        // unknown route
        return CupertinoPageRoute(builder: (context) => sample());
      },
    );
  }
}

class sample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Provider.of<FirstTimeUsageChangeNotifier>(context).isFirstTime(), // a Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new Container();
          case ConnectionState.waiting:
            // return new SpinKitDualRing(
            //   color: Theme.of(context).accentColor,
            //   size: 300,
            // );
            return Center();
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else {
              if (snapshot.data == true) {
                return AppIntroductionScreen();
              } else {
                // return splash();
                return DevicesListConnect();
              }
            }
        }
      },
    );
  }
}
