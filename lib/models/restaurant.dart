import 'package:baratie/config/utils.dart';

class Restaurant {
  final int id;
  final String nameR;
  final String? city;
  final String? address;
  final String? website;
  final String? phone;
  final String? typeR;
  final double? latitude;
  final double? longitude;
  final bool accessibl;
  final bool delivery;
  final Map<String, List<String>>? schedule;

  static const List<String> days = [
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
    'Su',
    'PH'
  ];

  static const Map<String, String> dayLabels = {
    'Mo': 'Lundi',
    'Tu': 'Mardi',
    'We': 'Mercredi',
    'Th': 'Jeudi',
    'Fr': 'Vendredi',
    'Sa': 'Samedi',
    'Su': 'Dimanche',
    'PH': 'Jours fériés',
  };

  Restaurant({
    required this.id,
    required this.nameR,
    this.city,
    this.address,
    this.website,
    this.phone,
    this.typeR,
    this.latitude,
    this.longitude,
    required this.accessibl,
    required this.delivery,
    this.schedule,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['idRestau'] ?? map['id'] ?? 0,
      nameR: map['nameR'] ?? '',
      city: map['city'],
      address: map['address'],
      website: map['website'],
      phone: map['phone'],
      typeR: map['typeR'],
      latitude: (map['latitude'] != null)
          ? double.tryParse(map['latitude'].toString())
          : null,
      longitude: (map['longitude'] != null)
          ? double.tryParse(map['longitude'].toString())
          : null,
      accessibl: map['accessibl'] == 1 || map['accessibl'] == true,
      delivery: map['delivery'] == 1 || map['delivery'] == true,
      schedule: map['schedule'] != null ? _mapSchedule(map['schedule']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idRestau': id,
      'nameR': nameR,
      'city': city,
      'address': address,
      'website': website,
      'phone': phone,
      'typeR': typeR,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'accessibl': accessibl ? 1 : 0,
      'delivery': delivery ? 1 : 0,
      'schedule': schedule?.toString(),
    };
  }

  String getAddress() {
    return city ?? address ?? '';
  }

  Map<String, dynamic> getCurrentDayTime() {
    final now = DateTime.now();
    final day = days[now.weekday - 1];
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return {
      'day': day,
      'time': time,
    };
  }

  bool isCurrentlyOpen() {
    final current = getCurrentDayTime();
    final currentDay = current['day'] as String;
    final currentTime = current['time'] as String;

    if (schedule != null && schedule!.containsKey(currentDay)) {
      for (final timeRange in schedule![currentDay]!) {
        final times = timeRange.split('-');
        if (times.length == 2) {
          final openTime = times[0].trim();
          final closeTime = times[1].trim();

          final currentTimestamp = _timeToMinutes(currentTime);
          final openTimestamp = _timeToMinutes(openTime);
          final closeTimestamp = _timeToMinutes(closeTime);

          if (closeTimestamp < openTimestamp) {
            return currentTimestamp >= openTimestamp ||
                currentTimestamp <= closeTimestamp;
          } else {
            return currentTimestamp >= openTimestamp &&
                currentTimestamp <= closeTimestamp;
          }
        }
      }
    }
    return false;
  }

  String whenWillClose() {
    final current = getCurrentDayTime();
    final currentDay = current['day'] as String;
    final currentTime = current['time'] as String;

    if (schedule != null && schedule!.containsKey(currentDay)) {
      for (final timeRange in schedule![currentDay]!) {
        final times = timeRange.split('-');
        if (times.length == 2) {
          final openTime = times[0].trim();
          final closeTime = times[1].trim();

          if (_isTimeBetween(currentTime, openTime, closeTime)) {
            return closeTime;
          }
        }
      }
    }
    return 'N/A';
  }

  String whenWillOpen() {
    final current = getCurrentDayTime();
    final currentDay = current['day'] as String;
    final currentTime = current['time'] as String;

    if (schedule != null && schedule!.containsKey(currentDay)) {
      for (final timeRange in schedule![currentDay]!) {
        final times = timeRange.split('-');
        if (times.length == 2) {
          final openTime = times[0].trim();

          if (currentTime.compareTo(openTime) < 0) {
            return openTime;
          }
        }
      }
    }

    final currentIndex = days.indexOf(currentDay);
    final nextDay = days[(currentIndex + 1) % days.length];

    if (schedule != null &&
        schedule!.containsKey(nextDay) &&
        schedule![nextDay]!.isNotEmpty) {
      final firstTimeRange = schedule![nextDay]!.first;
      final times = firstTimeRange.split('-');
      if (times.isNotEmpty) {
        return times[0].trim();
      }
    }
    return 'N/A';
  }

  static Map<String, List<String>> _mapSchedule(String schedule) {
    final parts = schedule
        .split(';')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    final mappedSchedule = <String, List<String>>{};

    for (final part in parts) {
      final spaceIndex = part.indexOf(' ');
      if (spaceIndex == -1) continue;

      final daysPart = part.substring(0, spaceIndex).trim();
      final hoursPart = part.substring(spaceIndex + 1).trim();
      final timeRanges = hoursPart
          .split(',')
          .map((h) => h.trim())
          .where((h) => h.isNotEmpty)
          .toList();

      for (final day in daysPart.split(',')) {
        if (day.contains('-')) {
          final range = day.split('-');
          if (range.length == 2) {
            final startDay = range[0].trim();
            final endDay = range[1].trim();
            final daysInRange = _getDaysInRange(startDay, endDay);
            for (final singleDay in daysInRange) {
              mappedSchedule[singleDay] = timeRanges;
            }
          }
        } else {
          mappedSchedule[day.trim()] = timeRanges;
        }
      }
    }
    return mappedSchedule;
  }

  static List<String> _getDaysInRange(String startDay, String endDay) {
    final startIdx = days.indexOf(startDay);
    final endIdx = days.indexOf(endDay);
    if (startIdx == -1 || endIdx == -1) return [];

    if (startIdx <= endIdx) {
      return days.sublist(startIdx, endIdx + 1);
    } else {
      return [...days.sublist(startIdx), ...days.sublist(0, endIdx + 1)];
    }
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  bool _isTimeBetween(String time, String start, String end) {
    final timeMins = _timeToMinutes(time);
    final startMins = _timeToMinutes(start);
    final endMins = _timeToMinutes(end);

    if (endMins < startMins) {
      return timeMins >= startMins || timeMins <= endMins;
    } else {
      return timeMins >= startMins && timeMins <= endMins;
    }
  }

  Future<double> getNote() async {
    return 0.0;
  }

  Future<String> getStars() async {
    final note = await getNote();
    return getStarsString(note);
  }

  Future<int> getReviewCount() async {
    return 0;
  }
}
