//import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
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
  String? selectedRabota;
  String tekData = '';

  TextEditingController inputData2 = TextEditingController();
  TextEditingController inputData3 = TextEditingController();
  TextEditingController inputData4 = TextEditingController();

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      nOtryad = globals.nOtryad;
      globals.normy = await poluchNorm(nOtryad);
      tekData = DateFormat('dd.MM').format(DateTime.now());
      inputData2.text = '00:00';
      inputData3.text = '00:00';
      inputData4.text = '0';
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
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FocusNode dataFocus1 = FocusNode();
    FocusNode dataFocus2 = FocusNode();
    FocusNode dataFocus3 = FocusNode();
    //String choice = '';
    var maskCifr = MaskTextInputFormatter(
        mask: '##:##',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading:
            Image.asset('assets/icon.png', fit: BoxFit.contain, height: 42),
        actions: <Widget>[
          // меню:
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white,),
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
                    style: TextStyle(
                      fontSize: 20 / globals.txScFact,
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
              SizedBox(
                width: MediaQuery.of(context).size.width - 80,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white)),
                  child: Text(globals.nazvOtr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color.fromRGBO(255, 255, 255, 1),
                        fontSize: 18 / globals.txScFact,
                      )),
                ),
              ),
              const Spacer(flex: 1),
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      'Укажите автомобиль',
                      style: TextStyle(
                        fontSize: 20 / globals.txScFact,
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
                                  fontSize: 20 / globals.txScFact,
                                  color: Colors.white,
                                ),
                              ),
                            ))
                        .toList(),
                    value: selectedValue1,
                    onChanged: (String? value) {
                      setState(() {
                        selectedValue1 = value;
                        izmen1 = true;
                        int nomerAvto =
                            globals.spisokPA.indexOf(selectedValue1!);
                        zapisAvto(selectedValue1!, nomerAvto);
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      // height: 50,
                      width: 160,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.black,
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xff5D2323),
                      ),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all(6),
                        thumbVisibility: MaterialStateProperty.all(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 80,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              Text('Ввод данных работы ПА:',
                  style: TextStyle(
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.bold,
                     // letterSpacing: 3,
                      fontSize: 20 / globals.txScFact)),
              Container(
                width: MediaQuery.of(context).size.width - 40,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.white)),
                child: Column(
                  children: <Widget>[
                    Row(children: <Widget>[
                      Stack(
                          //дата работы
                          alignment: AlignmentDirectional.topCenter,
                          children: <Widget>[
                            Positioned(
                                top: -5,
                                child: Text('дата',
                                    style: TextStyle(
                                        fontSize: 16 / globals.txScFact,
                                        color: Colors.white))),
                            SizedBox(
                                width: 70,
                                height: 50,
                                child: TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        side: const BorderSide(
                                            width: 1, color: Colors.white),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              const Color(0x70BE6666))),
                                  onPressed: () async {
                                    DateTime? newData = await showDatePicker(
                                        context: context,
                                        locale: const Locale('ru'),
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2033));
                                    if (newData != null) {
                                      setState(() {
                                        tekData =
                                            DateFormat('dd.MM').format(newData);
                                      });
                                    }
                                  },
                                  child: Text(tekData,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 19 / globals.txScFact)),
                                )),
                          ]),
                      const Spacer(),
                      Stack(
                          //время выезда
                          alignment: AlignmentDirectional.topCenter,
                          children: <Widget>[
                            Positioned(
                                top: -5,
                                child: Text('выезд',
                                    style: TextStyle(
                                        fontSize: 16 / globals.txScFact,
                                        color: Colors.white))),
                            SizedBox(
                              width: 70,
                              height: 50,
                              child: TextField(
                                controller: inputData2,
                                inputFormatters: [maskCifr],
                                focusNode: dataFocus1,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                onTap: () {
                                  setState(() {
                                    inputData2.text = '';
                                  });
                                },
                                //onEditingComplete: () => FocusScope.of(context).nextFocus(),
                                onSubmitted: (value) {
                                  if (!checkData(value) | value.isEmpty) {
                                    dataFocus1.requestFocus();
                                  } else {
                                    izmen3 = true;
                                    inputData3.text = '';
                                    FocusScope.of(context)
                                        .requestFocus(dataFocus2);
                                  }
                                },
                                cursorColor: Colors.white,
                                style: TextStyle(
                                    fontSize: 19 / globals.txScFact,
                                    color: Colors.white),
                                decoration: const InputDecoration(
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
                      const Spacer(),
                      Stack(
                          //время возвращения
                          alignment: AlignmentDirectional.topCenter,
                          children: <Widget>[
                            Positioned(
                                top: -5,
                                child: Text('возвр',
                                    style: TextStyle(
                                        fontSize: 16 / globals.txScFact,
                                        color: Colors.white))),
                            SizedBox(
                              width: 70,
                              height: 50,
                              child: TextField(
                                controller: inputData3,
                                inputFormatters: [maskCifr],
                                focusNode: dataFocus2,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                onTap: () {
                                  setState(() {
                                    inputData3.text = '';
                                  });
                                },
                                onSubmitted: (value) {
                                  if (!checkData(value) | value.isEmpty) {
                                    dataFocus2.requestFocus();
                                  } else {
                                    izmen4 = true;
                                    inputData4.text = '';
                                    FocusScope.of(context)
                                        .requestFocus(dataFocus3);
                                  }
                                },
                                cursorColor: Colors.white,
                                style: TextStyle(
                                    fontSize: 19 / globals.txScFact,
                                    color: Colors.white),
                                decoration: const InputDecoration(
                                    fillColor: Color(0x70BE6666),
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.white)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.white))),
                              ),
                            ),
                          ]),
                      const Spacer(),
                      Stack(
                          //проезд
                          alignment: AlignmentDirectional.topCenter,
                          children: <Widget>[
                            Positioned(
                                top: -5,
                                child: Text('проезд',
                                    style: TextStyle(
                                        fontSize: 16 / globals.txScFact,
                                        color: Colors.white))),
                            SizedBox(
                              width: 70,
                              height: 50,
                              child: TextField(
                                controller: inputData4,
                                focusNode: dataFocus3,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                onTap: () {
                                  setState(() {
                                    inputData4.text = '';
                                  });
                                },
                                cursorColor: Colors.white,
                                style: TextStyle(
                                    fontSize: 19 / globals.txScFact,
                                    color: Colors.white),
                                decoration: const InputDecoration(
                                    fillColor: Color(0x70BE6666),
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.white)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.white))),
                              ),
                            ),
                          ]),
                    ]),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Укажите вид работы',
                            style: TextStyle(
                              fontSize: 20 / globals.txScFact,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          items: vidyRabot
                              .map((String item2) => DropdownMenuItem<String>(
                                    value: item2,
                                    child: Text(
                                      item2,
                                      style: TextStyle(
                                        fontSize: 20 / globals.txScFact,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: selectedRabota,
                          onChanged: (String? value) {
                            setState(() {
                              selectedRabota = value;
                              izmen2 = true;
                              globals.vidRaboty =
                                  vidyRabot.indexOf(selectedRabota!);
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            // height: 50,
                            //width: 100,
                            padding: const EdgeInsets.only(left: 14, right: 14),
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
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: const Color(0xff5D2323),
                            ),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: MaterialStateProperty.all(6),
                              thumbVisibility: MaterialStateProperty.all(true),
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
              const Spacer(flex: 1),
              SizedBox(
                width: MediaQuery.of(context).size.width - 80,
                child: TextButton(
                  style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(20),
                      shadowColor: MaterialStateProperty.all(Colors.black),
                      overlayColor:
                          MaterialStateProperty.all(const Color(0xffBE4646)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(width: 1, color: Colors.white),
                      )),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xff7C1414))),
                  child: Text('РАССЧИТАТЬ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24 / globals.txScFact,
                        letterSpacing: 6,
                        fontWeight: FontWeight.bold,
                      )),
                  onPressed: () {
                    if (izmen1! & izmen2! & izmen3! & izmen4!) {
                      rashetRasxoda(tekData, inputData2.text, inputData3.text,
                          inputData4.text, context);
                      setState(() {});
                    } else {
                      pred(context);
                    }
                  },
                ),
              ),
              const Spacer(flex: 1),
              Text('Результаты работы ПА:',
                  style: TextStyle(
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.bold,
                      //letterSpacing: 3,
                      fontSize: 20 / globals.txScFact)),
              Container(
                  width: MediaQuery.of(context).size.width - 40,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.white)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('  Работа с насосом:',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    fontSize: 20 / globals.txScFact)),
                            Text(' ${globals.sNasosVrema} мин.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    //letterSpacing: 1,
                                    fontSize: 20 / globals.txScFact)),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('Работа без насоса:',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    fontSize: 20 / globals.txScFact)),
                            Text(' ${globals.bNasosVrema} мин.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    //letterSpacing: 1,
                                    fontSize: 20 / globals.txScFact)),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('       Прочие работы:',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    fontSize: 20 / globals.txScFact)),
                            Text(' ${globals.procheVrema} мин.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    //letterSpacing: 1,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    fontSize: 20 / globals.txScFact))
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('      Расход топлива:',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    fontSize: 20 / globals.txScFact)),
                            Text(' ${globals.rasXod} л.',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    //letterSpacing: 1,
                                    fontSize: 20 / globals.txScFact)),
                          ],
                        ),
                      ],
                    ),
                  )),
              const Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}

void pred(BuildContext ctx) {
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
              child: Text('Недостаточно данных для расчета!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: const Color(0xff7C1414),
                      fontWeight: FontWeight.bold,
                      fontSize: 20 / globals.txScFact)),
            ),
          ));
}
