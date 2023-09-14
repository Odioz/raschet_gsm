/// глобальные переменные
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'baza.dart';

SharedPreferences? prefs;
double txScFact = 1;   //коэффициент увеличения текста
Database? db;
String path = '';
List<Podraz> podrazdelen = [];
List<Normy> normy = [];
List<String> spisokOtr = [];
List<String> spisokPA = [];
//bool pervZapusk = true;
String nOtryad = '';
String nazvOtr = '';
String tekAvto = '';
int idtekAvto = 0;
int vidRaboty = 0;
double rasXod = 0.0;
int sNasosVrema = 0;
int bNasosVrema = 0;
int procheVrema = 0;
//String? nPA;
