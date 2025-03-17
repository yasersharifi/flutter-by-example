import 'package:flutter/material.dart';
import 'package:grocery_store/app_router.dart';

void main(){
  runApp(MyApp()); // Pass router in to the app
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
    );
  }
}
