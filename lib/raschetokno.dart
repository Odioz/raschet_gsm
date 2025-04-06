//import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'libs.dart';
import 'globals.dart' as globals;
import 'vidyrabot.dart';

class RaschetOkno extends StatefulWidget {
  const RaschetOkno({super.key});

  @override
  State<RaschetOkno> createState() => _RaschetOknoState();
}

class _RaschetOknoState extends State<RaschetOkno> {
  String nOtryad = '';
  String? selectedValue1;
  bool? izmen1;
  bool? izmen2;
  bool? izmen3;
  bool? izmen4;
  bool? izmen5;
  bool knpRas = false;
  String? selectedRabota;
  String tekData = '';
  double shhh = 0, shhh2 = 0, mejst = 0;
  double sizData = 0, sizeZag = 0, sizRas = 0;

  TextEditingController vrmVyezd = TextEditingController();
  TextEditingController vrmVozrv = TextEditingController();
  TextEditingController proezd = TextEditingController();
  FocusNode? vrmVyezdFocus;
  FocusNode? vrmVozvrFocus;
  FocusNode? proezdFocus;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      nOtryad = globals.nOtryad;
      globals.normy = await poluchNorm(nOtryad);
      tekData = DateFormat('dd.MM').format(DateTime.now());
      vrmVyezd.text = '00:00';
      vrmVozrv.text = '00:00';
      proezd.text = '0';

      setState(() {
        globals.spisokPA = spisokPA();

        if (globals.tekAvto.isNotEmpty) {
          selectedValue1 = globals.tekAvto;
          izmen1 = true;
        } else {
          izmen1 = false;
        }
        izmen2 = false;
        izmen3 = false;
        izmen4 = false;
        izmen5 = false;
        knpRas = false;
      });
    });
    vrmVyezdFocus = FocusNode();
    vrmVozvrFocus = FocusNode();
    proezdFocus = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    vrmVyezdFocus?.dispose();
    vrmVozvrFocus?.dispose();
    proezdFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var maskCifr = MaskTextInputFormatter(
        mask: '##:##',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy);
    double scrSz = (MediaQuery.of(context).size.width);
    if (scrSz >= 485) {
      shhh = ((scrSz - 90) / 4);
      shhh2 = (scrSz - 100);
      mejst = 8;
      sizeZag = 20;
      sizData = 23;
      sizRas = 24;
    }

    if (scrSz < 485 && scrSz > 411) {
      shhh = ((scrSz - 90) / 4);
      shhh2 = (scrSz - 90);
      mejst = 8;
      sizeZag = 19;
      sizData = 21;
      sizRas = 22;
    }
    if (scrSz < 411 && scrSz > 375) {
      shhh = ((scrSz - 90) / 4);
      shhh2 = (scrSz - 90);
      mejst = 6;
      sizeZag = 17;
      sizData = 18;
      sizRas = 20;
    }
    if (scrSz < 375 && scrSz > 320) {
      shhh = ((scrSz - 80) / 4);
      shhh2 = (scrSz - 90);
      mejst = 2;
      sizeZag = 14;
      sizData = 16;
      sizRas = 18;
    }
    if (scrSz <= 320) {
      shhh = ((scrSz - 80) / 4);
      shhh2 = (scrSz - 90);
      mejst = 2;
      sizeZag = 13;
      sizData = 13;
      sizRas = 15;
    }

    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(boldText: false, textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          // leading:
          //     Image.asset('assets/icon.png', fit: BoxFit.contain, height: 42),
          actions: <Widget>[
            // меню:
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              color: const Color.fromRGBO(124, 20, 21, 1),
              onSelected: (value) {
                vyborClick(value, context);
              },
              itemBuilder: (BuildContext context) {
                return {'Сменить отряд', 'О приложении'}.map((choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(
                      choice,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/fon.png"),
            fit: BoxFit.cover,
          )),
          child: Center(
            child: Column(
              children: <Widget>[
                const Spacer(flex: 1),
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  width: scrSz - 40,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Укажите автомобиль',
                        style: TextStyle(
                          fontSize: sizData,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      items: globals.spisokPA
                          .map((String item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: sizData,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ))
                          .toList(),
                      value: selectedValue1,
                      onChanged: (String? value) {
                        setState(() {
                          selectedValue1 = value;
                          izmen1 = true;
                          raschKnopka();
                          int nomerAvto =
                              globals.spisokPA.indexOf(selectedValue1!);
                          zapisAvto(selectedValue1!, nomerAvto);
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        width: 160,
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white,
                          ),
                          color: const Color.fromRGBO(124, 20, 21, 1),
                        ),
                        elevation: 2,
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.arrow_forward_ios_outlined,
                        ),
                        iconSize: 20,
                        iconEnabledColor: Colors.white,
                        iconDisabledColor: Colors.grey,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        openInterval: const Interval(0.35, 0.95),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xff5D2323),
                        ),
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(40),
                          thickness: WidgetStateProperty.all(6),
                          thumbVisibility: WidgetStateProperty.all(true),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 80,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                Stack(
                  children: <Widget>[
                    Container(
                      width: scrSz - 40,
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.white)),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 4),
                          Row(
                            // текст над полями ввода
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              SizedBox(
                                height: 40,
                                width: shhh,
                                child: Text(
                                  "Дата",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: sizeZag, color: Colors.white),
                                ),
                              ),
                              SizedBox(width: mejst),
                              SizedBox(
                                height: 40,
                                width: shhh,
                                child: Text(
                                  "Время\nвыезда ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: sizeZag,
                                      height: 1,
                                      color: Colors.white),
                                ),
                              ),
                              SizedBox(width: mejst),
                              SizedBox(
                                height: 40,
                                width: shhh,
                                child: Text(
                                  "Время\nвозврщ. ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: sizeZag,
                                      height: 1,
                                      color: Colors.white),
                                ),
                              ),
                              SizedBox(width: mejst),
                              SizedBox(
                                height: 40,
                                width: shhh,
                                child: Text(
                                  "Проезд",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: sizeZag, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          Row(
                              //Четыре поля ввода: дата, 2 время, проезд
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                SizedBox(
                                    height: 50,
                                    width: shhh,
                                    child: TextButton(
                                      //дата
                                      style: ButtonStyle(
                                          shape: WidgetStatePropertyAll(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            side: const BorderSide(
                                                width: 1, color: Colors.white),
                                          )),
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  const Color(0x70BE6666))),
                                      onPressed: () async {
                                        DateTime? newData =
                                            await showDatePicker(
                                                context: context,
                                                locale: const Locale('ru'),
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2033));
                                        if (newData != null) {
                                          setState(() {
                                            tekData = DateFormat('dd.MM')
                                                .format(newData);
                                          });
                                        }
                                      },
                                      child: Text(tekData,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: sizData)),
                                    )),
                                SizedBox(width: mejst),
                                SizedBox(
                                  //время выезда
                                  height: 50,
                                  width: shhh,
                                  child: TextField(
                                    controller: vrmVyezd,
                                    inputFormatters: [maskCifr],
                                    focusNode: vrmVyezdFocus,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    onTap: () {
                                      setState(() {
                                        knpRas = false;
                                        vrmVyezd.text = '';
                                        selectedRabota = null;
                                      });
                                    },
                                    //onEditingComplete: () => FocusScope.of(context).nextFocus(),
                                    onSubmitted: (value) {
                                      if (!checkData(value) | value.isEmpty) {
                                        raschKnopka();
                                        vrmVyezdFocus?.requestFocus();
                                      } else {
                                        izmen2 = true;
                                        vrmVozrv.text = '';
                                        FocusScope.of(context)
                                            .requestFocus(vrmVozvrFocus);
                                      }
                                    },
                                    cursorColor: Colors.white,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: sizData,
                                        color: Colors.white),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      fillColor: Color(0x70BE6666),
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.white)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.white)),
                                    ),
                                  ),
                                ),
                                SizedBox(width: mejst),
                                SizedBox(
                                  //время возвращения
                                  height: 50,
                                  width: shhh,
                                  child: TextField(
                                    controller: vrmVozrv,
                                    inputFormatters: [maskCifr],
                                    focusNode: vrmVozvrFocus,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    onTap: () {
                                      if (vrmVyezd.text != '') {
                                        setState(() {
                                          vrmVozrv.text = '';
                                          knpRas = false;
                                          selectedRabota = null;
                                        });
                                      }
                                    },
                                    //onEditingComplete: () => FocusScope.of(context).nextFocus(),
                                    onSubmitted: (value) {
                                      if (!checkData(value) | value.isEmpty) {
                                        raschKnopka();
                                        vrmVozvrFocus?.requestFocus();
                                      } else {
                                        izmen3 = true;
                                        proezd.text = '';
                                        FocusScope.of(context)
                                            .requestFocus(proezdFocus);
                                      }
                                    },
                                    cursorColor: Colors.white,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: sizData,
                                        color: Colors.white),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      fillColor: Color(0x70BE6666),
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.white)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.white)),
                                    ),
                                  ),
                                ),
                                SizedBox(width: mejst),
                                SizedBox(
                                  //проезд
                                  height: 50,
                                  width: shhh,
                                  child: TextField(
                                    controller: proezd,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    focusNode: proezdFocus,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    onTap: () {
                                      setState(() {
                                        proezd.text = '';
                                        knpRas = false;
                                        selectedRabota = null;
                                      });
                                    },
                                    onSubmitted: (value) {
                                      if (value.isEmpty) {
                                        proezdFocus?.requestFocus();
                                      } else {
                                        izmen4 = true;
                                        raschKnopka();
                                        proezdFocus?.unfocus();
                                        SystemChannels.textInput
                                            .invokeMethod('TextInput.hide');
                                      }
                                    },
                                    cursorColor: Colors.white,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: sizData,
                                        color: Colors.white),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      fillColor: Color(0x70BE6666),
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.white)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ]),
                          const SizedBox(height: 10),
                          SizedBox(
                            //выбор вида работ
                            width: double.infinity,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Укажите вид работы',
                                  style: TextStyle(
                                    fontSize: sizData,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                items: vidyRabot
                                    .map((String item2) =>
                                        DropdownMenuItem<String>(
                                          value: item2,
                                          child: Text(
                                            item2,
                                            style: TextStyle(
                                              fontSize: sizData,
                                              color: Colors.white,
                                              height: 1,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: selectedRabota,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedRabota = value;
                                    izmen5 = true;
                                    raschKnopka();
                                    globals.vidRaboty =
                                        vidyRabot.indexOf(selectedRabota!);
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  // height: 50,
                                  //width: 100,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    color: const Color(0xffBE6666),
                                  ),
                                  elevation: 2,
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_forward_ios_outlined,
                                  ),
                                  iconSize: 20,
                                  iconEnabledColor: Colors.white,
                                  iconDisabledColor: Colors.grey,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  openInterval: const Interval(0.35, 0.95),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color(0xff5D2323),
                                  ),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: WidgetStateProperty.all(6),
                                    thumbVisibility:
                                        WidgetStateProperty.all(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 50,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white),
                            color: const Color(0xffBE6666)),
                        child: Text('Ввод данных работы автомобиля',
                            style: TextStyle(
                                color: const Color.fromRGBO(255, 255, 255, 1),
                                fontWeight: FontWeight.bold,
                                // letterSpacing: 3,
                                fontSize: sizeZag)),
                      ),
                    )
                  ],
                ),
                const Spacer(flex: 1),
                SizedBox(
                  width: scrSz - 120,
                  child: TextButton(
                    style: ButtonStyle(
                        elevation: const WidgetStatePropertyAll(20),
                        shadowColor: WidgetStateProperty.all(Colors.black),
                        overlayColor:
                            WidgetStateProperty.all(const Color(0xffBE4646)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              width: 3,
                              color: knpRas
                                  ? Colors.white
                                  : const Color(0xffBE6666)),
                        )),
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color(0xff7C1414))),
                    child: Text('РАССЧИТАТЬ',
                        style: TextStyle(
                          color:
                              knpRas ? Colors.white : const Color(0xffBE6666),
                          fontSize: sizRas,
                          letterSpacing: 6,
                          fontWeight: FontWeight.bold,
                        )),
                    onPressed: () {
                      knpRas
                          ? Future.delayed(const Duration(milliseconds: 1000),
                              () {
                              vyzovrasch();
                            })
                          : null;
                    },
                  ),
                ),
                const Spacer(flex: 3),
                Stack(
                  children: <Widget>[
                    Container(
                        width: scrSz - 40,
                        margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white)),
                        child: Row(
                          //crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(
                                width: shhh2 * 7 / 10,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text('  Работа с насосом:',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: const Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              fontSize: sizData)),
                                      Text('Работа без насоса:',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: const Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              fontSize: sizData)),
                                      Text('       Прочие работы:',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: const Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              fontSize: sizData)),
                                      Text('      Расход топлива:',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                              color: const Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              fontSize: sizData)),
                                    ])),
                            SizedBox(
                                width: shhh2 *
                                    3 /
                                    10, //shhh2 - (shhh2 * 7 / 10)+30
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(' ${globals.sNasosVrema} мин.',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              fontSize: sizData)),
                                      Text(' ${globals.bNasosVrema} мин.',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              fontSize: sizData)),
                                      Text(' ${globals.procheVrema} мин.',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              fontSize: sizData)),
                                      Text(' ${globals.rasXod} л.',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              fontSize: sizData))
                                    ])),
                          ],
                        )),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white),
                            color: const Color(0xffBE6666)),
                        child: Text('Результаты работы автомобиля',
                            style: TextStyle(
                                color: const Color.fromRGBO(255, 255, 255, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: sizeZag)),
                      ),
                    )
                  ],
                ),
                const Spacer(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void raschKnopka() {
    if (proezd.text.isNotEmpty) {
      izmen4 = true;
    }
    if (vrmVozrv.text.isNotEmpty) {
      izmen3 = true;
    }
    if (vrmVyezd.text.isNotEmpty) {
      izmen2 = true;
    }
    if (izmen1! & izmen2! & izmen3! & izmen4! & izmen5!) {
      knpRas = true;
    }
  }

  void vyzovrasch() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    rashetRasxoda(tekData, vrmVyezd.text, vrmVozrv.text, proezd.text,
        globals.vidRaboty, context);
    setState(() {});
  }
}

void pred(BuildContext ctx) {
  showModalBottomSheet(
      //elevation: 20,
      backgroundColor: const Color(0xffffffff),
      context: ctx,
      builder: (ctx) => Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              width: MediaQuery.of(ctx).size.width - 40,
              height: 80,
              alignment: Alignment.center,
              child: Text('Недостаточно данных для расчета!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: const Color(0xff7C1414),
                      fontWeight: FontWeight.bold,
                      fontSize: 20 / globals.txScFact)),
            ),
          ));
}
