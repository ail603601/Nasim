import 'package:flutter/material.dart';
import 'package:nasim/IntroductionScreen/model/page_decoration.dart';
import 'package:nasim/IntroductionScreen/introduction_screen.dart';
import 'package:nasim/page/DevicePages/SettingsPages/UsersPage.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:provider/provider.dart';

import '../../utils.dart';
import 'Pages/wpage_temperature.dart';
import 'Pages/wpage_wellcome.dart';
import 'Pages/wpage_license.dart';
import 'Pages/wpage_users.dart';
import 'Pages/wpage_outlet_fan.dart';
import 'Pages/wpage_inlet_fan.dart';
import 'Pages/wpage_humidity.dart';
import 'Pages/wpage_air_quality.dart';
import 'Pages/wpage_light.dart';

class WizardPage extends StatelessWidget {
  static bool can_next = true;
  @override
  Widget build(BuildContext context) {
    void wizardEnded() async {
      if (!await Provider.of<ConnectionManager>(context, listen: false).set_request(121, "1")) {
        Utils.handleError(context);
        return;
      }
      Navigator.pop(context, true);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(SavedDevicesChangeNotifier.selected_device!.name, style: Theme.of(context).textTheme.headline5!),
          centerTitle: true,
        ),
        body: ChangeNotifierProvider<LicenseChangeNotifier>(
          create: (context) => LicenseChangeNotifier(context),
          lazy: false,
          child: IntroductionScreen(
            onNext: () => can_next,
            rawPages: [
              wpage_wellcome(),
              wpage_license(),
              wpage_users(),
              wpage_outlet_fan(),
              wpage_inlet_fan(),
              wpage_temperature(),
              wpage_humidity(),
              wpage_air_quality(),
              wpage_light()
            ],
            next: Icon(Icons.arrow_forward),
            done: Text(
              "Done",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            freeze: true,
            onDone: wizardEnded,
            isProgressTap: false,
            nextFlex: 0,
            skipFlex: 0,
          ),
        ));
  }
}
