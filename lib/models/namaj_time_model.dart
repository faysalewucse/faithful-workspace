class NamajTimeModel {
  String asr;
  String isha;
  String fajr;
  String dhuhr;
  String maghrib;

  NamajTimeModel({
    required this.asr,
    required this.isha,
    required this.fajr,
    required this.dhuhr,
    required this.maghrib,
  });

  factory NamajTimeModel.fromJson(Map<String, dynamic> json) {
    return NamajTimeModel(
      asr: json['asr'] ?? '',
      isha: json['isha'] ?? '',
      fajr: json['fajr'] ?? '',
      dhuhr: json['dhuhr'] ?? '',
      maghrib: json['maghrib'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "asr": asr,
      "fajr": fajr,
      "isha": isha,
      "dhuhr": dhuhr,
      "maghrib": maghrib,
    };
  }
}
