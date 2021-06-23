import 'package:flutter/material.dart';
import 'package:nasim/page/Wizard/Wizardpage.dart';

import '../../../utils.dart';

class wpage_wellcome extends StatefulWidget {
  @override
  _wpage_wellcomeState createState() => _wpage_wellcomeState();

  bool Function()? Next = null;
}

class _wpage_wellcomeState extends State<wpage_wellcome> {
  @override
  void initState() {
    widget.Next = () {
      return true;
    };

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
            child: Text("Here we go step by step setting up your device for fist time.", style: Theme.of(context).textTheme.bodyText1!),
          ),
        ],
      ),
    );
  }
}
