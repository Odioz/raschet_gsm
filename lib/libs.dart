//import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:raschet_gsm/baza.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'globals.dart' as globals;
import 'package:raschet_gsm/ustokno.dart';
import 'package:raschet_gsm/raschetokno.dart';

Future checkNewLaunch() async {
//проверка на первый запуск
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey("newLaunch")) {
    return true;
  } else {
    return false;
  }
}

vyborClick(String value, BuildContext context) {
  //меню
  switch (value) {
    case 'Сменить отряд':
      smenaOtryada(context);
      break;
    case 'О приложении':
      oPrilojenii(context);
      break;
  }
}

raschetOkno(BuildContext context) {
  //вызов "Расчет"
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    return const RaschetOkno();
  }));
}

smenaOtryada(BuildContext context) {
  //вызов "Выбор отряда"
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    return const UstanOkno();
  }));
}

ustanPrefern(String? nazv) async {
  //запись устанв данных
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var db = await loadDataBase();
  List<Map> otr = await db
      .rawQuery('SELECT DISTINCT otryad FROM podrazd WHERE nazv=?', [nazv]);
  prefs.setBool('newLaunch', false);
  globals.nOtryad = otr[0]['otryad'];
  globals.nazvOtr = nazv!;
  prefs.setString('nazvOtr', globals.nazvOtr);
  prefs.setString('nOtryada', globals.nOtryad);
  prefs.setString('tekAvto', '');
  prefs.setInt('tekAvtoId', 0);
  prefs.reload();
}

Future<String> readPrefern() async {
  //чтение установок
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('nOtryada') ?? '23';
}

Future<List<Podraz>> getPodrazd() async {
  //чтение из таблицы 'podrazd'
  var db = await loadDataBase();
  final List<Map<String, dynamic>> maps = await db.query('podrazd');
  return List.generate(maps.length, (index) => Podraz.fromJson(maps[index]));
}

spisokOtryadov() {
  //сделать список отрядов для выбора
  if (globals.spisokOtr.isEmpty) {
    for (var i = 0; i < globals.podrazdelen.length; i++) {
      if (globals.podrazdelen[i].krit == 'o') {
        globals.spisokOtr.add(globals.podrazdelen[i].nazv);
      }
    }
  }
}

zapisAvto(String sValue, int nA) async {
  //запомнить текущий автомобиль
  int idavto = globals.normy[nA].id!;
  globals.idtekAvto = idavto;
  globals.tekAvto = sValue;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('tekAvto', sValue);
  prefs.setInt('tekAvtoId', idavto);
}

Future<Database> loadDataBase() async {
  // копирование, открытие базы
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, "baza.db");
  var exists = await databaseExists(path);
  if (!exists) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
    ByteData data = await rootBundle.load(url.join("assets", "baza.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  }
  return await openDatabase(path, readOnly: true);
}

Future<List<Normy>> poluchNorm(String otr) async {
  // получение норм расхода
  var db = await loadDataBase();
  final List<Map<String, dynamic>> maps =
      await db.rawQuery('SELECT * FROM normy WHERE otryad=?', [otr]);
  return List.generate(maps.length, (index) => Normy.fromJson(maps[index]));
}

List<String> spisokPA() {
  // получение списка автомобилей
  List<String> sss = [];
  for (var i = 0; i < globals.normy.length; i++) {
    sss.add(
        '${globals.normy[i].marka} ${globals.normy[i].model} г/н ${globals.normy[i].nomer}');
  }
  return sss;
}

bool checkData(String strk) {
  //проверка введенного времени
  if (strk.length >= 5) {
    if (int.parse(strk.substring(0, 2)) <= 23) {
      if (int.parse(strk.substring(3, 5)) <= 59) {
        return true;
      }
    }
  }
  return false;
}

rashetRasxoda(String tdata, String vrVyez, String vrVozr, String proez,
    BuildContext cont) {
  //расчет расхода
  int obVrema = 0; //время проезда
  int nAvto;
  double rbe = 0; //норма расхода при езде
  double rbn = 0; //норма расхода при работе насоса
  double rbx = 0; //норма расхода при холостом ходе
  double rasxod = 0; //вычисляемый расход топлива
  int ezVrema = 0; //время на проезд
  int rabVrema = 0; //общее время работы без учета времени на проезд
  int bNasosVrema = 0; //время работы насоса
  int sNasosVrema = 0; //время работы без насоса
  int xolVrema = 0; //время холостого хода
  int proezd = int.parse(proez);

  DateTime vremaVyezd = DateFormat('dd.MM.yyyy HH:mm')
      .parse('$tdata.${DateFormat('yyyy').format(DateTime.now())} $vrVyez');
  DateTime vremaVozvr = DateFormat('dd.MM.yyyy HH:mm')
      .parse('$tdata.${DateFormat('yyyy').format(DateTime.now())} $vrVozr');
  if (vremaVyezd.compareTo(vremaVozvr) > 0) {
    vremaVozvr = vremaVozvr.add(const Duration(days: 1));
  }

  nAvto =
      globals.normy.indexWhere((element) => element.id == globals.idtekAvto);

  DateTime nachLeto = DateFormat('dd.MM').parse('16.05'); //начало лета 16.05
  DateTime koncLeto = DateFormat('dd.MM').parse('14.10');
  DateTime nachOktb = DateFormat('dd.MM').parse('15.10');
  DateTime koncOktb = DateFormat('dd.MM').parse('31.10');
  DateTime nachAprl = DateFormat('dd.MM').parse('01.04');
  DateTime koncAprl = DateFormat('dd.MM').parse('30.04');
  DateTime nachNoyb = DateFormat('dd.MM').parse('01.11');
  DateTime koncNoyb = DateFormat('dd.MM').parse('30.11');
  DateTime nachMart = DateFormat('dd.MM').parse('01.03');
  DateTime koncMart = DateFormat('dd.MM').parse('31.03');
  DateTime nachZima = DateFormat('dd.MM').parse('01.12');
  DateTime koncZima = DateFormat('dd.MM').parse('31.12');
  DateTime nachZima2 = DateFormat('dd.MM').parse('01.01');
  DateTime koncZima2 = DateFormat('dd.MM').parse('29.02');
  DateTime nachMaay = DateFormat('dd.MM').parse('01.05');
  DateTime koncMaay = DateFormat('dd.MM').parse('31.05');

  DateTime tekdata = DateFormat('dd.MM').parse(tdata);
  if (tekdata.compareTo(nachLeto) >= 0 && tekdata.compareTo(koncLeto) <= 0) {
    rbe = globals.normy[nAvto].rbel;
    rbn = globals.normy[nAvto].rbnl;
    rbx = globals.normy[nAvto].rbxl;
  }
  if (tekdata.compareTo(nachZima) >= 0 && tekdata.compareTo(koncZima) <= 0) {
    rbe = globals.normy[nAvto].rbez;
    rbn = globals.normy[nAvto].rbnz;
    rbx = globals.normy[nAvto].rbxz;
  }
  if (tekdata.compareTo(nachZima2) >= 0 && tekdata.compareTo(koncZima2) <= 0) {
    rbe = globals.normy[nAvto].rbez;
    rbn = globals.normy[nAvto].rbnz;
    rbx = globals.normy[nAvto].rbxz;
  }
  if (tekdata.compareTo(nachOktb) >= 0 && tekdata.compareTo(koncOktb) <= 0) {
    rbe = globals.normy[nAvto].rbes;
    rbn = globals.normy[nAvto].rbns;
    rbx = globals.normy[nAvto].rbxs;
  }
  if (tekdata.compareTo(nachAprl) >= 0 && tekdata.compareTo(koncAprl) <= 0) {
    rbe = globals.normy[nAvto].rbes;
    rbn = globals.normy[nAvto].rbns;
    rbx = globals.normy[nAvto].rbxs;
  }
  if (tekdata.compareTo(nachNoyb) >= 0 && tekdata.compareTo(koncNoyb) <= 0) {
    rbe = globals.normy[nAvto].rbej;
    rbn = globals.normy[nAvto].rbnj;
    rbx = globals.normy[nAvto].rbxj;
  }
  if (tekdata.compareTo(nachMart) >= 0 && tekdata.compareTo(koncMart) <= 0) {
    rbe = globals.normy[nAvto].rbej;
    rbn = globals.normy[nAvto].rbnj;
    rbx = globals.normy[nAvto].rbxj;
  }
  if (tekdata.compareTo(nachMaay) >= 0 && tekdata.compareTo(koncMaay) <= 0) {
    rbe = globals.normy[nAvto].rbem;
    rbn = globals.normy[nAvto].rbnm;
    rbx = globals.normy[nAvto].rbxm;
  }
  obVrema = vremaVozvr.difference(vremaVyezd).inMinutes;
  rbe = rbe / 100;
  switch (globals.vidRaboty) {
    case 0:
      {
        if (proezd < 10) {
          ezVrema = proezd * 2;
        } else {
          ezVrema = 20 + (proezd - 10);
        }
        rabVrema = obVrema - ezVrema;
        bNasosVrema = (rabVrema / 10).round();
        sNasosVrema = rabVrema - bNasosVrema;
        if (sNasosVrema < 0 || bNasosVrema < 0) {
          preduprej(cont);
        } else {
          rasxod = proezd * rbe + bNasosVrema * rbx + sNasosVrema * rbn;
        }
        globals.rasXod = double.parse((rasxod).toStringAsFixed(2));
        globals.sNasosVrema = sNasosVrema;
        globals.bNasosVrema = bNasosVrema;
        globals.procheVrema = 0;
      }
      break;
    case 1:
      {
        if (proezd < 10) {
          ezVrema = proezd * 2;
        } else {
          ezVrema = 20 + (proezd - 10);
        }
        bNasosVrema = obVrema - ezVrema;
        if (bNasosVrema < 0) {
          preduprej(cont);
        } else {
          rasxod = proezd * rbe + bNasosVrema * rbx;
        }
        globals.rasXod = double.parse((rasxod).toStringAsFixed(2));
        globals.bNasosVrema = bNasosVrema;
        globals.sNasosVrema = 0;
        globals.procheVrema = 0;
      }
      break;
    case 2:
      {
        if (proezd < 10) {
          ezVrema = proezd * 2;
        } else {
          ezVrema = 20 + (proezd - 10);
        }
        xolVrema = obVrema - ezVrema;
        if (xolVrema < 0) {
          preduprej(cont);
        } else {
          rasxod = proezd * rbe + xolVrema * rbx;
        }
        globals.rasXod = double.parse((rasxod).toStringAsFixed(2));
        globals.bNasosVrema = 0;
        globals.sNasosVrema = 0;
        globals.procheVrema = xolVrema;
      }
      break;
    case 3:
      {
        if (proezd < 10) {
          ezVrema = proezd * 2;
        } else {
          ezVrema = 20 + (proezd - 10);
        }
        if (tekdata.compareTo(nachLeto) >= 0 &&
            tekdata.compareTo(koncLeto) <= 0) {
          rasxod = proezd * rbe;
        } else {
          xolVrema = obVrema - ezVrema;
          if (xolVrema < 0) {
            preduprej(cont);
          } else {
            rasxod = proezd * rbe + xolVrema * rbx;
          }
        }
        globals.rasXod = double.parse((rasxod).toStringAsFixed(2));
        globals.bNasosVrema = 0;
        globals.sNasosVrema = 0;
        globals.procheVrema = xolVrema;
      }
      break;
  }
}

void preduprej(BuildContext ctx) {
  showModalBottomSheet(
      elevation: 10,
      backgroundColor: const Color(0xffBE6666),
      context: ctx,
      builder: (ctx) => Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              width: MediaQuery.of(ctx).size.width - 40,
              height: 80,
              alignment: Alignment.center,
              child: Text(
                  'Время выезда (или возвращения) указано неверно! Время работы не может быть отрицательным',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: const Color(0xff7C1414),
                      fontWeight: FontWeight.bold,
                      fontSize: 20 / globals.txScFact)),
            ),
          ));
}

oPrilojenii(context) {
  var alertStyle = AlertStyle(
    animationType: AnimationType.fromTop,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: const TextStyle(fontWeight: FontWeight.bold),
    animationDuration: const Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: const BorderSide(
        width: 1,
        color: Colors.black,
      ),
    ),
    titleStyle: const TextStyle(
      fontWeight: FontWeight.w800,
      color: Colors.white,
    ),
    backgroundColor: const Color(0xffBE6666),
    constraints:
        BoxConstraints.expand(width: MediaQuery.of(context).size.width - 20),
    //First to chars "55" represents transparency of color
    overlayColor: const Color(0x55000000),
    alertElevation: 10,
    alertAlignment: Alignment.centerRight,
  );
  Alert(
    context: context,
    style: alertStyle,
    title: "Расчет расхода топлива пожарных автомобилей",
    buttons: [
      DialogButton(
        width: 60,
        onPressed: () => Navigator.pop(context),
        color: const Color(0xff7C1414),
        radius: BorderRadius.circular(10.0),
        child: Text(
          "OK",
          style:
              TextStyle(color: Colors.white, fontSize: 20 / globals.txScFact),
        ),
      ),
    ],
    content: Column(children: <Widget>[
      Center(
          child: Text('Версия 1.1beta',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20 / globals.txScFact,
                color: Colors.white,
              ))),
      Text('', style: TextStyle(fontSize: 24 / globals.txScFact)),
      Center(
          child: Text('Разработка:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20 / globals.txScFact,
                color: Colors.white,
              ))),
      Center(child: Image.asset('assets/OdiozSoft.png', width: 90)),
      Text('', style: TextStyle(fontSize: 24 / globals.txScFact)),
      Center(
          child: Text(
              'Замечания, пожелания, сообщения об ошибках в работе приложения принимаются в группе WhatsApp:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20 / globals.txScFact,
                color: Colors.white,
              ))),
      Center(
          child: IconButton(
        icon: Image.asset('assets/whatsapp.png'),
        iconSize: 40,
        color: Colors.black,
        onPressed: () async => await openUrl(
            "https://chat.whatsapp.com/EOIo6hRUige5gMfssxL2z0"), //группа Вацап
      )),
    ]),
  ).show();
}

Future<bool> openUrl(String url, {bool newWindow = true}) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    return await launchUrl(
      Uri.parse(
        url,
      ),
      mode: LaunchMode.externalApplication,
    );
  } else {
    debugPrint("Could not launch $url");
    return false;
  }
}
