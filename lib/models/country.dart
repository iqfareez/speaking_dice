class Country {
  late int id;
  late String alpha2;
  late String alpha3;
  late String name;

  Country({
    required this.id,
    required this.alpha2,
    required this.alpha3,
    required this.name,
  });

  Country.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    alpha2 = json["alpha2"];
    alpha3 = json["alpha3"];
    name = json["name"];
  }

  static List<Country> fromList(List<dynamic> list) {
    return list.map((map) => Country.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["alpha2"] = alpha2;
    data["alpha3"] = alpha3;
    data["name"] = name;
    return data;
  }
}
