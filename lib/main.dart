//import 'dart:developer';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raschet_gsm/ustokno.dart';
import 'package:raschet_gsm/raschetokno.dart';
// import 'libs.dart';
import 'globals.dart' as globals;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor:
        Color.fromRGBO(124, 20, 21, 1), // цвет нижей полоски
    statusBarColor: Color.fromRGBO(124, 20, 21, 1), // цвет строки состояния
  ));

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool pervZap = prefs.getBool("newLaunch") ?? true;
  
  if (!pervZap) {
    globals.nOtryad = prefs.getString("nOtryada") ?? '';
    globals.nazvOtr = prefs.getString("nazvOtr") ?? '';
    globals.tekAvto = prefs.getString("tekAvto") ?? '';
    globals.idtekAvto = prefs.getInt("tekAvtoId") ?? 0;
  }
  //!!!
  if ((DateTime.now().millisecondsSinceEpoch / 1000).round() >= 1708700400) {
    SystemNavigator.pop();
  }

  runApp(MainApp(pervZap));
  //runApp(const MainApp(true));
}

class MainApp extends StatelessWidget {
  final bool pervzap;

  const MainApp(this.pervzap, {super.key});

  @override
  Widget build(BuildContext context) {
    globals.txScFact = MediaQuery.textScalerOf(context).scale(1);
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru'),
      ],
      theme: ThemeData(
        fontFamily: 'Nunito', //'RobotoCondensed',
        appBarTheme: const AppBarTheme(color: Color.fromRGBO(124, 20, 21, 1)),
      ),
      initialRoute: pervzap ? 'Ustanov' : 'Raschet',
      routes: {
        'Raschet': (context) => const RaschetOkno(),
        'Ustanov': (context) => const UstanOkno(),
      },
    );
  }
}
