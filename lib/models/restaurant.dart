class Restaurant {
  final String? nameR;
  final String? city;
  final String? schedule;
  final String? website;
  final String? phone;
  final String? typeR;
  final double? latitude;
  final double? longitude;
  final bool accessibl;
  final bool delivery;

  Restaurant({
    this.nameR,
    this.city,
    this.schedule,
    this.website,
    this.phone,
    this.typeR,
    this.latitude,
    this.longitude,
    required this.accessibl,
    required this.delivery,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      nameR: map['nameR'],
      city: map['city'],
      schedule: map['schedule'],
      website: map['website'],
      phone: map['phone'],
      typeR: map['typeR'],
      latitude: (map['latitude'] != null)
          ? double.tryParse(map['latitude'].toString())
          : null,
      longitude: (map['longitude'] != null)
          ? double.tryParse(map['longitude'].toString())
          : null,
      accessibl: map['accessibl'] == 1,
      delivery: map['delivery'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameR': nameR,
      'city': city,
      'schedule': schedule,
      'website': website,
      'phone': phone,
      'typeR': typeR,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'accessibl': accessibl ? 1 : 0,
      'delivery': delivery ? 1 : 0,
    };
  }
}
