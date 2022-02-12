import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

class MyTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  late SuperTooltip tooltip;

  MyTooltip({required this.message, required this.child}) {
    tooltip = SuperTooltip(
      backgroundColor: Color(0xFF333333),
      popupDirection: TooltipDirection.down,
      content: new Material(
        color: Color(0xFF333333),
          child: Text(
        message,
        softWrap: true,
        style: TextStyle(backgroundColor: Color(0xFF333333), color: Colors.white),
      )),
    );
  }
  // We create the tooltip on the first use

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () => {this.tooltip.show(context)},
      child: child,
    );

    // final key = GlobalKey<State<Tooltip>>();
    // return Tooltip(
    //   key: key,
    //   showDuration: Duration(seconds: 60),
    //   message: message,
    //   child: GestureDetector(
    //     behavior: HitTestBehavior.deferToChild,
    //     onTap: () => _onTap(key),
    //     child: child,
    //   ),
    // );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
  }
}
