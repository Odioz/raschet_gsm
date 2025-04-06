class Podraz {
  //класс подразделения
  final int? id;
  final String region;
  final String terr;
  final String otrd;
  final String podrz;
  final String nazv;
  final String krit;

  const Podraz(
      {this.id,
      required this.region,
      required this.terr,
      required this.otrd,
      required this.podrz,
      required this.nazv,
      required this.krit});

  factory Podraz.fromJson(Map<String, dynamic> json) => Podraz(
      id: json['id'],
      region: json['region'],
      terr: json['territory'],
      otrd: json['otryad'],
      podrz: json['podrazd'],
      nazv: json['nazv'],
      krit: json['krit']);
}

class Normy {
  //класс "нормы расхода"
  final int? id;
  final String otrd;
  final String model;
  final String marka;
  final String nomer;
  final String godvyp;
  final double rbel;
  final double rbnl;
  final double rbxl;
  final double rbes;
  final double rbns;
  final double rbxs;
  final double rbej;
  final double rbnj;
  final double rbxj;
  final double rbez;
  final double rbnz;
  final double rbxz;
  final double rbem;
  final double rbnm;
  final double rbxm;
  final double konder;
  final double prostoy;
  final double sp;

  Normy(
      {this.id,
      required this.otrd,
      required this.model,
      required this.marka,
      required this.nomer,
      required this.godvyp,
      required this.rbel,
      required this.rbnl,
      required this.rbxl,
      required this.rbes,
      required this.rbns,
      required this.rbxs,
      required this.rbej,
      required this.rbnj,
      required this.rbxj,
      required this.rbez,
      required this.rbnz,
      required this.rbxz,
      required this.rbem,
      required this.rbnm,
      required this.rbxm,
      required this.konder,
      required this.prostoy,
      required this.sp});

  factory Normy.fromJson(Map<String, dynamic> json) => Normy(
      id: json['id'],
      otrd: json['otryad'],
      model: json['model'],
      marka: json['marka'],
      nomer: json['nomer'],
      godvyp: json['godvyp'],
      rbel: double.parse((json['rbel'].toString())
          .replaceFirst(',', '.')), //заменяем запятую в числе на точку
      rbnl: double.parse((json['rbnl'].toString()).replaceFirst(',', '.')),
      rbxl: double.parse((json['rbxl'].toString()).replaceFirst(',', '.')),
      rbes: double.parse((json['rbes'].toString()).replaceFirst(',', '.')),
      rbns: double.parse((json['rbns'].toString()).replaceFirst(',', '.')),
      rbxs: double.parse((json['rbxs'].toString()).replaceFirst(',', '.')),
      rbej: double.parse((json['rbej'].toString()).replaceFirst(',', '.')),
      rbnj: double.parse((json['rbnj'].toString()).replaceFirst(',', '.')),
      rbxj: double.parse((json['rbxj'].toString()).replaceFirst(',', '.')),
      rbez: double.parse((json['rbez'].toString()).replaceFirst(',', '.')),
      rbnz: double.parse((json['rbnz'].toString()).replaceFirst(',', '.')),
      rbxz: double.parse((json['rbxz'].toString()).replaceFirst(',', '.')),
      rbem: double.parse((json['rbem'].toString()).replaceFirst(',', '.')),
      rbnm: double.parse((json['rbnm'].toString()).replaceFirst(',', '.')),
      rbxm: double.parse((json['rbxm'].toString()).replaceFirst(',', '.')),
      konder: double.parse((json['konder'].toString()).replaceFirst(',', '.')),
      prostoy:
          double.parse((json['prostoy'].toString()).replaceFirst(',', '.')),
      sp: double.parse((json['sp'].toString()).replaceFirst(',', '.')));
}
