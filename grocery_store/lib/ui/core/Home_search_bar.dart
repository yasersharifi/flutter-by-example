import 'package:flutter/material.dart';
import 'package:grocery_store/ui/core/themes/my_theme.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: TextField(

        decoration: InputDecoration(
          filled: true,
          fillColor: MyTheme.bg2,
          hintText: 'Search keywords...',
          hintStyle: TextStyle(color: MyTheme.textGray, fontSize: 15),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5.0),
          ),
          prefixIcon: Icon(Icons.search, size: 20),
          prefixIconColor: MyTheme.textGray,
          suffixIcon: Icon(Icons.settings),
          suffixIconColor: MyTheme.textGray,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),

        ),
      ),
    );
  }
}
