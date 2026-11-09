// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FarmsTable extends Farms with TableInfo<$FarmsTable, FarmRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _villageMeta = const VerificationMeta(
    'village',
  );
  @override
  late final GeneratedColumn<String> village = GeneratedColumn<String>(
    'village',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altPhoneMeta = const VerificationMeta(
    'altPhone',
  );
  @override
  late final GeneratedColumn<String> altPhone = GeneratedColumn<String>(
    'alt_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileCompletedAtMeta =
      const VerificationMeta('profileCompletedAt');
  @override
  late final GeneratedColumn<DateTime> profileCompletedAt =
      GeneratedColumn<DateTime>(
        'profile_completed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationAccuracyMMeta = const VerificationMeta(
    'locationAccuracyM',
  );
  @override
  late final GeneratedColumn<double> locationAccuracyM =
      GeneratedColumn<double>(
        'location_accuracy_m',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _locationCapturedAtMeta =
      const VerificationMeta('locationCapturedAt');
  @override
  late final GeneratedColumn<DateTime> locationCapturedAt =
      GeneratedColumn<DateTime>(
        'location_captured_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    name,
    location,
    district,
    village,
    phone,
    altPhone,
    notes,
    profileCompletedAt,
    latitude,
    longitude,
    locationAccuracyM,
    locationCapturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farms';
  @override
  VerificationContext validateIntegrity(
    Insertable<FarmRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('village')) {
      context.handle(
        _villageMeta,
        village.isAcceptableOrUnknown(data['village']!, _villageMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('alt_phone')) {
      context.handle(
        _altPhoneMeta,
        altPhone.isAcceptableOrUnknown(data['alt_phone']!, _altPhoneMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('profile_completed_at')) {
      context.handle(
        _profileCompletedAtMeta,
        profileCompletedAt.isAcceptableOrUnknown(
          data['profile_completed_at']!,
          _profileCompletedAtMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('location_accuracy_m')) {
      context.handle(
        _locationAccuracyMMeta,
        locationAccuracyM.isAcceptableOrUnknown(
          data['location_accuracy_m']!,
          _locationAccuracyMMeta,
        ),
      );
    }
    if (data.containsKey('location_captured_at')) {
      context.handle(
        _locationCapturedAtMeta,
        locationCapturedAt.isAcceptableOrUnknown(
          data['location_captured_at']!,
          _locationCapturedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      ),
      village: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      altPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alt_phone'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      profileCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}profile_completed_at'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      locationAccuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_accuracy_m'],
      ),
      locationCapturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}location_captured_at'],
      ),
    );
  }

  @override
  $FarmsTable createAlias(String alias) {
    return $FarmsTable(attachedDatabase, alias);
  }
}

class FarmRow extends DataClass implements Insertable<FarmRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String name;
  final String? location;
  final String? district;
  final String? village;
  final String? phone;
  final String? altPhone;
  final String? notes;
  final DateTime? profileCompletedAt;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracyM;
  final DateTime? locationCapturedAt;
  const FarmRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.name,
    this.location,
    this.district,
    this.village,
    this.phone,
    this.altPhone,
    this.notes,
    this.profileCompletedAt,
    this.latitude,
    this.longitude,
    this.locationAccuracyM,
    this.locationCapturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || district != null) {
      map['district'] = Variable<String>(district);
    }
    if (!nullToAbsent || village != null) {
      map['village'] = Variable<String>(village);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || altPhone != null) {
      map['alt_phone'] = Variable<String>(altPhone);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || profileCompletedAt != null) {
      map['profile_completed_at'] = Variable<DateTime>(profileCompletedAt);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || locationAccuracyM != null) {
      map['location_accuracy_m'] = Variable<double>(locationAccuracyM);
    }
    if (!nullToAbsent || locationCapturedAt != null) {
      map['location_captured_at'] = Variable<DateTime>(locationCapturedAt);
    }
    return map;
  }

  FarmsCompanion toCompanion(bool nullToAbsent) {
    return FarmsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      name: Value(name),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      village: village == null && nullToAbsent
          ? const Value.absent()
          : Value(village),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      altPhone: altPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(altPhone),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      profileCompletedAt: profileCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(profileCompletedAt),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      locationAccuracyM: locationAccuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(locationAccuracyM),
      locationCapturedAt: locationCapturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(locationCapturedAt),
    );
  }

  factory FarmRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String?>(json['location']),
      district: serializer.fromJson<String?>(json['district']),
      village: serializer.fromJson<String?>(json['village']),
      phone: serializer.fromJson<String?>(json['phone']),
      altPhone: serializer.fromJson<String?>(json['altPhone']),
      notes: serializer.fromJson<String?>(json['notes']),
      profileCompletedAt: serializer.fromJson<DateTime?>(
        json['profileCompletedAt'],
      ),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      locationAccuracyM: serializer.fromJson<double?>(
        json['locationAccuracyM'],
      ),
      locationCapturedAt: serializer.fromJson<DateTime?>(
        json['locationCapturedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String?>(location),
      'district': serializer.toJson<String?>(district),
      'village': serializer.toJson<String?>(village),
      'phone': serializer.toJson<String?>(phone),
      'altPhone': serializer.toJson<String?>(altPhone),
      'notes': serializer.toJson<String?>(notes),
      'profileCompletedAt': serializer.toJson<DateTime?>(profileCompletedAt),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'locationAccuracyM': serializer.toJson<double?>(locationAccuracyM),
      'locationCapturedAt': serializer.toJson<DateTime?>(locationCapturedAt),
    };
  }

  FarmRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? name,
    Value<String?> location = const Value.absent(),
    Value<String?> district = const Value.absent(),
    Value<String?> village = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> altPhone = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> profileCompletedAt = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> locationAccuracyM = const Value.absent(),
    Value<DateTime?> locationCapturedAt = const Value.absent(),
  }) => FarmRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    name: name ?? this.name,
    location: location.present ? location.value : this.location,
    district: district.present ? district.value : this.district,
    village: village.present ? village.value : this.village,
    phone: phone.present ? phone.value : this.phone,
    altPhone: altPhone.present ? altPhone.value : this.altPhone,
    notes: notes.present ? notes.value : this.notes,
    profileCompletedAt: profileCompletedAt.present
        ? profileCompletedAt.value
        : this.profileCompletedAt,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    locationAccuracyM: locationAccuracyM.present
        ? locationAccuracyM.value
        : this.locationAccuracyM,
    locationCapturedAt: locationCapturedAt.present
        ? locationCapturedAt.value
        : this.locationCapturedAt,
  );
  FarmRow copyWithCompanion(FarmsCompanion data) {
    return FarmRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      district: data.district.present ? data.district.value : this.district,
      village: data.village.present ? data.village.value : this.village,
      phone: data.phone.present ? data.phone.value : this.phone,
      altPhone: data.altPhone.present ? data.altPhone.value : this.altPhone,
      notes: data.notes.present ? data.notes.value : this.notes,
      profileCompletedAt: data.profileCompletedAt.present
          ? data.profileCompletedAt.value
          : this.profileCompletedAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      locationAccuracyM: data.locationAccuracyM.present
          ? data.locationAccuracyM.value
          : this.locationAccuracyM,
      locationCapturedAt: data.locationCapturedAt.present
          ? data.locationCapturedAt.value
          : this.locationCapturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('district: $district, ')
          ..write('village: $village, ')
          ..write('phone: $phone, ')
          ..write('altPhone: $altPhone, ')
          ..write('notes: $notes, ')
          ..write('profileCompletedAt: $profileCompletedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationAccuracyM: $locationAccuracyM, ')
          ..write('locationCapturedAt: $locationCapturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    name,
    location,
    district,
    village,
    phone,
    altPhone,
    notes,
    profileCompletedAt,
    latitude,
    longitude,
    locationAccuracyM,
    locationCapturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.name == this.name &&
          other.location == this.location &&
          other.district == this.district &&
          other.village == this.village &&
          other.phone == this.phone &&
          other.altPhone == this.altPhone &&
          other.notes == this.notes &&
          other.profileCompletedAt == this.profileCompletedAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.locationAccuracyM == this.locationAccuracyM &&
          other.locationCapturedAt == this.locationCapturedAt);
}

class FarmsCompanion extends UpdateCompanion<FarmRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> name;
  final Value<String?> location;
  final Value<String?> district;
  final Value<String?> village;
  final Value<String?> phone;
  final Value<String?> altPhone;
  final Value<String?> notes;
  final Value<DateTime?> profileCompletedAt;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> locationAccuracyM;
  final Value<DateTime?> locationCapturedAt;
  final Value<int> rowid;
  const FarmsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.district = const Value.absent(),
    this.village = const Value.absent(),
    this.phone = const Value.absent(),
    this.altPhone = const Value.absent(),
    this.notes = const Value.absent(),
    this.profileCompletedAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationAccuracyM = const Value.absent(),
    this.locationCapturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmsCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String name,
    this.location = const Value.absent(),
    this.district = const Value.absent(),
    this.village = const Value.absent(),
    this.phone = const Value.absent(),
    this.altPhone = const Value.absent(),
    this.notes = const Value.absent(),
    this.profileCompletedAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationAccuracyM = const Value.absent(),
    this.locationCapturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<FarmRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? name,
    Expression<String>? location,
    Expression<String>? district,
    Expression<String>? village,
    Expression<String>? phone,
    Expression<String>? altPhone,
    Expression<String>? notes,
    Expression<DateTime>? profileCompletedAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? locationAccuracyM,
    Expression<DateTime>? locationCapturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (district != null) 'district': district,
      if (village != null) 'village': village,
      if (phone != null) 'phone': phone,
      if (altPhone != null) 'alt_phone': altPhone,
      if (notes != null) 'notes': notes,
      if (profileCompletedAt != null)
        'profile_completed_at': profileCompletedAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationAccuracyM != null) 'location_accuracy_m': locationAccuracyM,
      if (locationCapturedAt != null)
        'location_captured_at': locationCapturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? name,
    Value<String?>? location,
    Value<String?>? district,
    Value<String?>? village,
    Value<String?>? phone,
    Value<String?>? altPhone,
    Value<String?>? notes,
    Value<DateTime?>? profileCompletedAt,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? locationAccuracyM,
    Value<DateTime?>? locationCapturedAt,
    Value<int>? rowid,
  }) {
    return FarmsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      name: name ?? this.name,
      location: location ?? this.location,
      district: district ?? this.district,
      village: village ?? this.village,
      phone: phone ?? this.phone,
      altPhone: altPhone ?? this.altPhone,
      notes: notes ?? this.notes,
      profileCompletedAt: profileCompletedAt ?? this.profileCompletedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAccuracyM: locationAccuracyM ?? this.locationAccuracyM,
      locationCapturedAt: locationCapturedAt ?? this.locationCapturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (village.present) {
      map['village'] = Variable<String>(village.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (altPhone.present) {
      map['alt_phone'] = Variable<String>(altPhone.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (profileCompletedAt.present) {
      map['profile_completed_at'] = Variable<DateTime>(
        profileCompletedAt.value,
      );
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (locationAccuracyM.present) {
      map['location_accuracy_m'] = Variable<double>(locationAccuracyM.value);
    }
    if (locationCapturedAt.present) {
      map['location_captured_at'] = Variable<DateTime>(
        locationCapturedAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('district: $district, ')
          ..write('village: $village, ')
          ..write('phone: $phone, ')
          ..write('altPhone: $altPhone, ')
          ..write('notes: $notes, ')
          ..write('profileCompletedAt: $profileCompletedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationAccuracyM: $locationAccuracyM, ')
          ..write('locationCapturedAt: $locationCapturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmMembersTable extends FarmMembers
    with TableInfo<$FarmMembersTable, FarmMemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    userId,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<FarmMemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmMemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmMemberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $FarmMembersTable createAlias(String alias) {
    return $FarmMembersTable(attachedDatabase, alias);
  }
}

class FarmMemberRow extends DataClass implements Insertable<FarmMemberRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String userId;
  final String role;
  const FarmMemberRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.userId,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    return map;
  }

  FarmMembersCompanion toCompanion(bool nullToAbsent) {
    return FarmMembersCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      userId: Value(userId),
      role: Value(role),
    );
  }

  factory FarmMemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmMemberRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
    };
  }

  FarmMemberRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? userId,
    String? role,
  }) => FarmMemberRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    userId: userId ?? this.userId,
    role: role ?? this.role,
  );
  FarmMemberRow copyWithCompanion(FarmMembersCompanion data) {
    return FarmMemberRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmMemberRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('userId: $userId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    userId,
    role,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmMemberRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.userId == this.userId &&
          other.role == this.role);
}

class FarmMembersCompanion extends UpdateCompanion<FarmMemberRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> userId;
  final Value<String> role;
  final Value<int> rowid;
  const FarmMembersCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmMembersCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String userId,
    required String role,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       userId = Value(userId),
       role = Value(role);
  static Insertable<FarmMemberRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? userId,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return FarmMembersCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmMembersCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BatchesTable extends Batches with TableInfo<$BatchesTable, BatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birdTypeMeta = const VerificationMeta(
    'birdType',
  );
  @override
  late final GeneratedColumn<String> birdType = GeneratedColumn<String>(
    'bird_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialCountMeta = const VerificationMeta(
    'initialCount',
  );
  @override
  late final GeneratedColumn<int> initialCount = GeneratedColumn<int>(
    'initial_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acquiredOnMeta = const VerificationMeta(
    'acquiredOn',
  );
  @override
  late final GeneratedColumn<DateTime> acquiredOn = GeneratedColumn<DateTime>(
    'acquired_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageAtAcquisitionDaysMeta =
      const VerificationMeta('ageAtAcquisitionDays');
  @override
  late final GeneratedColumn<int> ageAtAcquisitionDays = GeneratedColumn<int>(
    'age_at_acquisition_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hatcheryVaccinatedMeta =
      const VerificationMeta('hatcheryVaccinated');
  @override
  late final GeneratedColumn<bool> hatcheryVaccinated = GeneratedColumn<bool>(
    'hatchery_vaccinated',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hatchery_vaccinated" IN (0, 1))',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _programmeIdMeta = const VerificationMeta(
    'programmeId',
  );
  @override
  late final GeneratedColumn<String> programmeId = GeneratedColumn<String>(
    'programme_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _programmeVersionMeta = const VerificationMeta(
    'programmeVersion',
  );
  @override
  late final GeneratedColumn<int> programmeVersion = GeneratedColumn<int>(
    'programme_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productionTypeMeta = const VerificationMeta(
    'productionType',
  );
  @override
  late final GeneratedColumn<String> productionType = GeneratedColumn<String>(
    'production_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _programmeContentHashMeta =
      const VerificationMeta('programmeContentHash');
  @override
  late final GeneratedColumn<String> programmeContentHash =
      GeneratedColumn<String>(
        'programme_content_hash',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedOnMeta = const VerificationMeta(
    'closedOn',
  );
  @override
  late final GeneratedColumn<DateTime> closedOn = GeneratedColumn<DateTime>(
    'closed_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closeReasonMeta = const VerificationMeta(
    'closeReason',
  );
  @override
  late final GeneratedColumn<String> closeReason = GeneratedColumn<String>(
    'close_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closeNoteMeta = const VerificationMeta(
    'closeNote',
  );
  @override
  late final GeneratedColumn<String> closeNote = GeneratedColumn<String>(
    'close_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedGroupIdMeta = const VerificationMeta(
    'deletedGroupId',
  );
  @override
  late final GeneratedColumn<String> deletedGroupId = GeneratedColumn<String>(
    'deleted_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    name,
    birdType,
    initialCount,
    acquiredOn,
    ageAtAcquisitionDays,
    hatcheryVaccinated,
    source,
    status,
    programmeId,
    programmeVersion,
    productionType,
    programmeContentHash,
    notes,
    closedOn,
    closeReason,
    closeNote,
    deletedGroupId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<BatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('bird_type')) {
      context.handle(
        _birdTypeMeta,
        birdType.isAcceptableOrUnknown(data['bird_type']!, _birdTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_birdTypeMeta);
    }
    if (data.containsKey('initial_count')) {
      context.handle(
        _initialCountMeta,
        initialCount.isAcceptableOrUnknown(
          data['initial_count']!,
          _initialCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialCountMeta);
    }
    if (data.containsKey('acquired_on')) {
      context.handle(
        _acquiredOnMeta,
        acquiredOn.isAcceptableOrUnknown(data['acquired_on']!, _acquiredOnMeta),
      );
    } else if (isInserting) {
      context.missing(_acquiredOnMeta);
    }
    if (data.containsKey('age_at_acquisition_days')) {
      context.handle(
        _ageAtAcquisitionDaysMeta,
        ageAtAcquisitionDays.isAcceptableOrUnknown(
          data['age_at_acquisition_days']!,
          _ageAtAcquisitionDaysMeta,
        ),
      );
    }
    if (data.containsKey('hatchery_vaccinated')) {
      context.handle(
        _hatcheryVaccinatedMeta,
        hatcheryVaccinated.isAcceptableOrUnknown(
          data['hatchery_vaccinated']!,
          _hatcheryVaccinatedMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('programme_id')) {
      context.handle(
        _programmeIdMeta,
        programmeId.isAcceptableOrUnknown(
          data['programme_id']!,
          _programmeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_programmeIdMeta);
    }
    if (data.containsKey('programme_version')) {
      context.handle(
        _programmeVersionMeta,
        programmeVersion.isAcceptableOrUnknown(
          data['programme_version']!,
          _programmeVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_programmeVersionMeta);
    }
    if (data.containsKey('production_type')) {
      context.handle(
        _productionTypeMeta,
        productionType.isAcceptableOrUnknown(
          data['production_type']!,
          _productionTypeMeta,
        ),
      );
    }
    if (data.containsKey('programme_content_hash')) {
      context.handle(
        _programmeContentHashMeta,
        programmeContentHash.isAcceptableOrUnknown(
          data['programme_content_hash']!,
          _programmeContentHashMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('closed_on')) {
      context.handle(
        _closedOnMeta,
        closedOn.isAcceptableOrUnknown(data['closed_on']!, _closedOnMeta),
      );
    }
    if (data.containsKey('close_reason')) {
      context.handle(
        _closeReasonMeta,
        closeReason.isAcceptableOrUnknown(
          data['close_reason']!,
          _closeReasonMeta,
        ),
      );
    }
    if (data.containsKey('close_note')) {
      context.handle(
        _closeNoteMeta,
        closeNote.isAcceptableOrUnknown(data['close_note']!, _closeNoteMeta),
      );
    }
    if (data.containsKey('deleted_group_id')) {
      context.handle(
        _deletedGroupIdMeta,
        deletedGroupId.isAcceptableOrUnknown(
          data['deleted_group_id']!,
          _deletedGroupIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BatchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      birdType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bird_type'],
      )!,
      initialCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_count'],
      )!,
      acquiredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acquired_on'],
      )!,
      ageAtAcquisitionDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_at_acquisition_days'],
      )!,
      hatcheryVaccinated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hatchery_vaccinated'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      programmeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}programme_id'],
      )!,
      programmeVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}programme_version'],
      )!,
      productionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}production_type'],
      ),
      programmeContentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}programme_content_hash'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      closedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_on'],
      ),
      closeReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}close_reason'],
      ),
      closeNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}close_note'],
      ),
      deletedGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_group_id'],
      ),
    );
  }

  @override
  $BatchesTable createAlias(String alias) {
    return $BatchesTable(attachedDatabase, alias);
  }
}

class BatchRow extends DataClass implements Insertable<BatchRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String name;
  final String birdType;
  final int initialCount;
  final DateTime acquiredOn;
  final int ageAtAcquisitionDays;
  final bool? hatcheryVaccinated;
  final String? source;
  final String status;
  final String programmeId;
  final int programmeVersion;
  final String? productionType;
  final String? programmeContentHash;
  final String? notes;
  final DateTime? closedOn;
  final String? closeReason;
  final String? closeNote;
  final String? deletedGroupId;
  const BatchRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.name,
    required this.birdType,
    required this.initialCount,
    required this.acquiredOn,
    required this.ageAtAcquisitionDays,
    this.hatcheryVaccinated,
    this.source,
    required this.status,
    required this.programmeId,
    required this.programmeVersion,
    this.productionType,
    this.programmeContentHash,
    this.notes,
    this.closedOn,
    this.closeReason,
    this.closeNote,
    this.deletedGroupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['name'] = Variable<String>(name);
    map['bird_type'] = Variable<String>(birdType);
    map['initial_count'] = Variable<int>(initialCount);
    map['acquired_on'] = Variable<DateTime>(acquiredOn);
    map['age_at_acquisition_days'] = Variable<int>(ageAtAcquisitionDays);
    if (!nullToAbsent || hatcheryVaccinated != null) {
      map['hatchery_vaccinated'] = Variable<bool>(hatcheryVaccinated);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['status'] = Variable<String>(status);
    map['programme_id'] = Variable<String>(programmeId);
    map['programme_version'] = Variable<int>(programmeVersion);
    if (!nullToAbsent || productionType != null) {
      map['production_type'] = Variable<String>(productionType);
    }
    if (!nullToAbsent || programmeContentHash != null) {
      map['programme_content_hash'] = Variable<String>(programmeContentHash);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || closedOn != null) {
      map['closed_on'] = Variable<DateTime>(closedOn);
    }
    if (!nullToAbsent || closeReason != null) {
      map['close_reason'] = Variable<String>(closeReason);
    }
    if (!nullToAbsent || closeNote != null) {
      map['close_note'] = Variable<String>(closeNote);
    }
    if (!nullToAbsent || deletedGroupId != null) {
      map['deleted_group_id'] = Variable<String>(deletedGroupId);
    }
    return map;
  }

  BatchesCompanion toCompanion(bool nullToAbsent) {
    return BatchesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      name: Value(name),
      birdType: Value(birdType),
      initialCount: Value(initialCount),
      acquiredOn: Value(acquiredOn),
      ageAtAcquisitionDays: Value(ageAtAcquisitionDays),
      hatcheryVaccinated: hatcheryVaccinated == null && nullToAbsent
          ? const Value.absent()
          : Value(hatcheryVaccinated),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      status: Value(status),
      programmeId: Value(programmeId),
      programmeVersion: Value(programmeVersion),
      productionType: productionType == null && nullToAbsent
          ? const Value.absent()
          : Value(productionType),
      programmeContentHash: programmeContentHash == null && nullToAbsent
          ? const Value.absent()
          : Value(programmeContentHash),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      closedOn: closedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(closedOn),
      closeReason: closeReason == null && nullToAbsent
          ? const Value.absent()
          : Value(closeReason),
      closeNote: closeNote == null && nullToAbsent
          ? const Value.absent()
          : Value(closeNote),
      deletedGroupId: deletedGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedGroupId),
    );
  }

  factory BatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BatchRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      name: serializer.fromJson<String>(json['name']),
      birdType: serializer.fromJson<String>(json['birdType']),
      initialCount: serializer.fromJson<int>(json['initialCount']),
      acquiredOn: serializer.fromJson<DateTime>(json['acquiredOn']),
      ageAtAcquisitionDays: serializer.fromJson<int>(
        json['ageAtAcquisitionDays'],
      ),
      hatcheryVaccinated: serializer.fromJson<bool?>(
        json['hatcheryVaccinated'],
      ),
      source: serializer.fromJson<String?>(json['source']),
      status: serializer.fromJson<String>(json['status']),
      programmeId: serializer.fromJson<String>(json['programmeId']),
      programmeVersion: serializer.fromJson<int>(json['programmeVersion']),
      productionType: serializer.fromJson<String?>(json['productionType']),
      programmeContentHash: serializer.fromJson<String?>(
        json['programmeContentHash'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      closedOn: serializer.fromJson<DateTime?>(json['closedOn']),
      closeReason: serializer.fromJson<String?>(json['closeReason']),
      closeNote: serializer.fromJson<String?>(json['closeNote']),
      deletedGroupId: serializer.fromJson<String?>(json['deletedGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'name': serializer.toJson<String>(name),
      'birdType': serializer.toJson<String>(birdType),
      'initialCount': serializer.toJson<int>(initialCount),
      'acquiredOn': serializer.toJson<DateTime>(acquiredOn),
      'ageAtAcquisitionDays': serializer.toJson<int>(ageAtAcquisitionDays),
      'hatcheryVaccinated': serializer.toJson<bool?>(hatcheryVaccinated),
      'source': serializer.toJson<String?>(source),
      'status': serializer.toJson<String>(status),
      'programmeId': serializer.toJson<String>(programmeId),
      'programmeVersion': serializer.toJson<int>(programmeVersion),
      'productionType': serializer.toJson<String?>(productionType),
      'programmeContentHash': serializer.toJson<String?>(programmeContentHash),
      'notes': serializer.toJson<String?>(notes),
      'closedOn': serializer.toJson<DateTime?>(closedOn),
      'closeReason': serializer.toJson<String?>(closeReason),
      'closeNote': serializer.toJson<String?>(closeNote),
      'deletedGroupId': serializer.toJson<String?>(deletedGroupId),
    };
  }

  BatchRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? name,
    String? birdType,
    int? initialCount,
    DateTime? acquiredOn,
    int? ageAtAcquisitionDays,
    Value<bool?> hatcheryVaccinated = const Value.absent(),
    Value<String?> source = const Value.absent(),
    String? status,
    String? programmeId,
    int? programmeVersion,
    Value<String?> productionType = const Value.absent(),
    Value<String?> programmeContentHash = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> closedOn = const Value.absent(),
    Value<String?> closeReason = const Value.absent(),
    Value<String?> closeNote = const Value.absent(),
    Value<String?> deletedGroupId = const Value.absent(),
  }) => BatchRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    name: name ?? this.name,
    birdType: birdType ?? this.birdType,
    initialCount: initialCount ?? this.initialCount,
    acquiredOn: acquiredOn ?? this.acquiredOn,
    ageAtAcquisitionDays: ageAtAcquisitionDays ?? this.ageAtAcquisitionDays,
    hatcheryVaccinated: hatcheryVaccinated.present
        ? hatcheryVaccinated.value
        : this.hatcheryVaccinated,
    source: source.present ? source.value : this.source,
    status: status ?? this.status,
    programmeId: programmeId ?? this.programmeId,
    programmeVersion: programmeVersion ?? this.programmeVersion,
    productionType: productionType.present
        ? productionType.value
        : this.productionType,
    programmeContentHash: programmeContentHash.present
        ? programmeContentHash.value
        : this.programmeContentHash,
    notes: notes.present ? notes.value : this.notes,
    closedOn: closedOn.present ? closedOn.value : this.closedOn,
    closeReason: closeReason.present ? closeReason.value : this.closeReason,
    closeNote: closeNote.present ? closeNote.value : this.closeNote,
    deletedGroupId: deletedGroupId.present
        ? deletedGroupId.value
        : this.deletedGroupId,
  );
  BatchRow copyWithCompanion(BatchesCompanion data) {
    return BatchRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      name: data.name.present ? data.name.value : this.name,
      birdType: data.birdType.present ? data.birdType.value : this.birdType,
      initialCount: data.initialCount.present
          ? data.initialCount.value
          : this.initialCount,
      acquiredOn: data.acquiredOn.present
          ? data.acquiredOn.value
          : this.acquiredOn,
      ageAtAcquisitionDays: data.ageAtAcquisitionDays.present
          ? data.ageAtAcquisitionDays.value
          : this.ageAtAcquisitionDays,
      hatcheryVaccinated: data.hatcheryVaccinated.present
          ? data.hatcheryVaccinated.value
          : this.hatcheryVaccinated,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      programmeId: data.programmeId.present
          ? data.programmeId.value
          : this.programmeId,
      programmeVersion: data.programmeVersion.present
          ? data.programmeVersion.value
          : this.programmeVersion,
      productionType: data.productionType.present
          ? data.productionType.value
          : this.productionType,
      programmeContentHash: data.programmeContentHash.present
          ? data.programmeContentHash.value
          : this.programmeContentHash,
      notes: data.notes.present ? data.notes.value : this.notes,
      closedOn: data.closedOn.present ? data.closedOn.value : this.closedOn,
      closeReason: data.closeReason.present
          ? data.closeReason.value
          : this.closeReason,
      closeNote: data.closeNote.present ? data.closeNote.value : this.closeNote,
      deletedGroupId: data.deletedGroupId.present
          ? data.deletedGroupId.value
          : this.deletedGroupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BatchRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('name: $name, ')
          ..write('birdType: $birdType, ')
          ..write('initialCount: $initialCount, ')
          ..write('acquiredOn: $acquiredOn, ')
          ..write('ageAtAcquisitionDays: $ageAtAcquisitionDays, ')
          ..write('hatcheryVaccinated: $hatcheryVaccinated, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('programmeId: $programmeId, ')
          ..write('programmeVersion: $programmeVersion, ')
          ..write('productionType: $productionType, ')
          ..write('programmeContentHash: $programmeContentHash, ')
          ..write('notes: $notes, ')
          ..write('closedOn: $closedOn, ')
          ..write('closeReason: $closeReason, ')
          ..write('closeNote: $closeNote, ')
          ..write('deletedGroupId: $deletedGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    name,
    birdType,
    initialCount,
    acquiredOn,
    ageAtAcquisitionDays,
    hatcheryVaccinated,
    source,
    status,
    programmeId,
    programmeVersion,
    productionType,
    programmeContentHash,
    notes,
    closedOn,
    closeReason,
    closeNote,
    deletedGroupId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BatchRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.name == this.name &&
          other.birdType == this.birdType &&
          other.initialCount == this.initialCount &&
          other.acquiredOn == this.acquiredOn &&
          other.ageAtAcquisitionDays == this.ageAtAcquisitionDays &&
          other.hatcheryVaccinated == this.hatcheryVaccinated &&
          other.source == this.source &&
          other.status == this.status &&
          other.programmeId == this.programmeId &&
          other.programmeVersion == this.programmeVersion &&
          other.productionType == this.productionType &&
          other.programmeContentHash == this.programmeContentHash &&
          other.notes == this.notes &&
          other.closedOn == this.closedOn &&
          other.closeReason == this.closeReason &&
          other.closeNote == this.closeNote &&
          other.deletedGroupId == this.deletedGroupId);
}

class BatchesCompanion extends UpdateCompanion<BatchRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> name;
  final Value<String> birdType;
  final Value<int> initialCount;
  final Value<DateTime> acquiredOn;
  final Value<int> ageAtAcquisitionDays;
  final Value<bool?> hatcheryVaccinated;
  final Value<String?> source;
  final Value<String> status;
  final Value<String> programmeId;
  final Value<int> programmeVersion;
  final Value<String?> productionType;
  final Value<String?> programmeContentHash;
  final Value<String?> notes;
  final Value<DateTime?> closedOn;
  final Value<String?> closeReason;
  final Value<String?> closeNote;
  final Value<String?> deletedGroupId;
  final Value<int> rowid;
  const BatchesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.name = const Value.absent(),
    this.birdType = const Value.absent(),
    this.initialCount = const Value.absent(),
    this.acquiredOn = const Value.absent(),
    this.ageAtAcquisitionDays = const Value.absent(),
    this.hatcheryVaccinated = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.programmeId = const Value.absent(),
    this.programmeVersion = const Value.absent(),
    this.productionType = const Value.absent(),
    this.programmeContentHash = const Value.absent(),
    this.notes = const Value.absent(),
    this.closedOn = const Value.absent(),
    this.closeReason = const Value.absent(),
    this.closeNote = const Value.absent(),
    this.deletedGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchesCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String name,
    required String birdType,
    required int initialCount,
    required DateTime acquiredOn,
    this.ageAtAcquisitionDays = const Value.absent(),
    this.hatcheryVaccinated = const Value.absent(),
    this.source = const Value.absent(),
    required String status,
    required String programmeId,
    required int programmeVersion,
    this.productionType = const Value.absent(),
    this.programmeContentHash = const Value.absent(),
    this.notes = const Value.absent(),
    this.closedOn = const Value.absent(),
    this.closeReason = const Value.absent(),
    this.closeNote = const Value.absent(),
    this.deletedGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       birdType = Value(birdType),
       initialCount = Value(initialCount),
       acquiredOn = Value(acquiredOn),
       status = Value(status),
       programmeId = Value(programmeId),
       programmeVersion = Value(programmeVersion);
  static Insertable<BatchRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? name,
    Expression<String>? birdType,
    Expression<int>? initialCount,
    Expression<DateTime>? acquiredOn,
    Expression<int>? ageAtAcquisitionDays,
    Expression<bool>? hatcheryVaccinated,
    Expression<String>? source,
    Expression<String>? status,
    Expression<String>? programmeId,
    Expression<int>? programmeVersion,
    Expression<String>? productionType,
    Expression<String>? programmeContentHash,
    Expression<String>? notes,
    Expression<DateTime>? closedOn,
    Expression<String>? closeReason,
    Expression<String>? closeNote,
    Expression<String>? deletedGroupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (name != null) 'name': name,
      if (birdType != null) 'bird_type': birdType,
      if (initialCount != null) 'initial_count': initialCount,
      if (acquiredOn != null) 'acquired_on': acquiredOn,
      if (ageAtAcquisitionDays != null)
        'age_at_acquisition_days': ageAtAcquisitionDays,
      if (hatcheryVaccinated != null) 'hatchery_vaccinated': hatcheryVaccinated,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (programmeId != null) 'programme_id': programmeId,
      if (programmeVersion != null) 'programme_version': programmeVersion,
      if (productionType != null) 'production_type': productionType,
      if (programmeContentHash != null)
        'programme_content_hash': programmeContentHash,
      if (notes != null) 'notes': notes,
      if (closedOn != null) 'closed_on': closedOn,
      if (closeReason != null) 'close_reason': closeReason,
      if (closeNote != null) 'close_note': closeNote,
      if (deletedGroupId != null) 'deleted_group_id': deletedGroupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? name,
    Value<String>? birdType,
    Value<int>? initialCount,
    Value<DateTime>? acquiredOn,
    Value<int>? ageAtAcquisitionDays,
    Value<bool?>? hatcheryVaccinated,
    Value<String?>? source,
    Value<String>? status,
    Value<String>? programmeId,
    Value<int>? programmeVersion,
    Value<String?>? productionType,
    Value<String?>? programmeContentHash,
    Value<String?>? notes,
    Value<DateTime?>? closedOn,
    Value<String?>? closeReason,
    Value<String?>? closeNote,
    Value<String?>? deletedGroupId,
    Value<int>? rowid,
  }) {
    return BatchesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      name: name ?? this.name,
      birdType: birdType ?? this.birdType,
      initialCount: initialCount ?? this.initialCount,
      acquiredOn: acquiredOn ?? this.acquiredOn,
      ageAtAcquisitionDays: ageAtAcquisitionDays ?? this.ageAtAcquisitionDays,
      hatcheryVaccinated: hatcheryVaccinated ?? this.hatcheryVaccinated,
      source: source ?? this.source,
      status: status ?? this.status,
      programmeId: programmeId ?? this.programmeId,
      programmeVersion: programmeVersion ?? this.programmeVersion,
      productionType: productionType ?? this.productionType,
      programmeContentHash: programmeContentHash ?? this.programmeContentHash,
      notes: notes ?? this.notes,
      closedOn: closedOn ?? this.closedOn,
      closeReason: closeReason ?? this.closeReason,
      closeNote: closeNote ?? this.closeNote,
      deletedGroupId: deletedGroupId ?? this.deletedGroupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birdType.present) {
      map['bird_type'] = Variable<String>(birdType.value);
    }
    if (initialCount.present) {
      map['initial_count'] = Variable<int>(initialCount.value);
    }
    if (acquiredOn.present) {
      map['acquired_on'] = Variable<DateTime>(acquiredOn.value);
    }
    if (ageAtAcquisitionDays.present) {
      map['age_at_acquisition_days'] = Variable<int>(
        ageAtAcquisitionDays.value,
      );
    }
    if (hatcheryVaccinated.present) {
      map['hatchery_vaccinated'] = Variable<bool>(hatcheryVaccinated.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (programmeId.present) {
      map['programme_id'] = Variable<String>(programmeId.value);
    }
    if (programmeVersion.present) {
      map['programme_version'] = Variable<int>(programmeVersion.value);
    }
    if (productionType.present) {
      map['production_type'] = Variable<String>(productionType.value);
    }
    if (programmeContentHash.present) {
      map['programme_content_hash'] = Variable<String>(
        programmeContentHash.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (closedOn.present) {
      map['closed_on'] = Variable<DateTime>(closedOn.value);
    }
    if (closeReason.present) {
      map['close_reason'] = Variable<String>(closeReason.value);
    }
    if (closeNote.present) {
      map['close_note'] = Variable<String>(closeNote.value);
    }
    if (deletedGroupId.present) {
      map['deleted_group_id'] = Variable<String>(deletedGroupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('name: $name, ')
          ..write('birdType: $birdType, ')
          ..write('initialCount: $initialCount, ')
          ..write('acquiredOn: $acquiredOn, ')
          ..write('ageAtAcquisitionDays: $ageAtAcquisitionDays, ')
          ..write('hatcheryVaccinated: $hatcheryVaccinated, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('programmeId: $programmeId, ')
          ..write('programmeVersion: $programmeVersion, ')
          ..write('productionType: $productionType, ')
          ..write('programmeContentHash: $programmeContentHash, ')
          ..write('notes: $notes, ')
          ..write('closedOn: $closedOn, ')
          ..write('closeReason: $closeReason, ')
          ..write('closeNote: $closeNote, ')
          ..write('deletedGroupId: $deletedGroupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgrammesTable extends Programmes
    with TableInfo<$ProgrammesTable, ProgrammeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgrammesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birdTypesJsonMeta = const VerificationMeta(
    'birdTypesJson',
  );
  @override
  late final GeneratedColumn<String> birdTypesJson = GeneratedColumn<String>(
    'bird_types_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    name,
    version,
    birdTypesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'programmes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgrammeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('bird_types_json')) {
      context.handle(
        _birdTypesJsonMeta,
        birdTypesJson.isAcceptableOrUnknown(
          data['bird_types_json']!,
          _birdTypesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_birdTypesJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgrammeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgrammeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      birdTypesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bird_types_json'],
      )!,
    );
  }

  @override
  $ProgrammesTable createAlias(String alias) {
    return $ProgrammesTable(attachedDatabase, alias);
  }
}

class ProgrammeRow extends DataClass implements Insertable<ProgrammeRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String name;
  final int version;
  final String birdTypesJson;
  const ProgrammeRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.name,
    required this.version,
    required this.birdTypesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['name'] = Variable<String>(name);
    map['version'] = Variable<int>(version);
    map['bird_types_json'] = Variable<String>(birdTypesJson);
    return map;
  }

  ProgrammesCompanion toCompanion(bool nullToAbsent) {
    return ProgrammesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      name: Value(name),
      version: Value(version),
      birdTypesJson: Value(birdTypesJson),
    );
  }

  factory ProgrammeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgrammeRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      name: serializer.fromJson<String>(json['name']),
      version: serializer.fromJson<int>(json['version']),
      birdTypesJson: serializer.fromJson<String>(json['birdTypesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'name': serializer.toJson<String>(name),
      'version': serializer.toJson<int>(version),
      'birdTypesJson': serializer.toJson<String>(birdTypesJson),
    };
  }

  ProgrammeRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? name,
    int? version,
    String? birdTypesJson,
  }) => ProgrammeRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    name: name ?? this.name,
    version: version ?? this.version,
    birdTypesJson: birdTypesJson ?? this.birdTypesJson,
  );
  ProgrammeRow copyWithCompanion(ProgrammesCompanion data) {
    return ProgrammeRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      name: data.name.present ? data.name.value : this.name,
      version: data.version.present ? data.version.value : this.version,
      birdTypesJson: data.birdTypesJson.present
          ? data.birdTypesJson.value
          : this.birdTypesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgrammeRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('birdTypesJson: $birdTypesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    name,
    version,
    birdTypesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgrammeRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.name == this.name &&
          other.version == this.version &&
          other.birdTypesJson == this.birdTypesJson);
}

class ProgrammesCompanion extends UpdateCompanion<ProgrammeRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> name;
  final Value<int> version;
  final Value<String> birdTypesJson;
  final Value<int> rowid;
  const ProgrammesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.name = const Value.absent(),
    this.version = const Value.absent(),
    this.birdTypesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgrammesCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String name,
    required int version,
    required String birdTypesJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       version = Value(version),
       birdTypesJson = Value(birdTypesJson);
  static Insertable<ProgrammeRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? name,
    Expression<int>? version,
    Expression<String>? birdTypesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (name != null) 'name': name,
      if (version != null) 'version': version,
      if (birdTypesJson != null) 'bird_types_json': birdTypesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgrammesCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? name,
    Value<int>? version,
    Value<String>? birdTypesJson,
    Value<int>? rowid,
  }) {
    return ProgrammesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      name: name ?? this.name,
      version: version ?? this.version,
      birdTypesJson: birdTypesJson ?? this.birdTypesJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (birdTypesJson.present) {
      map['bird_types_json'] = Variable<String>(birdTypesJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgrammesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('birdTypesJson: $birdTypesJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgrammeStepsTable extends ProgrammeSteps
    with TableInfo<$ProgrammeStepsTable, ProgrammeStepRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgrammeStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _programmeIdMeta = const VerificationMeta(
    'programmeId',
  );
  @override
  late final GeneratedColumn<String> programmeId = GeneratedColumn<String>(
    'programme_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageDaysMeta = const VerificationMeta(
    'ageDays',
  );
  @override
  late final GeneratedColumn<int> ageDays = GeneratedColumn<int>(
    'age_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionalMeta = const VerificationMeta(
    'optional',
  );
  @override
  late final GeneratedColumn<bool> optional = GeneratedColumn<bool>(
    'optional',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("optional" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dueWindowDaysBeforeMeta =
      const VerificationMeta('dueWindowDaysBefore');
  @override
  late final GeneratedColumn<int> dueWindowDaysBefore = GeneratedColumn<int>(
    'due_window_days_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueWindowDaysAfterMeta =
      const VerificationMeta('dueWindowDaysAfter');
  @override
  late final GeneratedColumn<int> dueWindowDaysAfter = GeneratedColumn<int>(
    'due_window_days_after',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recurringJsonMeta = const VerificationMeta(
    'recurringJson',
  );
  @override
  late final GeneratedColumn<String> recurringJson = GeneratedColumn<String>(
    'recurring_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    programmeId,
    name,
    ageDays,
    location,
    optional,
    dueWindowDaysBefore,
    dueWindowDaysAfter,
    recurringJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'programme_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgrammeStepRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('programme_id')) {
      context.handle(
        _programmeIdMeta,
        programmeId.isAcceptableOrUnknown(
          data['programme_id']!,
          _programmeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_programmeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age_days')) {
      context.handle(
        _ageDaysMeta,
        ageDays.isAcceptableOrUnknown(data['age_days']!, _ageDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_ageDaysMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('optional')) {
      context.handle(
        _optionalMeta,
        optional.isAcceptableOrUnknown(data['optional']!, _optionalMeta),
      );
    }
    if (data.containsKey('due_window_days_before')) {
      context.handle(
        _dueWindowDaysBeforeMeta,
        dueWindowDaysBefore.isAcceptableOrUnknown(
          data['due_window_days_before']!,
          _dueWindowDaysBeforeMeta,
        ),
      );
    }
    if (data.containsKey('due_window_days_after')) {
      context.handle(
        _dueWindowDaysAfterMeta,
        dueWindowDaysAfter.isAcceptableOrUnknown(
          data['due_window_days_after']!,
          _dueWindowDaysAfterMeta,
        ),
      );
    }
    if (data.containsKey('recurring_json')) {
      context.handle(
        _recurringJsonMeta,
        recurringJson.isAcceptableOrUnknown(
          data['recurring_json']!,
          _recurringJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgrammeStepRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgrammeStepRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      programmeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}programme_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ageDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_days'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      optional: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}optional'],
      )!,
      dueWindowDaysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_window_days_before'],
      )!,
      dueWindowDaysAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_window_days_after'],
      )!,
      recurringJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_json'],
      ),
    );
  }

  @override
  $ProgrammeStepsTable createAlias(String alias) {
    return $ProgrammeStepsTable(attachedDatabase, alias);
  }
}

class ProgrammeStepRow extends DataClass
    implements Insertable<ProgrammeStepRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String programmeId;
  final String name;
  final int ageDays;
  final String location;
  final bool optional;
  final int dueWindowDaysBefore;
  final int dueWindowDaysAfter;
  final String? recurringJson;
  const ProgrammeStepRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.programmeId,
    required this.name,
    required this.ageDays,
    required this.location,
    required this.optional,
    required this.dueWindowDaysBefore,
    required this.dueWindowDaysAfter,
    this.recurringJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['programme_id'] = Variable<String>(programmeId);
    map['name'] = Variable<String>(name);
    map['age_days'] = Variable<int>(ageDays);
    map['location'] = Variable<String>(location);
    map['optional'] = Variable<bool>(optional);
    map['due_window_days_before'] = Variable<int>(dueWindowDaysBefore);
    map['due_window_days_after'] = Variable<int>(dueWindowDaysAfter);
    if (!nullToAbsent || recurringJson != null) {
      map['recurring_json'] = Variable<String>(recurringJson);
    }
    return map;
  }

  ProgrammeStepsCompanion toCompanion(bool nullToAbsent) {
    return ProgrammeStepsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      programmeId: Value(programmeId),
      name: Value(name),
      ageDays: Value(ageDays),
      location: Value(location),
      optional: Value(optional),
      dueWindowDaysBefore: Value(dueWindowDaysBefore),
      dueWindowDaysAfter: Value(dueWindowDaysAfter),
      recurringJson: recurringJson == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringJson),
    );
  }

  factory ProgrammeStepRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgrammeStepRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      programmeId: serializer.fromJson<String>(json['programmeId']),
      name: serializer.fromJson<String>(json['name']),
      ageDays: serializer.fromJson<int>(json['ageDays']),
      location: serializer.fromJson<String>(json['location']),
      optional: serializer.fromJson<bool>(json['optional']),
      dueWindowDaysBefore: serializer.fromJson<int>(
        json['dueWindowDaysBefore'],
      ),
      dueWindowDaysAfter: serializer.fromJson<int>(json['dueWindowDaysAfter']),
      recurringJson: serializer.fromJson<String?>(json['recurringJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'programmeId': serializer.toJson<String>(programmeId),
      'name': serializer.toJson<String>(name),
      'ageDays': serializer.toJson<int>(ageDays),
      'location': serializer.toJson<String>(location),
      'optional': serializer.toJson<bool>(optional),
      'dueWindowDaysBefore': serializer.toJson<int>(dueWindowDaysBefore),
      'dueWindowDaysAfter': serializer.toJson<int>(dueWindowDaysAfter),
      'recurringJson': serializer.toJson<String?>(recurringJson),
    };
  }

  ProgrammeStepRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? programmeId,
    String? name,
    int? ageDays,
    String? location,
    bool? optional,
    int? dueWindowDaysBefore,
    int? dueWindowDaysAfter,
    Value<String?> recurringJson = const Value.absent(),
  }) => ProgrammeStepRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    programmeId: programmeId ?? this.programmeId,
    name: name ?? this.name,
    ageDays: ageDays ?? this.ageDays,
    location: location ?? this.location,
    optional: optional ?? this.optional,
    dueWindowDaysBefore: dueWindowDaysBefore ?? this.dueWindowDaysBefore,
    dueWindowDaysAfter: dueWindowDaysAfter ?? this.dueWindowDaysAfter,
    recurringJson: recurringJson.present
        ? recurringJson.value
        : this.recurringJson,
  );
  ProgrammeStepRow copyWithCompanion(ProgrammeStepsCompanion data) {
    return ProgrammeStepRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      programmeId: data.programmeId.present
          ? data.programmeId.value
          : this.programmeId,
      name: data.name.present ? data.name.value : this.name,
      ageDays: data.ageDays.present ? data.ageDays.value : this.ageDays,
      location: data.location.present ? data.location.value : this.location,
      optional: data.optional.present ? data.optional.value : this.optional,
      dueWindowDaysBefore: data.dueWindowDaysBefore.present
          ? data.dueWindowDaysBefore.value
          : this.dueWindowDaysBefore,
      dueWindowDaysAfter: data.dueWindowDaysAfter.present
          ? data.dueWindowDaysAfter.value
          : this.dueWindowDaysAfter,
      recurringJson: data.recurringJson.present
          ? data.recurringJson.value
          : this.recurringJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgrammeStepRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('programmeId: $programmeId, ')
          ..write('name: $name, ')
          ..write('ageDays: $ageDays, ')
          ..write('location: $location, ')
          ..write('optional: $optional, ')
          ..write('dueWindowDaysBefore: $dueWindowDaysBefore, ')
          ..write('dueWindowDaysAfter: $dueWindowDaysAfter, ')
          ..write('recurringJson: $recurringJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    programmeId,
    name,
    ageDays,
    location,
    optional,
    dueWindowDaysBefore,
    dueWindowDaysAfter,
    recurringJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgrammeStepRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.programmeId == this.programmeId &&
          other.name == this.name &&
          other.ageDays == this.ageDays &&
          other.location == this.location &&
          other.optional == this.optional &&
          other.dueWindowDaysBefore == this.dueWindowDaysBefore &&
          other.dueWindowDaysAfter == this.dueWindowDaysAfter &&
          other.recurringJson == this.recurringJson);
}

class ProgrammeStepsCompanion extends UpdateCompanion<ProgrammeStepRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> programmeId;
  final Value<String> name;
  final Value<int> ageDays;
  final Value<String> location;
  final Value<bool> optional;
  final Value<int> dueWindowDaysBefore;
  final Value<int> dueWindowDaysAfter;
  final Value<String?> recurringJson;
  final Value<int> rowid;
  const ProgrammeStepsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.programmeId = const Value.absent(),
    this.name = const Value.absent(),
    this.ageDays = const Value.absent(),
    this.location = const Value.absent(),
    this.optional = const Value.absent(),
    this.dueWindowDaysBefore = const Value.absent(),
    this.dueWindowDaysAfter = const Value.absent(),
    this.recurringJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgrammeStepsCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String programmeId,
    required String name,
    required int ageDays,
    required String location,
    this.optional = const Value.absent(),
    this.dueWindowDaysBefore = const Value.absent(),
    this.dueWindowDaysAfter = const Value.absent(),
    this.recurringJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       programmeId = Value(programmeId),
       name = Value(name),
       ageDays = Value(ageDays),
       location = Value(location);
  static Insertable<ProgrammeStepRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? programmeId,
    Expression<String>? name,
    Expression<int>? ageDays,
    Expression<String>? location,
    Expression<bool>? optional,
    Expression<int>? dueWindowDaysBefore,
    Expression<int>? dueWindowDaysAfter,
    Expression<String>? recurringJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (programmeId != null) 'programme_id': programmeId,
      if (name != null) 'name': name,
      if (ageDays != null) 'age_days': ageDays,
      if (location != null) 'location': location,
      if (optional != null) 'optional': optional,
      if (dueWindowDaysBefore != null)
        'due_window_days_before': dueWindowDaysBefore,
      if (dueWindowDaysAfter != null)
        'due_window_days_after': dueWindowDaysAfter,
      if (recurringJson != null) 'recurring_json': recurringJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgrammeStepsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? programmeId,
    Value<String>? name,
    Value<int>? ageDays,
    Value<String>? location,
    Value<bool>? optional,
    Value<int>? dueWindowDaysBefore,
    Value<int>? dueWindowDaysAfter,
    Value<String?>? recurringJson,
    Value<int>? rowid,
  }) {
    return ProgrammeStepsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      programmeId: programmeId ?? this.programmeId,
      name: name ?? this.name,
      ageDays: ageDays ?? this.ageDays,
      location: location ?? this.location,
      optional: optional ?? this.optional,
      dueWindowDaysBefore: dueWindowDaysBefore ?? this.dueWindowDaysBefore,
      dueWindowDaysAfter: dueWindowDaysAfter ?? this.dueWindowDaysAfter,
      recurringJson: recurringJson ?? this.recurringJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (programmeId.present) {
      map['programme_id'] = Variable<String>(programmeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ageDays.present) {
      map['age_days'] = Variable<int>(ageDays.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (optional.present) {
      map['optional'] = Variable<bool>(optional.value);
    }
    if (dueWindowDaysBefore.present) {
      map['due_window_days_before'] = Variable<int>(dueWindowDaysBefore.value);
    }
    if (dueWindowDaysAfter.present) {
      map['due_window_days_after'] = Variable<int>(dueWindowDaysAfter.value);
    }
    if (recurringJson.present) {
      map['recurring_json'] = Variable<String>(recurringJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgrammeStepsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('programmeId: $programmeId, ')
          ..write('name: $name, ')
          ..write('ageDays: $ageDays, ')
          ..write('location: $location, ')
          ..write('optional: $optional, ')
          ..write('dueWindowDaysBefore: $dueWindowDaysBefore, ')
          ..write('dueWindowDaysAfter: $dueWindowDaysAfter, ')
          ..write('recurringJson: $recurringJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaccinationTasksTable extends VaccinationTasks
    with TableInfo<$VaccinationTasksTable, VaccinationTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaccinationTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepIdMeta = const VerificationMeta('stepId');
  @override
  late final GeneratedColumn<String> stepId = GeneratedColumn<String>(
    'step_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceMeta = const VerificationMeta(
    'occurrence',
  );
  @override
  late final GeneratedColumn<int> occurrence = GeneratedColumn<int>(
    'occurrence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueOnMeta = const VerificationMeta('dueOn');
  @override
  late final GeneratedColumn<DateTime> dueOn = GeneratedColumn<DateTime>(
    'due_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneOnMeta = const VerificationMeta('doneOn');
  @override
  late final GeneratedColumn<DateTime> doneOn = GeneratedColumn<DateTime>(
    'done_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneByMeta = const VerificationMeta('doneBy');
  @override
  late final GeneratedColumn<String> doneBy = GeneratedColumn<String>(
    'done_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productUsedMeta = const VerificationMeta(
    'productUsed',
  );
  @override
  late final GeneratedColumn<String> productUsed = GeneratedColumn<String>(
    'product_used',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepSnapshotMeta = const VerificationMeta(
    'stepSnapshot',
  );
  @override
  late final GeneratedColumn<String> stepSnapshot = GeneratedColumn<String>(
    'step_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _programmeContentHashMeta =
      const VerificationMeta('programmeContentHash');
  @override
  late final GeneratedColumn<String> programmeContentHash =
      GeneratedColumn<String>(
        'programme_content_hash',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _shiftedFromMeta = const VerificationMeta(
    'shiftedFrom',
  );
  @override
  late final GeneratedColumn<DateTime> shiftedFrom = GeneratedColumn<DateTime>(
    'shifted_from',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedGroupIdMeta = const VerificationMeta(
    'deletedGroupId',
  );
  @override
  late final GeneratedColumn<String> deletedGroupId = GeneratedColumn<String>(
    'deleted_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    batchId,
    stepId,
    occurrence,
    dueOn,
    enabled,
    status,
    doneOn,
    doneBy,
    productUsed,
    notes,
    stepSnapshot,
    programmeContentHash,
    shiftedFrom,
    deletedGroupId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaccination_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<VaccinationTaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('step_id')) {
      context.handle(
        _stepIdMeta,
        stepId.isAcceptableOrUnknown(data['step_id']!, _stepIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stepIdMeta);
    }
    if (data.containsKey('occurrence')) {
      context.handle(
        _occurrenceMeta,
        occurrence.isAcceptableOrUnknown(data['occurrence']!, _occurrenceMeta),
      );
    }
    if (data.containsKey('due_on')) {
      context.handle(
        _dueOnMeta,
        dueOn.isAcceptableOrUnknown(data['due_on']!, _dueOnMeta),
      );
    } else if (isInserting) {
      context.missing(_dueOnMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('done_on')) {
      context.handle(
        _doneOnMeta,
        doneOn.isAcceptableOrUnknown(data['done_on']!, _doneOnMeta),
      );
    }
    if (data.containsKey('done_by')) {
      context.handle(
        _doneByMeta,
        doneBy.isAcceptableOrUnknown(data['done_by']!, _doneByMeta),
      );
    }
    if (data.containsKey('product_used')) {
      context.handle(
        _productUsedMeta,
        productUsed.isAcceptableOrUnknown(
          data['product_used']!,
          _productUsedMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('step_snapshot')) {
      context.handle(
        _stepSnapshotMeta,
        stepSnapshot.isAcceptableOrUnknown(
          data['step_snapshot']!,
          _stepSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('programme_content_hash')) {
      context.handle(
        _programmeContentHashMeta,
        programmeContentHash.isAcceptableOrUnknown(
          data['programme_content_hash']!,
          _programmeContentHashMeta,
        ),
      );
    }
    if (data.containsKey('shifted_from')) {
      context.handle(
        _shiftedFromMeta,
        shiftedFrom.isAcceptableOrUnknown(
          data['shifted_from']!,
          _shiftedFromMeta,
        ),
      );
    }
    if (data.containsKey('deleted_group_id')) {
      context.handle(
        _deletedGroupIdMeta,
        deletedGroupId.isAcceptableOrUnknown(
          data['deleted_group_id']!,
          _deletedGroupIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaccinationTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaccinationTaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      stepId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_id'],
      )!,
      occurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurrence'],
      )!,
      dueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_on'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      doneOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}done_on'],
      ),
      doneBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}done_by'],
      ),
      productUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_used'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      stepSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_snapshot'],
      ),
      programmeContentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}programme_content_hash'],
      ),
      shiftedFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}shifted_from'],
      ),
      deletedGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_group_id'],
      ),
    );
  }

  @override
  $VaccinationTasksTable createAlias(String alias) {
    return $VaccinationTasksTable(attachedDatabase, alias);
  }
}

class VaccinationTaskRow extends DataClass
    implements Insertable<VaccinationTaskRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String batchId;
  final String stepId;
  final int occurrence;
  final DateTime dueOn;
  final bool enabled;
  final String status;
  final DateTime? doneOn;
  final String? doneBy;
  final String? productUsed;
  final String? notes;
  final String? stepSnapshot;
  final String? programmeContentHash;
  final DateTime? shiftedFrom;
  final String? deletedGroupId;
  const VaccinationTaskRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.batchId,
    required this.stepId,
    required this.occurrence,
    required this.dueOn,
    required this.enabled,
    required this.status,
    this.doneOn,
    this.doneBy,
    this.productUsed,
    this.notes,
    this.stepSnapshot,
    this.programmeContentHash,
    this.shiftedFrom,
    this.deletedGroupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['batch_id'] = Variable<String>(batchId);
    map['step_id'] = Variable<String>(stepId);
    map['occurrence'] = Variable<int>(occurrence);
    map['due_on'] = Variable<DateTime>(dueOn);
    map['enabled'] = Variable<bool>(enabled);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || doneOn != null) {
      map['done_on'] = Variable<DateTime>(doneOn);
    }
    if (!nullToAbsent || doneBy != null) {
      map['done_by'] = Variable<String>(doneBy);
    }
    if (!nullToAbsent || productUsed != null) {
      map['product_used'] = Variable<String>(productUsed);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || stepSnapshot != null) {
      map['step_snapshot'] = Variable<String>(stepSnapshot);
    }
    if (!nullToAbsent || programmeContentHash != null) {
      map['programme_content_hash'] = Variable<String>(programmeContentHash);
    }
    if (!nullToAbsent || shiftedFrom != null) {
      map['shifted_from'] = Variable<DateTime>(shiftedFrom);
    }
    if (!nullToAbsent || deletedGroupId != null) {
      map['deleted_group_id'] = Variable<String>(deletedGroupId);
    }
    return map;
  }

  VaccinationTasksCompanion toCompanion(bool nullToAbsent) {
    return VaccinationTasksCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      batchId: Value(batchId),
      stepId: Value(stepId),
      occurrence: Value(occurrence),
      dueOn: Value(dueOn),
      enabled: Value(enabled),
      status: Value(status),
      doneOn: doneOn == null && nullToAbsent
          ? const Value.absent()
          : Value(doneOn),
      doneBy: doneBy == null && nullToAbsent
          ? const Value.absent()
          : Value(doneBy),
      productUsed: productUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(productUsed),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      stepSnapshot: stepSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(stepSnapshot),
      programmeContentHash: programmeContentHash == null && nullToAbsent
          ? const Value.absent()
          : Value(programmeContentHash),
      shiftedFrom: shiftedFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftedFrom),
      deletedGroupId: deletedGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedGroupId),
    );
  }

  factory VaccinationTaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaccinationTaskRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      batchId: serializer.fromJson<String>(json['batchId']),
      stepId: serializer.fromJson<String>(json['stepId']),
      occurrence: serializer.fromJson<int>(json['occurrence']),
      dueOn: serializer.fromJson<DateTime>(json['dueOn']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      status: serializer.fromJson<String>(json['status']),
      doneOn: serializer.fromJson<DateTime?>(json['doneOn']),
      doneBy: serializer.fromJson<String?>(json['doneBy']),
      productUsed: serializer.fromJson<String?>(json['productUsed']),
      notes: serializer.fromJson<String?>(json['notes']),
      stepSnapshot: serializer.fromJson<String?>(json['stepSnapshot']),
      programmeContentHash: serializer.fromJson<String?>(
        json['programmeContentHash'],
      ),
      shiftedFrom: serializer.fromJson<DateTime?>(json['shiftedFrom']),
      deletedGroupId: serializer.fromJson<String?>(json['deletedGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'batchId': serializer.toJson<String>(batchId),
      'stepId': serializer.toJson<String>(stepId),
      'occurrence': serializer.toJson<int>(occurrence),
      'dueOn': serializer.toJson<DateTime>(dueOn),
      'enabled': serializer.toJson<bool>(enabled),
      'status': serializer.toJson<String>(status),
      'doneOn': serializer.toJson<DateTime?>(doneOn),
      'doneBy': serializer.toJson<String?>(doneBy),
      'productUsed': serializer.toJson<String?>(productUsed),
      'notes': serializer.toJson<String?>(notes),
      'stepSnapshot': serializer.toJson<String?>(stepSnapshot),
      'programmeContentHash': serializer.toJson<String?>(programmeContentHash),
      'shiftedFrom': serializer.toJson<DateTime?>(shiftedFrom),
      'deletedGroupId': serializer.toJson<String?>(deletedGroupId),
    };
  }

  VaccinationTaskRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? batchId,
    String? stepId,
    int? occurrence,
    DateTime? dueOn,
    bool? enabled,
    String? status,
    Value<DateTime?> doneOn = const Value.absent(),
    Value<String?> doneBy = const Value.absent(),
    Value<String?> productUsed = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> stepSnapshot = const Value.absent(),
    Value<String?> programmeContentHash = const Value.absent(),
    Value<DateTime?> shiftedFrom = const Value.absent(),
    Value<String?> deletedGroupId = const Value.absent(),
  }) => VaccinationTaskRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    batchId: batchId ?? this.batchId,
    stepId: stepId ?? this.stepId,
    occurrence: occurrence ?? this.occurrence,
    dueOn: dueOn ?? this.dueOn,
    enabled: enabled ?? this.enabled,
    status: status ?? this.status,
    doneOn: doneOn.present ? doneOn.value : this.doneOn,
    doneBy: doneBy.present ? doneBy.value : this.doneBy,
    productUsed: productUsed.present ? productUsed.value : this.productUsed,
    notes: notes.present ? notes.value : this.notes,
    stepSnapshot: stepSnapshot.present ? stepSnapshot.value : this.stepSnapshot,
    programmeContentHash: programmeContentHash.present
        ? programmeContentHash.value
        : this.programmeContentHash,
    shiftedFrom: shiftedFrom.present ? shiftedFrom.value : this.shiftedFrom,
    deletedGroupId: deletedGroupId.present
        ? deletedGroupId.value
        : this.deletedGroupId,
  );
  VaccinationTaskRow copyWithCompanion(VaccinationTasksCompanion data) {
    return VaccinationTaskRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      stepId: data.stepId.present ? data.stepId.value : this.stepId,
      occurrence: data.occurrence.present
          ? data.occurrence.value
          : this.occurrence,
      dueOn: data.dueOn.present ? data.dueOn.value : this.dueOn,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      status: data.status.present ? data.status.value : this.status,
      doneOn: data.doneOn.present ? data.doneOn.value : this.doneOn,
      doneBy: data.doneBy.present ? data.doneBy.value : this.doneBy,
      productUsed: data.productUsed.present
          ? data.productUsed.value
          : this.productUsed,
      notes: data.notes.present ? data.notes.value : this.notes,
      stepSnapshot: data.stepSnapshot.present
          ? data.stepSnapshot.value
          : this.stepSnapshot,
      programmeContentHash: data.programmeContentHash.present
          ? data.programmeContentHash.value
          : this.programmeContentHash,
      shiftedFrom: data.shiftedFrom.present
          ? data.shiftedFrom.value
          : this.shiftedFrom,
      deletedGroupId: data.deletedGroupId.present
          ? data.deletedGroupId.value
          : this.deletedGroupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationTaskRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('batchId: $batchId, ')
          ..write('stepId: $stepId, ')
          ..write('occurrence: $occurrence, ')
          ..write('dueOn: $dueOn, ')
          ..write('enabled: $enabled, ')
          ..write('status: $status, ')
          ..write('doneOn: $doneOn, ')
          ..write('doneBy: $doneBy, ')
          ..write('productUsed: $productUsed, ')
          ..write('notes: $notes, ')
          ..write('stepSnapshot: $stepSnapshot, ')
          ..write('programmeContentHash: $programmeContentHash, ')
          ..write('shiftedFrom: $shiftedFrom, ')
          ..write('deletedGroupId: $deletedGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    batchId,
    stepId,
    occurrence,
    dueOn,
    enabled,
    status,
    doneOn,
    doneBy,
    productUsed,
    notes,
    stepSnapshot,
    programmeContentHash,
    shiftedFrom,
    deletedGroupId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaccinationTaskRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.batchId == this.batchId &&
          other.stepId == this.stepId &&
          other.occurrence == this.occurrence &&
          other.dueOn == this.dueOn &&
          other.enabled == this.enabled &&
          other.status == this.status &&
          other.doneOn == this.doneOn &&
          other.doneBy == this.doneBy &&
          other.productUsed == this.productUsed &&
          other.notes == this.notes &&
          other.stepSnapshot == this.stepSnapshot &&
          other.programmeContentHash == this.programmeContentHash &&
          other.shiftedFrom == this.shiftedFrom &&
          other.deletedGroupId == this.deletedGroupId);
}

class VaccinationTasksCompanion extends UpdateCompanion<VaccinationTaskRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> batchId;
  final Value<String> stepId;
  final Value<int> occurrence;
  final Value<DateTime> dueOn;
  final Value<bool> enabled;
  final Value<String> status;
  final Value<DateTime?> doneOn;
  final Value<String?> doneBy;
  final Value<String?> productUsed;
  final Value<String?> notes;
  final Value<String?> stepSnapshot;
  final Value<String?> programmeContentHash;
  final Value<DateTime?> shiftedFrom;
  final Value<String?> deletedGroupId;
  final Value<int> rowid;
  const VaccinationTasksCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.batchId = const Value.absent(),
    this.stepId = const Value.absent(),
    this.occurrence = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.enabled = const Value.absent(),
    this.status = const Value.absent(),
    this.doneOn = const Value.absent(),
    this.doneBy = const Value.absent(),
    this.productUsed = const Value.absent(),
    this.notes = const Value.absent(),
    this.stepSnapshot = const Value.absent(),
    this.programmeContentHash = const Value.absent(),
    this.shiftedFrom = const Value.absent(),
    this.deletedGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaccinationTasksCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String batchId,
    required String stepId,
    this.occurrence = const Value.absent(),
    required DateTime dueOn,
    this.enabled = const Value.absent(),
    required String status,
    this.doneOn = const Value.absent(),
    this.doneBy = const Value.absent(),
    this.productUsed = const Value.absent(),
    this.notes = const Value.absent(),
    this.stepSnapshot = const Value.absent(),
    this.programmeContentHash = const Value.absent(),
    this.shiftedFrom = const Value.absent(),
    this.deletedGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       batchId = Value(batchId),
       stepId = Value(stepId),
       dueOn = Value(dueOn),
       status = Value(status);
  static Insertable<VaccinationTaskRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? batchId,
    Expression<String>? stepId,
    Expression<int>? occurrence,
    Expression<DateTime>? dueOn,
    Expression<bool>? enabled,
    Expression<String>? status,
    Expression<DateTime>? doneOn,
    Expression<String>? doneBy,
    Expression<String>? productUsed,
    Expression<String>? notes,
    Expression<String>? stepSnapshot,
    Expression<String>? programmeContentHash,
    Expression<DateTime>? shiftedFrom,
    Expression<String>? deletedGroupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (batchId != null) 'batch_id': batchId,
      if (stepId != null) 'step_id': stepId,
      if (occurrence != null) 'occurrence': occurrence,
      if (dueOn != null) 'due_on': dueOn,
      if (enabled != null) 'enabled': enabled,
      if (status != null) 'status': status,
      if (doneOn != null) 'done_on': doneOn,
      if (doneBy != null) 'done_by': doneBy,
      if (productUsed != null) 'product_used': productUsed,
      if (notes != null) 'notes': notes,
      if (stepSnapshot != null) 'step_snapshot': stepSnapshot,
      if (programmeContentHash != null)
        'programme_content_hash': programmeContentHash,
      if (shiftedFrom != null) 'shifted_from': shiftedFrom,
      if (deletedGroupId != null) 'deleted_group_id': deletedGroupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaccinationTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? batchId,
    Value<String>? stepId,
    Value<int>? occurrence,
    Value<DateTime>? dueOn,
    Value<bool>? enabled,
    Value<String>? status,
    Value<DateTime?>? doneOn,
    Value<String?>? doneBy,
    Value<String?>? productUsed,
    Value<String?>? notes,
    Value<String?>? stepSnapshot,
    Value<String?>? programmeContentHash,
    Value<DateTime?>? shiftedFrom,
    Value<String?>? deletedGroupId,
    Value<int>? rowid,
  }) {
    return VaccinationTasksCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      batchId: batchId ?? this.batchId,
      stepId: stepId ?? this.stepId,
      occurrence: occurrence ?? this.occurrence,
      dueOn: dueOn ?? this.dueOn,
      enabled: enabled ?? this.enabled,
      status: status ?? this.status,
      doneOn: doneOn ?? this.doneOn,
      doneBy: doneBy ?? this.doneBy,
      productUsed: productUsed ?? this.productUsed,
      notes: notes ?? this.notes,
      stepSnapshot: stepSnapshot ?? this.stepSnapshot,
      programmeContentHash: programmeContentHash ?? this.programmeContentHash,
      shiftedFrom: shiftedFrom ?? this.shiftedFrom,
      deletedGroupId: deletedGroupId ?? this.deletedGroupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (stepId.present) {
      map['step_id'] = Variable<String>(stepId.value);
    }
    if (occurrence.present) {
      map['occurrence'] = Variable<int>(occurrence.value);
    }
    if (dueOn.present) {
      map['due_on'] = Variable<DateTime>(dueOn.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (doneOn.present) {
      map['done_on'] = Variable<DateTime>(doneOn.value);
    }
    if (doneBy.present) {
      map['done_by'] = Variable<String>(doneBy.value);
    }
    if (productUsed.present) {
      map['product_used'] = Variable<String>(productUsed.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (stepSnapshot.present) {
      map['step_snapshot'] = Variable<String>(stepSnapshot.value);
    }
    if (programmeContentHash.present) {
      map['programme_content_hash'] = Variable<String>(
        programmeContentHash.value,
      );
    }
    if (shiftedFrom.present) {
      map['shifted_from'] = Variable<DateTime>(shiftedFrom.value);
    }
    if (deletedGroupId.present) {
      map['deleted_group_id'] = Variable<String>(deletedGroupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationTasksCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('batchId: $batchId, ')
          ..write('stepId: $stepId, ')
          ..write('occurrence: $occurrence, ')
          ..write('dueOn: $dueOn, ')
          ..write('enabled: $enabled, ')
          ..write('status: $status, ')
          ..write('doneOn: $doneOn, ')
          ..write('doneBy: $doneBy, ')
          ..write('productUsed: $productUsed, ')
          ..write('notes: $notes, ')
          ..write('stepSnapshot: $stepSnapshot, ')
          ..write('programmeContentHash: $programmeContentHash, ')
          ..write('shiftedFrom: $shiftedFrom, ')
          ..write('deletedGroupId: $deletedGroupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedItemsTable extends FeedItems
    with TableInfo<$FeedItemsTable, FeedItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedTypeMeta = const VerificationMeta(
    'feedType',
  );
  @override
  late final GeneratedColumn<String> feedType = GeneratedColumn<String>(
    'feed_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reorderLevelMeta = const VerificationMeta(
    'reorderLevel',
  );
  @override
  late final GeneratedColumn<double> reorderLevel = GeneratedColumn<double>(
    'reorder_level',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    name,
    feedType,
    unit,
    reorderLevel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('feed_type')) {
      context.handle(
        _feedTypeMeta,
        feedType.isAcceptableOrUnknown(data['feed_type']!, _feedTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_feedTypeMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
        _reorderLevelMeta,
        reorderLevel.isAcceptableOrUnknown(
          data['reorder_level']!,
          _reorderLevelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      feedType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_type'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      reorderLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reorder_level'],
      ),
    );
  }

  @override
  $FeedItemsTable createAlias(String alias) {
    return $FeedItemsTable(attachedDatabase, alias);
  }
}

class FeedItemRow extends DataClass implements Insertable<FeedItemRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String name;
  final String feedType;
  final String unit;
  final double? reorderLevel;
  const FeedItemRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.name,
    required this.feedType,
    required this.unit,
    this.reorderLevel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['name'] = Variable<String>(name);
    map['feed_type'] = Variable<String>(feedType);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || reorderLevel != null) {
      map['reorder_level'] = Variable<double>(reorderLevel);
    }
    return map;
  }

  FeedItemsCompanion toCompanion(bool nullToAbsent) {
    return FeedItemsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      name: Value(name),
      feedType: Value(feedType),
      unit: Value(unit),
      reorderLevel: reorderLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(reorderLevel),
    );
  }

  factory FeedItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedItemRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      name: serializer.fromJson<String>(json['name']),
      feedType: serializer.fromJson<String>(json['feedType']),
      unit: serializer.fromJson<String>(json['unit']),
      reorderLevel: serializer.fromJson<double?>(json['reorderLevel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'name': serializer.toJson<String>(name),
      'feedType': serializer.toJson<String>(feedType),
      'unit': serializer.toJson<String>(unit),
      'reorderLevel': serializer.toJson<double?>(reorderLevel),
    };
  }

  FeedItemRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? name,
    String? feedType,
    String? unit,
    Value<double?> reorderLevel = const Value.absent(),
  }) => FeedItemRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    name: name ?? this.name,
    feedType: feedType ?? this.feedType,
    unit: unit ?? this.unit,
    reorderLevel: reorderLevel.present ? reorderLevel.value : this.reorderLevel,
  );
  FeedItemRow copyWithCompanion(FeedItemsCompanion data) {
    return FeedItemRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      name: data.name.present ? data.name.value : this.name,
      feedType: data.feedType.present ? data.feedType.value : this.feedType,
      unit: data.unit.present ? data.unit.value : this.unit,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedItemRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('name: $name, ')
          ..write('feedType: $feedType, ')
          ..write('unit: $unit, ')
          ..write('reorderLevel: $reorderLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    name,
    feedType,
    unit,
    reorderLevel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedItemRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.name == this.name &&
          other.feedType == this.feedType &&
          other.unit == this.unit &&
          other.reorderLevel == this.reorderLevel);
}

class FeedItemsCompanion extends UpdateCompanion<FeedItemRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> name;
  final Value<String> feedType;
  final Value<String> unit;
  final Value<double?> reorderLevel;
  final Value<int> rowid;
  const FeedItemsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.name = const Value.absent(),
    this.feedType = const Value.absent(),
    this.unit = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedItemsCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String name,
    required String feedType,
    required String unit,
    this.reorderLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       feedType = Value(feedType),
       unit = Value(unit);
  static Insertable<FeedItemRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? name,
    Expression<String>? feedType,
    Expression<String>? unit,
    Expression<double>? reorderLevel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (name != null) 'name': name,
      if (feedType != null) 'feed_type': feedType,
      if (unit != null) 'unit': unit,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? name,
    Value<String>? feedType,
    Value<String>? unit,
    Value<double?>? reorderLevel,
    Value<int>? rowid,
  }) {
    return FeedItemsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      name: name ?? this.name,
      feedType: feedType ?? this.feedType,
      unit: unit ?? this.unit,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (feedType.present) {
      map['feed_type'] = Variable<String>(feedType.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<double>(reorderLevel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedItemsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('name: $name, ')
          ..write('feedType: $feedType, ')
          ..write('unit: $unit, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedTransactionsTable extends FeedTransactions
    with TableInfo<$FeedTransactionsTable, FeedTransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feedItemIdMeta = const VerificationMeta(
    'feedItemId',
  );
  @override
  late final GeneratedColumn<String> feedItemId = GeneratedColumn<String>(
    'feed_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
    'unit_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredOnMeta = const VerificationMeta(
    'occurredOn',
  );
  @override
  late final GeneratedColumn<DateTime> occurredOn = GeneratedColumn<DateTime>(
    'occurred_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    feedItemId,
    batchId,
    kind,
    quantity,
    unitCost,
    occurredOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedTransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('feed_item_id')) {
      context.handle(
        _feedItemIdMeta,
        feedItemId.isAcceptableOrUnknown(
          data['feed_item_id']!,
          _feedItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_feedItemIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    }
    if (data.containsKey('occurred_on')) {
      context.handle(
        _occurredOnMeta,
        occurredOn.isAcceptableOrUnknown(data['occurred_on']!, _occurredOnMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredOnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedTransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedTransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      feedItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_item_id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_cost'],
      ),
      occurredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_on'],
      )!,
    );
  }

  @override
  $FeedTransactionsTable createAlias(String alias) {
    return $FeedTransactionsTable(attachedDatabase, alias);
  }
}

class FeedTransactionRow extends DataClass
    implements Insertable<FeedTransactionRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String feedItemId;
  final String? batchId;
  final String kind;
  final double quantity;
  final double? unitCost;
  final DateTime occurredOn;
  const FeedTransactionRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.feedItemId,
    this.batchId,
    required this.kind,
    required this.quantity,
    this.unitCost,
    required this.occurredOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['feed_item_id'] = Variable<String>(feedItemId);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    map['kind'] = Variable<String>(kind);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || unitCost != null) {
      map['unit_cost'] = Variable<double>(unitCost);
    }
    map['occurred_on'] = Variable<DateTime>(occurredOn);
    return map;
  }

  FeedTransactionsCompanion toCompanion(bool nullToAbsent) {
    return FeedTransactionsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      feedItemId: Value(feedItemId),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      kind: Value(kind),
      quantity: Value(quantity),
      unitCost: unitCost == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCost),
      occurredOn: Value(occurredOn),
    );
  }

  factory FeedTransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedTransactionRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      feedItemId: serializer.fromJson<String>(json['feedItemId']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      kind: serializer.fromJson<String>(json['kind']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitCost: serializer.fromJson<double?>(json['unitCost']),
      occurredOn: serializer.fromJson<DateTime>(json['occurredOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'feedItemId': serializer.toJson<String>(feedItemId),
      'batchId': serializer.toJson<String?>(batchId),
      'kind': serializer.toJson<String>(kind),
      'quantity': serializer.toJson<double>(quantity),
      'unitCost': serializer.toJson<double?>(unitCost),
      'occurredOn': serializer.toJson<DateTime>(occurredOn),
    };
  }

  FeedTransactionRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? feedItemId,
    Value<String?> batchId = const Value.absent(),
    String? kind,
    double? quantity,
    Value<double?> unitCost = const Value.absent(),
    DateTime? occurredOn,
  }) => FeedTransactionRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    feedItemId: feedItemId ?? this.feedItemId,
    batchId: batchId.present ? batchId.value : this.batchId,
    kind: kind ?? this.kind,
    quantity: quantity ?? this.quantity,
    unitCost: unitCost.present ? unitCost.value : this.unitCost,
    occurredOn: occurredOn ?? this.occurredOn,
  );
  FeedTransactionRow copyWithCompanion(FeedTransactionsCompanion data) {
    return FeedTransactionRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      feedItemId: data.feedItemId.present
          ? data.feedItemId.value
          : this.feedItemId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      kind: data.kind.present ? data.kind.value : this.kind,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      occurredOn: data.occurredOn.present
          ? data.occurredOn.value
          : this.occurredOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedTransactionRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('feedItemId: $feedItemId, ')
          ..write('batchId: $batchId, ')
          ..write('kind: $kind, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('occurredOn: $occurredOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    feedItemId,
    batchId,
    kind,
    quantity,
    unitCost,
    occurredOn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedTransactionRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.feedItemId == this.feedItemId &&
          other.batchId == this.batchId &&
          other.kind == this.kind &&
          other.quantity == this.quantity &&
          other.unitCost == this.unitCost &&
          other.occurredOn == this.occurredOn);
}

class FeedTransactionsCompanion extends UpdateCompanion<FeedTransactionRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> feedItemId;
  final Value<String?> batchId;
  final Value<String> kind;
  final Value<double> quantity;
  final Value<double?> unitCost;
  final Value<DateTime> occurredOn;
  final Value<int> rowid;
  const FeedTransactionsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.feedItemId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.kind = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.occurredOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedTransactionsCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String feedItemId,
    this.batchId = const Value.absent(),
    required String kind,
    required double quantity,
    this.unitCost = const Value.absent(),
    required DateTime occurredOn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       feedItemId = Value(feedItemId),
       kind = Value(kind),
       quantity = Value(quantity),
       occurredOn = Value(occurredOn);
  static Insertable<FeedTransactionRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? feedItemId,
    Expression<String>? batchId,
    Expression<String>? kind,
    Expression<double>? quantity,
    Expression<double>? unitCost,
    Expression<DateTime>? occurredOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (feedItemId != null) 'feed_item_id': feedItemId,
      if (batchId != null) 'batch_id': batchId,
      if (kind != null) 'kind': kind,
      if (quantity != null) 'quantity': quantity,
      if (unitCost != null) 'unit_cost': unitCost,
      if (occurredOn != null) 'occurred_on': occurredOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? feedItemId,
    Value<String?>? batchId,
    Value<String>? kind,
    Value<double>? quantity,
    Value<double?>? unitCost,
    Value<DateTime>? occurredOn,
    Value<int>? rowid,
  }) {
    return FeedTransactionsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      feedItemId: feedItemId ?? this.feedItemId,
      batchId: batchId ?? this.batchId,
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      occurredOn: occurredOn ?? this.occurredOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (feedItemId.present) {
      map['feed_item_id'] = Variable<String>(feedItemId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (occurredOn.present) {
      map['occurred_on'] = Variable<DateTime>(occurredOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('feedItemId: $feedItemId, ')
          ..write('batchId: $batchId, ')
          ..write('kind: $kind, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HealthRecordsTable extends HealthRecords
    with TableInfo<$HealthRecordsTable, HealthRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredOnMeta = const VerificationMeta(
    'occurredOn',
  );
  @override
  late final GeneratedColumn<DateTime> occurredOn = GeneratedColumn<DateTime>(
    'occurred_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _affectedBirdCountMeta = const VerificationMeta(
    'affectedBirdCount',
  );
  @override
  late final GeneratedColumn<int> affectedBirdCount = GeneratedColumn<int>(
    'affected_bird_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _symptomsJsonMeta = const VerificationMeta(
    'symptomsJson',
  );
  @override
  late final GeneratedColumn<String> symptomsJson = GeneratedColumn<String>(
    'symptoms_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _recordKindMeta = const VerificationMeta(
    'recordKind',
  );
  @override
  late final GeneratedColumn<String> recordKind = GeneratedColumn<String>(
    'record_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('observation'),
  );
  static const VerificationMeta _photoObjectKeysJsonMeta =
      const VerificationMeta('photoObjectKeysJson');
  @override
  late final GeneratedColumn<String> photoObjectKeysJson =
      GeneratedColumn<String>(
        'photo_object_keys_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _pendingPhotoPathsJsonMeta =
      const VerificationMeta('pendingPhotoPathsJson');
  @override
  late final GeneratedColumn<String> pendingPhotoPathsJson =
      GeneratedColumn<String>(
        'pending_photo_paths_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    batchId,
    occurredOn,
    summary,
    notes,
    affectedBirdCount,
    symptomsJson,
    recordKind,
    photoObjectKeysJson,
    pendingPhotoPathsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('occurred_on')) {
      context.handle(
        _occurredOnMeta,
        occurredOn.isAcceptableOrUnknown(data['occurred_on']!, _occurredOnMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredOnMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('affected_bird_count')) {
      context.handle(
        _affectedBirdCountMeta,
        affectedBirdCount.isAcceptableOrUnknown(
          data['affected_bird_count']!,
          _affectedBirdCountMeta,
        ),
      );
    }
    if (data.containsKey('symptoms_json')) {
      context.handle(
        _symptomsJsonMeta,
        symptomsJson.isAcceptableOrUnknown(
          data['symptoms_json']!,
          _symptomsJsonMeta,
        ),
      );
    }
    if (data.containsKey('record_kind')) {
      context.handle(
        _recordKindMeta,
        recordKind.isAcceptableOrUnknown(data['record_kind']!, _recordKindMeta),
      );
    }
    if (data.containsKey('photo_object_keys_json')) {
      context.handle(
        _photoObjectKeysJsonMeta,
        photoObjectKeysJson.isAcceptableOrUnknown(
          data['photo_object_keys_json']!,
          _photoObjectKeysJsonMeta,
        ),
      );
    }
    if (data.containsKey('pending_photo_paths_json')) {
      context.handle(
        _pendingPhotoPathsJsonMeta,
        pendingPhotoPathsJson.isAcceptableOrUnknown(
          data['pending_photo_paths_json']!,
          _pendingPhotoPathsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HealthRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      occurredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_on'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      affectedBirdCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}affected_bird_count'],
      ),
      symptomsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms_json'],
      )!,
      recordKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_kind'],
      )!,
      photoObjectKeysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_object_keys_json'],
      )!,
      pendingPhotoPathsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_photo_paths_json'],
      )!,
    );
  }

  @override
  $HealthRecordsTable createAlias(String alias) {
    return $HealthRecordsTable(attachedDatabase, alias);
  }
}

class HealthRecordRow extends DataClass implements Insertable<HealthRecordRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String batchId;
  final DateTime occurredOn;
  final String summary;
  final String? notes;
  final int? affectedBirdCount;
  final String symptomsJson;
  final String recordKind;
  final String photoObjectKeysJson;

  /// Local filesystem paths awaiting upload (not synced to server).
  final String pendingPhotoPathsJson;
  const HealthRecordRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.batchId,
    required this.occurredOn,
    required this.summary,
    this.notes,
    this.affectedBirdCount,
    required this.symptomsJson,
    required this.recordKind,
    required this.photoObjectKeysJson,
    required this.pendingPhotoPathsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['batch_id'] = Variable<String>(batchId);
    map['occurred_on'] = Variable<DateTime>(occurredOn);
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || affectedBirdCount != null) {
      map['affected_bird_count'] = Variable<int>(affectedBirdCount);
    }
    map['symptoms_json'] = Variable<String>(symptomsJson);
    map['record_kind'] = Variable<String>(recordKind);
    map['photo_object_keys_json'] = Variable<String>(photoObjectKeysJson);
    map['pending_photo_paths_json'] = Variable<String>(pendingPhotoPathsJson);
    return map;
  }

  HealthRecordsCompanion toCompanion(bool nullToAbsent) {
    return HealthRecordsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      batchId: Value(batchId),
      occurredOn: Value(occurredOn),
      summary: Value(summary),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      affectedBirdCount: affectedBirdCount == null && nullToAbsent
          ? const Value.absent()
          : Value(affectedBirdCount),
      symptomsJson: Value(symptomsJson),
      recordKind: Value(recordKind),
      photoObjectKeysJson: Value(photoObjectKeysJson),
      pendingPhotoPathsJson: Value(pendingPhotoPathsJson),
    );
  }

  factory HealthRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthRecordRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      batchId: serializer.fromJson<String>(json['batchId']),
      occurredOn: serializer.fromJson<DateTime>(json['occurredOn']),
      summary: serializer.fromJson<String>(json['summary']),
      notes: serializer.fromJson<String?>(json['notes']),
      affectedBirdCount: serializer.fromJson<int?>(json['affectedBirdCount']),
      symptomsJson: serializer.fromJson<String>(json['symptomsJson']),
      recordKind: serializer.fromJson<String>(json['recordKind']),
      photoObjectKeysJson: serializer.fromJson<String>(
        json['photoObjectKeysJson'],
      ),
      pendingPhotoPathsJson: serializer.fromJson<String>(
        json['pendingPhotoPathsJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'batchId': serializer.toJson<String>(batchId),
      'occurredOn': serializer.toJson<DateTime>(occurredOn),
      'summary': serializer.toJson<String>(summary),
      'notes': serializer.toJson<String?>(notes),
      'affectedBirdCount': serializer.toJson<int?>(affectedBirdCount),
      'symptomsJson': serializer.toJson<String>(symptomsJson),
      'recordKind': serializer.toJson<String>(recordKind),
      'photoObjectKeysJson': serializer.toJson<String>(photoObjectKeysJson),
      'pendingPhotoPathsJson': serializer.toJson<String>(pendingPhotoPathsJson),
    };
  }

  HealthRecordRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? batchId,
    DateTime? occurredOn,
    String? summary,
    Value<String?> notes = const Value.absent(),
    Value<int?> affectedBirdCount = const Value.absent(),
    String? symptomsJson,
    String? recordKind,
    String? photoObjectKeysJson,
    String? pendingPhotoPathsJson,
  }) => HealthRecordRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    batchId: batchId ?? this.batchId,
    occurredOn: occurredOn ?? this.occurredOn,
    summary: summary ?? this.summary,
    notes: notes.present ? notes.value : this.notes,
    affectedBirdCount: affectedBirdCount.present
        ? affectedBirdCount.value
        : this.affectedBirdCount,
    symptomsJson: symptomsJson ?? this.symptomsJson,
    recordKind: recordKind ?? this.recordKind,
    photoObjectKeysJson: photoObjectKeysJson ?? this.photoObjectKeysJson,
    pendingPhotoPathsJson: pendingPhotoPathsJson ?? this.pendingPhotoPathsJson,
  );
  HealthRecordRow copyWithCompanion(HealthRecordsCompanion data) {
    return HealthRecordRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      occurredOn: data.occurredOn.present
          ? data.occurredOn.value
          : this.occurredOn,
      summary: data.summary.present ? data.summary.value : this.summary,
      notes: data.notes.present ? data.notes.value : this.notes,
      affectedBirdCount: data.affectedBirdCount.present
          ? data.affectedBirdCount.value
          : this.affectedBirdCount,
      symptomsJson: data.symptomsJson.present
          ? data.symptomsJson.value
          : this.symptomsJson,
      recordKind: data.recordKind.present
          ? data.recordKind.value
          : this.recordKind,
      photoObjectKeysJson: data.photoObjectKeysJson.present
          ? data.photoObjectKeysJson.value
          : this.photoObjectKeysJson,
      pendingPhotoPathsJson: data.pendingPhotoPathsJson.present
          ? data.pendingPhotoPathsJson.value
          : this.pendingPhotoPathsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthRecordRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('batchId: $batchId, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('summary: $summary, ')
          ..write('notes: $notes, ')
          ..write('affectedBirdCount: $affectedBirdCount, ')
          ..write('symptomsJson: $symptomsJson, ')
          ..write('recordKind: $recordKind, ')
          ..write('photoObjectKeysJson: $photoObjectKeysJson, ')
          ..write('pendingPhotoPathsJson: $pendingPhotoPathsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    batchId,
    occurredOn,
    summary,
    notes,
    affectedBirdCount,
    symptomsJson,
    recordKind,
    photoObjectKeysJson,
    pendingPhotoPathsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthRecordRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.batchId == this.batchId &&
          other.occurredOn == this.occurredOn &&
          other.summary == this.summary &&
          other.notes == this.notes &&
          other.affectedBirdCount == this.affectedBirdCount &&
          other.symptomsJson == this.symptomsJson &&
          other.recordKind == this.recordKind &&
          other.photoObjectKeysJson == this.photoObjectKeysJson &&
          other.pendingPhotoPathsJson == this.pendingPhotoPathsJson);
}

class HealthRecordsCompanion extends UpdateCompanion<HealthRecordRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> batchId;
  final Value<DateTime> occurredOn;
  final Value<String> summary;
  final Value<String?> notes;
  final Value<int?> affectedBirdCount;
  final Value<String> symptomsJson;
  final Value<String> recordKind;
  final Value<String> photoObjectKeysJson;
  final Value<String> pendingPhotoPathsJson;
  final Value<int> rowid;
  const HealthRecordsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.batchId = const Value.absent(),
    this.occurredOn = const Value.absent(),
    this.summary = const Value.absent(),
    this.notes = const Value.absent(),
    this.affectedBirdCount = const Value.absent(),
    this.symptomsJson = const Value.absent(),
    this.recordKind = const Value.absent(),
    this.photoObjectKeysJson = const Value.absent(),
    this.pendingPhotoPathsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HealthRecordsCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String batchId,
    required DateTime occurredOn,
    required String summary,
    this.notes = const Value.absent(),
    this.affectedBirdCount = const Value.absent(),
    this.symptomsJson = const Value.absent(),
    this.recordKind = const Value.absent(),
    this.photoObjectKeysJson = const Value.absent(),
    this.pendingPhotoPathsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       batchId = Value(batchId),
       occurredOn = Value(occurredOn),
       summary = Value(summary);
  static Insertable<HealthRecordRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? batchId,
    Expression<DateTime>? occurredOn,
    Expression<String>? summary,
    Expression<String>? notes,
    Expression<int>? affectedBirdCount,
    Expression<String>? symptomsJson,
    Expression<String>? recordKind,
    Expression<String>? photoObjectKeysJson,
    Expression<String>? pendingPhotoPathsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (batchId != null) 'batch_id': batchId,
      if (occurredOn != null) 'occurred_on': occurredOn,
      if (summary != null) 'summary': summary,
      if (notes != null) 'notes': notes,
      if (affectedBirdCount != null) 'affected_bird_count': affectedBirdCount,
      if (symptomsJson != null) 'symptoms_json': symptomsJson,
      if (recordKind != null) 'record_kind': recordKind,
      if (photoObjectKeysJson != null)
        'photo_object_keys_json': photoObjectKeysJson,
      if (pendingPhotoPathsJson != null)
        'pending_photo_paths_json': pendingPhotoPathsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HealthRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? batchId,
    Value<DateTime>? occurredOn,
    Value<String>? summary,
    Value<String?>? notes,
    Value<int?>? affectedBirdCount,
    Value<String>? symptomsJson,
    Value<String>? recordKind,
    Value<String>? photoObjectKeysJson,
    Value<String>? pendingPhotoPathsJson,
    Value<int>? rowid,
  }) {
    return HealthRecordsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      batchId: batchId ?? this.batchId,
      occurredOn: occurredOn ?? this.occurredOn,
      summary: summary ?? this.summary,
      notes: notes ?? this.notes,
      affectedBirdCount: affectedBirdCount ?? this.affectedBirdCount,
      symptomsJson: symptomsJson ?? this.symptomsJson,
      recordKind: recordKind ?? this.recordKind,
      photoObjectKeysJson: photoObjectKeysJson ?? this.photoObjectKeysJson,
      pendingPhotoPathsJson:
          pendingPhotoPathsJson ?? this.pendingPhotoPathsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (occurredOn.present) {
      map['occurred_on'] = Variable<DateTime>(occurredOn.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (affectedBirdCount.present) {
      map['affected_bird_count'] = Variable<int>(affectedBirdCount.value);
    }
    if (symptomsJson.present) {
      map['symptoms_json'] = Variable<String>(symptomsJson.value);
    }
    if (recordKind.present) {
      map['record_kind'] = Variable<String>(recordKind.value);
    }
    if (photoObjectKeysJson.present) {
      map['photo_object_keys_json'] = Variable<String>(
        photoObjectKeysJson.value,
      );
    }
    if (pendingPhotoPathsJson.present) {
      map['pending_photo_paths_json'] = Variable<String>(
        pendingPhotoPathsJson.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthRecordsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('batchId: $batchId, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('summary: $summary, ')
          ..write('notes: $notes, ')
          ..write('affectedBirdCount: $affectedBirdCount, ')
          ..write('symptomsJson: $symptomsJson, ')
          ..write('recordKind: $recordKind, ')
          ..write('photoObjectKeysJson: $photoObjectKeysJson, ')
          ..write('pendingPhotoPathsJson: $pendingPhotoPathsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MortalityRecordsTable extends MortalityRecords
    with TableInfo<$MortalityRecordsTable, MortalityRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MortalityRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('died'),
  );
  static const VerificationMeta _suspectedCauseMeta = const VerificationMeta(
    'suspectedCause',
  );
  @override
  late final GeneratedColumn<String> suspectedCause = GeneratedColumn<String>(
    'suspected_cause',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredOnMeta = const VerificationMeta(
    'occurredOn',
  );
  @override
  late final GeneratedColumn<DateTime> occurredOn = GeneratedColumn<DateTime>(
    'occurred_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedGroupIdMeta = const VerificationMeta(
    'deletedGroupId',
  );
  @override
  late final GeneratedColumn<String> deletedGroupId = GeneratedColumn<String>(
    'deleted_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    batchId,
    count,
    kind,
    suspectedCause,
    occurredOn,
    notes,
    editedAt,
    deletedGroupId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mortality_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MortalityRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('suspected_cause')) {
      context.handle(
        _suspectedCauseMeta,
        suspectedCause.isAcceptableOrUnknown(
          data['suspected_cause']!,
          _suspectedCauseMeta,
        ),
      );
    }
    if (data.containsKey('occurred_on')) {
      context.handle(
        _occurredOnMeta,
        occurredOn.isAcceptableOrUnknown(data['occurred_on']!, _occurredOnMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredOnMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    }
    if (data.containsKey('deleted_group_id')) {
      context.handle(
        _deletedGroupIdMeta,
        deletedGroupId.isAcceptableOrUnknown(
          data['deleted_group_id']!,
          _deletedGroupIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MortalityRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MortalityRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      suspectedCause: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suspected_cause'],
      ),
      occurredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_on'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edited_at'],
      ),
      deletedGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_group_id'],
      ),
    );
  }

  @override
  $MortalityRecordsTable createAlias(String alias) {
    return $MortalityRecordsTable(attachedDatabase, alias);
  }
}

class MortalityRecordRow extends DataClass
    implements Insertable<MortalityRecordRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String batchId;
  final int count;
  final String kind;
  final String? suspectedCause;
  final DateTime occurredOn;
  final String? notes;
  final DateTime? editedAt;
  final String? deletedGroupId;
  const MortalityRecordRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.batchId,
    required this.count,
    required this.kind,
    this.suspectedCause,
    required this.occurredOn,
    this.notes,
    this.editedAt,
    this.deletedGroupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['batch_id'] = Variable<String>(batchId);
    map['count'] = Variable<int>(count);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || suspectedCause != null) {
      map['suspected_cause'] = Variable<String>(suspectedCause);
    }
    map['occurred_on'] = Variable<DateTime>(occurredOn);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<DateTime>(editedAt);
    }
    if (!nullToAbsent || deletedGroupId != null) {
      map['deleted_group_id'] = Variable<String>(deletedGroupId);
    }
    return map;
  }

  MortalityRecordsCompanion toCompanion(bool nullToAbsent) {
    return MortalityRecordsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      batchId: Value(batchId),
      count: Value(count),
      kind: Value(kind),
      suspectedCause: suspectedCause == null && nullToAbsent
          ? const Value.absent()
          : Value(suspectedCause),
      occurredOn: Value(occurredOn),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
      deletedGroupId: deletedGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedGroupId),
    );
  }

  factory MortalityRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MortalityRecordRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      batchId: serializer.fromJson<String>(json['batchId']),
      count: serializer.fromJson<int>(json['count']),
      kind: serializer.fromJson<String>(json['kind']),
      suspectedCause: serializer.fromJson<String?>(json['suspectedCause']),
      occurredOn: serializer.fromJson<DateTime>(json['occurredOn']),
      notes: serializer.fromJson<String?>(json['notes']),
      editedAt: serializer.fromJson<DateTime?>(json['editedAt']),
      deletedGroupId: serializer.fromJson<String?>(json['deletedGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'batchId': serializer.toJson<String>(batchId),
      'count': serializer.toJson<int>(count),
      'kind': serializer.toJson<String>(kind),
      'suspectedCause': serializer.toJson<String?>(suspectedCause),
      'occurredOn': serializer.toJson<DateTime>(occurredOn),
      'notes': serializer.toJson<String?>(notes),
      'editedAt': serializer.toJson<DateTime?>(editedAt),
      'deletedGroupId': serializer.toJson<String?>(deletedGroupId),
    };
  }

  MortalityRecordRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? batchId,
    int? count,
    String? kind,
    Value<String?> suspectedCause = const Value.absent(),
    DateTime? occurredOn,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> editedAt = const Value.absent(),
    Value<String?> deletedGroupId = const Value.absent(),
  }) => MortalityRecordRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    batchId: batchId ?? this.batchId,
    count: count ?? this.count,
    kind: kind ?? this.kind,
    suspectedCause: suspectedCause.present
        ? suspectedCause.value
        : this.suspectedCause,
    occurredOn: occurredOn ?? this.occurredOn,
    notes: notes.present ? notes.value : this.notes,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
    deletedGroupId: deletedGroupId.present
        ? deletedGroupId.value
        : this.deletedGroupId,
  );
  MortalityRecordRow copyWithCompanion(MortalityRecordsCompanion data) {
    return MortalityRecordRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      count: data.count.present ? data.count.value : this.count,
      kind: data.kind.present ? data.kind.value : this.kind,
      suspectedCause: data.suspectedCause.present
          ? data.suspectedCause.value
          : this.suspectedCause,
      occurredOn: data.occurredOn.present
          ? data.occurredOn.value
          : this.occurredOn,
      notes: data.notes.present ? data.notes.value : this.notes,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      deletedGroupId: data.deletedGroupId.present
          ? data.deletedGroupId.value
          : this.deletedGroupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MortalityRecordRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('batchId: $batchId, ')
          ..write('count: $count, ')
          ..write('kind: $kind, ')
          ..write('suspectedCause: $suspectedCause, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('notes: $notes, ')
          ..write('editedAt: $editedAt, ')
          ..write('deletedGroupId: $deletedGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    batchId,
    count,
    kind,
    suspectedCause,
    occurredOn,
    notes,
    editedAt,
    deletedGroupId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MortalityRecordRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.batchId == this.batchId &&
          other.count == this.count &&
          other.kind == this.kind &&
          other.suspectedCause == this.suspectedCause &&
          other.occurredOn == this.occurredOn &&
          other.notes == this.notes &&
          other.editedAt == this.editedAt &&
          other.deletedGroupId == this.deletedGroupId);
}

class MortalityRecordsCompanion extends UpdateCompanion<MortalityRecordRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> batchId;
  final Value<int> count;
  final Value<String> kind;
  final Value<String?> suspectedCause;
  final Value<DateTime> occurredOn;
  final Value<String?> notes;
  final Value<DateTime?> editedAt;
  final Value<String?> deletedGroupId;
  final Value<int> rowid;
  const MortalityRecordsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.batchId = const Value.absent(),
    this.count = const Value.absent(),
    this.kind = const Value.absent(),
    this.suspectedCause = const Value.absent(),
    this.occurredOn = const Value.absent(),
    this.notes = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.deletedGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MortalityRecordsCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String batchId,
    required int count,
    this.kind = const Value.absent(),
    this.suspectedCause = const Value.absent(),
    required DateTime occurredOn,
    this.notes = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.deletedGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       batchId = Value(batchId),
       count = Value(count),
       occurredOn = Value(occurredOn);
  static Insertable<MortalityRecordRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? batchId,
    Expression<int>? count,
    Expression<String>? kind,
    Expression<String>? suspectedCause,
    Expression<DateTime>? occurredOn,
    Expression<String>? notes,
    Expression<DateTime>? editedAt,
    Expression<String>? deletedGroupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (batchId != null) 'batch_id': batchId,
      if (count != null) 'count': count,
      if (kind != null) 'kind': kind,
      if (suspectedCause != null) 'suspected_cause': suspectedCause,
      if (occurredOn != null) 'occurred_on': occurredOn,
      if (notes != null) 'notes': notes,
      if (editedAt != null) 'edited_at': editedAt,
      if (deletedGroupId != null) 'deleted_group_id': deletedGroupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MortalityRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? batchId,
    Value<int>? count,
    Value<String>? kind,
    Value<String?>? suspectedCause,
    Value<DateTime>? occurredOn,
    Value<String?>? notes,
    Value<DateTime?>? editedAt,
    Value<String?>? deletedGroupId,
    Value<int>? rowid,
  }) {
    return MortalityRecordsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      batchId: batchId ?? this.batchId,
      count: count ?? this.count,
      kind: kind ?? this.kind,
      suspectedCause: suspectedCause ?? this.suspectedCause,
      occurredOn: occurredOn ?? this.occurredOn,
      notes: notes ?? this.notes,
      editedAt: editedAt ?? this.editedAt,
      deletedGroupId: deletedGroupId ?? this.deletedGroupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (suspectedCause.present) {
      map['suspected_cause'] = Variable<String>(suspectedCause.value);
    }
    if (occurredOn.present) {
      map['occurred_on'] = Variable<DateTime>(occurredOn.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (deletedGroupId.present) {
      map['deleted_group_id'] = Variable<String>(deletedGroupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MortalityRecordsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('batchId: $batchId, ')
          ..write('count: $count, ')
          ..write('kind: $kind, ')
          ..write('suspectedCause: $suspectedCause, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('notes: $notes, ')
          ..write('editedAt: $editedAt, ')
          ..write('deletedGroupId: $deletedGroupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmEventsTable extends FarmEvents
    with TableInfo<$FarmEventsTable, FarmEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredOnMeta = const VerificationMeta(
    'occurredOn',
  );
  @override
  late final GeneratedColumn<DateTime> occurredOn = GeneratedColumn<DateTime>(
    'occurred_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    batchId,
    eventType,
    occurredOn,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<FarmEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('occurred_on')) {
      context.handle(
        _occurredOnMeta,
        occurredOn.isAcceptableOrUnknown(data['occurred_on']!, _occurredOnMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredOnMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      occurredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_on'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $FarmEventsTable createAlias(String alias) {
    return $FarmEventsTable(attachedDatabase, alias);
  }
}

class FarmEventRow extends DataClass implements Insertable<FarmEventRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String? batchId;
  final String eventType;
  final DateTime occurredOn;
  final String? notes;
  const FarmEventRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    this.batchId,
    required this.eventType,
    required this.occurredOn,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    map['event_type'] = Variable<String>(eventType);
    map['occurred_on'] = Variable<DateTime>(occurredOn);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  FarmEventsCompanion toCompanion(bool nullToAbsent) {
    return FarmEventsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      eventType: Value(eventType),
      occurredOn: Value(occurredOn),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory FarmEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmEventRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      occurredOn: serializer.fromJson<DateTime>(json['occurredOn']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'batchId': serializer.toJson<String?>(batchId),
      'eventType': serializer.toJson<String>(eventType),
      'occurredOn': serializer.toJson<DateTime>(occurredOn),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  FarmEventRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> batchId = const Value.absent(),
    String? eventType,
    DateTime? occurredOn,
    Value<String?> notes = const Value.absent(),
  }) => FarmEventRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    batchId: batchId.present ? batchId.value : this.batchId,
    eventType: eventType ?? this.eventType,
    occurredOn: occurredOn ?? this.occurredOn,
    notes: notes.present ? notes.value : this.notes,
  );
  FarmEventRow copyWithCompanion(FarmEventsCompanion data) {
    return FarmEventRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      occurredOn: data.occurredOn.present
          ? data.occurredOn.value
          : this.occurredOn,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmEventRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('batchId: $batchId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    batchId,
    eventType,
    occurredOn,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmEventRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.batchId == this.batchId &&
          other.eventType == this.eventType &&
          other.occurredOn == this.occurredOn &&
          other.notes == this.notes);
}

class FarmEventsCompanion extends UpdateCompanion<FarmEventRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String?> batchId;
  final Value<String> eventType;
  final Value<DateTime> occurredOn;
  final Value<String?> notes;
  final Value<int> rowid;
  const FarmEventsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.batchId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.occurredOn = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmEventsCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.batchId = const Value.absent(),
    required String eventType,
    required DateTime occurredOn,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       eventType = Value(eventType),
       occurredOn = Value(occurredOn);
  static Insertable<FarmEventRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? batchId,
    Expression<String>? eventType,
    Expression<DateTime>? occurredOn,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (batchId != null) 'batch_id': batchId,
      if (eventType != null) 'event_type': eventType,
      if (occurredOn != null) 'occurred_on': occurredOn,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String?>? batchId,
    Value<String>? eventType,
    Value<DateTime>? occurredOn,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return FarmEventsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      batchId: batchId ?? this.batchId,
      eventType: eventType ?? this.eventType,
      occurredOn: occurredOn ?? this.occurredOn,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (occurredOn.present) {
      map['occurred_on'] = Variable<DateTime>(occurredOn.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmEventsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('batchId: $batchId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntitlementsTable extends Entitlements
    with TableInfo<$EntitlementsTable, EntitlementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntitlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
    'plan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validUntilMeta = const VerificationMeta(
    'validUntil',
  );
  @override
  late final GeneratedColumn<DateTime> validUntil = GeneratedColumn<DateTime>(
    'valid_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastVerifiedAtMeta = const VerificationMeta(
    'lastVerifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVerifiedAt =
      GeneratedColumn<DateTime>(
        'last_verified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    plan,
    status,
    validUntil,
    lastVerifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entitlements';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitlementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('plan')) {
      context.handle(
        _planMeta,
        plan.isAcceptableOrUnknown(data['plan']!, _planMeta),
      );
    } else if (isInserting) {
      context.missing(_planMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('valid_until')) {
      context.handle(
        _validUntilMeta,
        validUntil.isAcceptableOrUnknown(data['valid_until']!, _validUntilMeta),
      );
    }
    if (data.containsKey('last_verified_at')) {
      context.handle(
        _lastVerifiedAtMeta,
        lastVerifiedAt.isAcceptableOrUnknown(
          data['last_verified_at']!,
          _lastVerifiedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitlementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitlementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      plan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      validUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}valid_until'],
      ),
      lastVerifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_verified_at'],
      ),
    );
  }

  @override
  $EntitlementsTable createAlias(String alias) {
    return $EntitlementsTable(attachedDatabase, alias);
  }
}

class EntitlementRow extends DataClass implements Insertable<EntitlementRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String plan;
  final String status;
  final DateTime? validUntil;
  final DateTime? lastVerifiedAt;
  const EntitlementRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.plan,
    required this.status,
    this.validUntil,
    this.lastVerifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['plan'] = Variable<String>(plan);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || validUntil != null) {
      map['valid_until'] = Variable<DateTime>(validUntil);
    }
    if (!nullToAbsent || lastVerifiedAt != null) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt);
    }
    return map;
  }

  EntitlementsCompanion toCompanion(bool nullToAbsent) {
    return EntitlementsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      plan: Value(plan),
      status: Value(status),
      validUntil: validUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(validUntil),
      lastVerifiedAt: lastVerifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVerifiedAt),
    );
  }

  factory EntitlementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitlementRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      plan: serializer.fromJson<String>(json['plan']),
      status: serializer.fromJson<String>(json['status']),
      validUntil: serializer.fromJson<DateTime?>(json['validUntil']),
      lastVerifiedAt: serializer.fromJson<DateTime?>(json['lastVerifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'plan': serializer.toJson<String>(plan),
      'status': serializer.toJson<String>(status),
      'validUntil': serializer.toJson<DateTime?>(validUntil),
      'lastVerifiedAt': serializer.toJson<DateTime?>(lastVerifiedAt),
    };
  }

  EntitlementRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? plan,
    String? status,
    Value<DateTime?> validUntil = const Value.absent(),
    Value<DateTime?> lastVerifiedAt = const Value.absent(),
  }) => EntitlementRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    plan: plan ?? this.plan,
    status: status ?? this.status,
    validUntil: validUntil.present ? validUntil.value : this.validUntil,
    lastVerifiedAt: lastVerifiedAt.present
        ? lastVerifiedAt.value
        : this.lastVerifiedAt,
  );
  EntitlementRow copyWithCompanion(EntitlementsCompanion data) {
    return EntitlementRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      plan: data.plan.present ? data.plan.value : this.plan,
      status: data.status.present ? data.status.value : this.status,
      validUntil: data.validUntil.present
          ? data.validUntil.value
          : this.validUntil,
      lastVerifiedAt: data.lastVerifiedAt.present
          ? data.lastVerifiedAt.value
          : this.lastVerifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitlementRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('plan: $plan, ')
          ..write('status: $status, ')
          ..write('validUntil: $validUntil, ')
          ..write('lastVerifiedAt: $lastVerifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    plan,
    status,
    validUntil,
    lastVerifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitlementRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.plan == this.plan &&
          other.status == this.status &&
          other.validUntil == this.validUntil &&
          other.lastVerifiedAt == this.lastVerifiedAt);
}

class EntitlementsCompanion extends UpdateCompanion<EntitlementRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> plan;
  final Value<String> status;
  final Value<DateTime?> validUntil;
  final Value<DateTime?> lastVerifiedAt;
  final Value<int> rowid;
  const EntitlementsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.plan = const Value.absent(),
    this.status = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntitlementsCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String plan,
    required String status,
    this.validUntil = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       plan = Value(plan),
       status = Value(status);
  static Insertable<EntitlementRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? plan,
    Expression<String>? status,
    Expression<DateTime>? validUntil,
    Expression<DateTime>? lastVerifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (plan != null) 'plan': plan,
      if (status != null) 'status': status,
      if (validUntil != null) 'valid_until': validUntil,
      if (lastVerifiedAt != null) 'last_verified_at': lastVerifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntitlementsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? plan,
    Value<String>? status,
    Value<DateTime?>? validUntil,
    Value<DateTime?>? lastVerifiedAt,
    Value<int>? rowid,
  }) {
    return EntitlementsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      validUntil: validUntil ?? this.validUntil,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (plan.present) {
      map['plan'] = Variable<String>(plan.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<DateTime>(validUntil.value);
    }
    if (lastVerifiedAt.present) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntitlementsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('plan: $plan, ')
          ..write('status: $status, ')
          ..write('validUntil: $validUntil, ')
          ..write('lastVerifiedAt: $lastVerifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _leaseUntilMeta = const VerificationMeta(
    'leaseUntil',
  );
  @override
  late final GeneratedColumn<DateTime> leaseUntil = GeneratedColumn<DateTime>(
    'lease_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retryableMeta = const VerificationMeta(
    'retryable',
  );
  @override
  late final GeneratedColumn<bool> retryable = GeneratedColumn<bool>(
    'retryable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("retryable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    targetTable,
    rowId,
    op,
    payload,
    createdAt,
    attempts,
    lastError,
    state,
    leaseUntil,
    retryable,
    errorCode,
    nextAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('lease_until')) {
      context.handle(
        _leaseUntilMeta,
        leaseUntil.isAcceptableOrUnknown(data['lease_until']!, _leaseUntilMeta),
      );
    }
    if (data.containsKey('retryable')) {
      context.handle(
        _retryableMeta,
        retryable.isAcceptableOrUnknown(data['retryable']!, _retryableMeta),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      leaseUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lease_until'],
      ),
      retryable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}retryable'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final String opId;
  final String targetTable;
  final String rowId;
  final String op;
  final String payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  final String state;
  final DateTime? leaseUntil;
  final bool retryable;
  final String? errorCode;
  final DateTime? nextAttemptAt;
  const OutboxRow({
    required this.opId,
    required this.targetTable,
    required this.rowId,
    required this.op,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    this.lastError,
    required this.state,
    this.leaseUntil,
    required this.retryable,
    this.errorCode,
    this.nextAttemptAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['target_table'] = Variable<String>(targetTable);
    map['row_id'] = Variable<String>(rowId);
    map['op'] = Variable<String>(op);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || leaseUntil != null) {
      map['lease_until'] = Variable<DateTime>(leaseUntil);
    }
    map['retryable'] = Variable<bool>(retryable);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      opId: Value(opId),
      targetTable: Value(targetTable),
      rowId: Value(rowId),
      op: Value(op),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      state: Value(state),
      leaseUntil: leaseUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseUntil),
      retryable: Value(retryable),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      opId: serializer.fromJson<String>(json['opId']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      rowId: serializer.fromJson<String>(json['rowId']),
      op: serializer.fromJson<String>(json['op']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      state: serializer.fromJson<String>(json['state']),
      leaseUntil: serializer.fromJson<DateTime?>(json['leaseUntil']),
      retryable: serializer.fromJson<bool>(json['retryable']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'targetTable': serializer.toJson<String>(targetTable),
      'rowId': serializer.toJson<String>(rowId),
      'op': serializer.toJson<String>(op),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'state': serializer.toJson<String>(state),
      'leaseUntil': serializer.toJson<DateTime?>(leaseUntil),
      'retryable': serializer.toJson<bool>(retryable),
      'errorCode': serializer.toJson<String?>(errorCode),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
    };
  }

  OutboxRow copyWith({
    String? opId,
    String? targetTable,
    String? rowId,
    String? op,
    String? payload,
    DateTime? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    String? state,
    Value<DateTime?> leaseUntil = const Value.absent(),
    bool? retryable,
    Value<String?> errorCode = const Value.absent(),
    Value<DateTime?> nextAttemptAt = const Value.absent(),
  }) => OutboxRow(
    opId: opId ?? this.opId,
    targetTable: targetTable ?? this.targetTable,
    rowId: rowId ?? this.rowId,
    op: op ?? this.op,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    state: state ?? this.state,
    leaseUntil: leaseUntil.present ? leaseUntil.value : this.leaseUntil,
    retryable: retryable ?? this.retryable,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
  );
  OutboxRow copyWithCompanion(OutboxCompanion data) {
    return OutboxRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      op: data.op.present ? data.op.value : this.op,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      state: data.state.present ? data.state.value : this.state,
      leaseUntil: data.leaseUntil.present
          ? data.leaseUntil.value
          : this.leaseUntil,
      retryable: data.retryable.present ? data.retryable.value : this.retryable,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('opId: $opId, ')
          ..write('targetTable: $targetTable, ')
          ..write('rowId: $rowId, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('state: $state, ')
          ..write('leaseUntil: $leaseUntil, ')
          ..write('retryable: $retryable, ')
          ..write('errorCode: $errorCode, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    targetTable,
    rowId,
    op,
    payload,
    createdAt,
    attempts,
    lastError,
    state,
    leaseUntil,
    retryable,
    errorCode,
    nextAttemptAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.opId == this.opId &&
          other.targetTable == this.targetTable &&
          other.rowId == this.rowId &&
          other.op == this.op &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.state == this.state &&
          other.leaseUntil == this.leaseUntil &&
          other.retryable == this.retryable &&
          other.errorCode == this.errorCode &&
          other.nextAttemptAt == this.nextAttemptAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<String> opId;
  final Value<String> targetTable;
  final Value<String> rowId;
  final Value<String> op;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<String> state;
  final Value<DateTime?> leaseUntil;
  final Value<bool> retryable;
  final Value<String?> errorCode;
  final Value<DateTime?> nextAttemptAt;
  final Value<int> rowid;
  const OutboxCompanion({
    this.opId = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.rowId = const Value.absent(),
    this.op = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.state = const Value.absent(),
    this.leaseUntil = const Value.absent(),
    this.retryable = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String opId,
    required String targetTable,
    required String rowId,
    required String op,
    required String payload,
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.state = const Value.absent(),
    this.leaseUntil = const Value.absent(),
    this.retryable = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       targetTable = Value(targetTable),
       rowId = Value(rowId),
       op = Value(op),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<String>? opId,
    Expression<String>? targetTable,
    Expression<String>? rowId,
    Expression<String>? op,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<String>? state,
    Expression<DateTime>? leaseUntil,
    Expression<bool>? retryable,
    Expression<String>? errorCode,
    Expression<DateTime>? nextAttemptAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (targetTable != null) 'target_table': targetTable,
      if (rowId != null) 'row_id': rowId,
      if (op != null) 'op': op,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (state != null) 'state': state,
      if (leaseUntil != null) 'lease_until': leaseUntil,
      if (retryable != null) 'retryable': retryable,
      if (errorCode != null) 'error_code': errorCode,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith({
    Value<String>? opId,
    Value<String>? targetTable,
    Value<String>? rowId,
    Value<String>? op,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<String>? state,
    Value<DateTime?>? leaseUntil,
    Value<bool>? retryable,
    Value<String?>? errorCode,
    Value<DateTime?>? nextAttemptAt,
    Value<int>? rowid,
  }) {
    return OutboxCompanion(
      opId: opId ?? this.opId,
      targetTable: targetTable ?? this.targetTable,
      rowId: rowId ?? this.rowId,
      op: op ?? this.op,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      state: state ?? this.state,
      leaseUntil: leaseUntil ?? this.leaseUntil,
      retryable: retryable ?? this.retryable,
      errorCode: errorCode ?? this.errorCode,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (leaseUntil.present) {
      map['lease_until'] = Variable<DateTime>(leaseUntil.value);
    }
    if (retryable.present) {
      map['retryable'] = Variable<bool>(retryable.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('opId: $opId, ')
          ..write('targetTable: $targetTable, ')
          ..write('rowId: $rowId, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('state: $state, ')
          ..write('leaseUntil: $leaseUntil, ')
          ..write('retryable: $retryable, ')
          ..write('errorCode: $errorCode, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncTableMeta = const VerificationMeta(
    'syncTable',
  );
  @override
  late final GeneratedColumn<String> syncTable = GeneratedColumn<String>(
    'sync_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<int> cursor = GeneratedColumn<int>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [syncTable, cursor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_table')) {
      context.handle(
        _syncTableMeta,
        syncTable.isAcceptableOrUnknown(data['sync_table']!, _syncTableMeta),
      );
    } else if (isInserting) {
      context.missing(_syncTableMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {syncTable};
  @override
  SyncCursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorRow(
      syncTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_table'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cursor'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursorRow extends DataClass implements Insertable<SyncCursorRow> {
  final String syncTable;
  final int cursor;
  const SyncCursorRow({required this.syncTable, required this.cursor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_table'] = Variable<String>(syncTable);
    map['cursor'] = Variable<int>(cursor);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      syncTable: Value(syncTable),
      cursor: Value(cursor),
    );
  }

  factory SyncCursorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorRow(
      syncTable: serializer.fromJson<String>(json['syncTable']),
      cursor: serializer.fromJson<int>(json['cursor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncTable': serializer.toJson<String>(syncTable),
      'cursor': serializer.toJson<int>(cursor),
    };
  }

  SyncCursorRow copyWith({String? syncTable, int? cursor}) => SyncCursorRow(
    syncTable: syncTable ?? this.syncTable,
    cursor: cursor ?? this.cursor,
  );
  SyncCursorRow copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursorRow(
      syncTable: data.syncTable.present ? data.syncTable.value : this.syncTable,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorRow(')
          ..write('syncTable: $syncTable, ')
          ..write('cursor: $cursor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(syncTable, cursor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorRow &&
          other.syncTable == this.syncTable &&
          other.cursor == this.cursor);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursorRow> {
  final Value<String> syncTable;
  final Value<int> cursor;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.syncTable = const Value.absent(),
    this.cursor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String syncTable,
    this.cursor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncTable = Value(syncTable);
  static Insertable<SyncCursorRow> custom({
    Expression<String>? syncTable,
    Expression<int>? cursor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncTable != null) 'sync_table': syncTable,
      if (cursor != null) 'cursor': cursor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? syncTable,
    Value<int>? cursor,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      syncTable: syncTable ?? this.syncTable,
      cursor: cursor ?? this.cursor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncTable.present) {
      map['sync_table'] = Variable<String>(syncTable.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<int>(cursor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('syncTable: $syncTable, ')
          ..write('cursor: $cursor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaRow extends DataClass implements Insertable<SyncMetaRow> {
  final String key;
  final String value;
  const SyncMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(key: Value(key), value: Value(value));
  }

  factory SyncMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SyncMetaRow copyWith({String? key, String? value}) =>
      SyncMetaRow(key: key ?? this.key, value: value ?? this.value);
  SyncMetaRow copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncEventsTable extends SyncEvents
    with TableInfo<$SyncEventsTable, SyncEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, occurredAt, level, message];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
    );
  }

  @override
  $SyncEventsTable createAlias(String alias) {
    return $SyncEventsTable(attachedDatabase, alias);
  }
}

class SyncEventRow extends DataClass implements Insertable<SyncEventRow> {
  final int id;
  final DateTime occurredAt;
  final String level;
  final String message;
  const SyncEventRow({
    required this.id,
    required this.occurredAt,
    required this.level,
    required this.message,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['level'] = Variable<String>(level);
    map['message'] = Variable<String>(message);
    return map;
  }

  SyncEventsCompanion toCompanion(bool nullToAbsent) {
    return SyncEventsCompanion(
      id: Value(id),
      occurredAt: Value(occurredAt),
      level: Value(level),
      message: Value(message),
    );
  }

  factory SyncEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncEventRow(
      id: serializer.fromJson<int>(json['id']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      level: serializer.fromJson<String>(json['level']),
      message: serializer.fromJson<String>(json['message']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'level': serializer.toJson<String>(level),
      'message': serializer.toJson<String>(message),
    };
  }

  SyncEventRow copyWith({
    int? id,
    DateTime? occurredAt,
    String? level,
    String? message,
  }) => SyncEventRow(
    id: id ?? this.id,
    occurredAt: occurredAt ?? this.occurredAt,
    level: level ?? this.level,
    message: message ?? this.message,
  );
  SyncEventRow copyWithCompanion(SyncEventsCompanion data) {
    return SyncEventRow(
      id: data.id.present ? data.id.value : this.id,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      level: data.level.present ? data.level.value : this.level,
      message: data.message.present ? data.message.value : this.message,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncEventRow(')
          ..write('id: $id, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('level: $level, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, occurredAt, level, message);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncEventRow &&
          other.id == this.id &&
          other.occurredAt == this.occurredAt &&
          other.level == this.level &&
          other.message == this.message);
}

class SyncEventsCompanion extends UpdateCompanion<SyncEventRow> {
  final Value<int> id;
  final Value<DateTime> occurredAt;
  final Value<String> level;
  final Value<String> message;
  const SyncEventsCompanion({
    this.id = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.level = const Value.absent(),
    this.message = const Value.absent(),
  });
  SyncEventsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime occurredAt,
    required String level,
    required String message,
  }) : occurredAt = Value(occurredAt),
       level = Value(level),
       message = Value(message);
  static Insertable<SyncEventRow> custom({
    Expression<int>? id,
    Expression<DateTime>? occurredAt,
    Expression<String>? level,
    Expression<String>? message,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (level != null) 'level': level,
      if (message != null) 'message': message,
    });
  }

  SyncEventsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? occurredAt,
    Value<String>? level,
    Value<String>? message,
  }) {
    return SyncEventsCompanion(
      id: id ?? this.id,
      occurredAt: occurredAt ?? this.occurredAt,
      level: level ?? this.level,
      message: message ?? this.message,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncEventsCompanion(')
          ..write('id: $id, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('level: $level, ')
          ..write('message: $message')
          ..write(')'))
        .toString();
  }
}

class $SyncLockTable extends SyncLock
    with TableInfo<$SyncLockTable, SyncLockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLockTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _holderMeta = const VerificationMeta('holder');
  @override
  late final GeneratedColumn<String> holder = GeneratedColumn<String>(
    'holder',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leaseUntilMeta = const VerificationMeta(
    'leaseUntil',
  );
  @override
  late final GeneratedColumn<DateTime> leaseUntil = GeneratedColumn<DateTime>(
    'lease_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, holder, leaseUntil];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_lock';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('holder')) {
      context.handle(
        _holderMeta,
        holder.isAcceptableOrUnknown(data['holder']!, _holderMeta),
      );
    }
    if (data.containsKey('lease_until')) {
      context.handle(
        _leaseUntilMeta,
        leaseUntil.isAcceptableOrUnknown(data['lease_until']!, _leaseUntilMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLockRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      holder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}holder'],
      ),
      leaseUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lease_until'],
      ),
    );
  }

  @override
  $SyncLockTable createAlias(String alias) {
    return $SyncLockTable(attachedDatabase, alias);
  }
}

class SyncLockRow extends DataClass implements Insertable<SyncLockRow> {
  final int id;
  final String? holder;
  final DateTime? leaseUntil;
  const SyncLockRow({required this.id, this.holder, this.leaseUntil});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || holder != null) {
      map['holder'] = Variable<String>(holder);
    }
    if (!nullToAbsent || leaseUntil != null) {
      map['lease_until'] = Variable<DateTime>(leaseUntil);
    }
    return map;
  }

  SyncLockCompanion toCompanion(bool nullToAbsent) {
    return SyncLockCompanion(
      id: Value(id),
      holder: holder == null && nullToAbsent
          ? const Value.absent()
          : Value(holder),
      leaseUntil: leaseUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(leaseUntil),
    );
  }

  factory SyncLockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLockRow(
      id: serializer.fromJson<int>(json['id']),
      holder: serializer.fromJson<String?>(json['holder']),
      leaseUntil: serializer.fromJson<DateTime?>(json['leaseUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'holder': serializer.toJson<String?>(holder),
      'leaseUntil': serializer.toJson<DateTime?>(leaseUntil),
    };
  }

  SyncLockRow copyWith({
    int? id,
    Value<String?> holder = const Value.absent(),
    Value<DateTime?> leaseUntil = const Value.absent(),
  }) => SyncLockRow(
    id: id ?? this.id,
    holder: holder.present ? holder.value : this.holder,
    leaseUntil: leaseUntil.present ? leaseUntil.value : this.leaseUntil,
  );
  SyncLockRow copyWithCompanion(SyncLockCompanion data) {
    return SyncLockRow(
      id: data.id.present ? data.id.value : this.id,
      holder: data.holder.present ? data.holder.value : this.holder,
      leaseUntil: data.leaseUntil.present
          ? data.leaseUntil.value
          : this.leaseUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLockRow(')
          ..write('id: $id, ')
          ..write('holder: $holder, ')
          ..write('leaseUntil: $leaseUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, holder, leaseUntil);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLockRow &&
          other.id == this.id &&
          other.holder == this.holder &&
          other.leaseUntil == this.leaseUntil);
}

class SyncLockCompanion extends UpdateCompanion<SyncLockRow> {
  final Value<int> id;
  final Value<String?> holder;
  final Value<DateTime?> leaseUntil;
  const SyncLockCompanion({
    this.id = const Value.absent(),
    this.holder = const Value.absent(),
    this.leaseUntil = const Value.absent(),
  });
  SyncLockCompanion.insert({
    this.id = const Value.absent(),
    this.holder = const Value.absent(),
    this.leaseUntil = const Value.absent(),
  });
  static Insertable<SyncLockRow> custom({
    Expression<int>? id,
    Expression<String>? holder,
    Expression<DateTime>? leaseUntil,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (holder != null) 'holder': holder,
      if (leaseUntil != null) 'lease_until': leaseUntil,
    });
  }

  SyncLockCompanion copyWith({
    Value<int>? id,
    Value<String?>? holder,
    Value<DateTime?>? leaseUntil,
  }) {
    return SyncLockCompanion(
      id: id ?? this.id,
      holder: holder ?? this.holder,
      leaseUntil: leaseUntil ?? this.leaseUntil,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (holder.present) {
      map['holder'] = Variable<String>(holder.value);
    }
    if (leaseUntil.present) {
      map['lease_until'] = Variable<DateTime>(leaseUntil.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLockCompanion(')
          ..write('id: $id, ')
          ..write('holder: $holder, ')
          ..write('leaseUntil: $leaseUntil')
          ..write(')'))
        .toString();
  }
}

class $AuthSnapshotTable extends AuthSnapshot
    with TableInfo<$AuthSnapshotTable, AuthSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthSnapshotTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _farmIdsJsonMeta = const VerificationMeta(
    'farmIdsJson',
  );
  @override
  late final GeneratedColumn<String> farmIdsJson = GeneratedColumn<String>(
    'farm_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appRoleMeta = const VerificationMeta(
    'appRole',
  );
  @override
  late final GeneratedColumn<String> appRole = GeneratedColumn<String>(
    'app_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('farmer'),
  );
  static const VerificationMeta _lastVerifiedAtMeta = const VerificationMeta(
    'lastVerifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVerifiedAt =
      GeneratedColumn<DateTime>(
        'last_verified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    email,
    phone,
    farmIdsJson,
    appRole,
    lastVerifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auth_snapshot';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuthSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('farm_ids_json')) {
      context.handle(
        _farmIdsJsonMeta,
        farmIdsJson.isAcceptableOrUnknown(
          data['farm_ids_json']!,
          _farmIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_farmIdsJsonMeta);
    }
    if (data.containsKey('app_role')) {
      context.handle(
        _appRoleMeta,
        appRole.isAcceptableOrUnknown(data['app_role']!, _appRoleMeta),
      );
    }
    if (data.containsKey('last_verified_at')) {
      context.handle(
        _lastVerifiedAtMeta,
        lastVerifiedAt.isAcceptableOrUnknown(
          data['last_verified_at']!,
          _lastVerifiedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuthSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthSnapshotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      farmIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_ids_json'],
      )!,
      appRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_role'],
      )!,
      lastVerifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_verified_at'],
      ),
    );
  }

  @override
  $AuthSnapshotTable createAlias(String alias) {
    return $AuthSnapshotTable(attachedDatabase, alias);
  }
}

class AuthSnapshotRow extends DataClass implements Insertable<AuthSnapshotRow> {
  final int id;
  final String userId;
  final String? email;
  final String? phone;
  final String farmIdsJson;
  final String appRole;
  final DateTime? lastVerifiedAt;
  const AuthSnapshotRow({
    required this.id,
    required this.userId,
    this.email,
    this.phone,
    required this.farmIdsJson,
    required this.appRole,
    this.lastVerifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['farm_ids_json'] = Variable<String>(farmIdsJson);
    map['app_role'] = Variable<String>(appRole);
    if (!nullToAbsent || lastVerifiedAt != null) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt);
    }
    return map;
  }

  AuthSnapshotCompanion toCompanion(bool nullToAbsent) {
    return AuthSnapshotCompanion(
      id: Value(id),
      userId: Value(userId),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      farmIdsJson: Value(farmIdsJson),
      appRole: Value(appRole),
      lastVerifiedAt: lastVerifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVerifiedAt),
    );
  }

  factory AuthSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthSnapshotRow(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      farmIdsJson: serializer.fromJson<String>(json['farmIdsJson']),
      appRole: serializer.fromJson<String>(json['appRole']),
      lastVerifiedAt: serializer.fromJson<DateTime?>(json['lastVerifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'farmIdsJson': serializer.toJson<String>(farmIdsJson),
      'appRole': serializer.toJson<String>(appRole),
      'lastVerifiedAt': serializer.toJson<DateTime?>(lastVerifiedAt),
    };
  }

  AuthSnapshotRow copyWith({
    int? id,
    String? userId,
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? farmIdsJson,
    String? appRole,
    Value<DateTime?> lastVerifiedAt = const Value.absent(),
  }) => AuthSnapshotRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    farmIdsJson: farmIdsJson ?? this.farmIdsJson,
    appRole: appRole ?? this.appRole,
    lastVerifiedAt: lastVerifiedAt.present
        ? lastVerifiedAt.value
        : this.lastVerifiedAt,
  );
  AuthSnapshotRow copyWithCompanion(AuthSnapshotCompanion data) {
    return AuthSnapshotRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      farmIdsJson: data.farmIdsJson.present
          ? data.farmIdsJson.value
          : this.farmIdsJson,
      appRole: data.appRole.present ? data.appRole.value : this.appRole,
      lastVerifiedAt: data.lastVerifiedAt.present
          ? data.lastVerifiedAt.value
          : this.lastVerifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuthSnapshotRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('farmIdsJson: $farmIdsJson, ')
          ..write('appRole: $appRole, ')
          ..write('lastVerifiedAt: $lastVerifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    email,
    phone,
    farmIdsJson,
    appRole,
    lastVerifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthSnapshotRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.farmIdsJson == this.farmIdsJson &&
          other.appRole == this.appRole &&
          other.lastVerifiedAt == this.lastVerifiedAt);
}

class AuthSnapshotCompanion extends UpdateCompanion<AuthSnapshotRow> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String> farmIdsJson;
  final Value<String> appRole;
  final Value<DateTime?> lastVerifiedAt;
  const AuthSnapshotCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.farmIdsJson = const Value.absent(),
    this.appRole = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
  });
  AuthSnapshotCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    required String farmIdsJson,
    this.appRole = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
  }) : userId = Value(userId),
       farmIdsJson = Value(farmIdsJson);
  static Insertable<AuthSnapshotRow> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? farmIdsJson,
    Expression<String>? appRole,
    Expression<DateTime>? lastVerifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (farmIdsJson != null) 'farm_ids_json': farmIdsJson,
      if (appRole != null) 'app_role': appRole,
      if (lastVerifiedAt != null) 'last_verified_at': lastVerifiedAt,
    });
  }

  AuthSnapshotCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String>? farmIdsJson,
    Value<String>? appRole,
    Value<DateTime?>? lastVerifiedAt,
  }) {
    return AuthSnapshotCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      farmIdsJson: farmIdsJson ?? this.farmIdsJson,
      appRole: appRole ?? this.appRole,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (farmIdsJson.present) {
      map['farm_ids_json'] = Variable<String>(farmIdsJson.value);
    }
    if (appRole.present) {
      map['app_role'] = Variable<String>(appRole.value);
    }
    if (lastVerifiedAt.present) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthSnapshotCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('farmIdsJson: $farmIdsJson, ')
          ..write('appRole: $appRole, ')
          ..write('lastVerifiedAt: $lastVerifiedAt')
          ..write(')'))
        .toString();
  }
}

class $VetAssistanceRequestsTable extends VetAssistanceRequests
    with TableInfo<$VetAssistanceRequestsTable, VetAssistanceRequestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VetAssistanceRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _healthRecordIdMeta = const VerificationMeta(
    'healthRecordId',
  );
  @override
  late final GeneratedColumn<String> healthRecordId = GeneratedColumn<String>(
    'health_record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceTypeMeta = const VerificationMeta(
    'serviceType',
  );
  @override
  late final GeneratedColumn<String> serviceType = GeneratedColumn<String>(
    'service_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shareLocationMeta = const VerificationMeta(
    'shareLocation',
  );
  @override
  late final GeneratedColumn<bool> shareLocation = GeneratedColumn<bool>(
    'share_location',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("share_location" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _farmerNotesMeta = const VerificationMeta(
    'farmerNotes',
  );
  @override
  late final GeneratedColumn<String> farmerNotes = GeneratedColumn<String>(
    'farmer_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedVetUserIdMeta = const VerificationMeta(
    'assignedVetUserId',
  );
  @override
  late final GeneratedColumn<String> assignedVetUserId =
      GeneratedColumn<String>(
        'assigned_vet_user_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _requestedVetUserIdMeta =
      const VerificationMeta('requestedVetUserId');
  @override
  late final GeneratedColumn<String> requestedVetUserId =
      GeneratedColumn<String>(
        'requested_vet_user_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    batchId,
    healthRecordId,
    serviceType,
    status,
    shareLocation,
    priority,
    farmerNotes,
    assignedVetUserId,
    requestedVetUserId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vet_assistance_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<VetAssistanceRequestRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('health_record_id')) {
      context.handle(
        _healthRecordIdMeta,
        healthRecordId.isAcceptableOrUnknown(
          data['health_record_id']!,
          _healthRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_healthRecordIdMeta);
    }
    if (data.containsKey('service_type')) {
      context.handle(
        _serviceTypeMeta,
        serviceType.isAcceptableOrUnknown(
          data['service_type']!,
          _serviceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('share_location')) {
      context.handle(
        _shareLocationMeta,
        shareLocation.isAcceptableOrUnknown(
          data['share_location']!,
          _shareLocationMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('farmer_notes')) {
      context.handle(
        _farmerNotesMeta,
        farmerNotes.isAcceptableOrUnknown(
          data['farmer_notes']!,
          _farmerNotesMeta,
        ),
      );
    }
    if (data.containsKey('assigned_vet_user_id')) {
      context.handle(
        _assignedVetUserIdMeta,
        assignedVetUserId.isAcceptableOrUnknown(
          data['assigned_vet_user_id']!,
          _assignedVetUserIdMeta,
        ),
      );
    }
    if (data.containsKey('requested_vet_user_id')) {
      context.handle(
        _requestedVetUserIdMeta,
        requestedVetUserId.isAcceptableOrUnknown(
          data['requested_vet_user_id']!,
          _requestedVetUserIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VetAssistanceRequestRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VetAssistanceRequestRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      healthRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}health_record_id'],
      )!,
      serviceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      shareLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}share_location'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      farmerNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farmer_notes'],
      ),
      assignedVetUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_vet_user_id'],
      ),
      requestedVetUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_vet_user_id'],
      ),
    );
  }

  @override
  $VetAssistanceRequestsTable createAlias(String alias) {
    return $VetAssistanceRequestsTable(attachedDatabase, alias);
  }
}

class VetAssistanceRequestRow extends DataClass
    implements Insertable<VetAssistanceRequestRow> {
  final String id;
  final String farmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String batchId;
  final String healthRecordId;
  final String serviceType;
  final String status;
  final bool shareLocation;
  final String priority;
  final String? farmerNotes;
  final String? assignedVetUserId;
  final String? requestedVetUserId;
  const VetAssistanceRequestRow({
    required this.id,
    required this.farmId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.batchId,
    required this.healthRecordId,
    required this.serviceType,
    required this.status,
    required this.shareLocation,
    required this.priority,
    this.farmerNotes,
    this.assignedVetUserId,
    this.requestedVetUserId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['batch_id'] = Variable<String>(batchId);
    map['health_record_id'] = Variable<String>(healthRecordId);
    map['service_type'] = Variable<String>(serviceType);
    map['status'] = Variable<String>(status);
    map['share_location'] = Variable<bool>(shareLocation);
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || farmerNotes != null) {
      map['farmer_notes'] = Variable<String>(farmerNotes);
    }
    if (!nullToAbsent || assignedVetUserId != null) {
      map['assigned_vet_user_id'] = Variable<String>(assignedVetUserId);
    }
    if (!nullToAbsent || requestedVetUserId != null) {
      map['requested_vet_user_id'] = Variable<String>(requestedVetUserId);
    }
    return map;
  }

  VetAssistanceRequestsCompanion toCompanion(bool nullToAbsent) {
    return VetAssistanceRequestsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      batchId: Value(batchId),
      healthRecordId: Value(healthRecordId),
      serviceType: Value(serviceType),
      status: Value(status),
      shareLocation: Value(shareLocation),
      priority: Value(priority),
      farmerNotes: farmerNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(farmerNotes),
      assignedVetUserId: assignedVetUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedVetUserId),
      requestedVetUserId: requestedVetUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(requestedVetUserId),
    );
  }

  factory VetAssistanceRequestRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VetAssistanceRequestRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      batchId: serializer.fromJson<String>(json['batchId']),
      healthRecordId: serializer.fromJson<String>(json['healthRecordId']),
      serviceType: serializer.fromJson<String>(json['serviceType']),
      status: serializer.fromJson<String>(json['status']),
      shareLocation: serializer.fromJson<bool>(json['shareLocation']),
      priority: serializer.fromJson<String>(json['priority']),
      farmerNotes: serializer.fromJson<String?>(json['farmerNotes']),
      assignedVetUserId: serializer.fromJson<String?>(
        json['assignedVetUserId'],
      ),
      requestedVetUserId: serializer.fromJson<String?>(
        json['requestedVetUserId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'batchId': serializer.toJson<String>(batchId),
      'healthRecordId': serializer.toJson<String>(healthRecordId),
      'serviceType': serializer.toJson<String>(serviceType),
      'status': serializer.toJson<String>(status),
      'shareLocation': serializer.toJson<bool>(shareLocation),
      'priority': serializer.toJson<String>(priority),
      'farmerNotes': serializer.toJson<String?>(farmerNotes),
      'assignedVetUserId': serializer.toJson<String?>(assignedVetUserId),
      'requestedVetUserId': serializer.toJson<String?>(requestedVetUserId),
    };
  }

  VetAssistanceRequestRow copyWith({
    String? id,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? batchId,
    String? healthRecordId,
    String? serviceType,
    String? status,
    bool? shareLocation,
    String? priority,
    Value<String?> farmerNotes = const Value.absent(),
    Value<String?> assignedVetUserId = const Value.absent(),
    Value<String?> requestedVetUserId = const Value.absent(),
  }) => VetAssistanceRequestRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    batchId: batchId ?? this.batchId,
    healthRecordId: healthRecordId ?? this.healthRecordId,
    serviceType: serviceType ?? this.serviceType,
    status: status ?? this.status,
    shareLocation: shareLocation ?? this.shareLocation,
    priority: priority ?? this.priority,
    farmerNotes: farmerNotes.present ? farmerNotes.value : this.farmerNotes,
    assignedVetUserId: assignedVetUserId.present
        ? assignedVetUserId.value
        : this.assignedVetUserId,
    requestedVetUserId: requestedVetUserId.present
        ? requestedVetUserId.value
        : this.requestedVetUserId,
  );
  VetAssistanceRequestRow copyWithCompanion(
    VetAssistanceRequestsCompanion data,
  ) {
    return VetAssistanceRequestRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      healthRecordId: data.healthRecordId.present
          ? data.healthRecordId.value
          : this.healthRecordId,
      serviceType: data.serviceType.present
          ? data.serviceType.value
          : this.serviceType,
      status: data.status.present ? data.status.value : this.status,
      shareLocation: data.shareLocation.present
          ? data.shareLocation.value
          : this.shareLocation,
      priority: data.priority.present ? data.priority.value : this.priority,
      farmerNotes: data.farmerNotes.present
          ? data.farmerNotes.value
          : this.farmerNotes,
      assignedVetUserId: data.assignedVetUserId.present
          ? data.assignedVetUserId.value
          : this.assignedVetUserId,
      requestedVetUserId: data.requestedVetUserId.present
          ? data.requestedVetUserId.value
          : this.requestedVetUserId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VetAssistanceRequestRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('batchId: $batchId, ')
          ..write('healthRecordId: $healthRecordId, ')
          ..write('serviceType: $serviceType, ')
          ..write('status: $status, ')
          ..write('shareLocation: $shareLocation, ')
          ..write('priority: $priority, ')
          ..write('farmerNotes: $farmerNotes, ')
          ..write('assignedVetUserId: $assignedVetUserId, ')
          ..write('requestedVetUserId: $requestedVetUserId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    batchId,
    healthRecordId,
    serviceType,
    status,
    shareLocation,
    priority,
    farmerNotes,
    assignedVetUserId,
    requestedVetUserId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VetAssistanceRequestRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.batchId == this.batchId &&
          other.healthRecordId == this.healthRecordId &&
          other.serviceType == this.serviceType &&
          other.status == this.status &&
          other.shareLocation == this.shareLocation &&
          other.priority == this.priority &&
          other.farmerNotes == this.farmerNotes &&
          other.assignedVetUserId == this.assignedVetUserId &&
          other.requestedVetUserId == this.requestedVetUserId);
}

class VetAssistanceRequestsCompanion
    extends UpdateCompanion<VetAssistanceRequestRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> batchId;
  final Value<String> healthRecordId;
  final Value<String> serviceType;
  final Value<String> status;
  final Value<bool> shareLocation;
  final Value<String> priority;
  final Value<String?> farmerNotes;
  final Value<String?> assignedVetUserId;
  final Value<String?> requestedVetUserId;
  final Value<int> rowid;
  const VetAssistanceRequestsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.batchId = const Value.absent(),
    this.healthRecordId = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.status = const Value.absent(),
    this.shareLocation = const Value.absent(),
    this.priority = const Value.absent(),
    this.farmerNotes = const Value.absent(),
    this.assignedVetUserId = const Value.absent(),
    this.requestedVetUserId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VetAssistanceRequestsCompanion.insert({
    required String id,
    required String farmId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String batchId,
    required String healthRecordId,
    required String serviceType,
    required String status,
    this.shareLocation = const Value.absent(),
    this.priority = const Value.absent(),
    this.farmerNotes = const Value.absent(),
    this.assignedVetUserId = const Value.absent(),
    this.requestedVetUserId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       batchId = Value(batchId),
       healthRecordId = Value(healthRecordId),
       serviceType = Value(serviceType),
       status = Value(status);
  static Insertable<VetAssistanceRequestRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? batchId,
    Expression<String>? healthRecordId,
    Expression<String>? serviceType,
    Expression<String>? status,
    Expression<bool>? shareLocation,
    Expression<String>? priority,
    Expression<String>? farmerNotes,
    Expression<String>? assignedVetUserId,
    Expression<String>? requestedVetUserId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (batchId != null) 'batch_id': batchId,
      if (healthRecordId != null) 'health_record_id': healthRecordId,
      if (serviceType != null) 'service_type': serviceType,
      if (status != null) 'status': status,
      if (shareLocation != null) 'share_location': shareLocation,
      if (priority != null) 'priority': priority,
      if (farmerNotes != null) 'farmer_notes': farmerNotes,
      if (assignedVetUserId != null) 'assigned_vet_user_id': assignedVetUserId,
      if (requestedVetUserId != null)
        'requested_vet_user_id': requestedVetUserId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VetAssistanceRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? batchId,
    Value<String>? healthRecordId,
    Value<String>? serviceType,
    Value<String>? status,
    Value<bool>? shareLocation,
    Value<String>? priority,
    Value<String?>? farmerNotes,
    Value<String?>? assignedVetUserId,
    Value<String?>? requestedVetUserId,
    Value<int>? rowid,
  }) {
    return VetAssistanceRequestsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      batchId: batchId ?? this.batchId,
      healthRecordId: healthRecordId ?? this.healthRecordId,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      shareLocation: shareLocation ?? this.shareLocation,
      priority: priority ?? this.priority,
      farmerNotes: farmerNotes ?? this.farmerNotes,
      assignedVetUserId: assignedVetUserId ?? this.assignedVetUserId,
      requestedVetUserId: requestedVetUserId ?? this.requestedVetUserId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (healthRecordId.present) {
      map['health_record_id'] = Variable<String>(healthRecordId.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<String>(serviceType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (shareLocation.present) {
      map['share_location'] = Variable<bool>(shareLocation.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (farmerNotes.present) {
      map['farmer_notes'] = Variable<String>(farmerNotes.value);
    }
    if (assignedVetUserId.present) {
      map['assigned_vet_user_id'] = Variable<String>(assignedVetUserId.value);
    }
    if (requestedVetUserId.present) {
      map['requested_vet_user_id'] = Variable<String>(requestedVetUserId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VetAssistanceRequestsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('batchId: $batchId, ')
          ..write('healthRecordId: $healthRecordId, ')
          ..write('serviceType: $serviceType, ')
          ..write('status: $status, ')
          ..write('shareLocation: $shareLocation, ')
          ..write('priority: $priority, ')
          ..write('farmerNotes: $farmerNotes, ')
          ..write('assignedVetUserId: $assignedVetUserId, ')
          ..write('requestedVetUserId: $requestedVetUserId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaseMessagesTable extends CaseMessages
    with TableInfo<$CaseMessagesTable, CaseMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaseMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderUserIdMeta = const VerificationMeta(
    'senderUserId',
  );
  @override
  late final GeneratedColumn<String> senderUserId = GeneratedColumn<String>(
    'sender_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderRoleMeta = const VerificationMeta(
    'senderRole',
  );
  @override
  late final GeneratedColumn<String> senderRole = GeneratedColumn<String>(
    'sender_role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientCreatedAtMeta = const VerificationMeta(
    'clientCreatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientCreatedAt =
      GeneratedColumn<DateTime>(
        'client_created_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _localFailReasonMeta = const VerificationMeta(
    'localFailReason',
  );
  @override
  late final GeneratedColumn<String> localFailReason = GeneratedColumn<String>(
    'local_fail_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    requestId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    senderUserId,
    senderRole,
    kind,
    body,
    clientCreatedAt,
    localFailReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'case_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<CaseMessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('sender_user_id')) {
      context.handle(
        _senderUserIdMeta,
        senderUserId.isAcceptableOrUnknown(
          data['sender_user_id']!,
          _senderUserIdMeta,
        ),
      );
    }
    if (data.containsKey('sender_role')) {
      context.handle(
        _senderRoleMeta,
        senderRole.isAcceptableOrUnknown(data['sender_role']!, _senderRoleMeta),
      );
    } else if (isInserting) {
      context.missing(_senderRoleMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('client_created_at')) {
      context.handle(
        _clientCreatedAtMeta,
        clientCreatedAt.isAcceptableOrUnknown(
          data['client_created_at']!,
          _clientCreatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientCreatedAtMeta);
    }
    if (data.containsKey('local_fail_reason')) {
      context.handle(
        _localFailReasonMeta,
        localFailReason.isAcceptableOrUnknown(
          data['local_fail_reason']!,
          _localFailReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaseMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaseMessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      senderUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_user_id'],
      ),
      senderRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_role'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      clientCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_created_at'],
      )!,
      localFailReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_fail_reason'],
      ),
    );
  }

  @override
  $CaseMessagesTable createAlias(String alias) {
    return $CaseMessagesTable(attachedDatabase, alias);
  }
}

class CaseMessageRow extends DataClass implements Insertable<CaseMessageRow> {
  final String id;
  final String farmId;
  final String requestId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String? senderUserId;
  final String senderRole;
  final String kind;
  final String? body;
  final DateTime clientCreatedAt;
  final String? localFailReason;
  const CaseMessageRow({
    required this.id,
    required this.farmId,
    required this.requestId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    this.senderUserId,
    required this.senderRole,
    required this.kind,
    this.body,
    required this.clientCreatedAt,
    this.localFailReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['request_id'] = Variable<String>(requestId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    if (!nullToAbsent || senderUserId != null) {
      map['sender_user_id'] = Variable<String>(senderUserId);
    }
    map['sender_role'] = Variable<String>(senderRole);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    map['client_created_at'] = Variable<DateTime>(clientCreatedAt);
    if (!nullToAbsent || localFailReason != null) {
      map['local_fail_reason'] = Variable<String>(localFailReason);
    }
    return map;
  }

  CaseMessagesCompanion toCompanion(bool nullToAbsent) {
    return CaseMessagesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      requestId: Value(requestId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      senderUserId: senderUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(senderUserId),
      senderRole: Value(senderRole),
      kind: Value(kind),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      clientCreatedAt: Value(clientCreatedAt),
      localFailReason: localFailReason == null && nullToAbsent
          ? const Value.absent()
          : Value(localFailReason),
    );
  }

  factory CaseMessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaseMessageRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      requestId: serializer.fromJson<String>(json['requestId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      senderUserId: serializer.fromJson<String?>(json['senderUserId']),
      senderRole: serializer.fromJson<String>(json['senderRole']),
      kind: serializer.fromJson<String>(json['kind']),
      body: serializer.fromJson<String?>(json['body']),
      clientCreatedAt: serializer.fromJson<DateTime>(json['clientCreatedAt']),
      localFailReason: serializer.fromJson<String?>(json['localFailReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'requestId': serializer.toJson<String>(requestId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'senderUserId': serializer.toJson<String?>(senderUserId),
      'senderRole': serializer.toJson<String>(senderRole),
      'kind': serializer.toJson<String>(kind),
      'body': serializer.toJson<String?>(body),
      'clientCreatedAt': serializer.toJson<DateTime>(clientCreatedAt),
      'localFailReason': serializer.toJson<String?>(localFailReason),
    };
  }

  CaseMessageRow copyWith({
    String? id,
    String? farmId,
    String? requestId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    Value<String?> senderUserId = const Value.absent(),
    String? senderRole,
    String? kind,
    Value<String?> body = const Value.absent(),
    DateTime? clientCreatedAt,
    Value<String?> localFailReason = const Value.absent(),
  }) => CaseMessageRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    requestId: requestId ?? this.requestId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    senderUserId: senderUserId.present ? senderUserId.value : this.senderUserId,
    senderRole: senderRole ?? this.senderRole,
    kind: kind ?? this.kind,
    body: body.present ? body.value : this.body,
    clientCreatedAt: clientCreatedAt ?? this.clientCreatedAt,
    localFailReason: localFailReason.present
        ? localFailReason.value
        : this.localFailReason,
  );
  CaseMessageRow copyWithCompanion(CaseMessagesCompanion data) {
    return CaseMessageRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      senderUserId: data.senderUserId.present
          ? data.senderUserId.value
          : this.senderUserId,
      senderRole: data.senderRole.present
          ? data.senderRole.value
          : this.senderRole,
      kind: data.kind.present ? data.kind.value : this.kind,
      body: data.body.present ? data.body.value : this.body,
      clientCreatedAt: data.clientCreatedAt.present
          ? data.clientCreatedAt.value
          : this.clientCreatedAt,
      localFailReason: data.localFailReason.present
          ? data.localFailReason.value
          : this.localFailReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaseMessageRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('requestId: $requestId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('senderUserId: $senderUserId, ')
          ..write('senderRole: $senderRole, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('clientCreatedAt: $clientCreatedAt, ')
          ..write('localFailReason: $localFailReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    requestId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    senderUserId,
    senderRole,
    kind,
    body,
    clientCreatedAt,
    localFailReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaseMessageRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.requestId == this.requestId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.senderUserId == this.senderUserId &&
          other.senderRole == this.senderRole &&
          other.kind == this.kind &&
          other.body == this.body &&
          other.clientCreatedAt == this.clientCreatedAt &&
          other.localFailReason == this.localFailReason);
}

class CaseMessagesCompanion extends UpdateCompanion<CaseMessageRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> requestId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String?> senderUserId;
  final Value<String> senderRole;
  final Value<String> kind;
  final Value<String?> body;
  final Value<DateTime> clientCreatedAt;
  final Value<String?> localFailReason;
  final Value<int> rowid;
  const CaseMessagesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.requestId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.senderUserId = const Value.absent(),
    this.senderRole = const Value.absent(),
    this.kind = const Value.absent(),
    this.body = const Value.absent(),
    this.clientCreatedAt = const Value.absent(),
    this.localFailReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaseMessagesCompanion.insert({
    required String id,
    required String farmId,
    required String requestId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.senderUserId = const Value.absent(),
    required String senderRole,
    required String kind,
    this.body = const Value.absent(),
    required DateTime clientCreatedAt,
    this.localFailReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       requestId = Value(requestId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       senderRole = Value(senderRole),
       kind = Value(kind),
       clientCreatedAt = Value(clientCreatedAt);
  static Insertable<CaseMessageRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? requestId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? senderUserId,
    Expression<String>? senderRole,
    Expression<String>? kind,
    Expression<String>? body,
    Expression<DateTime>? clientCreatedAt,
    Expression<String>? localFailReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (requestId != null) 'request_id': requestId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (senderUserId != null) 'sender_user_id': senderUserId,
      if (senderRole != null) 'sender_role': senderRole,
      if (kind != null) 'kind': kind,
      if (body != null) 'body': body,
      if (clientCreatedAt != null) 'client_created_at': clientCreatedAt,
      if (localFailReason != null) 'local_fail_reason': localFailReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaseMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? requestId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String?>? senderUserId,
    Value<String>? senderRole,
    Value<String>? kind,
    Value<String?>? body,
    Value<DateTime>? clientCreatedAt,
    Value<String?>? localFailReason,
    Value<int>? rowid,
  }) {
    return CaseMessagesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      requestId: requestId ?? this.requestId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      senderUserId: senderUserId ?? this.senderUserId,
      senderRole: senderRole ?? this.senderRole,
      kind: kind ?? this.kind,
      body: body ?? this.body,
      clientCreatedAt: clientCreatedAt ?? this.clientCreatedAt,
      localFailReason: localFailReason ?? this.localFailReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (senderUserId.present) {
      map['sender_user_id'] = Variable<String>(senderUserId.value);
    }
    if (senderRole.present) {
      map['sender_role'] = Variable<String>(senderRole.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (clientCreatedAt.present) {
      map['client_created_at'] = Variable<DateTime>(clientCreatedAt.value);
    }
    if (localFailReason.present) {
      map['local_fail_reason'] = Variable<String>(localFailReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaseMessagesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('requestId: $requestId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('senderUserId: $senderUserId, ')
          ..write('senderRole: $senderRole, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('clientCreatedAt: $clientCreatedAt, ')
          ..write('localFailReason: $localFailReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaseMessageAttachmentsTable extends CaseMessageAttachments
    with TableInfo<$CaseMessageAttachmentsTable, CaseMessageAttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaseMessageAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _objectKeyMeta = const VerificationMeta(
    'objectKey',
  );
  @override
  late final GeneratedColumn<String> objectKey = GeneratedColumn<String>(
    'object_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('image/jpeg'),
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbB64Meta = const VerificationMeta(
    'thumbB64',
  );
  @override
  late final GeneratedColumn<String> thumbB64 = GeneratedColumn<String>(
    'thumb_b64',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmId,
    requestId,
    messageId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    objectKey,
    mime,
    bytes,
    width,
    height,
    thumbB64,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'case_message_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<CaseMessageAttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('object_key')) {
      context.handle(
        _objectKeyMeta,
        objectKey.isAcceptableOrUnknown(data['object_key']!, _objectKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_objectKeyMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('thumb_b64')) {
      context.handle(
        _thumbB64Meta,
        thumbB64.isAcceptableOrUnknown(data['thumb_b64']!, _thumbB64Meta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaseMessageAttachmentRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaseMessageAttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      objectKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_key'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      thumbB64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumb_b64'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $CaseMessageAttachmentsTable createAlias(String alias) {
    return $CaseMessageAttachmentsTable(attachedDatabase, alias);
  }
}

class CaseMessageAttachmentRow extends DataClass
    implements Insertable<CaseMessageAttachmentRow> {
  final String id;
  final String farmId;
  final String requestId;
  final String messageId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  final String objectKey;
  final String mime;
  final int? bytes;
  final int? width;
  final int? height;
  final String? thumbB64;
  final String status;
  const CaseMessageAttachmentRow({
    required this.id,
    required this.farmId,
    required this.requestId,
    required this.messageId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
    required this.objectKey,
    required this.mime,
    this.bytes,
    this.width,
    this.height,
    this.thumbB64,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['request_id'] = Variable<String>(requestId);
    map['message_id'] = Variable<String>(messageId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['object_key'] = Variable<String>(objectKey);
    map['mime'] = Variable<String>(mime);
    if (!nullToAbsent || bytes != null) {
      map['bytes'] = Variable<int>(bytes);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || thumbB64 != null) {
      map['thumb_b64'] = Variable<String>(thumbB64);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  CaseMessageAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return CaseMessageAttachmentsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      requestId: Value(requestId),
      messageId: Value(messageId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      objectKey: Value(objectKey),
      mime: Value(mime),
      bytes: bytes == null && nullToAbsent
          ? const Value.absent()
          : Value(bytes),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      thumbB64: thumbB64 == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbB64),
      status: Value(status),
    );
  }

  factory CaseMessageAttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaseMessageAttachmentRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      requestId: serializer.fromJson<String>(json['requestId']),
      messageId: serializer.fromJson<String>(json['messageId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      objectKey: serializer.fromJson<String>(json['objectKey']),
      mime: serializer.fromJson<String>(json['mime']),
      bytes: serializer.fromJson<int?>(json['bytes']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      thumbB64: serializer.fromJson<String?>(json['thumbB64']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'requestId': serializer.toJson<String>(requestId),
      'messageId': serializer.toJson<String>(messageId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'objectKey': serializer.toJson<String>(objectKey),
      'mime': serializer.toJson<String>(mime),
      'bytes': serializer.toJson<int?>(bytes),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'thumbB64': serializer.toJson<String?>(thumbB64),
      'status': serializer.toJson<String>(status),
    };
  }

  CaseMessageAttachmentRow copyWith({
    String? id,
    String? farmId,
    String? requestId,
    String? messageId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    String? objectKey,
    String? mime,
    Value<int?> bytes = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<String?> thumbB64 = const Value.absent(),
    String? status,
  }) => CaseMessageAttachmentRow(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    requestId: requestId ?? this.requestId,
    messageId: messageId ?? this.messageId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    objectKey: objectKey ?? this.objectKey,
    mime: mime ?? this.mime,
    bytes: bytes.present ? bytes.value : this.bytes,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    thumbB64: thumbB64.present ? thumbB64.value : this.thumbB64,
    status: status ?? this.status,
  );
  CaseMessageAttachmentRow copyWithCompanion(
    CaseMessageAttachmentsCompanion data,
  ) {
    return CaseMessageAttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      objectKey: data.objectKey.present ? data.objectKey.value : this.objectKey,
      mime: data.mime.present ? data.mime.value : this.mime,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      thumbB64: data.thumbB64.present ? data.thumbB64.value : this.thumbB64,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaseMessageAttachmentRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('requestId: $requestId, ')
          ..write('messageId: $messageId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('objectKey: $objectKey, ')
          ..write('mime: $mime, ')
          ..write('bytes: $bytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('thumbB64: $thumbB64, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmId,
    requestId,
    messageId,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
    objectKey,
    mime,
    bytes,
    width,
    height,
    thumbB64,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaseMessageAttachmentRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.requestId == this.requestId &&
          other.messageId == this.messageId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion &&
          other.objectKey == this.objectKey &&
          other.mime == this.mime &&
          other.bytes == this.bytes &&
          other.width == this.width &&
          other.height == this.height &&
          other.thumbB64 == this.thumbB64 &&
          other.status == this.status);
}

class CaseMessageAttachmentsCompanion
    extends UpdateCompanion<CaseMessageAttachmentRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> requestId;
  final Value<String> messageId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<String> objectKey;
  final Value<String> mime;
  final Value<int?> bytes;
  final Value<int?> width;
  final Value<int?> height;
  final Value<String?> thumbB64;
  final Value<String> status;
  final Value<int> rowid;
  const CaseMessageAttachmentsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.requestId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.objectKey = const Value.absent(),
    this.mime = const Value.absent(),
    this.bytes = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.thumbB64 = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaseMessageAttachmentsCompanion.insert({
    required String id,
    required String farmId,
    required String requestId,
    required String messageId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required String objectKey,
    this.mime = const Value.absent(),
    this.bytes = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.thumbB64 = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       farmId = Value(farmId),
       requestId = Value(requestId),
       messageId = Value(messageId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       objectKey = Value(objectKey);
  static Insertable<CaseMessageAttachmentRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? requestId,
    Expression<String>? messageId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<String>? objectKey,
    Expression<String>? mime,
    Expression<int>? bytes,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? thumbB64,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (requestId != null) 'request_id': requestId,
      if (messageId != null) 'message_id': messageId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (objectKey != null) 'object_key': objectKey,
      if (mime != null) 'mime': mime,
      if (bytes != null) 'bytes': bytes,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (thumbB64 != null) 'thumb_b64': thumbB64,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaseMessageAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmId,
    Value<String>? requestId,
    Value<String>? messageId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<String>? objectKey,
    Value<String>? mime,
    Value<int?>? bytes,
    Value<int?>? width,
    Value<int?>? height,
    Value<String?>? thumbB64,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return CaseMessageAttachmentsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      requestId: requestId ?? this.requestId,
      messageId: messageId ?? this.messageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      objectKey: objectKey ?? this.objectKey,
      mime: mime ?? this.mime,
      bytes: bytes ?? this.bytes,
      width: width ?? this.width,
      height: height ?? this.height,
      thumbB64: thumbB64 ?? this.thumbB64,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (objectKey.present) {
      map['object_key'] = Variable<String>(objectKey.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (thumbB64.present) {
      map['thumb_b64'] = Variable<String>(thumbB64.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaseMessageAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('requestId: $requestId, ')
          ..write('messageId: $messageId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('objectKey: $objectKey, ')
          ..write('mime: $mime, ')
          ..write('bytes: $bytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('thumbB64: $thumbB64, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaseReadStatesTable extends CaseReadStates
    with TableInfo<$CaseReadStatesTable, CaseReadStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaseReadStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
    'farm_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReadAtMeta = const VerificationMeta(
    'lastReadAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReadAt = GeneratedColumn<DateTime>(
    'last_read_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReadMessageIdMeta = const VerificationMeta(
    'lastReadMessageId',
  );
  @override
  late final GeneratedColumn<String> lastReadMessageId =
      GeneratedColumn<String>(
        'last_read_message_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mutedMeta = const VerificationMeta('muted');
  @override
  late final GeneratedColumn<bool> muted = GeneratedColumn<bool>(
    'muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("muted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    requestId,
    userId,
    farmId,
    lastReadAt,
    lastReadMessageId,
    muted,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'case_read_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<CaseReadStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(
        _farmIdMeta,
        farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta),
      );
    }
    if (data.containsKey('last_read_at')) {
      context.handle(
        _lastReadAtMeta,
        lastReadAt.isAcceptableOrUnknown(
          data['last_read_at']!,
          _lastReadAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastReadAtMeta);
    }
    if (data.containsKey('last_read_message_id')) {
      context.handle(
        _lastReadMessageIdMeta,
        lastReadMessageId.isAcceptableOrUnknown(
          data['last_read_message_id']!,
          _lastReadMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('muted')) {
      context.handle(
        _mutedMeta,
        muted.isAcceptableOrUnknown(data['muted']!, _mutedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {requestId, userId};
  @override
  CaseReadStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaseReadStateRow(
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      farmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farm_id'],
      ),
      lastReadAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read_at'],
      )!,
      lastReadMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_read_message_id'],
      ),
      muted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}muted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
    );
  }

  @override
  $CaseReadStatesTable createAlias(String alias) {
    return $CaseReadStatesTable(attachedDatabase, alias);
  }
}

class CaseReadStateRow extends DataClass
    implements Insertable<CaseReadStateRow> {
  final String requestId;
  final String userId;
  final String? farmId;
  final DateTime lastReadAt;
  final String? lastReadMessageId;
  final bool muted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverVersion;
  const CaseReadStateRow({
    required this.requestId,
    required this.userId,
    this.farmId,
    required this.lastReadAt,
    this.lastReadMessageId,
    required this.muted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['request_id'] = Variable<String>(requestId);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['last_read_at'] = Variable<DateTime>(lastReadAt);
    if (!nullToAbsent || lastReadMessageId != null) {
      map['last_read_message_id'] = Variable<String>(lastReadMessageId);
    }
    map['muted'] = Variable<bool>(muted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    return map;
  }

  CaseReadStatesCompanion toCompanion(bool nullToAbsent) {
    return CaseReadStatesCompanion(
      requestId: Value(requestId),
      userId: Value(userId),
      farmId: farmId == null && nullToAbsent
          ? const Value.absent()
          : Value(farmId),
      lastReadAt: Value(lastReadAt),
      lastReadMessageId: lastReadMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadMessageId),
      muted: Value(muted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
    );
  }

  factory CaseReadStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaseReadStateRow(
      requestId: serializer.fromJson<String>(json['requestId']),
      userId: serializer.fromJson<String>(json['userId']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      lastReadAt: serializer.fromJson<DateTime>(json['lastReadAt']),
      lastReadMessageId: serializer.fromJson<String?>(
        json['lastReadMessageId'],
      ),
      muted: serializer.fromJson<bool>(json['muted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'requestId': serializer.toJson<String>(requestId),
      'userId': serializer.toJson<String>(userId),
      'farmId': serializer.toJson<String?>(farmId),
      'lastReadAt': serializer.toJson<DateTime>(lastReadAt),
      'lastReadMessageId': serializer.toJson<String?>(lastReadMessageId),
      'muted': serializer.toJson<bool>(muted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serverVersion': serializer.toJson<int?>(serverVersion),
    };
  }

  CaseReadStateRow copyWith({
    String? requestId,
    String? userId,
    Value<String?> farmId = const Value.absent(),
    DateTime? lastReadAt,
    Value<String?> lastReadMessageId = const Value.absent(),
    bool? muted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
  }) => CaseReadStateRow(
    requestId: requestId ?? this.requestId,
    userId: userId ?? this.userId,
    farmId: farmId.present ? farmId.value : this.farmId,
    lastReadAt: lastReadAt ?? this.lastReadAt,
    lastReadMessageId: lastReadMessageId.present
        ? lastReadMessageId.value
        : this.lastReadMessageId,
    muted: muted ?? this.muted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
  );
  CaseReadStateRow copyWithCompanion(CaseReadStatesCompanion data) {
    return CaseReadStateRow(
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      userId: data.userId.present ? data.userId.value : this.userId,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      lastReadAt: data.lastReadAt.present
          ? data.lastReadAt.value
          : this.lastReadAt,
      lastReadMessageId: data.lastReadMessageId.present
          ? data.lastReadMessageId.value
          : this.lastReadMessageId,
      muted: data.muted.present ? data.muted.value : this.muted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaseReadStateRow(')
          ..write('requestId: $requestId, ')
          ..write('userId: $userId, ')
          ..write('farmId: $farmId, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('lastReadMessageId: $lastReadMessageId, ')
          ..write('muted: $muted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    requestId,
    userId,
    farmId,
    lastReadAt,
    lastReadMessageId,
    muted,
    createdAt,
    updatedAt,
    deletedAt,
    serverVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaseReadStateRow &&
          other.requestId == this.requestId &&
          other.userId == this.userId &&
          other.farmId == this.farmId &&
          other.lastReadAt == this.lastReadAt &&
          other.lastReadMessageId == this.lastReadMessageId &&
          other.muted == this.muted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverVersion == this.serverVersion);
}

class CaseReadStatesCompanion extends UpdateCompanion<CaseReadStateRow> {
  final Value<String> requestId;
  final Value<String> userId;
  final Value<String?> farmId;
  final Value<DateTime> lastReadAt;
  final Value<String?> lastReadMessageId;
  final Value<bool> muted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int?> serverVersion;
  final Value<int> rowid;
  const CaseReadStatesCompanion({
    this.requestId = const Value.absent(),
    this.userId = const Value.absent(),
    this.farmId = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.lastReadMessageId = const Value.absent(),
    this.muted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaseReadStatesCompanion.insert({
    required String requestId,
    required String userId,
    this.farmId = const Value.absent(),
    required DateTime lastReadAt,
    this.lastReadMessageId = const Value.absent(),
    this.muted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : requestId = Value(requestId),
       userId = Value(userId),
       lastReadAt = Value(lastReadAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CaseReadStateRow> custom({
    Expression<String>? requestId,
    Expression<String>? userId,
    Expression<String>? farmId,
    Expression<DateTime>? lastReadAt,
    Expression<String>? lastReadMessageId,
    Expression<bool>? muted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? serverVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (requestId != null) 'request_id': requestId,
      if (userId != null) 'user_id': userId,
      if (farmId != null) 'farm_id': farmId,
      if (lastReadAt != null) 'last_read_at': lastReadAt,
      if (lastReadMessageId != null) 'last_read_message_id': lastReadMessageId,
      if (muted != null) 'muted': muted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaseReadStatesCompanion copyWith({
    Value<String>? requestId,
    Value<String>? userId,
    Value<String?>? farmId,
    Value<DateTime>? lastReadAt,
    Value<String?>? lastReadMessageId,
    Value<bool>? muted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int?>? serverVersion,
    Value<int>? rowid,
  }) {
    return CaseReadStatesCompanion(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      farmId: farmId ?? this.farmId,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      muted: muted ?? this.muted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt.value);
    }
    if (lastReadMessageId.present) {
      map['last_read_message_id'] = Variable<String>(lastReadMessageId.value);
    }
    if (muted.present) {
      map['muted'] = Variable<bool>(muted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaseReadStatesCompanion(')
          ..write('requestId: $requestId, ')
          ..write('userId: $userId, ')
          ..write('farmId: $farmId, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('lastReadMessageId: $lastReadMessageId, ')
          ..write('muted: $muted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaUploadJobsTable extends MediaUploadJobs
    with TableInfo<$MediaUploadJobsTable, MediaUploadJobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaUploadJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attachmentIdMeta = const VerificationMeta(
    'attachmentId',
  );
  @override
  late final GeneratedColumn<String> attachmentId = GeneratedColumn<String>(
    'attachment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bytesSentMeta = const VerificationMeta(
    'bytesSent',
  );
  @override
  late final GeneratedColumn<int> bytesSent = GeneratedColumn<int>(
    'bytes_sent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _userForcedMeta = const VerificationMeta(
    'userForced',
  );
  @override
  late final GeneratedColumn<bool> userForced = GeneratedColumn<bool>(
    'user_forced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("user_forced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attachmentId,
    requestId,
    localPath,
    state,
    attempts,
    bytesSent,
    nextAttemptAt,
    userForced,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_upload_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaUploadJobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('attachment_id')) {
      context.handle(
        _attachmentIdMeta,
        attachmentId.isAcceptableOrUnknown(
          data['attachment_id']!,
          _attachmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('bytes_sent')) {
      context.handle(
        _bytesSentMeta,
        bytesSent.isAcceptableOrUnknown(data['bytes_sent']!, _bytesSentMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('user_forced')) {
      context.handle(
        _userForcedMeta,
        userForced.isAcceptableOrUnknown(data['user_forced']!, _userForcedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaUploadJobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaUploadJobRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      attachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      bytesSent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_sent'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      userForced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_forced'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MediaUploadJobsTable createAlias(String alias) {
    return $MediaUploadJobsTable(attachedDatabase, alias);
  }
}

class MediaUploadJobRow extends DataClass
    implements Insertable<MediaUploadJobRow> {
  final String id;
  final String attachmentId;
  final String requestId;
  final String localPath;
  final String state;
  final int attempts;
  final int bytesSent;
  final DateTime? nextAttemptAt;
  final bool userForced;
  final DateTime createdAt;
  const MediaUploadJobRow({
    required this.id,
    required this.attachmentId,
    required this.requestId,
    required this.localPath,
    required this.state,
    required this.attempts,
    required this.bytesSent,
    this.nextAttemptAt,
    required this.userForced,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['attachment_id'] = Variable<String>(attachmentId);
    map['request_id'] = Variable<String>(requestId);
    map['local_path'] = Variable<String>(localPath);
    map['state'] = Variable<String>(state);
    map['attempts'] = Variable<int>(attempts);
    map['bytes_sent'] = Variable<int>(bytesSent);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    map['user_forced'] = Variable<bool>(userForced);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MediaUploadJobsCompanion toCompanion(bool nullToAbsent) {
    return MediaUploadJobsCompanion(
      id: Value(id),
      attachmentId: Value(attachmentId),
      requestId: Value(requestId),
      localPath: Value(localPath),
      state: Value(state),
      attempts: Value(attempts),
      bytesSent: Value(bytesSent),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      userForced: Value(userForced),
      createdAt: Value(createdAt),
    );
  }

  factory MediaUploadJobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaUploadJobRow(
      id: serializer.fromJson<String>(json['id']),
      attachmentId: serializer.fromJson<String>(json['attachmentId']),
      requestId: serializer.fromJson<String>(json['requestId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      state: serializer.fromJson<String>(json['state']),
      attempts: serializer.fromJson<int>(json['attempts']),
      bytesSent: serializer.fromJson<int>(json['bytesSent']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      userForced: serializer.fromJson<bool>(json['userForced']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'attachmentId': serializer.toJson<String>(attachmentId),
      'requestId': serializer.toJson<String>(requestId),
      'localPath': serializer.toJson<String>(localPath),
      'state': serializer.toJson<String>(state),
      'attempts': serializer.toJson<int>(attempts),
      'bytesSent': serializer.toJson<int>(bytesSent),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'userForced': serializer.toJson<bool>(userForced),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MediaUploadJobRow copyWith({
    String? id,
    String? attachmentId,
    String? requestId,
    String? localPath,
    String? state,
    int? attempts,
    int? bytesSent,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    bool? userForced,
    DateTime? createdAt,
  }) => MediaUploadJobRow(
    id: id ?? this.id,
    attachmentId: attachmentId ?? this.attachmentId,
    requestId: requestId ?? this.requestId,
    localPath: localPath ?? this.localPath,
    state: state ?? this.state,
    attempts: attempts ?? this.attempts,
    bytesSent: bytesSent ?? this.bytesSent,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    userForced: userForced ?? this.userForced,
    createdAt: createdAt ?? this.createdAt,
  );
  MediaUploadJobRow copyWithCompanion(MediaUploadJobsCompanion data) {
    return MediaUploadJobRow(
      id: data.id.present ? data.id.value : this.id,
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      state: data.state.present ? data.state.value : this.state,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      bytesSent: data.bytesSent.present ? data.bytesSent.value : this.bytesSent,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      userForced: data.userForced.present
          ? data.userForced.value
          : this.userForced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaUploadJobRow(')
          ..write('id: $id, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('requestId: $requestId, ')
          ..write('localPath: $localPath, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('bytesSent: $bytesSent, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('userForced: $userForced, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    attachmentId,
    requestId,
    localPath,
    state,
    attempts,
    bytesSent,
    nextAttemptAt,
    userForced,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaUploadJobRow &&
          other.id == this.id &&
          other.attachmentId == this.attachmentId &&
          other.requestId == this.requestId &&
          other.localPath == this.localPath &&
          other.state == this.state &&
          other.attempts == this.attempts &&
          other.bytesSent == this.bytesSent &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.userForced == this.userForced &&
          other.createdAt == this.createdAt);
}

class MediaUploadJobsCompanion extends UpdateCompanion<MediaUploadJobRow> {
  final Value<String> id;
  final Value<String> attachmentId;
  final Value<String> requestId;
  final Value<String> localPath;
  final Value<String> state;
  final Value<int> attempts;
  final Value<int> bytesSent;
  final Value<DateTime?> nextAttemptAt;
  final Value<bool> userForced;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MediaUploadJobsCompanion({
    this.id = const Value.absent(),
    this.attachmentId = const Value.absent(),
    this.requestId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.bytesSent = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.userForced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaUploadJobsCompanion.insert({
    required String id,
    required String attachmentId,
    required String requestId,
    required String localPath,
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.bytesSent = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.userForced = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       attachmentId = Value(attachmentId),
       requestId = Value(requestId),
       localPath = Value(localPath),
       createdAt = Value(createdAt);
  static Insertable<MediaUploadJobRow> custom({
    Expression<String>? id,
    Expression<String>? attachmentId,
    Expression<String>? requestId,
    Expression<String>? localPath,
    Expression<String>? state,
    Expression<int>? attempts,
    Expression<int>? bytesSent,
    Expression<DateTime>? nextAttemptAt,
    Expression<bool>? userForced,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attachmentId != null) 'attachment_id': attachmentId,
      if (requestId != null) 'request_id': requestId,
      if (localPath != null) 'local_path': localPath,
      if (state != null) 'state': state,
      if (attempts != null) 'attempts': attempts,
      if (bytesSent != null) 'bytes_sent': bytesSent,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (userForced != null) 'user_forced': userForced,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaUploadJobsCompanion copyWith({
    Value<String>? id,
    Value<String>? attachmentId,
    Value<String>? requestId,
    Value<String>? localPath,
    Value<String>? state,
    Value<int>? attempts,
    Value<int>? bytesSent,
    Value<DateTime?>? nextAttemptAt,
    Value<bool>? userForced,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MediaUploadJobsCompanion(
      id: id ?? this.id,
      attachmentId: attachmentId ?? this.attachmentId,
      requestId: requestId ?? this.requestId,
      localPath: localPath ?? this.localPath,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      bytesSent: bytesSent ?? this.bytesSent,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      userForced: userForced ?? this.userForced,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (attachmentId.present) {
      map['attachment_id'] = Variable<String>(attachmentId.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (bytesSent.present) {
      map['bytes_sent'] = Variable<int>(bytesSent.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (userForced.present) {
      map['user_forced'] = Variable<bool>(userForced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaUploadJobsCompanion(')
          ..write('id: $id, ')
          ..write('attachmentId: $attachmentId, ')
          ..write('requestId: $requestId, ')
          ..write('localPath: $localPath, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('bytesSent: $bytesSent, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('userForced: $userForced, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaCacheTable extends MediaCache
    with TableInfo<$MediaCacheTable, MediaCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _objectKeyMeta = const VerificationMeta(
    'objectKey',
  );
  @override
  late final GeneratedColumn<String> objectKey = GeneratedColumn<String>(
    'object_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessAtMeta = const VerificationMeta(
    'lastAccessAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessAt = GeneratedColumn<DateTime>(
    'last_access_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    objectKey,
    localPath,
    bytes,
    lastAccessAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('object_key')) {
      context.handle(
        _objectKeyMeta,
        objectKey.isAcceptableOrUnknown(data['object_key']!, _objectKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_objectKeyMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('last_access_at')) {
      context.handle(
        _lastAccessAtMeta,
        lastAccessAt.isAcceptableOrUnknown(
          data['last_access_at']!,
          _lastAccessAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {objectKey};
  @override
  MediaCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaCacheRow(
      objectKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_key'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
      lastAccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_access_at'],
      )!,
    );
  }

  @override
  $MediaCacheTable createAlias(String alias) {
    return $MediaCacheTable(attachedDatabase, alias);
  }
}

class MediaCacheRow extends DataClass implements Insertable<MediaCacheRow> {
  final String objectKey;
  final String localPath;
  final int bytes;
  final DateTime lastAccessAt;
  const MediaCacheRow({
    required this.objectKey,
    required this.localPath,
    required this.bytes,
    required this.lastAccessAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['object_key'] = Variable<String>(objectKey);
    map['local_path'] = Variable<String>(localPath);
    map['bytes'] = Variable<int>(bytes);
    map['last_access_at'] = Variable<DateTime>(lastAccessAt);
    return map;
  }

  MediaCacheCompanion toCompanion(bool nullToAbsent) {
    return MediaCacheCompanion(
      objectKey: Value(objectKey),
      localPath: Value(localPath),
      bytes: Value(bytes),
      lastAccessAt: Value(lastAccessAt),
    );
  }

  factory MediaCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaCacheRow(
      objectKey: serializer.fromJson<String>(json['objectKey']),
      localPath: serializer.fromJson<String>(json['localPath']),
      bytes: serializer.fromJson<int>(json['bytes']),
      lastAccessAt: serializer.fromJson<DateTime>(json['lastAccessAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'objectKey': serializer.toJson<String>(objectKey),
      'localPath': serializer.toJson<String>(localPath),
      'bytes': serializer.toJson<int>(bytes),
      'lastAccessAt': serializer.toJson<DateTime>(lastAccessAt),
    };
  }

  MediaCacheRow copyWith({
    String? objectKey,
    String? localPath,
    int? bytes,
    DateTime? lastAccessAt,
  }) => MediaCacheRow(
    objectKey: objectKey ?? this.objectKey,
    localPath: localPath ?? this.localPath,
    bytes: bytes ?? this.bytes,
    lastAccessAt: lastAccessAt ?? this.lastAccessAt,
  );
  MediaCacheRow copyWithCompanion(MediaCacheCompanion data) {
    return MediaCacheRow(
      objectKey: data.objectKey.present ? data.objectKey.value : this.objectKey,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      lastAccessAt: data.lastAccessAt.present
          ? data.lastAccessAt.value
          : this.lastAccessAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaCacheRow(')
          ..write('objectKey: $objectKey, ')
          ..write('localPath: $localPath, ')
          ..write('bytes: $bytes, ')
          ..write('lastAccessAt: $lastAccessAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(objectKey, localPath, bytes, lastAccessAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaCacheRow &&
          other.objectKey == this.objectKey &&
          other.localPath == this.localPath &&
          other.bytes == this.bytes &&
          other.lastAccessAt == this.lastAccessAt);
}

class MediaCacheCompanion extends UpdateCompanion<MediaCacheRow> {
  final Value<String> objectKey;
  final Value<String> localPath;
  final Value<int> bytes;
  final Value<DateTime> lastAccessAt;
  final Value<int> rowid;
  const MediaCacheCompanion({
    this.objectKey = const Value.absent(),
    this.localPath = const Value.absent(),
    this.bytes = const Value.absent(),
    this.lastAccessAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaCacheCompanion.insert({
    required String objectKey,
    required String localPath,
    required int bytes,
    required DateTime lastAccessAt,
    this.rowid = const Value.absent(),
  }) : objectKey = Value(objectKey),
       localPath = Value(localPath),
       bytes = Value(bytes),
       lastAccessAt = Value(lastAccessAt);
  static Insertable<MediaCacheRow> custom({
    Expression<String>? objectKey,
    Expression<String>? localPath,
    Expression<int>? bytes,
    Expression<DateTime>? lastAccessAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (objectKey != null) 'object_key': objectKey,
      if (localPath != null) 'local_path': localPath,
      if (bytes != null) 'bytes': bytes,
      if (lastAccessAt != null) 'last_access_at': lastAccessAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaCacheCompanion copyWith({
    Value<String>? objectKey,
    Value<String>? localPath,
    Value<int>? bytes,
    Value<DateTime>? lastAccessAt,
    Value<int>? rowid,
  }) {
    return MediaCacheCompanion(
      objectKey: objectKey ?? this.objectKey,
      localPath: localPath ?? this.localPath,
      bytes: bytes ?? this.bytes,
      lastAccessAt: lastAccessAt ?? this.lastAccessAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (objectKey.present) {
      map['object_key'] = Variable<String>(objectKey.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (lastAccessAt.present) {
      map['last_access_at'] = Variable<DateTime>(lastAccessAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaCacheCompanion(')
          ..write('objectKey: $objectKey, ')
          ..write('localPath: $localPath, ')
          ..write('bytes: $bytes, ')
          ..write('lastAccessAt: $lastAccessAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PushRegistrationsTable extends PushRegistrations
    with TableInfo<$PushRegistrationsTable, PushRegistrationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PushRegistrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tokenHashMeta = const VerificationMeta(
    'tokenHash',
  );
  @override
  late final GeneratedColumn<String> tokenHash = GeneratedColumn<String>(
    'token_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registeredAtMeta = const VerificationMeta(
    'registeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> registeredAt = GeneratedColumn<DateTime>(
    'registered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [tokenHash, registeredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'push_registrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PushRegistrationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('token_hash')) {
      context.handle(
        _tokenHashMeta,
        tokenHash.isAcceptableOrUnknown(data['token_hash']!, _tokenHashMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenHashMeta);
    }
    if (data.containsKey('registered_at')) {
      context.handle(
        _registeredAtMeta,
        registeredAt.isAcceptableOrUnknown(
          data['registered_at']!,
          _registeredAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tokenHash};
  @override
  PushRegistrationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PushRegistrationRow(
      tokenHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_hash'],
      )!,
      registeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}registered_at'],
      )!,
    );
  }

  @override
  $PushRegistrationsTable createAlias(String alias) {
    return $PushRegistrationsTable(attachedDatabase, alias);
  }
}

class PushRegistrationRow extends DataClass
    implements Insertable<PushRegistrationRow> {
  final String tokenHash;
  final DateTime registeredAt;
  const PushRegistrationRow({
    required this.tokenHash,
    required this.registeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['token_hash'] = Variable<String>(tokenHash);
    map['registered_at'] = Variable<DateTime>(registeredAt);
    return map;
  }

  PushRegistrationsCompanion toCompanion(bool nullToAbsent) {
    return PushRegistrationsCompanion(
      tokenHash: Value(tokenHash),
      registeredAt: Value(registeredAt),
    );
  }

  factory PushRegistrationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PushRegistrationRow(
      tokenHash: serializer.fromJson<String>(json['tokenHash']),
      registeredAt: serializer.fromJson<DateTime>(json['registeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tokenHash': serializer.toJson<String>(tokenHash),
      'registeredAt': serializer.toJson<DateTime>(registeredAt),
    };
  }

  PushRegistrationRow copyWith({String? tokenHash, DateTime? registeredAt}) =>
      PushRegistrationRow(
        tokenHash: tokenHash ?? this.tokenHash,
        registeredAt: registeredAt ?? this.registeredAt,
      );
  PushRegistrationRow copyWithCompanion(PushRegistrationsCompanion data) {
    return PushRegistrationRow(
      tokenHash: data.tokenHash.present ? data.tokenHash.value : this.tokenHash,
      registeredAt: data.registeredAt.present
          ? data.registeredAt.value
          : this.registeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PushRegistrationRow(')
          ..write('tokenHash: $tokenHash, ')
          ..write('registeredAt: $registeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tokenHash, registeredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PushRegistrationRow &&
          other.tokenHash == this.tokenHash &&
          other.registeredAt == this.registeredAt);
}

class PushRegistrationsCompanion extends UpdateCompanion<PushRegistrationRow> {
  final Value<String> tokenHash;
  final Value<DateTime> registeredAt;
  final Value<int> rowid;
  const PushRegistrationsCompanion({
    this.tokenHash = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PushRegistrationsCompanion.insert({
    required String tokenHash,
    required DateTime registeredAt,
    this.rowid = const Value.absent(),
  }) : tokenHash = Value(tokenHash),
       registeredAt = Value(registeredAt);
  static Insertable<PushRegistrationRow> custom({
    Expression<String>? tokenHash,
    Expression<DateTime>? registeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tokenHash != null) 'token_hash': tokenHash,
      if (registeredAt != null) 'registered_at': registeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PushRegistrationsCompanion copyWith({
    Value<String>? tokenHash,
    Value<DateTime>? registeredAt,
    Value<int>? rowid,
  }) {
    return PushRegistrationsCompanion(
      tokenHash: tokenHash ?? this.tokenHash,
      registeredAt: registeredAt ?? this.registeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tokenHash.present) {
      map['token_hash'] = Variable<String>(tokenHash.value);
    }
    if (registeredAt.present) {
      map['registered_at'] = Variable<DateTime>(registeredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PushRegistrationsCompanion(')
          ..write('tokenHash: $tokenHash, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FarmsTable farms = $FarmsTable(this);
  late final $FarmMembersTable farmMembers = $FarmMembersTable(this);
  late final $BatchesTable batches = $BatchesTable(this);
  late final $ProgrammesTable programmes = $ProgrammesTable(this);
  late final $ProgrammeStepsTable programmeSteps = $ProgrammeStepsTable(this);
  late final $VaccinationTasksTable vaccinationTasks = $VaccinationTasksTable(
    this,
  );
  late final $FeedItemsTable feedItems = $FeedItemsTable(this);
  late final $FeedTransactionsTable feedTransactions = $FeedTransactionsTable(
    this,
  );
  late final $HealthRecordsTable healthRecords = $HealthRecordsTable(this);
  late final $MortalityRecordsTable mortalityRecords = $MortalityRecordsTable(
    this,
  );
  late final $FarmEventsTable farmEvents = $FarmEventsTable(this);
  late final $EntitlementsTable entitlements = $EntitlementsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  late final $SyncEventsTable syncEvents = $SyncEventsTable(this);
  late final $SyncLockTable syncLock = $SyncLockTable(this);
  late final $AuthSnapshotTable authSnapshot = $AuthSnapshotTable(this);
  late final $VetAssistanceRequestsTable vetAssistanceRequests =
      $VetAssistanceRequestsTable(this);
  late final $CaseMessagesTable caseMessages = $CaseMessagesTable(this);
  late final $CaseMessageAttachmentsTable caseMessageAttachments =
      $CaseMessageAttachmentsTable(this);
  late final $CaseReadStatesTable caseReadStates = $CaseReadStatesTable(this);
  late final $MediaUploadJobsTable mediaUploadJobs = $MediaUploadJobsTable(
    this,
  );
  late final $MediaCacheTable mediaCache = $MediaCacheTable(this);
  late final $PushRegistrationsTable pushRegistrations =
      $PushRegistrationsTable(this);
  late final Index batchesFarmStatusIdx = Index(
    'batches_farm_status_idx',
    'CREATE INDEX batches_farm_status_idx ON batches (farm_id, status)',
  );
  late final Index mortalityBatchOccurredIdx = Index(
    'mortality_batch_occurred_idx',
    'CREATE INDEX mortality_batch_occurred_idx ON mortality_records (batch_id, occurred_on)',
  );
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  late final SyncMetaDao syncMetaDao = SyncMetaDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    farms,
    farmMembers,
    batches,
    programmes,
    programmeSteps,
    vaccinationTasks,
    feedItems,
    feedTransactions,
    healthRecords,
    mortalityRecords,
    farmEvents,
    entitlements,
    outbox,
    syncCursors,
    syncMeta,
    syncEvents,
    syncLock,
    authSnapshot,
    vetAssistanceRequests,
    caseMessages,
    caseMessageAttachments,
    caseReadStates,
    mediaUploadJobs,
    mediaCache,
    pushRegistrations,
    batchesFarmStatusIdx,
    mortalityBatchOccurredIdx,
  ];
}

typedef $$FarmsTableCreateCompanionBuilder = FarmsCompanion Function({
  required String id,
  required String farmId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> serverVersion,
  required String name,
  Value<String?> location,
  Value<String?> district,
  Value<String?> village,
  Value<String?> phone,
  Value<String?> altPhone,
  Value<String?> notes,
  Value<DateTime?> profileCompletedAt,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<double?> locationAccuracyM,
  Value<DateTime?> locationCapturedAt,
  Value<int> rowid,
});
typedef $$FarmsTableUpdateCompanionBuilder = FarmsCompanion Function({
  Value<String> id,
  Value<String> farmId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> serverVersion,
  Value<String> name,
  Value<String?> location,
  Value<String?> district,
  Value<String?> village,
  Value<String?> phone,
  Value<String?> altPhone,
  Value<String?> notes,
  Value<DateTime?> profileCompletedAt,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<double?> locationAccuracyM,
  Value<DateTime?> locationCapturedAt,
  Value<int> rowid,
});

class $$FarmsTableFilterComposer extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get altPhone => $composableBuilder(
    column: $table.altPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get profileCompletedAt => $composableBuilder(
    column: $table.profileCompletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationAccuracyM => $composableBuilder(
    column: $table.locationAccuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get locationCapturedAt => $composableBuilder(
    column: $table.locationCapturedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FarmsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get altPhone => $composableBuilder(
    column: $table.altPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get profileCompletedAt => $composableBuilder(
    column: $table.profileCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationAccuracyM => $composableBuilder(
    column: $table.locationAccuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get locationCapturedAt => $composableBuilder(
    column: $table.locationCapturedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get village =>
      $composableBuilder(column: $table.village, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get altPhone =>
      $composableBuilder(column: $table.altPhone, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get profileCompletedAt => $composableBuilder(
    column: $table.profileCompletedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get locationAccuracyM => $composableBuilder(
    column: $table.locationAccuracyM,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get locationCapturedAt => $composableBuilder(
    column: $table.locationCapturedAt,
    builder: (column) => column,
  );
}

class $$FarmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmsTable,
          FarmRow,
          $$FarmsTableFilterComposer,
          $$FarmsTableOrderingComposer,
          $$FarmsTableAnnotationComposer,
          $$FarmsTableCreateCompanionBuilder,
          $$FarmsTableUpdateCompanionBuilder,
          (FarmRow, BaseReferences<_$AppDatabase, $FarmsTable, FarmRow>),
          FarmRow,
          PrefetchHooks Function()
        > {
  $$FarmsTableTableManager(_$AppDatabase db, $FarmsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> village = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> altPhone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> profileCompletedAt = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> locationAccuracyM = const Value.absent(),
                Value<DateTime?> locationCapturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmsCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                name: name,
                location: location,
                district: district,
                village: village,
                phone: phone,
                altPhone: altPhone,
                notes: notes,
                profileCompletedAt: profileCompletedAt,
                latitude: latitude,
                longitude: longitude,
                locationAccuracyM: locationAccuracyM,
                locationCapturedAt: locationCapturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String name,
                Value<String?> location = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> village = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> altPhone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> profileCompletedAt = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> locationAccuracyM = const Value.absent(),
                Value<DateTime?> locationCapturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmsCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                name: name,
                location: location,
                district: district,
                village: village,
                phone: phone,
                altPhone: altPhone,
                notes: notes,
                profileCompletedAt: profileCompletedAt,
                latitude: latitude,
                longitude: longitude,
                locationAccuracyM: locationAccuracyM,
                locationCapturedAt: locationCapturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FarmsTable, FarmRow>(table),
                  BaseReferences<_$AppDatabase, $FarmsTable, FarmRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FarmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmsTable,
      FarmRow,
      $$FarmsTableFilterComposer,
      $$FarmsTableOrderingComposer,
      $$FarmsTableAnnotationComposer,
      $$FarmsTableCreateCompanionBuilder,
      $$FarmsTableUpdateCompanionBuilder,
      (FarmRow, BaseReferences<_$AppDatabase, $FarmsTable, FarmRow>),
      FarmRow,
      PrefetchHooks Function()
    >;
typedef $$FarmMembersTableCreateCompanionBuilder =
    FarmMembersCompanion Function({
      required String id,
      required String farmId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      required String userId,
      required String role,
      Value<int> rowid,
    });
typedef $$FarmMembersTableUpdateCompanionBuilder =
    FarmMembersCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<String> userId,
      Value<String> role,
      Value<int> rowid,
    });

class $$FarmMembersTableFilterComposer
    extends Composer<_$AppDatabase, $FarmMembersTable> {
  $$FarmMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FarmMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmMembersTable> {
  $$FarmMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmMembersTable> {
  $$FarmMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $$FarmMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmMembersTable,
          FarmMemberRow,
          $$FarmMembersTableFilterComposer,
          $$FarmMembersTableOrderingComposer,
          $$FarmMembersTableAnnotationComposer,
          $$FarmMembersTableCreateCompanionBuilder,
          $$FarmMembersTableUpdateCompanionBuilder,
          (
            FarmMemberRow,
            BaseReferences<_$AppDatabase, $FarmMembersTable, FarmMemberRow>,
          ),
          FarmMemberRow,
          PrefetchHooks Function()
        > {
  $$FarmMembersTableTableManager(_$AppDatabase db, $FarmMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmMembersCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                userId: userId,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String userId,
                required String role,
                Value<int> rowid = const Value.absent(),
              }) => FarmMembersCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                userId: userId,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FarmMembersTable, FarmMemberRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FarmMembersTable,
                    FarmMemberRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FarmMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmMembersTable,
      FarmMemberRow,
      $$FarmMembersTableFilterComposer,
      $$FarmMembersTableOrderingComposer,
      $$FarmMembersTableAnnotationComposer,
      $$FarmMembersTableCreateCompanionBuilder,
      $$FarmMembersTableUpdateCompanionBuilder,
      (
        FarmMemberRow,
        BaseReferences<_$AppDatabase, $FarmMembersTable, FarmMemberRow>,
      ),
      FarmMemberRow,
      PrefetchHooks Function()
    >;
typedef $$BatchesTableCreateCompanionBuilder = BatchesCompanion Function({
  required String id,
  required String farmId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> serverVersion,
  required String name,
  required String birdType,
  required int initialCount,
  required DateTime acquiredOn,
  Value<int> ageAtAcquisitionDays,
  Value<bool?> hatcheryVaccinated,
  Value<String?> source,
  required String status,
  required String programmeId,
  required int programmeVersion,
  Value<String?> productionType,
  Value<String?> programmeContentHash,
  Value<String?> notes,
  Value<DateTime?> closedOn,
  Value<String?> closeReason,
  Value<String?> closeNote,
  Value<String?> deletedGroupId,
  Value<int> rowid,
});
typedef $$BatchesTableUpdateCompanionBuilder = BatchesCompanion Function({
  Value<String> id,
  Value<String> farmId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> serverVersion,
  Value<String> name,
  Value<String> birdType,
  Value<int> initialCount,
  Value<DateTime> acquiredOn,
  Value<int> ageAtAcquisitionDays,
  Value<bool?> hatcheryVaccinated,
  Value<String?> source,
  Value<String> status,
  Value<String> programmeId,
  Value<int> programmeVersion,
  Value<String?> productionType,
  Value<String?> programmeContentHash,
  Value<String?> notes,
  Value<DateTime?> closedOn,
  Value<String?> closeReason,
  Value<String?> closeNote,
  Value<String?> deletedGroupId,
  Value<int> rowid,
});

class $$BatchesTableFilterComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birdType => $composableBuilder(
    column: $table.birdType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialCount => $composableBuilder(
    column: $table.initialCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acquiredOn => $composableBuilder(
    column: $table.acquiredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageAtAcquisitionDays => $composableBuilder(
    column: $table.ageAtAcquisitionDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hatcheryVaccinated => $composableBuilder(
    column: $table.hatcheryVaccinated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get programmeId => $composableBuilder(
    column: $table.programmeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get programmeVersion => $composableBuilder(
    column: $table.programmeVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productionType => $composableBuilder(
    column: $table.productionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get programmeContentHash => $composableBuilder(
    column: $table.programmeContentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedOn => $composableBuilder(
    column: $table.closedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closeReason => $composableBuilder(
    column: $table.closeReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closeNote => $composableBuilder(
    column: $table.closeNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedGroupId => $composableBuilder(
    column: $table.deletedGroupId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birdType => $composableBuilder(
    column: $table.birdType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialCount => $composableBuilder(
    column: $table.initialCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acquiredOn => $composableBuilder(
    column: $table.acquiredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageAtAcquisitionDays => $composableBuilder(
    column: $table.ageAtAcquisitionDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hatcheryVaccinated => $composableBuilder(
    column: $table.hatcheryVaccinated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get programmeId => $composableBuilder(
    column: $table.programmeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get programmeVersion => $composableBuilder(
    column: $table.programmeVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productionType => $composableBuilder(
    column: $table.productionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get programmeContentHash => $composableBuilder(
    column: $table.programmeContentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedOn => $composableBuilder(
    column: $table.closedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closeReason => $composableBuilder(
    column: $table.closeReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closeNote => $composableBuilder(
    column: $table.closeNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedGroupId => $composableBuilder(
    column: $table.deletedGroupId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get birdType =>
      $composableBuilder(column: $table.birdType, builder: (column) => column);

  GeneratedColumn<int> get initialCount => $composableBuilder(
    column: $table.initialCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get acquiredOn => $composableBuilder(
    column: $table.acquiredOn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ageAtAcquisitionDays => $composableBuilder(
    column: $table.ageAtAcquisitionDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hatcheryVaccinated => $composableBuilder(
    column: $table.hatcheryVaccinated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get programmeId => $composableBuilder(
    column: $table.programmeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get programmeVersion => $composableBuilder(
    column: $table.programmeVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productionType => $composableBuilder(
    column: $table.productionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get programmeContentHash => $composableBuilder(
    column: $table.programmeContentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get closedOn =>
      $composableBuilder(column: $table.closedOn, builder: (column) => column);

  GeneratedColumn<String> get closeReason => $composableBuilder(
    column: $table.closeReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get closeNote =>
      $composableBuilder(column: $table.closeNote, builder: (column) => column);

  GeneratedColumn<String> get deletedGroupId => $composableBuilder(
    column: $table.deletedGroupId,
    builder: (column) => column,
  );
}

class $$BatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchesTable,
          BatchRow,
          $$BatchesTableFilterComposer,
          $$BatchesTableOrderingComposer,
          $$BatchesTableAnnotationComposer,
          $$BatchesTableCreateCompanionBuilder,
          $$BatchesTableUpdateCompanionBuilder,
          (BatchRow, BaseReferences<_$AppDatabase, $BatchesTable, BatchRow>),
          BatchRow,
          PrefetchHooks Function()
        > {
  $$BatchesTableTableManager(_$AppDatabase db, $BatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> birdType = const Value.absent(),
                Value<int> initialCount = const Value.absent(),
                Value<DateTime> acquiredOn = const Value.absent(),
                Value<int> ageAtAcquisitionDays = const Value.absent(),
                Value<bool?> hatcheryVaccinated = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> programmeId = const Value.absent(),
                Value<int> programmeVersion = const Value.absent(),
                Value<String?> productionType = const Value.absent(),
                Value<String?> programmeContentHash = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> closedOn = const Value.absent(),
                Value<String?> closeReason = const Value.absent(),
                Value<String?> closeNote = const Value.absent(),
                Value<String?> deletedGroupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                name: name,
                birdType: birdType,
                initialCount: initialCount,
                acquiredOn: acquiredOn,
                ageAtAcquisitionDays: ageAtAcquisitionDays,
                hatcheryVaccinated: hatcheryVaccinated,
                source: source,
                status: status,
                programmeId: programmeId,
                programmeVersion: programmeVersion,
                productionType: productionType,
                programmeContentHash: programmeContentHash,
                notes: notes,
                closedOn: closedOn,
                closeReason: closeReason,
                closeNote: closeNote,
                deletedGroupId: deletedGroupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String name,
                required String birdType,
                required int initialCount,
                required DateTime acquiredOn,
                Value<int> ageAtAcquisitionDays = const Value.absent(),
                Value<bool?> hatcheryVaccinated = const Value.absent(),
                Value<String?> source = const Value.absent(),
                required String status,
                required String programmeId,
                required int programmeVersion,
                Value<String?> productionType = const Value.absent(),
                Value<String?> programmeContentHash = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> closedOn = const Value.absent(),
                Value<String?> closeReason = const Value.absent(),
                Value<String?> closeNote = const Value.absent(),
                Value<String?> deletedGroupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                name: name,
                birdType: birdType,
                initialCount: initialCount,
                acquiredOn: acquiredOn,
                ageAtAcquisitionDays: ageAtAcquisitionDays,
                hatcheryVaccinated: hatcheryVaccinated,
                source: source,
                status: status,
                programmeId: programmeId,
                programmeVersion: programmeVersion,
                productionType: productionType,
                programmeContentHash: programmeContentHash,
                notes: notes,
                closedOn: closedOn,
                closeReason: closeReason,
                closeNote: closeNote,
                deletedGroupId: deletedGroupId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BatchesTable, BatchRow>(table),
                  BaseReferences<_$AppDatabase, $BatchesTable, BatchRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchesTable,
      BatchRow,
      $$BatchesTableFilterComposer,
      $$BatchesTableOrderingComposer,
      $$BatchesTableAnnotationComposer,
      $$BatchesTableCreateCompanionBuilder,
      $$BatchesTableUpdateCompanionBuilder,
      (BatchRow, BaseReferences<_$AppDatabase, $BatchesTable, BatchRow>),
      BatchRow,
      PrefetchHooks Function()
    >;
typedef $$ProgrammesTableCreateCompanionBuilder = ProgrammesCompanion Function({
  required String id,
  required String farmId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> serverVersion,
  required String name,
  required int version,
  required String birdTypesJson,
  Value<int> rowid,
});
typedef $$ProgrammesTableUpdateCompanionBuilder = ProgrammesCompanion Function({
  Value<String> id,
  Value<String> farmId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> serverVersion,
  Value<String> name,
  Value<int> version,
  Value<String> birdTypesJson,
  Value<int> rowid,
});

class $$ProgrammesTableFilterComposer
    extends Composer<_$AppDatabase, $ProgrammesTable> {
  $$ProgrammesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birdTypesJson => $composableBuilder(
    column: $table.birdTypesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgrammesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgrammesTable> {
  $$ProgrammesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birdTypesJson => $composableBuilder(
    column: $table.birdTypesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgrammesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgrammesTable> {
  $$ProgrammesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get birdTypesJson => $composableBuilder(
    column: $table.birdTypesJson,
    builder: (column) => column,
  );
}

class $$ProgrammesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgrammesTable,
          ProgrammeRow,
          $$ProgrammesTableFilterComposer,
          $$ProgrammesTableOrderingComposer,
          $$ProgrammesTableAnnotationComposer,
          $$ProgrammesTableCreateCompanionBuilder,
          $$ProgrammesTableUpdateCompanionBuilder,
          (
            ProgrammeRow,
            BaseReferences<_$AppDatabase, $ProgrammesTable, ProgrammeRow>,
          ),
          ProgrammeRow,
          PrefetchHooks Function()
        > {
  $$ProgrammesTableTableManager(_$AppDatabase db, $ProgrammesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgrammesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgrammesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgrammesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> birdTypesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgrammesCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                name: name,
                version: version,
                birdTypesJson: birdTypesJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String name,
                required int version,
                required String birdTypesJson,
                Value<int> rowid = const Value.absent(),
              }) => ProgrammesCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                name: name,
                version: version,
                birdTypesJson: birdTypesJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProgrammesTable, ProgrammeRow>(table),
                  BaseReferences<_$AppDatabase, $ProgrammesTable, ProgrammeRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgrammesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgrammesTable,
      ProgrammeRow,
      $$ProgrammesTableFilterComposer,
      $$ProgrammesTableOrderingComposer,
      $$ProgrammesTableAnnotationComposer,
      $$ProgrammesTableCreateCompanionBuilder,
      $$ProgrammesTableUpdateCompanionBuilder,
      (
        ProgrammeRow,
        BaseReferences<_$AppDatabase, $ProgrammesTable, ProgrammeRow>,
      ),
      ProgrammeRow,
      PrefetchHooks Function()
    >;
typedef $$ProgrammeStepsTableCreateCompanionBuilder =
    ProgrammeStepsCompanion Function({
      required String id,
      required String farmId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      required String programmeId,
      required String name,
      required int ageDays,
      required String location,
      Value<bool> optional,
      Value<int> dueWindowDaysBefore,
      Value<int> dueWindowDaysAfter,
      Value<String?> recurringJson,
      Value<int> rowid,
    });
typedef $$ProgrammeStepsTableUpdateCompanionBuilder =
    ProgrammeStepsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<String> programmeId,
      Value<String> name,
      Value<int> ageDays,
      Value<String> location,
      Value<bool> optional,
      Value<int> dueWindowDaysBefore,
      Value<int> dueWindowDaysAfter,
      Value<String?> recurringJson,
      Value<int> rowid,
    });

class $$ProgrammeStepsTableFilterComposer
    extends Composer<_$AppDatabase, $ProgrammeStepsTable> {
  $$ProgrammeStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get programmeId => $composableBuilder(
    column: $table.programmeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageDays => $composableBuilder(
    column: $table.ageDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get optional => $composableBuilder(
    column: $table.optional,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueWindowDaysBefore => $composableBuilder(
    column: $table.dueWindowDaysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueWindowDaysAfter => $composableBuilder(
    column: $table.dueWindowDaysAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringJson => $composableBuilder(
    column: $table.recurringJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgrammeStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgrammeStepsTable> {
  $$ProgrammeStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get programmeId => $composableBuilder(
    column: $table.programmeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageDays => $composableBuilder(
    column: $table.ageDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get optional => $composableBuilder(
    column: $table.optional,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueWindowDaysBefore => $composableBuilder(
    column: $table.dueWindowDaysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueWindowDaysAfter => $composableBuilder(
    column: $table.dueWindowDaysAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringJson => $composableBuilder(
    column: $table.recurringJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgrammeStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgrammeStepsTable> {
  $$ProgrammeStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get programmeId => $composableBuilder(
    column: $table.programmeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get ageDays =>
      $composableBuilder(column: $table.ageDays, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<bool> get optional =>
      $composableBuilder(column: $table.optional, builder: (column) => column);

  GeneratedColumn<int> get dueWindowDaysBefore => $composableBuilder(
    column: $table.dueWindowDaysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueWindowDaysAfter => $composableBuilder(
    column: $table.dueWindowDaysAfter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurringJson => $composableBuilder(
    column: $table.recurringJson,
    builder: (column) => column,
  );
}

class $$ProgrammeStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgrammeStepsTable,
          ProgrammeStepRow,
          $$ProgrammeStepsTableFilterComposer,
          $$ProgrammeStepsTableOrderingComposer,
          $$ProgrammeStepsTableAnnotationComposer,
          $$ProgrammeStepsTableCreateCompanionBuilder,
          $$ProgrammeStepsTableUpdateCompanionBuilder,
          (
            ProgrammeStepRow,
            BaseReferences<
              _$AppDatabase,
              $ProgrammeStepsTable,
              ProgrammeStepRow
            >,
          ),
          ProgrammeStepRow,
          PrefetchHooks Function()
        > {
  $$ProgrammeStepsTableTableManager(
    _$AppDatabase db,
    $ProgrammeStepsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgrammeStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgrammeStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgrammeStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> programmeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> ageDays = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<bool> optional = const Value.absent(),
                Value<int> dueWindowDaysBefore = const Value.absent(),
                Value<int> dueWindowDaysAfter = const Value.absent(),
                Value<String?> recurringJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgrammeStepsCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                programmeId: programmeId,
                name: name,
                ageDays: ageDays,
                location: location,
                optional: optional,
                dueWindowDaysBefore: dueWindowDaysBefore,
                dueWindowDaysAfter: dueWindowDaysAfter,
                recurringJson: recurringJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String programmeId,
                required String name,
                required int ageDays,
                required String location,
                Value<bool> optional = const Value.absent(),
                Value<int> dueWindowDaysBefore = const Value.absent(),
                Value<int> dueWindowDaysAfter = const Value.absent(),
                Value<String?> recurringJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgrammeStepsCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                programmeId: programmeId,
                name: name,
                ageDays: ageDays,
                location: location,
                optional: optional,
                dueWindowDaysBefore: dueWindowDaysBefore,
                dueWindowDaysAfter: dueWindowDaysAfter,
                recurringJson: recurringJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProgrammeStepsTable, ProgrammeStepRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProgrammeStepsTable,
                    ProgrammeStepRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgrammeStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgrammeStepsTable,
      ProgrammeStepRow,
      $$ProgrammeStepsTableFilterComposer,
      $$ProgrammeStepsTableOrderingComposer,
      $$ProgrammeStepsTableAnnotationComposer,
      $$ProgrammeStepsTableCreateCompanionBuilder,
      $$ProgrammeStepsTableUpdateCompanionBuilder,
      (
        ProgrammeStepRow,
        BaseReferences<_$AppDatabase, $ProgrammeStepsTable, ProgrammeStepRow>,
      ),
      ProgrammeStepRow,
      PrefetchHooks Function()
    >;
typedef $$VaccinationTasksTableCreateCompanionBuilder =
    VaccinationTasksCompanion Function({
      required String id,
      required String farmId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      required String batchId,
      required String stepId,
      Value<int> occurrence,
      required DateTime dueOn,
      Value<bool> enabled,
      required String status,
      Value<DateTime?> doneOn,
      Value<String?> doneBy,
      Value<String?> productUsed,
      Value<String?> notes,
      Value<String?> stepSnapshot,
      Value<String?> programmeContentHash,
      Value<DateTime?> shiftedFrom,
      Value<String?> deletedGroupId,
      Value<int> rowid,
    });
typedef $$VaccinationTasksTableUpdateCompanionBuilder =
    VaccinationTasksCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<String> batchId,
      Value<String> stepId,
      Value<int> occurrence,
      Value<DateTime> dueOn,
      Value<bool> enabled,
      Value<String> status,
      Value<DateTime?> doneOn,
      Value<String?> doneBy,
      Value<String?> productUsed,
      Value<String?> notes,
      Value<String?> stepSnapshot,
      Value<String?> programmeContentHash,
      Value<DateTime?> shiftedFrom,
      Value<String?> deletedGroupId,
      Value<int> rowid,
    });

class $$VaccinationTasksTableFilterComposer
    extends Composer<_$AppDatabase, $VaccinationTasksTable> {
  $$VaccinationTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepId => $composableBuilder(
    column: $table.stepId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurrence => $composableBuilder(
    column: $table.occurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get doneOn => $composableBuilder(
    column: $table.doneOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doneBy => $composableBuilder(
    column: $table.doneBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productUsed => $composableBuilder(
    column: $table.productUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepSnapshot => $composableBuilder(
    column: $table.stepSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get programmeContentHash => $composableBuilder(
    column: $table.programmeContentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get shiftedFrom => $composableBuilder(
    column: $table.shiftedFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedGroupId => $composableBuilder(
    column: $table.deletedGroupId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaccinationTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $VaccinationTasksTable> {
  $$VaccinationTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepId => $composableBuilder(
    column: $table.stepId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurrence => $composableBuilder(
    column: $table.occurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get doneOn => $composableBuilder(
    column: $table.doneOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doneBy => $composableBuilder(
    column: $table.doneBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productUsed => $composableBuilder(
    column: $table.productUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepSnapshot => $composableBuilder(
    column: $table.stepSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get programmeContentHash => $composableBuilder(
    column: $table.programmeContentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get shiftedFrom => $composableBuilder(
    column: $table.shiftedFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedGroupId => $composableBuilder(
    column: $table.deletedGroupId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaccinationTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaccinationTasksTable> {
  $$VaccinationTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get stepId =>
      $composableBuilder(column: $table.stepId, builder: (column) => column);

  GeneratedColumn<int> get occurrence => $composableBuilder(
    column: $table.occurrence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueOn =>
      $composableBuilder(column: $table.dueOn, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get doneOn =>
      $composableBuilder(column: $table.doneOn, builder: (column) => column);

  GeneratedColumn<String> get doneBy =>
      $composableBuilder(column: $table.doneBy, builder: (column) => column);

  GeneratedColumn<String> get productUsed => $composableBuilder(
    column: $table.productUsed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get stepSnapshot => $composableBuilder(
    column: $table.stepSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get programmeContentHash => $composableBuilder(
    column: $table.programmeContentHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get shiftedFrom => $composableBuilder(
    column: $table.shiftedFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deletedGroupId => $composableBuilder(
    column: $table.deletedGroupId,
    builder: (column) => column,
  );
}

class $$VaccinationTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaccinationTasksTable,
          VaccinationTaskRow,
          $$VaccinationTasksTableFilterComposer,
          $$VaccinationTasksTableOrderingComposer,
          $$VaccinationTasksTableAnnotationComposer,
          $$VaccinationTasksTableCreateCompanionBuilder,
          $$VaccinationTasksTableUpdateCompanionBuilder,
          (
            VaccinationTaskRow,
            BaseReferences<
              _$AppDatabase,
              $VaccinationTasksTable,
              VaccinationTaskRow
            >,
          ),
          VaccinationTaskRow,
          PrefetchHooks Function()
        > {
  $$VaccinationTasksTableTableManager(
    _$AppDatabase db,
    $VaccinationTasksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaccinationTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaccinationTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaccinationTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> stepId = const Value.absent(),
                Value<int> occurrence = const Value.absent(),
                Value<DateTime> dueOn = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> doneOn = const Value.absent(),
                Value<String?> doneBy = const Value.absent(),
                Value<String?> productUsed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> stepSnapshot = const Value.absent(),
                Value<String?> programmeContentHash = const Value.absent(),
                Value<DateTime?> shiftedFrom = const Value.absent(),
                Value<String?> deletedGroupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaccinationTasksCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                batchId: batchId,
                stepId: stepId,
                occurrence: occurrence,
                dueOn: dueOn,
                enabled: enabled,
                status: status,
                doneOn: doneOn,
                doneBy: doneBy,
                productUsed: productUsed,
                notes: notes,
                stepSnapshot: stepSnapshot,
                programmeContentHash: programmeContentHash,
                shiftedFrom: shiftedFrom,
                deletedGroupId: deletedGroupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String batchId,
                required String stepId,
                Value<int> occurrence = const Value.absent(),
                required DateTime dueOn,
                Value<bool> enabled = const Value.absent(),
                required String status,
                Value<DateTime?> doneOn = const Value.absent(),
                Value<String?> doneBy = const Value.absent(),
                Value<String?> productUsed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> stepSnapshot = const Value.absent(),
                Value<String?> programmeContentHash = const Value.absent(),
                Value<DateTime?> shiftedFrom = const Value.absent(),
                Value<String?> deletedGroupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaccinationTasksCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                batchId: batchId,
                stepId: stepId,
                occurrence: occurrence,
                dueOn: dueOn,
                enabled: enabled,
                status: status,
                doneOn: doneOn,
                doneBy: doneBy,
                productUsed: productUsed,
                notes: notes,
                stepSnapshot: stepSnapshot,
                programmeContentHash: programmeContentHash,
                shiftedFrom: shiftedFrom,
                deletedGroupId: deletedGroupId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VaccinationTasksTable, VaccinationTaskRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $VaccinationTasksTable,
                    VaccinationTaskRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaccinationTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaccinationTasksTable,
      VaccinationTaskRow,
      $$VaccinationTasksTableFilterComposer,
      $$VaccinationTasksTableOrderingComposer,
      $$VaccinationTasksTableAnnotationComposer,
      $$VaccinationTasksTableCreateCompanionBuilder,
      $$VaccinationTasksTableUpdateCompanionBuilder,
      (
        VaccinationTaskRow,
        BaseReferences<
          _$AppDatabase,
          $VaccinationTasksTable,
          VaccinationTaskRow
        >,
      ),
      VaccinationTaskRow,
      PrefetchHooks Function()
    >;
typedef $$FeedItemsTableCreateCompanionBuilder = FeedItemsCompanion Function({
  required String id,
  required String farmId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> serverVersion,
  required String name,
  required String feedType,
  required String unit,
  Value<double?> reorderLevel,
  Value<int> rowid,
});
typedef $$FeedItemsTableUpdateCompanionBuilder = FeedItemsCompanion Function({
  Value<String> id,
  Value<String> farmId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> serverVersion,
  Value<String> name,
  Value<String> feedType,
  Value<String> unit,
  Value<double?> reorderLevel,
  Value<int> rowid,
});

class $$FeedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedItemsTable> {
  $$FeedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedType => $composableBuilder(
    column: $table.feedType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedItemsTable> {
  $$FeedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedType => $composableBuilder(
    column: $table.feedType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedItemsTable> {
  $$FeedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get feedType =>
      $composableBuilder(column: $table.feedType, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => column,
  );
}

class $$FeedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedItemsTable,
          FeedItemRow,
          $$FeedItemsTableFilterComposer,
          $$FeedItemsTableOrderingComposer,
          $$FeedItemsTableAnnotationComposer,
          $$FeedItemsTableCreateCompanionBuilder,
          $$FeedItemsTableUpdateCompanionBuilder,
          (
            FeedItemRow,
            BaseReferences<_$AppDatabase, $FeedItemsTable, FeedItemRow>,
          ),
          FeedItemRow,
          PrefetchHooks Function()
        > {
  $$FeedItemsTableTableManager(_$AppDatabase db, $FeedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> feedType = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double?> reorderLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedItemsCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                name: name,
                feedType: feedType,
                unit: unit,
                reorderLevel: reorderLevel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String name,
                required String feedType,
                required String unit,
                Value<double?> reorderLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedItemsCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                name: name,
                feedType: feedType,
                unit: unit,
                reorderLevel: reorderLevel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeedItemsTable, FeedItemRow>(table),
                  BaseReferences<_$AppDatabase, $FeedItemsTable, FeedItemRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedItemsTable,
      FeedItemRow,
      $$FeedItemsTableFilterComposer,
      $$FeedItemsTableOrderingComposer,
      $$FeedItemsTableAnnotationComposer,
      $$FeedItemsTableCreateCompanionBuilder,
      $$FeedItemsTableUpdateCompanionBuilder,
      (
        FeedItemRow,
        BaseReferences<_$AppDatabase, $FeedItemsTable, FeedItemRow>,
      ),
      FeedItemRow,
      PrefetchHooks Function()
    >;
typedef $$FeedTransactionsTableCreateCompanionBuilder =
    FeedTransactionsCompanion Function({
      required String id,
      required String farmId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      required String feedItemId,
      Value<String?> batchId,
      required String kind,
      required double quantity,
      Value<double?> unitCost,
      required DateTime occurredOn,
      Value<int> rowid,
    });
typedef $$FeedTransactionsTableUpdateCompanionBuilder =
    FeedTransactionsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<String> feedItemId,
      Value<String?> batchId,
      Value<String> kind,
      Value<double> quantity,
      Value<double?> unitCost,
      Value<DateTime> occurredOn,
      Value<int> rowid,
    });

class $$FeedTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedTransactionsTable> {
  $$FeedTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedItemId => $composableBuilder(
    column: $table.feedItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedTransactionsTable> {
  $$FeedTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedItemId => $composableBuilder(
    column: $table.feedItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedTransactionsTable> {
  $$FeedTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedItemId => $composableBuilder(
    column: $table.feedItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => column,
  );
}

class $$FeedTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedTransactionsTable,
          FeedTransactionRow,
          $$FeedTransactionsTableFilterComposer,
          $$FeedTransactionsTableOrderingComposer,
          $$FeedTransactionsTableAnnotationComposer,
          $$FeedTransactionsTableCreateCompanionBuilder,
          $$FeedTransactionsTableUpdateCompanionBuilder,
          (
            FeedTransactionRow,
            BaseReferences<
              _$AppDatabase,
              $FeedTransactionsTable,
              FeedTransactionRow
            >,
          ),
          FeedTransactionRow,
          PrefetchHooks Function()
        > {
  $$FeedTransactionsTableTableManager(
    _$AppDatabase db,
    $FeedTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedTransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> feedItemId = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double?> unitCost = const Value.absent(),
                Value<DateTime> occurredOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedTransactionsCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                feedItemId: feedItemId,
                batchId: batchId,
                kind: kind,
                quantity: quantity,
                unitCost: unitCost,
                occurredOn: occurredOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String feedItemId,
                Value<String?> batchId = const Value.absent(),
                required String kind,
                required double quantity,
                Value<double?> unitCost = const Value.absent(),
                required DateTime occurredOn,
                Value<int> rowid = const Value.absent(),
              }) => FeedTransactionsCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                feedItemId: feedItemId,
                batchId: batchId,
                kind: kind,
                quantity: quantity,
                unitCost: unitCost,
                occurredOn: occurredOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeedTransactionsTable, FeedTransactionRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $FeedTransactionsTable,
                    FeedTransactionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedTransactionsTable,
      FeedTransactionRow,
      $$FeedTransactionsTableFilterComposer,
      $$FeedTransactionsTableOrderingComposer,
      $$FeedTransactionsTableAnnotationComposer,
      $$FeedTransactionsTableCreateCompanionBuilder,
      $$FeedTransactionsTableUpdateCompanionBuilder,
      (
        FeedTransactionRow,
        BaseReferences<
          _$AppDatabase,
          $FeedTransactionsTable,
          FeedTransactionRow
        >,
      ),
      FeedTransactionRow,
      PrefetchHooks Function()
    >;
typedef $$HealthRecordsTableCreateCompanionBuilder =
    HealthRecordsCompanion Function({
      required String id,
      required String farmId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      required String batchId,
      required DateTime occurredOn,
      required String summary,
      Value<String?> notes,
      Value<int?> affectedBirdCount,
      Value<String> symptomsJson,
      Value<String> recordKind,
      Value<String> photoObjectKeysJson,
      Value<String> pendingPhotoPathsJson,
      Value<int> rowid,
    });
typedef $$HealthRecordsTableUpdateCompanionBuilder =
    HealthRecordsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<String> batchId,
      Value<DateTime> occurredOn,
      Value<String> summary,
      Value<String?> notes,
      Value<int?> affectedBirdCount,
      Value<String> symptomsJson,
      Value<String> recordKind,
      Value<String> photoObjectKeysJson,
      Value<String> pendingPhotoPathsJson,
      Value<int> rowid,
    });

class $$HealthRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $HealthRecordsTable> {
  $$HealthRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get affectedBirdCount => $composableBuilder(
    column: $table.affectedBirdCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptomsJson => $composableBuilder(
    column: $table.symptomsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordKind => $composableBuilder(
    column: $table.recordKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoObjectKeysJson => $composableBuilder(
    column: $table.photoObjectKeysJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingPhotoPathsJson => $composableBuilder(
    column: $table.pendingPhotoPathsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthRecordsTable> {
  $$HealthRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get affectedBirdCount => $composableBuilder(
    column: $table.affectedBirdCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptomsJson => $composableBuilder(
    column: $table.symptomsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordKind => $composableBuilder(
    column: $table.recordKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoObjectKeysJson => $composableBuilder(
    column: $table.photoObjectKeysJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingPhotoPathsJson => $composableBuilder(
    column: $table.pendingPhotoPathsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthRecordsTable> {
  $$HealthRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get affectedBirdCount => $composableBuilder(
    column: $table.affectedBirdCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get symptomsJson => $composableBuilder(
    column: $table.symptomsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordKind => $composableBuilder(
    column: $table.recordKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoObjectKeysJson => $composableBuilder(
    column: $table.photoObjectKeysJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pendingPhotoPathsJson => $composableBuilder(
    column: $table.pendingPhotoPathsJson,
    builder: (column) => column,
  );
}

class $$HealthRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthRecordsTable,
          HealthRecordRow,
          $$HealthRecordsTableFilterComposer,
          $$HealthRecordsTableOrderingComposer,
          $$HealthRecordsTableAnnotationComposer,
          $$HealthRecordsTableCreateCompanionBuilder,
          $$HealthRecordsTableUpdateCompanionBuilder,
          (
            HealthRecordRow,
            BaseReferences<_$AppDatabase, $HealthRecordsTable, HealthRecordRow>,
          ),
          HealthRecordRow,
          PrefetchHooks Function()
        > {
  $$HealthRecordsTableTableManager(_$AppDatabase db, $HealthRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<DateTime> occurredOn = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> affectedBirdCount = const Value.absent(),
                Value<String> symptomsJson = const Value.absent(),
                Value<String> recordKind = const Value.absent(),
                Value<String> photoObjectKeysJson = const Value.absent(),
                Value<String> pendingPhotoPathsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthRecordsCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                batchId: batchId,
                occurredOn: occurredOn,
                summary: summary,
                notes: notes,
                affectedBirdCount: affectedBirdCount,
                symptomsJson: symptomsJson,
                recordKind: recordKind,
                photoObjectKeysJson: photoObjectKeysJson,
                pendingPhotoPathsJson: pendingPhotoPathsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String batchId,
                required DateTime occurredOn,
                required String summary,
                Value<String?> notes = const Value.absent(),
                Value<int?> affectedBirdCount = const Value.absent(),
                Value<String> symptomsJson = const Value.absent(),
                Value<String> recordKind = const Value.absent(),
                Value<String> photoObjectKeysJson = const Value.absent(),
                Value<String> pendingPhotoPathsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HealthRecordsCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                batchId: batchId,
                occurredOn: occurredOn,
                summary: summary,
                notes: notes,
                affectedBirdCount: affectedBirdCount,
                symptomsJson: symptomsJson,
                recordKind: recordKind,
                photoObjectKeysJson: photoObjectKeysJson,
                pendingPhotoPathsJson: pendingPhotoPathsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HealthRecordsTable, HealthRecordRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $HealthRecordsTable,
                    HealthRecordRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthRecordsTable,
      HealthRecordRow,
      $$HealthRecordsTableFilterComposer,
      $$HealthRecordsTableOrderingComposer,
      $$HealthRecordsTableAnnotationComposer,
      $$HealthRecordsTableCreateCompanionBuilder,
      $$HealthRecordsTableUpdateCompanionBuilder,
      (
        HealthRecordRow,
        BaseReferences<_$AppDatabase, $HealthRecordsTable, HealthRecordRow>,
      ),
      HealthRecordRow,
      PrefetchHooks Function()
    >;
typedef $$MortalityRecordsTableCreateCompanionBuilder =
    MortalityRecordsCompanion Function({
      required String id,
      required String farmId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      required String batchId,
      required int count,
      Value<String> kind,
      Value<String?> suspectedCause,
      required DateTime occurredOn,
      Value<String?> notes,
      Value<DateTime?> editedAt,
      Value<String?> deletedGroupId,
      Value<int> rowid,
    });
typedef $$MortalityRecordsTableUpdateCompanionBuilder =
    MortalityRecordsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<String> batchId,
      Value<int> count,
      Value<String> kind,
      Value<String?> suspectedCause,
      Value<DateTime> occurredOn,
      Value<String?> notes,
      Value<DateTime?> editedAt,
      Value<String?> deletedGroupId,
      Value<int> rowid,
    });

class $$MortalityRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MortalityRecordsTable> {
  $$MortalityRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suspectedCause => $composableBuilder(
    column: $table.suspectedCause,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedGroupId => $composableBuilder(
    column: $table.deletedGroupId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MortalityRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MortalityRecordsTable> {
  $$MortalityRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suspectedCause => $composableBuilder(
    column: $table.suspectedCause,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedGroupId => $composableBuilder(
    column: $table.deletedGroupId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MortalityRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MortalityRecordsTable> {
  $$MortalityRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get suspectedCause => $composableBuilder(
    column: $table.suspectedCause,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedGroupId => $composableBuilder(
    column: $table.deletedGroupId,
    builder: (column) => column,
  );
}

class $$MortalityRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MortalityRecordsTable,
          MortalityRecordRow,
          $$MortalityRecordsTableFilterComposer,
          $$MortalityRecordsTableOrderingComposer,
          $$MortalityRecordsTableAnnotationComposer,
          $$MortalityRecordsTableCreateCompanionBuilder,
          $$MortalityRecordsTableUpdateCompanionBuilder,
          (
            MortalityRecordRow,
            BaseReferences<
              _$AppDatabase,
              $MortalityRecordsTable,
              MortalityRecordRow
            >,
          ),
          MortalityRecordRow,
          PrefetchHooks Function()
        > {
  $$MortalityRecordsTableTableManager(
    _$AppDatabase db,
    $MortalityRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MortalityRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MortalityRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MortalityRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> suspectedCause = const Value.absent(),
                Value<DateTime> occurredOn = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<String?> deletedGroupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MortalityRecordsCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                batchId: batchId,
                count: count,
                kind: kind,
                suspectedCause: suspectedCause,
                occurredOn: occurredOn,
                notes: notes,
                editedAt: editedAt,
                deletedGroupId: deletedGroupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String batchId,
                required int count,
                Value<String> kind = const Value.absent(),
                Value<String?> suspectedCause = const Value.absent(),
                required DateTime occurredOn,
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<String?> deletedGroupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MortalityRecordsCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                batchId: batchId,
                count: count,
                kind: kind,
                suspectedCause: suspectedCause,
                occurredOn: occurredOn,
                notes: notes,
                editedAt: editedAt,
                deletedGroupId: deletedGroupId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MortalityRecordsTable, MortalityRecordRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $MortalityRecordsTable,
                    MortalityRecordRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MortalityRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MortalityRecordsTable,
      MortalityRecordRow,
      $$MortalityRecordsTableFilterComposer,
      $$MortalityRecordsTableOrderingComposer,
      $$MortalityRecordsTableAnnotationComposer,
      $$MortalityRecordsTableCreateCompanionBuilder,
      $$MortalityRecordsTableUpdateCompanionBuilder,
      (
        MortalityRecordRow,
        BaseReferences<
          _$AppDatabase,
          $MortalityRecordsTable,
          MortalityRecordRow
        >,
      ),
      MortalityRecordRow,
      PrefetchHooks Function()
    >;
typedef $$FarmEventsTableCreateCompanionBuilder = FarmEventsCompanion Function({
  required String id,
  required String farmId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> serverVersion,
  Value<String?> batchId,
  required String eventType,
  required DateTime occurredOn,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$FarmEventsTableUpdateCompanionBuilder = FarmEventsCompanion Function({
  Value<String> id,
  Value<String> farmId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int?> serverVersion,
  Value<String?> batchId,
  Value<String> eventType,
  Value<DateTime> occurredOn,
  Value<String?> notes,
  Value<int> rowid,
});

class $$FarmEventsTableFilterComposer
    extends Composer<_$AppDatabase, $FarmEventsTable> {
  $$FarmEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FarmEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmEventsTable> {
  $$FarmEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmEventsTable> {
  $$FarmEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$FarmEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmEventsTable,
          FarmEventRow,
          $$FarmEventsTableFilterComposer,
          $$FarmEventsTableOrderingComposer,
          $$FarmEventsTableAnnotationComposer,
          $$FarmEventsTableCreateCompanionBuilder,
          $$FarmEventsTableUpdateCompanionBuilder,
          (
            FarmEventRow,
            BaseReferences<_$AppDatabase, $FarmEventsTable, FarmEventRow>,
          ),
          FarmEventRow,
          PrefetchHooks Function()
        > {
  $$FarmEventsTableTableManager(_$AppDatabase db, $FarmEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> occurredOn = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmEventsCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                batchId: batchId,
                eventType: eventType,
                occurredOn: occurredOn,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                required String eventType,
                required DateTime occurredOn,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmEventsCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                batchId: batchId,
                eventType: eventType,
                occurredOn: occurredOn,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FarmEventsTable, FarmEventRow>(table),
                  BaseReferences<_$AppDatabase, $FarmEventsTable, FarmEventRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FarmEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmEventsTable,
      FarmEventRow,
      $$FarmEventsTableFilterComposer,
      $$FarmEventsTableOrderingComposer,
      $$FarmEventsTableAnnotationComposer,
      $$FarmEventsTableCreateCompanionBuilder,
      $$FarmEventsTableUpdateCompanionBuilder,
      (
        FarmEventRow,
        BaseReferences<_$AppDatabase, $FarmEventsTable, FarmEventRow>,
      ),
      FarmEventRow,
      PrefetchHooks Function()
    >;
typedef $$EntitlementsTableCreateCompanionBuilder =
    EntitlementsCompanion Function({
      required String id,
      required String farmId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      required String plan,
      required String status,
      Value<DateTime?> validUntil,
      Value<DateTime?> lastVerifiedAt,
      Value<int> rowid,
    });
typedef $$EntitlementsTableUpdateCompanionBuilder =
    EntitlementsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<String> plan,
      Value<String> status,
      Value<DateTime?> validUntil,
      Value<DateTime?> lastVerifiedAt,
      Value<int> rowid,
    });

class $$EntitlementsTableFilterComposer
    extends Composer<_$AppDatabase, $EntitlementsTable> {
  $$EntitlementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntitlementsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntitlementsTable> {
  $$EntitlementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plan => $composableBuilder(
    column: $table.plan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntitlementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntitlementsTable> {
  $$EntitlementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plan =>
      $composableBuilder(column: $table.plan, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => column,
  );
}

class $$EntitlementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntitlementsTable,
          EntitlementRow,
          $$EntitlementsTableFilterComposer,
          $$EntitlementsTableOrderingComposer,
          $$EntitlementsTableAnnotationComposer,
          $$EntitlementsTableCreateCompanionBuilder,
          $$EntitlementsTableUpdateCompanionBuilder,
          (
            EntitlementRow,
            BaseReferences<_$AppDatabase, $EntitlementsTable, EntitlementRow>,
          ),
          EntitlementRow,
          PrefetchHooks Function()
        > {
  $$EntitlementsTableTableManager(_$AppDatabase db, $EntitlementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntitlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntitlementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntitlementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> plan = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> validUntil = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitlementsCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                plan: plan,
                status: status,
                validUntil: validUntil,
                lastVerifiedAt: lastVerifiedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String plan,
                required String status,
                Value<DateTime?> validUntil = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitlementsCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                plan: plan,
                status: status,
                validUntil: validUntil,
                lastVerifiedAt: lastVerifiedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntitlementsTable, EntitlementRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EntitlementsTable,
                    EntitlementRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntitlementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntitlementsTable,
      EntitlementRow,
      $$EntitlementsTableFilterComposer,
      $$EntitlementsTableOrderingComposer,
      $$EntitlementsTableAnnotationComposer,
      $$EntitlementsTableCreateCompanionBuilder,
      $$EntitlementsTableUpdateCompanionBuilder,
      (
        EntitlementRow,
        BaseReferences<_$AppDatabase, $EntitlementsTable, EntitlementRow>,
      ),
      EntitlementRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  required String opId,
  required String targetTable,
  required String rowId,
  required String op,
  required String payload,
  required DateTime createdAt,
  Value<int> attempts,
  Value<String?> lastError,
  Value<String> state,
  Value<DateTime?> leaseUntil,
  Value<bool> retryable,
  Value<String?> errorCode,
  Value<DateTime?> nextAttemptAt,
  Value<int> rowid,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<String> opId,
  Value<String> targetTable,
  Value<String> rowId,
  Value<String> op,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<String?> lastError,
  Value<String> state,
  Value<DateTime?> leaseUntil,
  Value<bool> retryable,
  Value<String?> errorCode,
  Value<DateTime?> nextAttemptAt,
  Value<int> rowid,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get retryable => $composableBuilder(
    column: $table.retryable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get retryable => $composableBuilder(
    column: $table.retryable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get retryable =>
      $composableBuilder(column: $table.retryable, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxRow,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime?> leaseUntil = const Value.absent(),
                Value<bool> retryable = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion(
                opId: opId,
                targetTable: targetTable,
                rowId: rowId,
                op: op,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                state: state,
                leaseUntil: leaseUntil,
                retryable: retryable,
                errorCode: errorCode,
                nextAttemptAt: nextAttemptAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String targetTable,
                required String rowId,
                required String op,
                required String payload,
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime?> leaseUntil = const Value.absent(),
                Value<bool> retryable = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion.insert(
                opId: opId,
                targetTable: targetTable,
                rowId: rowId,
                op: op,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                state: state,
                leaseUntil: leaseUntil,
                retryable: retryable,
                errorCode: errorCode,
                nextAttemptAt: nextAttemptAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxTable, OutboxRow>(table),
                  BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxRow,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String syncTable,
      Value<int> cursor,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> syncTable,
      Value<int> cursor,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncTable => $composableBuilder(
    column: $table.syncTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncTable => $composableBuilder(
    column: $table.syncTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncTable =>
      $composableBuilder(column: $table.syncTable, builder: (column) => column);

  GeneratedColumn<int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursorRow,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursorRow,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>,
          ),
          SyncCursorRow,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncTable = const Value.absent(),
                Value<int> cursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                syncTable: syncTable,
                cursor: cursor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncTable,
                Value<int> cursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                syncTable: syncTable,
                cursor: cursor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursorRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncCursorsTable,
                    SyncCursorRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursorRow,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursorRow,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>,
      ),
      SyncCursorRow,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder = SyncMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SyncMetaTableUpdateCompanionBuilder = SyncMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          SyncMetaRow,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaRow,
            BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaRow>,
          ),
          SyncMetaRow,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SyncMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SyncMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncMetaTable, SyncMetaRow>(table),
                  BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      SyncMetaRow,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (SyncMetaRow, BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaRow>),
      SyncMetaRow,
      PrefetchHooks Function()
    >;
typedef $$SyncEventsTableCreateCompanionBuilder = SyncEventsCompanion Function({
  Value<int> id,
  required DateTime occurredAt,
  required String level,
  required String message,
});
typedef $$SyncEventsTableUpdateCompanionBuilder = SyncEventsCompanion Function({
  Value<int> id,
  Value<DateTime> occurredAt,
  Value<String> level,
  Value<String> message,
});

class $$SyncEventsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncEventsTable> {
  $$SyncEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncEventsTable> {
  $$SyncEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncEventsTable> {
  $$SyncEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);
}

class $$SyncEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncEventsTable,
          SyncEventRow,
          $$SyncEventsTableFilterComposer,
          $$SyncEventsTableOrderingComposer,
          $$SyncEventsTableAnnotationComposer,
          $$SyncEventsTableCreateCompanionBuilder,
          $$SyncEventsTableUpdateCompanionBuilder,
          (
            SyncEventRow,
            BaseReferences<_$AppDatabase, $SyncEventsTable, SyncEventRow>,
          ),
          SyncEventRow,
          PrefetchHooks Function()
        > {
  $$SyncEventsTableTableManager(_$AppDatabase db, $SyncEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> message = const Value.absent(),
              }) => SyncEventsCompanion(
                id: id,
                occurredAt: occurredAt,
                level: level,
                message: message,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime occurredAt,
                required String level,
                required String message,
              }) => SyncEventsCompanion.insert(
                id: id,
                occurredAt: occurredAt,
                level: level,
                message: message,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncEventsTable, SyncEventRow>(table),
                  BaseReferences<_$AppDatabase, $SyncEventsTable, SyncEventRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncEventsTable,
      SyncEventRow,
      $$SyncEventsTableFilterComposer,
      $$SyncEventsTableOrderingComposer,
      $$SyncEventsTableAnnotationComposer,
      $$SyncEventsTableCreateCompanionBuilder,
      $$SyncEventsTableUpdateCompanionBuilder,
      (
        SyncEventRow,
        BaseReferences<_$AppDatabase, $SyncEventsTable, SyncEventRow>,
      ),
      SyncEventRow,
      PrefetchHooks Function()
    >;
typedef $$SyncLockTableCreateCompanionBuilder = SyncLockCompanion Function({
  Value<int> id,
  Value<String?> holder,
  Value<DateTime?> leaseUntil,
});
typedef $$SyncLockTableUpdateCompanionBuilder = SyncLockCompanion Function({
  Value<int> id,
  Value<String?> holder,
  Value<DateTime?> leaseUntil,
});

class $$SyncLockTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLockTable> {
  $$SyncLockTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get holder => $composableBuilder(
    column: $table.holder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLockTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLockTable> {
  $$SyncLockTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get holder => $composableBuilder(
    column: $table.holder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLockTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLockTable> {
  $$SyncLockTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get holder =>
      $composableBuilder(column: $table.holder, builder: (column) => column);

  GeneratedColumn<DateTime> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => column,
  );
}

class $$SyncLockTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLockTable,
          SyncLockRow,
          $$SyncLockTableFilterComposer,
          $$SyncLockTableOrderingComposer,
          $$SyncLockTableAnnotationComposer,
          $$SyncLockTableCreateCompanionBuilder,
          $$SyncLockTableUpdateCompanionBuilder,
          (
            SyncLockRow,
            BaseReferences<_$AppDatabase, $SyncLockTable, SyncLockRow>,
          ),
          SyncLockRow,
          PrefetchHooks Function()
        > {
  $$SyncLockTableTableManager(_$AppDatabase db, $SyncLockTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLockTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLockTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLockTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> holder = const Value.absent(),
                Value<DateTime?> leaseUntil = const Value.absent(),
              }) => SyncLockCompanion(
                id: id,
                holder: holder,
                leaseUntil: leaseUntil,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> holder = const Value.absent(),
                Value<DateTime?> leaseUntil = const Value.absent(),
              }) => SyncLockCompanion.insert(
                id: id,
                holder: holder,
                leaseUntil: leaseUntil,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncLockTable, SyncLockRow>(table),
                  BaseReferences<_$AppDatabase, $SyncLockTable, SyncLockRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLockTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLockTable,
      SyncLockRow,
      $$SyncLockTableFilterComposer,
      $$SyncLockTableOrderingComposer,
      $$SyncLockTableAnnotationComposer,
      $$SyncLockTableCreateCompanionBuilder,
      $$SyncLockTableUpdateCompanionBuilder,
      (SyncLockRow, BaseReferences<_$AppDatabase, $SyncLockTable, SyncLockRow>),
      SyncLockRow,
      PrefetchHooks Function()
    >;
typedef $$AuthSnapshotTableCreateCompanionBuilder =
    AuthSnapshotCompanion Function({
      Value<int> id,
      required String userId,
      Value<String?> email,
      Value<String?> phone,
      required String farmIdsJson,
      Value<String> appRole,
      Value<DateTime?> lastVerifiedAt,
    });
typedef $$AuthSnapshotTableUpdateCompanionBuilder =
    AuthSnapshotCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String?> email,
      Value<String?> phone,
      Value<String> farmIdsJson,
      Value<String> appRole,
      Value<DateTime?> lastVerifiedAt,
    });

class $$AuthSnapshotTableFilterComposer
    extends Composer<_$AppDatabase, $AuthSnapshotTable> {
  $$AuthSnapshotTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmIdsJson => $composableBuilder(
    column: $table.farmIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appRole => $composableBuilder(
    column: $table.appRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuthSnapshotTableOrderingComposer
    extends Composer<_$AppDatabase, $AuthSnapshotTable> {
  $$AuthSnapshotTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmIdsJson => $composableBuilder(
    column: $table.farmIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appRole => $composableBuilder(
    column: $table.appRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuthSnapshotTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuthSnapshotTable> {
  $$AuthSnapshotTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get farmIdsJson => $composableBuilder(
    column: $table.farmIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appRole =>
      $composableBuilder(column: $table.appRole, builder: (column) => column);

  GeneratedColumn<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => column,
  );
}

class $$AuthSnapshotTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuthSnapshotTable,
          AuthSnapshotRow,
          $$AuthSnapshotTableFilterComposer,
          $$AuthSnapshotTableOrderingComposer,
          $$AuthSnapshotTableAnnotationComposer,
          $$AuthSnapshotTableCreateCompanionBuilder,
          $$AuthSnapshotTableUpdateCompanionBuilder,
          (
            AuthSnapshotRow,
            BaseReferences<_$AppDatabase, $AuthSnapshotTable, AuthSnapshotRow>,
          ),
          AuthSnapshotRow,
          PrefetchHooks Function()
        > {
  $$AuthSnapshotTableTableManager(_$AppDatabase db, $AuthSnapshotTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthSnapshotTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthSnapshotTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthSnapshotTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> farmIdsJson = const Value.absent(),
                Value<String> appRole = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
              }) => AuthSnapshotCompanion(
                id: id,
                userId: userId,
                email: email,
                phone: phone,
                farmIdsJson: farmIdsJson,
                appRole: appRole,
                lastVerifiedAt: lastVerifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                required String farmIdsJson,
                Value<String> appRole = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
              }) => AuthSnapshotCompanion.insert(
                id: id,
                userId: userId,
                email: email,
                phone: phone,
                farmIdsJson: farmIdsJson,
                appRole: appRole,
                lastVerifiedAt: lastVerifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuthSnapshotTable, AuthSnapshotRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AuthSnapshotTable,
                    AuthSnapshotRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuthSnapshotTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuthSnapshotTable,
      AuthSnapshotRow,
      $$AuthSnapshotTableFilterComposer,
      $$AuthSnapshotTableOrderingComposer,
      $$AuthSnapshotTableAnnotationComposer,
      $$AuthSnapshotTableCreateCompanionBuilder,
      $$AuthSnapshotTableUpdateCompanionBuilder,
      (
        AuthSnapshotRow,
        BaseReferences<_$AppDatabase, $AuthSnapshotTable, AuthSnapshotRow>,
      ),
      AuthSnapshotRow,
      PrefetchHooks Function()
    >;
typedef $$VetAssistanceRequestsTableCreateCompanionBuilder =
    VetAssistanceRequestsCompanion Function({
      required String id,
      required String farmId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      required String batchId,
      required String healthRecordId,
      required String serviceType,
      required String status,
      Value<bool> shareLocation,
      Value<String> priority,
      Value<String?> farmerNotes,
      Value<String?> assignedVetUserId,
      Value<String?> requestedVetUserId,
      Value<int> rowid,
    });
typedef $$VetAssistanceRequestsTableUpdateCompanionBuilder =
    VetAssistanceRequestsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<String> batchId,
      Value<String> healthRecordId,
      Value<String> serviceType,
      Value<String> status,
      Value<bool> shareLocation,
      Value<String> priority,
      Value<String?> farmerNotes,
      Value<String?> assignedVetUserId,
      Value<String?> requestedVetUserId,
      Value<int> rowid,
    });

class $$VetAssistanceRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $VetAssistanceRequestsTable> {
  $$VetAssistanceRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get healthRecordId => $composableBuilder(
    column: $table.healthRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shareLocation => $composableBuilder(
    column: $table.shareLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmerNotes => $composableBuilder(
    column: $table.farmerNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedVetUserId => $composableBuilder(
    column: $table.assignedVetUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedVetUserId => $composableBuilder(
    column: $table.requestedVetUserId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VetAssistanceRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $VetAssistanceRequestsTable> {
  $$VetAssistanceRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get healthRecordId => $composableBuilder(
    column: $table.healthRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shareLocation => $composableBuilder(
    column: $table.shareLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmerNotes => $composableBuilder(
    column: $table.farmerNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedVetUserId => $composableBuilder(
    column: $table.assignedVetUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedVetUserId => $composableBuilder(
    column: $table.requestedVetUserId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VetAssistanceRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VetAssistanceRequestsTable> {
  $$VetAssistanceRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get healthRecordId => $composableBuilder(
    column: $table.healthRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get shareLocation => $composableBuilder(
    column: $table.shareLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get farmerNotes => $composableBuilder(
    column: $table.farmerNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignedVetUserId => $composableBuilder(
    column: $table.assignedVetUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestedVetUserId => $composableBuilder(
    column: $table.requestedVetUserId,
    builder: (column) => column,
  );
}

class $$VetAssistanceRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VetAssistanceRequestsTable,
          VetAssistanceRequestRow,
          $$VetAssistanceRequestsTableFilterComposer,
          $$VetAssistanceRequestsTableOrderingComposer,
          $$VetAssistanceRequestsTableAnnotationComposer,
          $$VetAssistanceRequestsTableCreateCompanionBuilder,
          $$VetAssistanceRequestsTableUpdateCompanionBuilder,
          (
            VetAssistanceRequestRow,
            BaseReferences<
              _$AppDatabase,
              $VetAssistanceRequestsTable,
              VetAssistanceRequestRow
            >,
          ),
          VetAssistanceRequestRow,
          PrefetchHooks Function()
        > {
  $$VetAssistanceRequestsTableTableManager(
    _$AppDatabase db,
    $VetAssistanceRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VetAssistanceRequestsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$VetAssistanceRequestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$VetAssistanceRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> healthRecordId = const Value.absent(),
                Value<String> serviceType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> shareLocation = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String?> farmerNotes = const Value.absent(),
                Value<String?> assignedVetUserId = const Value.absent(),
                Value<String?> requestedVetUserId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VetAssistanceRequestsCompanion(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                batchId: batchId,
                healthRecordId: healthRecordId,
                serviceType: serviceType,
                status: status,
                shareLocation: shareLocation,
                priority: priority,
                farmerNotes: farmerNotes,
                assignedVetUserId: assignedVetUserId,
                requestedVetUserId: requestedVetUserId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String batchId,
                required String healthRecordId,
                required String serviceType,
                required String status,
                Value<bool> shareLocation = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String?> farmerNotes = const Value.absent(),
                Value<String?> assignedVetUserId = const Value.absent(),
                Value<String?> requestedVetUserId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VetAssistanceRequestsCompanion.insert(
                id: id,
                farmId: farmId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                batchId: batchId,
                healthRecordId: healthRecordId,
                serviceType: serviceType,
                status: status,
                shareLocation: shareLocation,
                priority: priority,
                farmerNotes: farmerNotes,
                assignedVetUserId: assignedVetUserId,
                requestedVetUserId: requestedVetUserId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $VetAssistanceRequestsTable,
                    VetAssistanceRequestRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $VetAssistanceRequestsTable,
                    VetAssistanceRequestRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VetAssistanceRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VetAssistanceRequestsTable,
      VetAssistanceRequestRow,
      $$VetAssistanceRequestsTableFilterComposer,
      $$VetAssistanceRequestsTableOrderingComposer,
      $$VetAssistanceRequestsTableAnnotationComposer,
      $$VetAssistanceRequestsTableCreateCompanionBuilder,
      $$VetAssistanceRequestsTableUpdateCompanionBuilder,
      (
        VetAssistanceRequestRow,
        BaseReferences<
          _$AppDatabase,
          $VetAssistanceRequestsTable,
          VetAssistanceRequestRow
        >,
      ),
      VetAssistanceRequestRow,
      PrefetchHooks Function()
    >;
typedef $$CaseMessagesTableCreateCompanionBuilder =
    CaseMessagesCompanion Function({
      required String id,
      required String farmId,
      required String requestId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<String?> senderUserId,
      required String senderRole,
      required String kind,
      Value<String?> body,
      required DateTime clientCreatedAt,
      Value<String?> localFailReason,
      Value<int> rowid,
    });
typedef $$CaseMessagesTableUpdateCompanionBuilder =
    CaseMessagesCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> requestId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<String?> senderUserId,
      Value<String> senderRole,
      Value<String> kind,
      Value<String?> body,
      Value<DateTime> clientCreatedAt,
      Value<String?> localFailReason,
      Value<int> rowid,
    });

class $$CaseMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $CaseMessagesTable> {
  $$CaseMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderUserId => $composableBuilder(
    column: $table.senderUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderRole => $composableBuilder(
    column: $table.senderRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientCreatedAt => $composableBuilder(
    column: $table.clientCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFailReason => $composableBuilder(
    column: $table.localFailReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CaseMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CaseMessagesTable> {
  $$CaseMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderUserId => $composableBuilder(
    column: $table.senderUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderRole => $composableBuilder(
    column: $table.senderRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientCreatedAt => $composableBuilder(
    column: $table.clientCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFailReason => $composableBuilder(
    column: $table.localFailReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CaseMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaseMessagesTable> {
  $$CaseMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderUserId => $composableBuilder(
    column: $table.senderUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderRole => $composableBuilder(
    column: $table.senderRole,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get clientCreatedAt => $composableBuilder(
    column: $table.clientCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localFailReason => $composableBuilder(
    column: $table.localFailReason,
    builder: (column) => column,
  );
}

class $$CaseMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CaseMessagesTable,
          CaseMessageRow,
          $$CaseMessagesTableFilterComposer,
          $$CaseMessagesTableOrderingComposer,
          $$CaseMessagesTableAnnotationComposer,
          $$CaseMessagesTableCreateCompanionBuilder,
          $$CaseMessagesTableUpdateCompanionBuilder,
          (
            CaseMessageRow,
            BaseReferences<_$AppDatabase, $CaseMessagesTable, CaseMessageRow>,
          ),
          CaseMessageRow,
          PrefetchHooks Function()
        > {
  $$CaseMessagesTableTableManager(_$AppDatabase db, $CaseMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaseMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaseMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaseMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> senderUserId = const Value.absent(),
                Value<String> senderRole = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<DateTime> clientCreatedAt = const Value.absent(),
                Value<String?> localFailReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CaseMessagesCompanion(
                id: id,
                farmId: farmId,
                requestId: requestId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                senderUserId: senderUserId,
                senderRole: senderRole,
                kind: kind,
                body: body,
                clientCreatedAt: clientCreatedAt,
                localFailReason: localFailReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String requestId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String?> senderUserId = const Value.absent(),
                required String senderRole,
                required String kind,
                Value<String?> body = const Value.absent(),
                required DateTime clientCreatedAt,
                Value<String?> localFailReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CaseMessagesCompanion.insert(
                id: id,
                farmId: farmId,
                requestId: requestId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                senderUserId: senderUserId,
                senderRole: senderRole,
                kind: kind,
                body: body,
                clientCreatedAt: clientCreatedAt,
                localFailReason: localFailReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CaseMessagesTable, CaseMessageRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CaseMessagesTable,
                    CaseMessageRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CaseMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CaseMessagesTable,
      CaseMessageRow,
      $$CaseMessagesTableFilterComposer,
      $$CaseMessagesTableOrderingComposer,
      $$CaseMessagesTableAnnotationComposer,
      $$CaseMessagesTableCreateCompanionBuilder,
      $$CaseMessagesTableUpdateCompanionBuilder,
      (
        CaseMessageRow,
        BaseReferences<_$AppDatabase, $CaseMessagesTable, CaseMessageRow>,
      ),
      CaseMessageRow,
      PrefetchHooks Function()
    >;
typedef $$CaseMessageAttachmentsTableCreateCompanionBuilder =
    CaseMessageAttachmentsCompanion Function({
      required String id,
      required String farmId,
      required String requestId,
      required String messageId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      required String objectKey,
      Value<String> mime,
      Value<int?> bytes,
      Value<int?> width,
      Value<int?> height,
      Value<String?> thumbB64,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$CaseMessageAttachmentsTableUpdateCompanionBuilder =
    CaseMessageAttachmentsCompanion Function({
      Value<String> id,
      Value<String> farmId,
      Value<String> requestId,
      Value<String> messageId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<String> objectKey,
      Value<String> mime,
      Value<int?> bytes,
      Value<int?> width,
      Value<int?> height,
      Value<String?> thumbB64,
      Value<String> status,
      Value<int> rowid,
    });

class $$CaseMessageAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $CaseMessageAttachmentsTable> {
  $$CaseMessageAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectKey => $composableBuilder(
    column: $table.objectKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbB64 => $composableBuilder(
    column: $table.thumbB64,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CaseMessageAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CaseMessageAttachmentsTable> {
  $$CaseMessageAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectKey => $composableBuilder(
    column: $table.objectKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbB64 => $composableBuilder(
    column: $table.thumbB64,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CaseMessageAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaseMessageAttachmentsTable> {
  $$CaseMessageAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get objectKey =>
      $composableBuilder(column: $table.objectKey, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get thumbB64 =>
      $composableBuilder(column: $table.thumbB64, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$CaseMessageAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CaseMessageAttachmentsTable,
          CaseMessageAttachmentRow,
          $$CaseMessageAttachmentsTableFilterComposer,
          $$CaseMessageAttachmentsTableOrderingComposer,
          $$CaseMessageAttachmentsTableAnnotationComposer,
          $$CaseMessageAttachmentsTableCreateCompanionBuilder,
          $$CaseMessageAttachmentsTableUpdateCompanionBuilder,
          (
            CaseMessageAttachmentRow,
            BaseReferences<
              _$AppDatabase,
              $CaseMessageAttachmentsTable,
              CaseMessageAttachmentRow
            >,
          ),
          CaseMessageAttachmentRow,
          PrefetchHooks Function()
        > {
  $$CaseMessageAttachmentsTableTableManager(
    _$AppDatabase db,
    $CaseMessageAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaseMessageAttachmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CaseMessageAttachmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CaseMessageAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmId = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<String> objectKey = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<int?> bytes = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String?> thumbB64 = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CaseMessageAttachmentsCompanion(
                id: id,
                farmId: farmId,
                requestId: requestId,
                messageId: messageId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                objectKey: objectKey,
                mime: mime,
                bytes: bytes,
                width: width,
                height: height,
                thumbB64: thumbB64,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String farmId,
                required String requestId,
                required String messageId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required String objectKey,
                Value<String> mime = const Value.absent(),
                Value<int?> bytes = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<String?> thumbB64 = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CaseMessageAttachmentsCompanion.insert(
                id: id,
                farmId: farmId,
                requestId: requestId,
                messageId: messageId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                objectKey: objectKey,
                mime: mime,
                bytes: bytes,
                width: width,
                height: height,
                thumbB64: thumbB64,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CaseMessageAttachmentsTable,
                    CaseMessageAttachmentRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CaseMessageAttachmentsTable,
                    CaseMessageAttachmentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CaseMessageAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CaseMessageAttachmentsTable,
      CaseMessageAttachmentRow,
      $$CaseMessageAttachmentsTableFilterComposer,
      $$CaseMessageAttachmentsTableOrderingComposer,
      $$CaseMessageAttachmentsTableAnnotationComposer,
      $$CaseMessageAttachmentsTableCreateCompanionBuilder,
      $$CaseMessageAttachmentsTableUpdateCompanionBuilder,
      (
        CaseMessageAttachmentRow,
        BaseReferences<
          _$AppDatabase,
          $CaseMessageAttachmentsTable,
          CaseMessageAttachmentRow
        >,
      ),
      CaseMessageAttachmentRow,
      PrefetchHooks Function()
    >;
typedef $$CaseReadStatesTableCreateCompanionBuilder =
    CaseReadStatesCompanion Function({
      required String requestId,
      required String userId,
      Value<String?> farmId,
      required DateTime lastReadAt,
      Value<String?> lastReadMessageId,
      Value<bool> muted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<int> rowid,
    });
typedef $$CaseReadStatesTableUpdateCompanionBuilder =
    CaseReadStatesCompanion Function({
      Value<String> requestId,
      Value<String> userId,
      Value<String?> farmId,
      Value<DateTime> lastReadAt,
      Value<String?> lastReadMessageId,
      Value<bool> muted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int?> serverVersion,
      Value<int> rowid,
    });

class $$CaseReadStatesTableFilterComposer
    extends Composer<_$AppDatabase, $CaseReadStatesTable> {
  $$CaseReadStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastReadMessageId => $composableBuilder(
    column: $table.lastReadMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CaseReadStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CaseReadStatesTable> {
  $$CaseReadStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmId => $composableBuilder(
    column: $table.farmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastReadMessageId => $composableBuilder(
    column: $table.lastReadMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get muted => $composableBuilder(
    column: $table.muted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CaseReadStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaseReadStatesTable> {
  $$CaseReadStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastReadMessageId => $composableBuilder(
    column: $table.lastReadMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get muted =>
      $composableBuilder(column: $table.muted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );
}

class $$CaseReadStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CaseReadStatesTable,
          CaseReadStateRow,
          $$CaseReadStatesTableFilterComposer,
          $$CaseReadStatesTableOrderingComposer,
          $$CaseReadStatesTableAnnotationComposer,
          $$CaseReadStatesTableCreateCompanionBuilder,
          $$CaseReadStatesTableUpdateCompanionBuilder,
          (
            CaseReadStateRow,
            BaseReferences<
              _$AppDatabase,
              $CaseReadStatesTable,
              CaseReadStateRow
            >,
          ),
          CaseReadStateRow,
          PrefetchHooks Function()
        > {
  $$CaseReadStatesTableTableManager(
    _$AppDatabase db,
    $CaseReadStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaseReadStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaseReadStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaseReadStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> requestId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> farmId = const Value.absent(),
                Value<DateTime> lastReadAt = const Value.absent(),
                Value<String?> lastReadMessageId = const Value.absent(),
                Value<bool> muted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CaseReadStatesCompanion(
                requestId: requestId,
                userId: userId,
                farmId: farmId,
                lastReadAt: lastReadAt,
                lastReadMessageId: lastReadMessageId,
                muted: muted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String requestId,
                required String userId,
                Value<String?> farmId = const Value.absent(),
                required DateTime lastReadAt,
                Value<String?> lastReadMessageId = const Value.absent(),
                Value<bool> muted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CaseReadStatesCompanion.insert(
                requestId: requestId,
                userId: userId,
                farmId: farmId,
                lastReadAt: lastReadAt,
                lastReadMessageId: lastReadMessageId,
                muted: muted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverVersion: serverVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CaseReadStatesTable, CaseReadStateRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CaseReadStatesTable,
                    CaseReadStateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CaseReadStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CaseReadStatesTable,
      CaseReadStateRow,
      $$CaseReadStatesTableFilterComposer,
      $$CaseReadStatesTableOrderingComposer,
      $$CaseReadStatesTableAnnotationComposer,
      $$CaseReadStatesTableCreateCompanionBuilder,
      $$CaseReadStatesTableUpdateCompanionBuilder,
      (
        CaseReadStateRow,
        BaseReferences<_$AppDatabase, $CaseReadStatesTable, CaseReadStateRow>,
      ),
      CaseReadStateRow,
      PrefetchHooks Function()
    >;
typedef $$MediaUploadJobsTableCreateCompanionBuilder =
    MediaUploadJobsCompanion Function({
      required String id,
      required String attachmentId,
      required String requestId,
      required String localPath,
      Value<String> state,
      Value<int> attempts,
      Value<int> bytesSent,
      Value<DateTime?> nextAttemptAt,
      Value<bool> userForced,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MediaUploadJobsTableUpdateCompanionBuilder =
    MediaUploadJobsCompanion Function({
      Value<String> id,
      Value<String> attachmentId,
      Value<String> requestId,
      Value<String> localPath,
      Value<String> state,
      Value<int> attempts,
      Value<int> bytesSent,
      Value<DateTime?> nextAttemptAt,
      Value<bool> userForced,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$MediaUploadJobsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaUploadJobsTable> {
  $$MediaUploadJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesSent => $composableBuilder(
    column: $table.bytesSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userForced => $composableBuilder(
    column: $table.userForced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaUploadJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaUploadJobsTable> {
  $$MediaUploadJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesSent => $composableBuilder(
    column: $table.bytesSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userForced => $composableBuilder(
    column: $table.userForced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaUploadJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaUploadJobsTable> {
  $$MediaUploadJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get bytesSent =>
      $composableBuilder(column: $table.bytesSent, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get userForced => $composableBuilder(
    column: $table.userForced,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MediaUploadJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaUploadJobsTable,
          MediaUploadJobRow,
          $$MediaUploadJobsTableFilterComposer,
          $$MediaUploadJobsTableOrderingComposer,
          $$MediaUploadJobsTableAnnotationComposer,
          $$MediaUploadJobsTableCreateCompanionBuilder,
          $$MediaUploadJobsTableUpdateCompanionBuilder,
          (
            MediaUploadJobRow,
            BaseReferences<
              _$AppDatabase,
              $MediaUploadJobsTable,
              MediaUploadJobRow
            >,
          ),
          MediaUploadJobRow,
          PrefetchHooks Function()
        > {
  $$MediaUploadJobsTableTableManager(
    _$AppDatabase db,
    $MediaUploadJobsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaUploadJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaUploadJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaUploadJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> attachmentId = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> bytesSent = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<bool> userForced = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaUploadJobsCompanion(
                id: id,
                attachmentId: attachmentId,
                requestId: requestId,
                localPath: localPath,
                state: state,
                attempts: attempts,
                bytesSent: bytesSent,
                nextAttemptAt: nextAttemptAt,
                userForced: userForced,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String attachmentId,
                required String requestId,
                required String localPath,
                Value<String> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> bytesSent = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<bool> userForced = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MediaUploadJobsCompanion.insert(
                id: id,
                attachmentId: attachmentId,
                requestId: requestId,
                localPath: localPath,
                state: state,
                attempts: attempts,
                bytesSent: bytesSent,
                nextAttemptAt: nextAttemptAt,
                userForced: userForced,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaUploadJobsTable, MediaUploadJobRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MediaUploadJobsTable,
                    MediaUploadJobRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaUploadJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaUploadJobsTable,
      MediaUploadJobRow,
      $$MediaUploadJobsTableFilterComposer,
      $$MediaUploadJobsTableOrderingComposer,
      $$MediaUploadJobsTableAnnotationComposer,
      $$MediaUploadJobsTableCreateCompanionBuilder,
      $$MediaUploadJobsTableUpdateCompanionBuilder,
      (
        MediaUploadJobRow,
        BaseReferences<_$AppDatabase, $MediaUploadJobsTable, MediaUploadJobRow>,
      ),
      MediaUploadJobRow,
      PrefetchHooks Function()
    >;
typedef $$MediaCacheTableCreateCompanionBuilder = MediaCacheCompanion Function({
  required String objectKey,
  required String localPath,
  required int bytes,
  required DateTime lastAccessAt,
  Value<int> rowid,
});
typedef $$MediaCacheTableUpdateCompanionBuilder = MediaCacheCompanion Function({
  Value<String> objectKey,
  Value<String> localPath,
  Value<int> bytes,
  Value<DateTime> lastAccessAt,
  Value<int> rowid,
});

class $$MediaCacheTableFilterComposer
    extends Composer<_$AppDatabase, $MediaCacheTable> {
  $$MediaCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get objectKey => $composableBuilder(
    column: $table.objectKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessAt => $composableBuilder(
    column: $table.lastAccessAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaCacheTable> {
  $$MediaCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get objectKey => $composableBuilder(
    column: $table.objectKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessAt => $composableBuilder(
    column: $table.lastAccessAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaCacheTable> {
  $$MediaCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get objectKey =>
      $composableBuilder(column: $table.objectKey, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessAt => $composableBuilder(
    column: $table.lastAccessAt,
    builder: (column) => column,
  );
}

class $$MediaCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaCacheTable,
          MediaCacheRow,
          $$MediaCacheTableFilterComposer,
          $$MediaCacheTableOrderingComposer,
          $$MediaCacheTableAnnotationComposer,
          $$MediaCacheTableCreateCompanionBuilder,
          $$MediaCacheTableUpdateCompanionBuilder,
          (
            MediaCacheRow,
            BaseReferences<_$AppDatabase, $MediaCacheTable, MediaCacheRow>,
          ),
          MediaCacheRow,
          PrefetchHooks Function()
        > {
  $$MediaCacheTableTableManager(_$AppDatabase db, $MediaCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> objectKey = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<DateTime> lastAccessAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaCacheCompanion(
                objectKey: objectKey,
                localPath: localPath,
                bytes: bytes,
                lastAccessAt: lastAccessAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String objectKey,
                required String localPath,
                required int bytes,
                required DateTime lastAccessAt,
                Value<int> rowid = const Value.absent(),
              }) => MediaCacheCompanion.insert(
                objectKey: objectKey,
                localPath: localPath,
                bytes: bytes,
                lastAccessAt: lastAccessAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaCacheTable, MediaCacheRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MediaCacheTable,
                    MediaCacheRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaCacheTable,
      MediaCacheRow,
      $$MediaCacheTableFilterComposer,
      $$MediaCacheTableOrderingComposer,
      $$MediaCacheTableAnnotationComposer,
      $$MediaCacheTableCreateCompanionBuilder,
      $$MediaCacheTableUpdateCompanionBuilder,
      (
        MediaCacheRow,
        BaseReferences<_$AppDatabase, $MediaCacheTable, MediaCacheRow>,
      ),
      MediaCacheRow,
      PrefetchHooks Function()
    >;
typedef $$PushRegistrationsTableCreateCompanionBuilder =
    PushRegistrationsCompanion Function({
      required String tokenHash,
      required DateTime registeredAt,
      Value<int> rowid,
    });
typedef $$PushRegistrationsTableUpdateCompanionBuilder =
    PushRegistrationsCompanion Function({
      Value<String> tokenHash,
      Value<DateTime> registeredAt,
      Value<int> rowid,
    });

class $$PushRegistrationsTableFilterComposer
    extends Composer<_$AppDatabase, $PushRegistrationsTable> {
  $$PushRegistrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tokenHash => $composableBuilder(
    column: $table.tokenHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PushRegistrationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PushRegistrationsTable> {
  $$PushRegistrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tokenHash => $composableBuilder(
    column: $table.tokenHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PushRegistrationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PushRegistrationsTable> {
  $$PushRegistrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tokenHash =>
      $composableBuilder(column: $table.tokenHash, builder: (column) => column);

  GeneratedColumn<DateTime> get registeredAt => $composableBuilder(
    column: $table.registeredAt,
    builder: (column) => column,
  );
}

class $$PushRegistrationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PushRegistrationsTable,
          PushRegistrationRow,
          $$PushRegistrationsTableFilterComposer,
          $$PushRegistrationsTableOrderingComposer,
          $$PushRegistrationsTableAnnotationComposer,
          $$PushRegistrationsTableCreateCompanionBuilder,
          $$PushRegistrationsTableUpdateCompanionBuilder,
          (
            PushRegistrationRow,
            BaseReferences<
              _$AppDatabase,
              $PushRegistrationsTable,
              PushRegistrationRow
            >,
          ),
          PushRegistrationRow,
          PrefetchHooks Function()
        > {
  $$PushRegistrationsTableTableManager(
    _$AppDatabase db,
    $PushRegistrationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PushRegistrationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PushRegistrationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PushRegistrationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> tokenHash = const Value.absent(),
                Value<DateTime> registeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PushRegistrationsCompanion(
                tokenHash: tokenHash,
                registeredAt: registeredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tokenHash,
                required DateTime registeredAt,
                Value<int> rowid = const Value.absent(),
              }) => PushRegistrationsCompanion.insert(
                tokenHash: tokenHash,
                registeredAt: registeredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PushRegistrationsTable, PushRegistrationRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $PushRegistrationsTable,
                    PushRegistrationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PushRegistrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PushRegistrationsTable,
      PushRegistrationRow,
      $$PushRegistrationsTableFilterComposer,
      $$PushRegistrationsTableOrderingComposer,
      $$PushRegistrationsTableAnnotationComposer,
      $$PushRegistrationsTableCreateCompanionBuilder,
      $$PushRegistrationsTableUpdateCompanionBuilder,
      (
        PushRegistrationRow,
        BaseReferences<
          _$AppDatabase,
          $PushRegistrationsTable,
          PushRegistrationRow
        >,
      ),
      PushRegistrationRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FarmsTableTableManager get farms =>
      $$FarmsTableTableManager(_db, _db.farms);
  $$FarmMembersTableTableManager get farmMembers =>
      $$FarmMembersTableTableManager(_db, _db.farmMembers);
  $$BatchesTableTableManager get batches =>
      $$BatchesTableTableManager(_db, _db.batches);
  $$ProgrammesTableTableManager get programmes =>
      $$ProgrammesTableTableManager(_db, _db.programmes);
  $$ProgrammeStepsTableTableManager get programmeSteps =>
      $$ProgrammeStepsTableTableManager(_db, _db.programmeSteps);
  $$VaccinationTasksTableTableManager get vaccinationTasks =>
      $$VaccinationTasksTableTableManager(_db, _db.vaccinationTasks);
  $$FeedItemsTableTableManager get feedItems =>
      $$FeedItemsTableTableManager(_db, _db.feedItems);
  $$FeedTransactionsTableTableManager get feedTransactions =>
      $$FeedTransactionsTableTableManager(_db, _db.feedTransactions);
  $$HealthRecordsTableTableManager get healthRecords =>
      $$HealthRecordsTableTableManager(_db, _db.healthRecords);
  $$MortalityRecordsTableTableManager get mortalityRecords =>
      $$MortalityRecordsTableTableManager(_db, _db.mortalityRecords);
  $$FarmEventsTableTableManager get farmEvents =>
      $$FarmEventsTableTableManager(_db, _db.farmEvents);
  $$EntitlementsTableTableManager get entitlements =>
      $$EntitlementsTableTableManager(_db, _db.entitlements);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
  $$SyncEventsTableTableManager get syncEvents =>
      $$SyncEventsTableTableManager(_db, _db.syncEvents);
  $$SyncLockTableTableManager get syncLock =>
      $$SyncLockTableTableManager(_db, _db.syncLock);
  $$AuthSnapshotTableTableManager get authSnapshot =>
      $$AuthSnapshotTableTableManager(_db, _db.authSnapshot);
  $$VetAssistanceRequestsTableTableManager get vetAssistanceRequests =>
      $$VetAssistanceRequestsTableTableManager(_db, _db.vetAssistanceRequests);
  $$CaseMessagesTableTableManager get caseMessages =>
      $$CaseMessagesTableTableManager(_db, _db.caseMessages);
  $$CaseMessageAttachmentsTableTableManager get caseMessageAttachments =>
      $$CaseMessageAttachmentsTableTableManager(
        _db,
        _db.caseMessageAttachments,
      );
  $$CaseReadStatesTableTableManager get caseReadStates =>
      $$CaseReadStatesTableTableManager(_db, _db.caseReadStates);
  $$MediaUploadJobsTableTableManager get mediaUploadJobs =>
      $$MediaUploadJobsTableTableManager(_db, _db.mediaUploadJobs);
  $$MediaCacheTableTableManager get mediaCache =>
      $$MediaCacheTableTableManager(_db, _db.mediaCache);
  $$PushRegistrationsTableTableManager get pushRegistrations =>
      $$PushRegistrationsTableTableManager(_db, _db.pushRegistrations);
}
