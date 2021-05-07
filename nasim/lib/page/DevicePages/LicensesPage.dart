import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';

class LicensesPage extends StatefulWidget {
  @override
  _LicensesPageState createState() => _LicensesPageState();
}

class _LicensesPageState extends State<LicensesPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    // await Provider.of<ConnectionManager>(context, listen: false).getRequest("").then(print);
    // await Provider.of<ConnectionManager>(context, listen: false).getRequest("").then(print);
    // await Provider.of<ConnectionManager>(context, listen: false).getRequest("").then(print);
    // await Provider.of<ConnectionManager>(context, listen: false).getRequest("").then(print);
    // await Provider.of<ConnectionManager>(context, listen: false).getRequest("").then(print);
  }

  List<Widget> build_license_row(title) {
    return [
      ListTile(
        subtitle: Text(
          "valid untill 2023/06/25",
          style: Theme.of(context).textTheme.bodyText2,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.headline6,
        ),
        trailing: Icon(Icons.verified_outlined),
      ),
      Divider(
        color: Theme.of(context).accentColor,
      ),
    ];
  }

  Widget buildTextField(BuildContext context) => TextField(
        // controller: controller,
        keyboardType: TextInputType.number,

        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),

        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.enterSerialNumber,
          hintStyle: Theme.of(context).textTheme.bodyText1!,
        ),
      );
  void openBottomSheet(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text("you need to provice license serial number", style: Theme.of(context).textTheme.headline6!),
              ),
              ListTile(
                  leading: Icon(Icons.qr_code),
                  title: Text(AppLocalizations.of(context)!.scanQrCode, style: Theme.of(context).textTheme.headline5!),
                  onTap: () {
                    Navigator.pushNamed(context, "/scan_barcode");
                  }),
              Divider(
                color: Theme.of(context).accentColor,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 60),
                child: Row(
                  children: [
                    Expanded(child: buildTextField(context)),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () {},
                      child: Icon(Icons.done, size: 30),
                      // onPressed: () => setState(() {}),
                    )
                  ],
                ),
              ),
            ]));
  }

  build_new_license_button() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: () {
              openBottomSheet(context);
            },
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
            child: Text("New License", style: Theme.of(context).textTheme.headline6),
          ),
        ),
      );
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).canvasColor,
        child: SafeArea(
            child: Column(mainAxisSize: MainAxisSize.max, children: [
          ...build_license_row("Power Box"),
          ...build_license_row("Room Temp sensor"),
          Expanded(child: Align(alignment: Alignment.bottomCenter, child: build_new_license_button()))
        ])));
  }
}
