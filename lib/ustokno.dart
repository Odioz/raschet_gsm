// экран начального выбора Отряда
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'libs.dart';
import 'globals.dart' as globals;

class UstanOkno extends StatefulWidget {
  const UstanOkno({super.key});

  @override
  State<UstanOkno> createState() => _UstanOknoState();
}

class _UstanOknoState extends State<UstanOkno> {
  String? selectedValue2;
  bool izmen = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      izmen = false;
      globals.podrazdelen = await getPodrazd();
      globals.tekAvto = '';
      globals.idtekAvto = 0;
      setState(() {
        spisokOtryadov();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/fon.png"),
            fit: BoxFit.cover,
          )),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Spacer(flex: 3),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: DefaultTextStyle(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Evolventa',
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 22.0 / globals.txScFact,
                      fontWeight: FontWeight.bold,
                      backgroundColor: const Color(0xffBE6666),
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        // TyperAnimatedText('Привет!',
                        //     speed: const Duration(milliseconds: 160),
                        //     textAlign: TextAlign.center),
                        // TyperAnimatedText('          ',
                        //     speed: const Duration(milliseconds: 160),
                        //     textAlign: TextAlign.center),
                        // TyperAnimatedText('Это приложение ',
                        //     speed: const Duration(milliseconds: 160),
                        //     textAlign: TextAlign.center),
                        // TyperAnimatedText('поможет рассчитать',
                        //     speed: const Duration(milliseconds: 160),
                        //     textAlign: TextAlign.center),
                        // TyperAnimatedText(' расход топлива',
                        //     speed: const Duration(milliseconds: 160),
                        //     textAlign: TextAlign.center),
                        // TyperAnimatedText('          ',
                        //     speed: const Duration(milliseconds: 160),
                        //     textAlign: TextAlign.center),
                        TyperAnimatedText('Укажите Ваше подразделение',
                            speed: const Duration(milliseconds: 160),
                            textAlign: TextAlign.center),
                      ],
                      totalRepeatCount: 1,
                      pause: const Duration(milliseconds: 300),
                      displayFullTextOnTap: false,
                      stopPauseOnTap: true,
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Отряд (ПЧ) ГБУ РС(Я) "ГПС РС(Я)"',
                        style: TextStyle(
                          fontSize: 18 / globals.txScFact,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      items: globals.spisokOtr
                          .map((String item) => DropdownMenuItem<String>(
                                value: item,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 20 / globals.txScFact,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                      value: selectedValue2,
                      onChanged: (String? value) {
                        //log(value);
                        setState(() {
                          selectedValue2 = value;
                          izmen = true;
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
                        openInterval: const Interval(0.15, 0.95),
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
                        //padding: EdgeInsets.fromLTRB(4, 10, 4, 10),
                        height: 100,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 120,
                  child: TextButton(
                      style: ButtonStyle(
                          elevation: WidgetStateProperty.all(2),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(14.0))),
                          backgroundColor: WidgetStateProperty.all<Color>(
                              const Color.fromRGBO(124, 20, 21, 1))),
                      child: Text('Подтвердить',
                          style: TextStyle(
                            color: izmen
                                ? const Color.fromRGBO(255, 255, 255, 1)
                                : Colors.grey,
                            fontSize: 30 / globals.txScFact,
                            fontWeight: FontWeight.w300,
                          )),
                      onPressed: () {
                        izmen
                            ? Future.delayed(Duration.zero, () async {
                                await ustanPrefern(selectedValue2);
                                Future.delayed(
                                    const Duration(milliseconds: 1000), () {
                                  if (context.mounted) {
                                    raschetOkno(
                                        context); //вызов экрана Расчетов
                                  }
                                });
                              })
                            : null;
                      }),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
