import 'package:flutter/material.dart';
import 'package:nasim/IntroductionScreen/model/page_decoration.dart';
import 'package:nasim/IntroductionScreen/introduction_screen.dart';
import 'package:nasim/page/DevicePages/SettingsPages/UsersPage.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:provider/provider.dart';

import '../../utils.dart';
import '../DevicesListConnect.dart';
import 'Pages/wpage_temperature.dart';
import 'Pages/wpage_wellcome.dart';
import 'Pages/wpage_license.dart';
import 'Pages/wpage_users.dart';
import 'Pages/wpage_outlet_fan.dart';
import 'Pages/wpage_inlet_fan.dart';
import 'Pages/wpage_humidity.dart';
import 'Pages/wpage_air_quality.dart';
import 'Pages/wpage_controller_status.dart';
import 'Pages/wpage_sms.dart';
import 'Pages/wpage_light.dart';

class WizardPage extends StatefulWidget {
  const WizardPage({Key? key}) : super(key: key);

  @override
  WizardPageState createState() => WizardPageState();
}

class WizardPageState extends State<WizardPage> {
  @override
  void initState() {
    super.initState();
  }

  static bool can_next = true;

  static void wizardNewSetup() {
    wpage_outlet_fanState.is_maximum_set = false;
    wpage_outlet_fanState.is_minimum_set = false;

    wpage_inlet_fanState.is_maximum_day_set = false;
    wpage_inlet_fanState.is_maximum_night_set = false;
    wpage_inlet_fanState.is_minimum_day_set = false;
    wpage_inlet_fanState.is_minimum_night_set = false;

    wpage_inlet_fanState.expanded_min_day = true;
    wpage_inlet_fanState.expanded_min_night = false;
    wpage_inlet_fanState.expanded_max_day = true;
    wpage_inlet_fanState.expanded_max_night = false;
    wpage_inlet_fanState.is_inlet_fan_available = false;

    wpage_temperatureState.is_day_set = false;
    wpage_temperatureState.is_night_set = false;

    wpage_humidityState.is_day_set = false;
    wpage_humidityState.is_night_set = false;

    wpage_air_qualityState.is_day_set = false;
    wpage_air_qualityState.is_night_set = false;
  }

  static void wizardEnded(context) async {
    wizardNewSetup();

    // if (DevicesListConnectState.flag_only_user == true) {
    // if (wpage_usersState.can_next) {
    //   await Provider.of<ConnectionManager>(context, listen: false).setRequest(121, "1");
    //   Navigator.pop(context, true);
    // }
    // } else {
    await Provider.of<ConnectionManager>(context, listen: false).setRequest(121, "1");
    Navigator.pop(context, true);
    // }
  }

  List<Widget> raw_pages = [
    wpage_wellcome(),
    wpage_license(),
    wpage_users(),
    wpage_outlet_fan(),
    wpage_inlet_fan(),
    wpage_temperature(),
    wpage_humidity(),
    wpage_air_quality(),
    wpage_controller_status(),
    wpage_sms(),
    wpage_light()
  ];
  void wizard_done() {
    if ((raw_pages.last as dynamic).Next()) {
      wizardEnded(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool can_next(int i) {
      return (raw_pages[i] as dynamic).Next();
    }

    bool can_back(int i) {
      if ((raw_pages[i] as dynamic).Back != null)
        return (raw_pages[i] as dynamic).Back();
      else
        return true;
    }

    if (DevicesListConnectState.flag_only_user == true) {
      raw_pages = [
        wpage_users(),
      ];
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(SavedDevicesChangeNotifier.getSelectedDevice()!.name, style: Theme.of(context).textTheme.headline5!),
          centerTitle: true,
        ),
        body: ChangeNotifierProvider<LicenseChangeNotifier>(
          create: (context) => LicenseChangeNotifier(context),
          lazy: false,
          child: IntroductionScreen(
            onNext: can_next,
            onBack: can_back,
            rawPages: raw_pages as List<Widget>,
            next: Icon(Icons.arrow_forward),
            done: Text(
              "Done",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            freeze: true,
            onDone: () {
              wizard_done();
            },
            isProgressTap: false,
            nextFlex: 0,
            skipFlex: 0,
          ),
        ));
  }
}
