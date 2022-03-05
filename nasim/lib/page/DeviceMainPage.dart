import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
import 'package:nasim/page/DevicePages/DeviceinfoPage.dart';
import 'package:nasim/provider/ConnectionAvailableChangeNotifier.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../enums.dart';
import '../provider/SavedevicesChangeNofiter.dart';
import 'DevicePages/ControllPage.dart';
import 'DevicePages/LicensesPage.dart';
import 'DevicePages/OverviewPage.dart';
import 'Wizard/Wizardpage.dart';

class DeivceMainPage extends StatefulWidget {
  const DeivceMainPage({Key? key}) : super(key: key);

  @override
  _DeivceMainPageState createState() => _DeivceMainPageState();
}

class _DeivceMainPageState extends State<DeivceMainPage> {
  @override
  void initState() {
    super.initState();
    var cmg = Provider.of<ConnectionManager>(context, listen: false);
    cmg.getRequest(126, context).then((value) async {
      bool connection_failed = (int.tryParse(value) ?? 0) == 1;
      if (connection_failed) {
        ConnectionManager.DEVICE_WIFI_TO_CONNECT_NAME = await cmg.getRequest(123, context);
        Utils.alert(context, "", "Connection to Wifi '${ConnectionManager.DEVICE_WIFI_TO_CONNECT_NAME}' failed.\nPlease check your Wifi name and password.");
      }
      cmg.setRequest(126, "0");
    });

    if (WizardPage.flag_ask_to_config_internet) {
      Utils.setTimeOut(0, () {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.INFO_REVERSED,
          animType: AnimType.BOTTOMSLIDE,
          title: "Note",
          desc: "Do you want to configure internet connection for this device?",
          btnCancelText: "No",
          btnOkOnPress: () {
            var menuInfo = Provider.of<MenuInfo>(context, listen: false);
            setState(() {
              menuInfo.updateMenu(MenuInfo(MenuType.Controll, title: AppLocalizations.of(context)!.controll, imageSource: Icons.fact_check));
            });
          },
          btnCancelOnPress: () {
            WizardPage.flag_ask_to_config_internet = false;
          },
        )..show();
      });
    }
  }

  Widget build(BuildContext context) {
    final menuItems = [
      MenuInfo(MenuType.Overview, title: "Overview", imageSource: Icons.grid_view),
      MenuInfo(MenuType.Controll, title: "Settings", imageSource: Icons.fact_check),
      MenuInfo(MenuType.DeviceInformation, title: "Information", imageSource: Icons.info),
      MenuInfo(MenuType.Licenses, title: AppLocalizations.of(context)!.licenses, imageSource: Icons.assignment)
    ];
    return Stack(children: [
      Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/app_bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Row(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: menuItems.map((currentMenuInfo) => buildMenuButton(currentMenuInfo)).toList(),
              ),
              VerticalDivider(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
              Expanded(
                child: ChangeNotifierProvider<LicenseChangeNotifier>(
                    create: (context) => LicenseChangeNotifier(context),
                    lazy: false,
                    child: Consumer<LicenseChangeNotifier>(builder: (context, lcn, child) {
                      return FutureBuilder<bool>(
                          future: lcn.loading_finished.future, // a Future<String> or null
                          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                            switch (snapshot.connectionState) {
                              default:
                                if (snapshot.hasError)
                                  return new Text('Error: ${snapshot.error}');
                                else {
                                  if (snapshot.data == true) {
                                    return Container(
                                      decoration: new BoxDecoration(),
                                      clipBehavior: Clip.hardEdge,
                                      child: Consumer<MenuInfo>(
                                        builder: (BuildContext context, MenuInfo value, Widget? child) {
                                          if (value.menuType == MenuType.Overview)
                                            return new OverviePage();
                                          else if (value.menuType == MenuType.Controll)
                                            return new ControllPage();
                                          else if (value.menuType == MenuType.DeviceInformation)
                                            return new DeviceInfoPage();
                                          else if (value.menuType == MenuType.Licenses)
                                            return new LicensesPage();
                                          else
                                            return Container(
                                              child: RichText(
                                                text: TextSpan(
                                                  style: TextStyle(fontSize: 20),
                                                  children: <TextSpan>[
                                                    TextSpan(text: 'Upcoming \n'),
                                                    TextSpan(
                                                      text: value.title,
                                                      style: TextStyle(fontSize: 48),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                        },
                                      ),
                                    );
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                            }
                          });
                    })),
              ),
            ],
          ),
        ),
      ),
      ChangeNotifierProvider(
          create: (context) => ConnectionAvailableChangeNotifier(),
          child: Consumer<ConnectionAvailableChangeNotifier>(builder: (context, CACN, child) {
            ConnectionAvailableChangeNotifier.instance = CACN;

            return CACN.is_offline()
                ? SafeArea(
                    child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: EdgeInsets.only(top: 55, right: 55),
                      child: Banner(
                        message: "Offline",
                        location: BannerLocation.bottomStart,
                      ),
                    ),
                  ))
                : Container();
          }))
    ]);
  }

  bool simple_check_done = false;
  var simplecheckDialogInputValue = "";
  Future<bool> simplecheck(BuildContext context) async {
    var rng = new Random();
    var num1 = rng.nextInt(10);
    var num2 = rng.nextInt(10);
    var math_res = (num1 * num2).toString();
    Completer<bool> dialog_beify_answer = new Completer<bool>();
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Result of  $num1 * $num2 ?", style: Theme.of(context).textTheme.bodyText1),
            content: TextField(
              maxLength: 10,
              style: Theme.of(context).textTheme.bodyText1,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                simplecheckDialogInputValue = value;
              },
              decoration: InputDecoration(hintText: "", counterText: ""),
            ),
            actions: <Widget>[
              FlatButton(
                // color: Colors.red,
                textColor: Colors.black,
                child: Text('CANCEL', style: Theme.of(context).textTheme.bodyText1),
                onPressed: () {
                  dialog_beify_answer.complete(false);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                // color: Colors.green,
                textColor: Colors.black,
                child: Text('OK', style: Theme.of(context).textTheme.bodyText1),
                onPressed: () async {
                  if (math_res == simplecheckDialogInputValue) {
                    dialog_beify_answer.complete(true);
                    Navigator.pop(context);
                  } else {
                    dialog_beify_answer.complete(false);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
    if (!dialog_beify_answer.isCompleted) dialog_beify_answer.complete(false);

    return dialog_beify_answer.future;
  }

  Widget buildMenuButton(MenuInfo currentMenuInfo) {
    return Consumer<MenuInfo>(
      builder: (BuildContext context, MenuInfo value, Widget? child) {
        return FlatButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(32))),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
          color: currentMenuInfo.menuType == value.menuType ? Colors.black26 : Colors.transparent,
          onPressed: () async {
            var menuInfo = Provider.of<MenuInfo>(context, listen: false);
            if (!simple_check_done && (currentMenuInfo.menuType == MenuType.Controll)) {
              if (await simplecheck(context)) {
                simple_check_done = true;
                menuInfo.updateMenu(currentMenuInfo);
              }
            } else {
              menuInfo.updateMenu(currentMenuInfo);
            }
          },
          child: Column(
            children: <Widget>[
              Icon(
                currentMenuInfo.imageSource,
                size: 38,
              ),
              SizedBox(height: 16),
              Text(
                currentMenuInfo.title,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
        );
      },
    );
  }
}
