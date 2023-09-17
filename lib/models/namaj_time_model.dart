class NamajTimeModel {
  String asr;
  String isha;
  String fajr;
  String zuhor;
  String maghrib;

  NamajTimeModel({
    required this.asr,
    required this.isha,
    required this.fajr,
    required this.zuhor,
    required this.maghrib,
  });

  factory NamajTimeModel.fromJson(Map<String, dynamic> json) {
    return NamajTimeModel(
      asr: json['asr'] ?? '',
      isha: json['isha'] ?? '',
      fajr: json['fajr'] ?? '',
      zuhor: json['zuhor'] ?? '',
      maghrib: json['maghrib'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "asr": asr,
      "fajr": fajr,
      "isha": isha,
      "zuhor": zuhor,
      "maghrib": maghrib,
    };
  }


}
