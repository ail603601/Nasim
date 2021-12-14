import 'package:flutter/material.dart';
import 'package:nasim/page/Wizard/Wizardpage.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';

import '../../../utils.dart';

class wpage_wellcome extends StatefulWidget {
  @override
  _wpage_wellcomeState createState() => _wpage_wellcomeState();

  bool Function()? Next = null;
  bool Function()? Back = null;
}

class _wpage_wellcomeState extends State<wpage_wellcome> {
  @override
  void initState() {
    widget.Next = () {
      return true;
    };
    // Provider.of<ConnectionManager>(context, listen: false).setRequest(123, "", context);
    // Provider.of<ConnectionManager>(context, listen: false).setRequest(124, "", context);
    // Provider.of<ConnectionManager>(context, listen: false).setRequest(125, "0", context);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    precacheImage(AssetImage('assets/setup.png'), context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF9CB3C1),
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Text("Setup Wizard", style: Theme.of(context).textTheme.headline1!),
          SizedBox(
            height: 25,
          ),
          Image.asset(
            "assets/setup.png",
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Here we go step by step setting\n up your device for first time.",
              style: Theme.of(context).textTheme.headline6!,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
