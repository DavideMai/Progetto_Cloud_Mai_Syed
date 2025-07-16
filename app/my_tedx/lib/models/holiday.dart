class Holiday {
  final DateTime date;
  final String event;
  final String type;
  final String countryName;
  final String countryCode;

  Holiday({
    required this.date,
    required this.event,
    required this.type,
    required this.countryName,
    required this.countryCode,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      date: DateTime.parse(json['Date'] as String),
      event: json['Event'] as String,
      type: (json['Type'] as String).replaceAll(RegExp(r"[\[\]']"), ''), // Rimuove parentesi e apici
      countryName: json['Country Name'] as String,
      countryCode: json['Country Code'] as String,
    );
  }

  @override
  String toString() {
    return 'Holiday(date: $date, event: $event, type: $type, countryName: $countryName, countryCode: $countryCode)';
  }
}