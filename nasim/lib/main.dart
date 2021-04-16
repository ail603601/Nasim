import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nasim/page/products_page.dart';
import 'package:nasim/provider/shop_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static final String title = 'Shop UI - Drinks';
  final state = ShopProvider();

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<ShopProvider>.value(
        value: state,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: title,
          theme: ThemeData(
            primaryColor: Colors.deepOrange,
            primaryColorDark: Colors.white,
            primaryColorLight: Colors.white,
          ),
          home: ProductsPage(), //CartPage(),
        ),
      );
}
