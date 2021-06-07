import 'package:flutter/material.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../enums.dart';
import 'DevicePages/SettingsPage.dart';
import 'DevicePages/SettingsPages/UsersPage.dart';
import 'DevicePages/ControllPage.dart';
import 'DevicePages/LicensesPage.dart';
import 'DevicePages/OverviewPage.dart';

class DeivceMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final menuItems = [
      MenuInfo(MenuType.Overview, title: "Overview", imageSource: Icons.grid_view),
      MenuInfo(MenuType.Controll, title: AppLocalizations.of(context)!.controll, imageSource: Icons.fact_check),
      MenuInfo(MenuType.Settings, title: AppLocalizations.of(context)!.settings, imageSource: Icons.settings),
      MenuInfo(MenuType.Licenses, title: AppLocalizations.of(context)!.licenses, imageSource: Icons.assignment)
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
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
              child: Container(
                decoration: new BoxDecoration(),
                clipBehavior: Clip.hardEdge,
                child: Consumer<MenuInfo>(
                  builder: (BuildContext context, MenuInfo value, Widget? child) {
                    if (value.menuType == MenuType.Overview)
                      return new OverviePage();
                    else if (value.menuType == MenuType.Controll)
                      return new ControllPage();
                    else if (value.menuType == MenuType.Settings)
                      return new SettingsPage();
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuButton(MenuInfo currentMenuInfo) {
    return Consumer<MenuInfo>(
      builder: (BuildContext context, MenuInfo value, Widget? child) {
        return FlatButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(32))),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
          color: currentMenuInfo.menuType == value.menuType ? Colors.black26 : Colors.transparent,
          onPressed: () {
            var menuInfo = Provider.of<MenuInfo>(context, listen: false);

            menuInfo.updateMenu(currentMenuInfo);
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
