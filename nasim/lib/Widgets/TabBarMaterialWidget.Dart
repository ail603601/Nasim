import 'package:flutter/material.dart';
import 'package:nasim/provider/DeviceListFabChangeNotifier.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TabBarMaterialWidget extends StatefulWidget {
  @override
  _TabBarMaterialWidgetState createState() => _TabBarMaterialWidgetState();
}

class _TabBarMaterialWidgetState extends State<TabBarMaterialWidget> {
  @override
  Widget build(BuildContext context) {
    final is_open = Provider.of<DeviceListFabChangeNotifier>(context).current_status;

    Future<bool> _onWillPop() async {
      final is_open = Provider.of<DeviceListFabChangeNotifier>(context, listen: false).current_status;
      if (is_open)
        Provider.of<DeviceListFabChangeNotifier>(context, listen: false).clicked();
      else
        return true;
      return false;
    }

    Widget choose_connection_way = Column(
      children: [
        SizedBox(height: 54),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/search_devices');
          },
          child: Ink(
            color: Colors.blue[500],
            height: 200,
            padding: EdgeInsets.zero,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                decoration: BoxDecoration(
                    // color: Colors.blue[500],border: Border.all(width: 0, color: Colors.blue[500]!),
                    ),
                width: 150,
                height: 200,
                child: Image.asset(
                  "assets/close_connection_method.png",
                  // fit: BoxFit.contain,
                  width: 150,
                  height: 200,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                height: 150,
                width: 2,
                color: Colors.white,
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
                // decoration: BoxDecoration(color: Colors.blue[500], border: Border.all(width: 0, color: Colors.blue[500]!)),
                height: 200,
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.closeConnectionTitle, style: Theme.of(context).textTheme.headline5),
                    SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.closeConnectionDescription, style: Theme.of(context).textTheme.bodyText2),
                  ],
                ),
              ))

              // Expanded(child: Container(color: Colors.amber)),
            ]),
          ),
        ),
        InkWell(
          onTap: () {},
          child: Ink(
            color: Colors.deepPurple[400],
            height: 200,
            padding: EdgeInsets.zero,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                  child: Container(
                padding: EdgeInsets.fromLTRB(10, 25, 0, 0),
                // decoration: BoxDecoration(color: Colors.blue[500], border: Border.all(width: 0, color: Colors.blue[500]!)),
                height: 200,
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.internetConnectionTitle, style: Theme.of(context).textTheme.headline5),
                    SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.internetConnectionDescription, style: Theme.of(context).textTheme.bodyText2),
                  ],
                ),
              )),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                height: 150,
                width: 2,
                color: Colors.white,
              ),
              Container(
                decoration: BoxDecoration(
                    // color: Colors.blue[500],border: Border.all(width: 0, color: Colors.blue[500]!),
                    ),
                width: 150,
                height: 200,
                child: Image.asset(
                  "assets/internet_connection_method.png",
                  // fit: BoxFit.contain,
                  width: 150,
                  height: 200,
                ),
              ),

              // Expanded(child: Container(color: Colors.amber)),
            ]),
          ),
        )
      ],
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        // color: Colors.red,
        child: Row(
          children: [
            AnimatedContainer(
              height: is_open ? 454 : 54,
              width: MediaQuery.of(context).size.width,
              child: is_open ? choose_connection_way : SizedBox(height: 54),
              duration: Duration(milliseconds: 300),
            )
          ],
        ),
      ),
    );
  }
}
// class TabBarMaterialWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 250),
//       child: BottomAppBar(
//         shape: CircularNotchedRectangle(),
//         notchMargin: 8,
//         // color: Colors.red,
//         child: Row(
//           children: [
//             SizedBox(
//               height: 540,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
