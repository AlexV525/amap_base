part of x_amap_base;

/// 定位信息类
///
/// 可提供内容包括：
///
/// [provider]定位信息提供者，注意，如果是iOS平台只会返回‘iOS’
/// [latLng]经纬度信息
/// [accuracy] 水平精确度
/// [altitude] 海拔
/// [bearing] 角度
/// [speed] 速度
/// [time] 定位时间
class AMapLocation {
  const AMapLocation({
    this.provider = '',
    required this.latLng,
    this.accuracy = 0,
    this.altitude = 0,
    this.bearing = 0,
    this.speed = 0,
    this.time = 0,
  });

  /// 定位提供者
  ///
  /// Android平台根据系统信息透出
  /// iOS平台只会返回'iOS'
  final String provider;

  /// 经纬度
  final LatLng latLng;

  /// 水平精确度
  final double accuracy;

  /// 海拔
  final double altitude;

  /// 角度
  final double bearing;

  /// 速度
  final double speed;

  /// 定位时间
  final num time;

  static AMapLocation? fromMap(dynamic json) {
    if (null == json) {
      return null;
    }

    return AMapLocation(
      provider: json['provider'],
      latLng: LatLng.fromJson(json['latLng'])!,
      accuracy: (json['accuracy']).toDouble(),
      altitude: (json['altitude']).toDouble(),
      bearing: (json['bearing']).toDouble(),
      speed: (json['speed']).toDouble(),
      time: json['time'],
    );
  }

  /// Converts this object to something serializable in JSON.
  Map<String, Object> toJson() {
    final json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    json['latlng'] = latLng.toJson();
    addIfPresent('provider', provider);
    addIfPresent('accuracy', accuracy);
    addIfPresent('altitude', altitude);
    addIfPresent('bearing', bearing);
    addIfPresent('speed', speed);
    addIfPresent('time', time);
    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! AMapLocation) {
      return false;
    }
    return provider == other.provider &&
        latLng == other.latLng &&
        accuracy == other.accuracy &&
        altitude == other.altitude &&
        bearing == other.bearing &&
        speed == other.speed &&
        time == other.time;
  }

  @override
  int get hashCode => Object.hashAll([
        provider,
        latLng,
        accuracy,
        altitude,
        bearing,
        speed,
        time,
      ]);
}

/// 经纬度坐标对象，单位为度。
@immutable
class LatLng {
  /// 根据纬度 [latitude] 和经度 [longitude] 创建经纬度对象。
  ///
  /// [latitude] 取值范围 [-90.0, 90.0]
  /// [longitude] 取值范围 [-180.0, 180.0]
  const LatLng(
    double latitude,
    double longitude,
  )   : latitude = latitude < -90.0
            ? -90.0
            : 90.0 < latitude
                ? 90.0
                : latitude,
        longitude = (longitude + 180.0) % 360.0 - 180.0;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 根据传入的经纬度数组 \[lat, lng\] 序列化一个LatLng对象.
  static LatLng? fromJson(List? json) {
    if (json == null) {
      return null;
    }
    return LatLng(json[0], json[1]);
  }

  List<double> toJson() {
    return <double>[latitude, longitude];
  }

  @override
  String toString() => 'LatLng(${toJson()})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! LatLng) {
      return false;
    }
    return other.latitude == latitude && other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hashAll([latitude, longitude]);
}

/// 代表了经纬度划分的一个矩形区域。
@immutable
class LatLngBounds {
  /// 使用传入的西南角坐标 [southwest] 和东北角坐标 [northeast] 创建一个矩形区域。
  LatLngBounds({
    required this.southwest,
    required this.northeast,
  }) : assert(
          southwest.latitude <= northeast.latitude,
          '西南角纬度超过了东北角纬度'
          '(${southwest.latitude} > ${northeast.latitude})',
        );

  /// 西南角坐标.
  final LatLng southwest;

  /// 东北角坐标.
  final LatLng northeast;

  static LatLngBounds? fromList(List? json) {
    if (json == null) {
      return null;
    }
    return LatLngBounds(
      southwest: LatLng.fromJson(json[0])!,
      northeast: LatLng.fromJson(json[1])!,
    );
  }

  /// 判断矩形区域是否包含传入的经纬度[point].
  bool contains(LatLng point) {
    return _containsLatitude(point.latitude) &&
        _containsLongitude(point.longitude);
  }

  bool _containsLatitude(double lat) {
    return (southwest.latitude <= lat) && (lat <= northeast.latitude);
  }

  bool _containsLongitude(double lng) {
    if (southwest.longitude <= northeast.longitude) {
      return southwest.longitude <= lng && lng <= northeast.longitude;
    } else {
      return southwest.longitude <= lng || lng <= northeast.longitude;
    }
  }

  List<List<double>> toJson() {
    return [southwest.toJson(), northeast.toJson()];
  }

  @override
  String toString() {
    return 'LatLngBounds(${toJson()})';
  }

  @override
  bool operator ==(Object other) {
    return other is LatLngBounds &&
        other.southwest == southwest &&
        other.northeast == northeast;
  }

  @override
  int get hashCode => Object.hashAll([southwest, northeast]);
}

/// 可视区域：地图 View 四个顶点对应的经纬度所围成的多边形被称作 可视区域；
/// 此多边形是不规则四边形，如果地图没有倾斜时，可视区域为矩形，
/// 如果地图有倾斜时，可视区域为梯形。
@immutable
class VisibleRegion {
  const VisibleRegion({
    required this.latLngBounds,
    required this.farLeft,
    required this.farRight,
    required this.nearLeft,
    required this.nearRight,
  });

  /// 由可视区域的四个顶点形成的经纬度范围
  final LatLngBounds latLngBounds;

  /// 可视区域的左上角
  final LatLng farLeft;

  /// 可视区域的右上角
  final LatLng farRight;

  /// 可视区域的左下角
  final LatLng nearLeft;

  /// 可视区域的右下角
  final LatLng nearRight;

  /// 根据传入的内容序列化一个 VisibleRegion 对象。
  static VisibleRegion? fromJson(Map? json) {
    if (json == null) {
      return null;
    }
    return VisibleRegion(
      latLngBounds: LatLngBounds.fromList(json['latLngBounds'])!,
      farLeft: LatLng.fromJson(json['farLeft'])!,
      farRight: LatLng.fromJson(json['farRight'])!,
      nearLeft: LatLng.fromJson(json['nearLeft'])!,
      nearRight: LatLng.fromJson(json['nearRight'])!,
    );
  }

  Map<String, Object> toJson() {
    return {
      'latLngBounds': latLngBounds.toJson(),
      'farLeft': farLeft.toJson(),
      'farRight': farRight.toJson(),
      'nearLeft': nearLeft.toJson(),
      'nearRight': nearRight.toJson(),
    };
  }

  @override
  String toString() {
    return 'VisibleRegion(${toJson()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! VisibleRegion) {
      return false;
    }
    return latLngBounds == other.latLngBounds &&
        farLeft == other.farLeft &&
        farRight == other.farRight &&
        nearLeft == other.nearLeft &&
        nearRight == other.nearRight;
  }

  @override
  int get hashCode => Object.hashAll([
        latLngBounds,
        farLeft,
        farRight,
        nearLeft,
        nearRight,
      ]);
}
