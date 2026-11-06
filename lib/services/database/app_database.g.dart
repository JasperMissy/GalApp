// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
    'street',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _zipMeta = const VerificationMeta('zip');
  @override
  late final GeneratedColumn<String> zip = GeneratedColumn<String>(
    'zip',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ClientsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    street,
    zip,
    city,
    phone,
    email,
    lat,
    lon,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Client> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('street')) {
      context.handle(
        _streetMeta,
        street.isAcceptableOrUnknown(data['street']!, _streetMeta),
      );
    }
    if (data.containsKey('zip')) {
      context.handle(
        _zipMeta,
        zip.isAcceptableOrUnknown(data['zip']!, _zipMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      street: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street'],
      )!,
      zip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zip'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      ),
      createdAt: $ClientsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const IsoDateConverter();
}

class Client extends DataClass implements Insertable<Client> {
  final String id;
  final String name;
  final String street;
  final String zip;
  final String city;
  final String phone;
  final String email;
  final double? lat;
  final double? lon;
  final DateTime createdAt;
  const Client({
    required this.id,
    required this.name,
    required this.street,
    required this.zip,
    required this.city,
    required this.phone,
    required this.email,
    this.lat,
    this.lon,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['street'] = Variable<String>(street);
    map['zip'] = Variable<String>(zip);
    map['city'] = Variable<String>(city);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    {
      map['created_at'] = Variable<String>(
        $ClientsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      name: Value(name),
      street: Value(street),
      zip: Value(zip),
      city: Value(city),
      phone: Value(phone),
      email: Value(email),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      createdAt: Value(createdAt),
    );
  }

  factory Client.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      street: serializer.fromJson<String>(json['street']),
      zip: serializer.fromJson<String>(json['zip']),
      city: serializer.fromJson<String>(json['city']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'street': serializer.toJson<String>(street),
      'zip': serializer.toJson<String>(zip),
      'city': serializer.toJson<String>(city),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Client copyWith({
    String? id,
    String? name,
    String? street,
    String? zip,
    String? city,
    String? phone,
    String? email,
    Value<double?> lat = const Value.absent(),
    Value<double?> lon = const Value.absent(),
    DateTime? createdAt,
  }) => Client(
    id: id ?? this.id,
    name: name ?? this.name,
    street: street ?? this.street,
    zip: zip ?? this.zip,
    city: city ?? this.city,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    lat: lat.present ? lat.value : this.lat,
    lon: lon.present ? lon.value : this.lon,
    createdAt: createdAt ?? this.createdAt,
  );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      street: data.street.present ? data.street.value : this.street,
      zip: data.zip.present ? data.zip.value : this.zip,
      city: data.city.present ? data.city.value : this.city,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('street: $street, ')
          ..write('zip: $zip, ')
          ..write('city: $city, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    street,
    zip,
    city,
    phone,
    email,
    lat,
    lon,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.name == this.name &&
          other.street == this.street &&
          other.zip == this.zip &&
          other.city == this.city &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.createdAt == this.createdAt);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> street;
  final Value<String> zip;
  final Value<String> city;
  final Value<String> phone;
  final Value<String> email;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.street = const Value.absent(),
    this.zip = const Value.absent(),
    this.city = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsCompanion.insert({
    required String id,
    required String name,
    this.street = const Value.absent(),
    this.zip = const Value.absent(),
    this.city = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Client> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? street,
    Expression<String>? zip,
    Expression<String>? city,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (street != null) 'street': street,
      if (zip != null) 'zip': zip,
      if (city != null) 'city': city,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? street,
    Value<String>? zip,
    Value<String>? city,
    Value<String>? phone,
    Value<String>? email,
    Value<double?>? lat,
    Value<double?>? lon,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ClientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      street: street ?? this.street,
      zip: zip ?? this.zip,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (street.present) {
      map['street'] = Variable<String>(street.value);
    }
    if (zip.present) {
      map['zip'] = Variable<String>(zip.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $ClientsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('street: $street, ')
          ..write('zip: $zip, ')
          ..write('city: $city, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('invoice'),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
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
    defaultValue: const Constant('draft'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> issuedDate =
      GeneratedColumn<String>(
        'issued_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($InvoicesTable.$converterissuedDaten);
  static const VerificationMeta _netCentsMeta = const VerificationMeta(
    'netCents',
  );
  @override
  late final GeneratedColumn<int> netCents = GeneratedColumn<int>(
    'net_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vatRateBpMeta = const VerificationMeta(
    'vatRateBp',
  );
  @override
  late final GeneratedColumn<int> vatRateBp = GeneratedColumn<int>(
    'vat_rate_bp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1900),
  );
  static const VerificationMeta _vatCentsMeta = const VerificationMeta(
    'vatCents',
  );
  @override
  late final GeneratedColumn<int> vatCents = GeneratedColumn<int>(
    'vat_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _grossCentsMeta = const VerificationMeta(
    'grossCents',
  );
  @override
  late final GeneratedColumn<int> grossCents = GeneratedColumn<int>(
    'gross_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($InvoicesTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    type,
    clientId,
    orderId,
    status,
    issuedDate,
    netCents,
    vatRateBp,
    vatCents,
    grossCents,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Invoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('net_cents')) {
      context.handle(
        _netCentsMeta,
        netCents.isAcceptableOrUnknown(data['net_cents']!, _netCentsMeta),
      );
    }
    if (data.containsKey('vat_rate_bp')) {
      context.handle(
        _vatRateBpMeta,
        vatRateBp.isAcceptableOrUnknown(data['vat_rate_bp']!, _vatRateBpMeta),
      );
    }
    if (data.containsKey('vat_cents')) {
      context.handle(
        _vatCentsMeta,
        vatCents.isAcceptableOrUnknown(data['vat_cents']!, _vatCentsMeta),
      );
    }
    if (data.containsKey('gross_cents')) {
      context.handle(
        _grossCentsMeta,
        grossCents.isAcceptableOrUnknown(data['gross_cents']!, _grossCentsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      issuedDate: $InvoicesTable.$converterissuedDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}issued_date'],
        ),
      ),
      netCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_cents'],
      )!,
      vatRateBp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vat_rate_bp'],
      )!,
      vatCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vat_cents'],
      )!,
      grossCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_cents'],
      )!,
      createdAt: $InvoicesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterissuedDate =
      const IsoDateConverter();
  static TypeConverter<DateTime?, String?> $converterissuedDaten =
      NullAwareTypeConverter.wrap($converterissuedDate);
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const IsoDateConverter();
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final String id;
  final String? number;
  final String type;
  final String clientId;
  final String? orderId;
  final String status;
  final DateTime? issuedDate;
  final int netCents;
  final int vatRateBp;
  final int vatCents;
  final int grossCents;
  final DateTime createdAt;
  const Invoice({
    required this.id,
    this.number,
    required this.type,
    required this.clientId,
    this.orderId,
    required this.status,
    this.issuedDate,
    required this.netCents,
    required this.vatRateBp,
    required this.vatCents,
    required this.grossCents,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<String>(number);
    }
    map['type'] = Variable<String>(type);
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || orderId != null) {
      map['order_id'] = Variable<String>(orderId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || issuedDate != null) {
      map['issued_date'] = Variable<String>(
        $InvoicesTable.$converterissuedDaten.toSql(issuedDate),
      );
    }
    map['net_cents'] = Variable<int>(netCents);
    map['vat_rate_bp'] = Variable<int>(vatRateBp);
    map['vat_cents'] = Variable<int>(vatCents);
    map['gross_cents'] = Variable<int>(grossCents);
    {
      map['created_at'] = Variable<String>(
        $InvoicesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      type: Value(type),
      clientId: Value(clientId),
      orderId: orderId == null && nullToAbsent
          ? const Value.absent()
          : Value(orderId),
      status: Value(status),
      issuedDate: issuedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(issuedDate),
      netCents: Value(netCents),
      vatRateBp: Value(vatRateBp),
      vatCents: Value(vatCents),
      grossCents: Value(grossCents),
      createdAt: Value(createdAt),
    );
  }

  factory Invoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<String>(json['id']),
      number: serializer.fromJson<String?>(json['number']),
      type: serializer.fromJson<String>(json['type']),
      clientId: serializer.fromJson<String>(json['clientId']),
      orderId: serializer.fromJson<String?>(json['orderId']),
      status: serializer.fromJson<String>(json['status']),
      issuedDate: serializer.fromJson<DateTime?>(json['issuedDate']),
      netCents: serializer.fromJson<int>(json['netCents']),
      vatRateBp: serializer.fromJson<int>(json['vatRateBp']),
      vatCents: serializer.fromJson<int>(json['vatCents']),
      grossCents: serializer.fromJson<int>(json['grossCents']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'number': serializer.toJson<String?>(number),
      'type': serializer.toJson<String>(type),
      'clientId': serializer.toJson<String>(clientId),
      'orderId': serializer.toJson<String?>(orderId),
      'status': serializer.toJson<String>(status),
      'issuedDate': serializer.toJson<DateTime?>(issuedDate),
      'netCents': serializer.toJson<int>(netCents),
      'vatRateBp': serializer.toJson<int>(vatRateBp),
      'vatCents': serializer.toJson<int>(vatCents),
      'grossCents': serializer.toJson<int>(grossCents),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Invoice copyWith({
    String? id,
    Value<String?> number = const Value.absent(),
    String? type,
    String? clientId,
    Value<String?> orderId = const Value.absent(),
    String? status,
    Value<DateTime?> issuedDate = const Value.absent(),
    int? netCents,
    int? vatRateBp,
    int? vatCents,
    int? grossCents,
    DateTime? createdAt,
  }) => Invoice(
    id: id ?? this.id,
    number: number.present ? number.value : this.number,
    type: type ?? this.type,
    clientId: clientId ?? this.clientId,
    orderId: orderId.present ? orderId.value : this.orderId,
    status: status ?? this.status,
    issuedDate: issuedDate.present ? issuedDate.value : this.issuedDate,
    netCents: netCents ?? this.netCents,
    vatRateBp: vatRateBp ?? this.vatRateBp,
    vatCents: vatCents ?? this.vatCents,
    grossCents: grossCents ?? this.grossCents,
    createdAt: createdAt ?? this.createdAt,
  );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      type: data.type.present ? data.type.value : this.type,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      status: data.status.present ? data.status.value : this.status,
      issuedDate: data.issuedDate.present
          ? data.issuedDate.value
          : this.issuedDate,
      netCents: data.netCents.present ? data.netCents.value : this.netCents,
      vatRateBp: data.vatRateBp.present ? data.vatRateBp.value : this.vatRateBp,
      vatCents: data.vatCents.present ? data.vatCents.value : this.vatCents,
      grossCents: data.grossCents.present
          ? data.grossCents.value
          : this.grossCents,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('type: $type, ')
          ..write('clientId: $clientId, ')
          ..write('orderId: $orderId, ')
          ..write('status: $status, ')
          ..write('issuedDate: $issuedDate, ')
          ..write('netCents: $netCents, ')
          ..write('vatRateBp: $vatRateBp, ')
          ..write('vatCents: $vatCents, ')
          ..write('grossCents: $grossCents, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    number,
    type,
    clientId,
    orderId,
    status,
    issuedDate,
    netCents,
    vatRateBp,
    vatCents,
    grossCents,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.number == this.number &&
          other.type == this.type &&
          other.clientId == this.clientId &&
          other.orderId == this.orderId &&
          other.status == this.status &&
          other.issuedDate == this.issuedDate &&
          other.netCents == this.netCents &&
          other.vatRateBp == this.vatRateBp &&
          other.vatCents == this.vatCents &&
          other.grossCents == this.grossCents &&
          other.createdAt == this.createdAt);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<String> id;
  final Value<String?> number;
  final Value<String> type;
  final Value<String> clientId;
  final Value<String?> orderId;
  final Value<String> status;
  final Value<DateTime?> issuedDate;
  final Value<int> netCents;
  final Value<int> vatRateBp;
  final Value<int> vatCents;
  final Value<int> grossCents;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.type = const Value.absent(),
    this.clientId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.status = const Value.absent(),
    this.issuedDate = const Value.absent(),
    this.netCents = const Value.absent(),
    this.vatRateBp = const Value.absent(),
    this.vatCents = const Value.absent(),
    this.grossCents = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    required String id,
    this.number = const Value.absent(),
    this.type = const Value.absent(),
    required String clientId,
    this.orderId = const Value.absent(),
    this.status = const Value.absent(),
    this.issuedDate = const Value.absent(),
    this.netCents = const Value.absent(),
    this.vatRateBp = const Value.absent(),
    this.vatCents = const Value.absent(),
    this.grossCents = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       createdAt = Value(createdAt);
  static Insertable<Invoice> custom({
    Expression<String>? id,
    Expression<String>? number,
    Expression<String>? type,
    Expression<String>? clientId,
    Expression<String>? orderId,
    Expression<String>? status,
    Expression<String>? issuedDate,
    Expression<int>? netCents,
    Expression<int>? vatRateBp,
    Expression<int>? vatCents,
    Expression<int>? grossCents,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (type != null) 'type': type,
      if (clientId != null) 'client_id': clientId,
      if (orderId != null) 'order_id': orderId,
      if (status != null) 'status': status,
      if (issuedDate != null) 'issued_date': issuedDate,
      if (netCents != null) 'net_cents': netCents,
      if (vatRateBp != null) 'vat_rate_bp': vatRateBp,
      if (vatCents != null) 'vat_cents': vatCents,
      if (grossCents != null) 'gross_cents': grossCents,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith({
    Value<String>? id,
    Value<String?>? number,
    Value<String>? type,
    Value<String>? clientId,
    Value<String?>? orderId,
    Value<String>? status,
    Value<DateTime?>? issuedDate,
    Value<int>? netCents,
    Value<int>? vatRateBp,
    Value<int>? vatCents,
    Value<int>? grossCents,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InvoicesCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      type: type ?? this.type,
      clientId: clientId ?? this.clientId,
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      issuedDate: issuedDate ?? this.issuedDate,
      netCents: netCents ?? this.netCents,
      vatRateBp: vatRateBp ?? this.vatRateBp,
      vatCents: vatCents ?? this.vatCents,
      grossCents: grossCents ?? this.grossCents,
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
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (issuedDate.present) {
      map['issued_date'] = Variable<String>(
        $InvoicesTable.$converterissuedDaten.toSql(issuedDate.value),
      );
    }
    if (netCents.present) {
      map['net_cents'] = Variable<int>(netCents.value);
    }
    if (vatRateBp.present) {
      map['vat_rate_bp'] = Variable<int>(vatRateBp.value);
    }
    if (vatCents.present) {
      map['vat_cents'] = Variable<int>(vatCents.value);
    }
    if (grossCents.present) {
      map['gross_cents'] = Variable<int>(grossCents.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $InvoicesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('type: $type, ')
          ..write('clientId: $clientId, ')
          ..write('orderId: $orderId, ')
          ..write('status: $status, ')
          ..write('issuedDate: $issuedDate, ')
          ..write('netCents: $netCents, ')
          ..write('vatRateBp: $vatRateBp, ')
          ..write('vatCents: $vatCents, ')
          ..write('grossCents: $grossCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoices (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMilliMeta = const VerificationMeta(
    'quantityMilli',
  );
  @override
  late final GeneratedColumn<int> quantityMilli = GeneratedColumn<int>(
    'quantity_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _unitPriceCentsMeta = const VerificationMeta(
    'unitPriceCents',
  );
  @override
  late final GeneratedColumn<int> unitPriceCents = GeneratedColumn<int>(
    'unit_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    position,
    description,
    quantityMilli,
    unit,
    unitPriceCents,
    totalCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantity_milli')) {
      context.handle(
        _quantityMilliMeta,
        quantityMilli.isAcceptableOrUnknown(
          data['quantity_milli']!,
          _quantityMilliMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityMilliMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('unit_price_cents')) {
      context.handle(
        _unitPriceCentsMeta,
        unitPriceCents.isAcceptableOrUnknown(
          data['unit_price_cents']!,
          _unitPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceCentsMeta);
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      quantityMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_milli'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      unitPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_cents'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  final String id;
  final String invoiceId;
  final int position;
  final String description;
  final int quantityMilli;
  final String unit;
  final int unitPriceCents;
  final int totalCents;
  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.position,
    required this.description,
    required this.quantityMilli,
    required this.unit,
    required this.unitPriceCents,
    required this.totalCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['position'] = Variable<int>(position);
    map['description'] = Variable<String>(description);
    map['quantity_milli'] = Variable<int>(quantityMilli);
    map['unit'] = Variable<String>(unit);
    map['unit_price_cents'] = Variable<int>(unitPriceCents);
    map['total_cents'] = Variable<int>(totalCents);
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      position: Value(position),
      description: Value(description),
      quantityMilli: Value(quantityMilli),
      unit: Value(unit),
      unitPriceCents: Value(unitPriceCents),
      totalCents: Value(totalCents),
    );
  }

  factory InvoiceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      position: serializer.fromJson<int>(json['position']),
      description: serializer.fromJson<String>(json['description']),
      quantityMilli: serializer.fromJson<int>(json['quantityMilli']),
      unit: serializer.fromJson<String>(json['unit']),
      unitPriceCents: serializer.fromJson<int>(json['unitPriceCents']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'position': serializer.toJson<int>(position),
      'description': serializer.toJson<String>(description),
      'quantityMilli': serializer.toJson<int>(quantityMilli),
      'unit': serializer.toJson<String>(unit),
      'unitPriceCents': serializer.toJson<int>(unitPriceCents),
      'totalCents': serializer.toJson<int>(totalCents),
    };
  }

  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    int? position,
    String? description,
    int? quantityMilli,
    String? unit,
    int? unitPriceCents,
    int? totalCents,
  }) => InvoiceItem(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    position: position ?? this.position,
    description: description ?? this.description,
    quantityMilli: quantityMilli ?? this.quantityMilli,
    unit: unit ?? this.unit,
    unitPriceCents: unitPriceCents ?? this.unitPriceCents,
    totalCents: totalCents ?? this.totalCents,
  );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      position: data.position.present ? data.position.value : this.position,
      description: data.description.present
          ? data.description.value
          : this.description,
      quantityMilli: data.quantityMilli.present
          ? data.quantityMilli.value
          : this.quantityMilli,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitPriceCents: data.unitPriceCents.present
          ? data.unitPriceCents.value
          : this.unitPriceCents,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('position: $position, ')
          ..write('description: $description, ')
          ..write('quantityMilli: $quantityMilli, ')
          ..write('unit: $unit, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('totalCents: $totalCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceId,
    position,
    description,
    quantityMilli,
    unit,
    unitPriceCents,
    totalCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.position == this.position &&
          other.description == this.description &&
          other.quantityMilli == this.quantityMilli &&
          other.unit == this.unit &&
          other.unitPriceCents == this.unitPriceCents &&
          other.totalCents == this.totalCents);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<int> position;
  final Value<String> description;
  final Value<int> quantityMilli;
  final Value<String> unit;
  final Value<int> unitPriceCents;
  final Value<int> totalCents;
  final Value<int> rowid;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.position = const Value.absent(),
    this.description = const Value.absent(),
    this.quantityMilli = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitPriceCents = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    required String id,
    required String invoiceId,
    required int position,
    required String description,
    required int quantityMilli,
    this.unit = const Value.absent(),
    required int unitPriceCents,
    required int totalCents,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       invoiceId = Value(invoiceId),
       position = Value(position),
       description = Value(description),
       quantityMilli = Value(quantityMilli),
       unitPriceCents = Value(unitPriceCents),
       totalCents = Value(totalCents);
  static Insertable<InvoiceItem> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<int>? position,
    Expression<String>? description,
    Expression<int>? quantityMilli,
    Expression<String>? unit,
    Expression<int>? unitPriceCents,
    Expression<int>? totalCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (position != null) 'position': position,
      if (description != null) 'description': description,
      if (quantityMilli != null) 'quantity_milli': quantityMilli,
      if (unit != null) 'unit': unit,
      if (unitPriceCents != null) 'unit_price_cents': unitPriceCents,
      if (totalCents != null) 'total_cents': totalCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? invoiceId,
    Value<int>? position,
    Value<String>? description,
    Value<int>? quantityMilli,
    Value<String>? unit,
    Value<int>? unitPriceCents,
    Value<int>? totalCents,
    Value<int>? rowid,
  }) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      position: position ?? this.position,
      description: description ?? this.description,
      quantityMilli: quantityMilli ?? this.quantityMilli,
      unit: unit ?? this.unit,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      totalCents: totalCents ?? this.totalCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantityMilli.present) {
      map['quantity_milli'] = Variable<int>(quantityMilli.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitPriceCents.present) {
      map['unit_price_cents'] = Variable<int>(unitPriceCents.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('position: $position, ')
          ..write('description: $description, ')
          ..write('quantityMilli: $quantityMilli, ')
          ..write('unit: $unit, ')
          ..write('unitPriceCents: $unitPriceCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
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
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
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
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
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

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
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
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
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

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
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
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceSequencesTable extends InvoiceSequences
    with TableInfo<$InvoiceSequencesTable, InvoiceSequence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceSequencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNumberMeta = const VerificationMeta(
    'lastNumber',
  );
  @override
  late final GeneratedColumn<int> lastNumber = GeneratedColumn<int>(
    'last_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [year, type, lastNumber];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_sequences';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceSequence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('last_number')) {
      context.handle(
        _lastNumberMeta,
        lastNumber.isAcceptableOrUnknown(data['last_number']!, _lastNumberMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {year, type};
  @override
  InvoiceSequence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceSequence(
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      lastNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_number'],
      )!,
    );
  }

  @override
  $InvoiceSequencesTable createAlias(String alias) {
    return $InvoiceSequencesTable(attachedDatabase, alias);
  }
}

class InvoiceSequence extends DataClass implements Insertable<InvoiceSequence> {
  final int year;
  final String type;
  final int lastNumber;
  const InvoiceSequence({
    required this.year,
    required this.type,
    required this.lastNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['year'] = Variable<int>(year);
    map['type'] = Variable<String>(type);
    map['last_number'] = Variable<int>(lastNumber);
    return map;
  }

  InvoiceSequencesCompanion toCompanion(bool nullToAbsent) {
    return InvoiceSequencesCompanion(
      year: Value(year),
      type: Value(type),
      lastNumber: Value(lastNumber),
    );
  }

  factory InvoiceSequence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceSequence(
      year: serializer.fromJson<int>(json['year']),
      type: serializer.fromJson<String>(json['type']),
      lastNumber: serializer.fromJson<int>(json['lastNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'year': serializer.toJson<int>(year),
      'type': serializer.toJson<String>(type),
      'lastNumber': serializer.toJson<int>(lastNumber),
    };
  }

  InvoiceSequence copyWith({int? year, String? type, int? lastNumber}) =>
      InvoiceSequence(
        year: year ?? this.year,
        type: type ?? this.type,
        lastNumber: lastNumber ?? this.lastNumber,
      );
  InvoiceSequence copyWithCompanion(InvoiceSequencesCompanion data) {
    return InvoiceSequence(
      year: data.year.present ? data.year.value : this.year,
      type: data.type.present ? data.type.value : this.type,
      lastNumber: data.lastNumber.present
          ? data.lastNumber.value
          : this.lastNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceSequence(')
          ..write('year: $year, ')
          ..write('type: $type, ')
          ..write('lastNumber: $lastNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(year, type, lastNumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceSequence &&
          other.year == this.year &&
          other.type == this.type &&
          other.lastNumber == this.lastNumber);
}

class InvoiceSequencesCompanion extends UpdateCompanion<InvoiceSequence> {
  final Value<int> year;
  final Value<String> type;
  final Value<int> lastNumber;
  final Value<int> rowid;
  const InvoiceSequencesCompanion({
    this.year = const Value.absent(),
    this.type = const Value.absent(),
    this.lastNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceSequencesCompanion.insert({
    required int year,
    required String type,
    this.lastNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : year = Value(year),
       type = Value(type);
  static Insertable<InvoiceSequence> custom({
    Expression<int>? year,
    Expression<String>? type,
    Expression<int>? lastNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (year != null) 'year': year,
      if (type != null) 'type': type,
      if (lastNumber != null) 'last_number': lastNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceSequencesCompanion copyWith({
    Value<int>? year,
    Value<String>? type,
    Value<int>? lastNumber,
    Value<int>? rowid,
  }) {
    return InvoiceSequencesCompanion(
      year: year ?? this.year,
      type: type ?? this.type,
      lastNumber: lastNumber ?? this.lastNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (lastNumber.present) {
      map['last_number'] = Variable<int>(lastNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceSequencesCompanion(')
          ..write('year: $year, ')
          ..write('type: $type, ')
          ..write('lastNumber: $lastNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($OrdersTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> dueDateStart =
      GeneratedColumn<String>(
        'due_date_start',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($OrdersTable.$converterdueDateStartn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> dueDateEnd =
      GeneratedColumn<String>(
        'due_date_end',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($OrdersTable.$converterdueDateEndn);
  @override
  late final GeneratedColumnWithTypeConverter<OrderStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('offen'),
      ).withConverter<OrderStatus>($OrdersTable.$converterstatus);
  static const VerificationMeta _recurringMeta = const VerificationMeta(
    'recurring',
  );
  @override
  late final GeneratedColumn<bool> recurring = GeneratedColumn<bool>(
    'recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    title,
    description,
    createdAt,
    dueDateStart,
    dueDateEnd,
    status,
    recurring,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Order> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('recurring')) {
      context.handle(
        _recurringMeta,
        recurring.isAcceptableOrUnknown(data['recurring']!, _recurringMeta),
      );
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
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      createdAt: $OrdersTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      dueDateStart: $OrdersTable.$converterdueDateStartn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_date_start'],
        ),
      ),
      dueDateEnd: $OrdersTable.$converterdueDateEndn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_date_end'],
        ),
      ),
      status: $OrdersTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      recurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recurring'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const IsoDateConverter();
  static TypeConverter<DateTime, String> $converterdueDateStart =
      const IsoDateConverter();
  static TypeConverter<DateTime?, String?> $converterdueDateStartn =
      NullAwareTypeConverter.wrap($converterdueDateStart);
  static TypeConverter<DateTime, String> $converterdueDateEnd =
      const IsoDateConverter();
  static TypeConverter<DateTime?, String?> $converterdueDateEndn =
      NullAwareTypeConverter.wrap($converterdueDateEnd);
  static JsonTypeConverter2<OrderStatus, String, String> $converterstatus =
      const EnumNameConverter<OrderStatus>(OrderStatus.values);
}

class Order extends DataClass implements Insertable<Order> {
  final String id;
  final String clientId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueDateStart;
  final DateTime? dueDateEnd;
  final OrderStatus status;
  final bool recurring;
  final String notes;
  const Order({
    required this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueDateStart,
    this.dueDateEnd,
    required this.status,
    required this.recurring,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    {
      map['created_at'] = Variable<String>(
        $OrdersTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    if (!nullToAbsent || dueDateStart != null) {
      map['due_date_start'] = Variable<String>(
        $OrdersTable.$converterdueDateStartn.toSql(dueDateStart),
      );
    }
    if (!nullToAbsent || dueDateEnd != null) {
      map['due_date_end'] = Variable<String>(
        $OrdersTable.$converterdueDateEndn.toSql(dueDateEnd),
      );
    }
    {
      map['status'] = Variable<String>(
        $OrdersTable.$converterstatus.toSql(status),
      );
    }
    map['recurring'] = Variable<bool>(recurring);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      clientId: Value(clientId),
      title: Value(title),
      description: Value(description),
      createdAt: Value(createdAt),
      dueDateStart: dueDateStart == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDateStart),
      dueDateEnd: dueDateEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDateEnd),
      status: Value(status),
      recurring: Value(recurring),
      notes: Value(notes),
    );
  }

  factory Order.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      dueDateStart: serializer.fromJson<DateTime?>(json['dueDateStart']),
      dueDateEnd: serializer.fromJson<DateTime?>(json['dueDateEnd']),
      status: $OrdersTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      recurring: serializer.fromJson<bool>(json['recurring']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'dueDateStart': serializer.toJson<DateTime?>(dueDateStart),
      'dueDateEnd': serializer.toJson<DateTime?>(dueDateEnd),
      'status': serializer.toJson<String>(
        $OrdersTable.$converterstatus.toJson(status),
      ),
      'recurring': serializer.toJson<bool>(recurring),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Order copyWith({
    String? id,
    String? clientId,
    String? title,
    String? description,
    DateTime? createdAt,
    Value<DateTime?> dueDateStart = const Value.absent(),
    Value<DateTime?> dueDateEnd = const Value.absent(),
    OrderStatus? status,
    bool? recurring,
    String? notes,
  }) => Order(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    title: title ?? this.title,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    dueDateStart: dueDateStart.present ? dueDateStart.value : this.dueDateStart,
    dueDateEnd: dueDateEnd.present ? dueDateEnd.value : this.dueDateEnd,
    status: status ?? this.status,
    recurring: recurring ?? this.recurring,
    notes: notes ?? this.notes,
  );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      dueDateStart: data.dueDateStart.present
          ? data.dueDateStart.value
          : this.dueDateStart,
      dueDateEnd: data.dueDateEnd.present
          ? data.dueDateEnd.value
          : this.dueDateEnd,
      status: data.status.present ? data.status.value : this.status,
      recurring: data.recurring.present ? data.recurring.value : this.recurring,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('dueDateStart: $dueDateStart, ')
          ..write('dueDateEnd: $dueDateEnd, ')
          ..write('status: $status, ')
          ..write('recurring: $recurring, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    title,
    description,
    createdAt,
    dueDateStart,
    dueDateEnd,
    status,
    recurring,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.dueDateStart == this.dueDateStart &&
          other.dueDateEnd == this.dueDateEnd &&
          other.status == this.status &&
          other.recurring == this.recurring &&
          other.notes == this.notes);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> createdAt;
  final Value<DateTime?> dueDateStart;
  final Value<DateTime?> dueDateEnd;
  final Value<OrderStatus> status;
  final Value<bool> recurring;
  final Value<String> notes;
  final Value<int> rowid;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dueDateStart = const Value.absent(),
    this.dueDateEnd = const Value.absent(),
    this.status = const Value.absent(),
    this.recurring = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String id,
    required String clientId,
    required String title,
    this.description = const Value.absent(),
    required DateTime createdAt,
    this.dueDateStart = const Value.absent(),
    this.dueDateEnd = const Value.absent(),
    this.status = const Value.absent(),
    this.recurring = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clientId = Value(clientId),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<Order> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? createdAt,
    Expression<String>? dueDateStart,
    Expression<String>? dueDateEnd,
    Expression<String>? status,
    Expression<bool>? recurring,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (dueDateStart != null) 'due_date_start': dueDateStart,
      if (dueDateEnd != null) 'due_date_end': dueDateEnd,
      if (status != null) 'status': status,
      if (recurring != null) 'recurring': recurring,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime>? createdAt,
    Value<DateTime?>? dueDateStart,
    Value<DateTime?>? dueDateEnd,
    Value<OrderStatus>? status,
    Value<bool>? recurring,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return OrdersCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDateStart: dueDateStart ?? this.dueDateStart,
      dueDateEnd: dueDateEnd ?? this.dueDateEnd,
      status: status ?? this.status,
      recurring: recurring ?? this.recurring,
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
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $OrdersTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (dueDateStart.present) {
      map['due_date_start'] = Variable<String>(
        $OrdersTable.$converterdueDateStartn.toSql(dueDateStart.value),
      );
    }
    if (dueDateEnd.present) {
      map['due_date_end'] = Variable<String>(
        $OrdersTable.$converterdueDateEndn.toSql(dueDateEnd.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $OrdersTable.$converterstatus.toSql(status.value),
      );
    }
    if (recurring.present) {
      map['recurring'] = Variable<bool>(recurring.value);
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
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('dueDateStart: $dueDateStart, ')
          ..write('dueDateEnd: $dueDateEnd, ')
          ..write('status: $status, ')
          ..write('recurring: $recurring, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $InvoiceSequencesTable invoiceSequences = $InvoiceSequencesTable(
    this,
  );
  late final $OrdersTable orders = $OrdersTable(this);
  late final Index idxInvoicesClient = Index(
    'idx_invoices_client',
    'CREATE INDEX idx_invoices_client ON invoices (client_id)',
  );
  late final Index idxInvoicesOrder = Index(
    'idx_invoices_order',
    'CREATE INDEX idx_invoices_order ON invoices (order_id)',
  );
  late final Index idxOrdersClient = Index(
    'idx_orders_client',
    'CREATE INDEX idx_orders_client ON orders (client_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clients,
    invoices,
    invoiceItems,
    settings,
    invoiceSequences,
    orders,
    idxInvoicesClient,
    idxInvoicesOrder,
    idxOrdersClient,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'invoices',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('invoice_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ClientsTableCreateCompanionBuilder = ClientsCompanion Function({
  required String id,
  required String name,
  Value<String> street,
  Value<String> zip,
  Value<String> city,
  Value<String> phone,
  Value<String> email,
  Value<double?> lat,
  Value<double?> lon,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ClientsTableUpdateCompanionBuilder = ClientsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> street,
  Value<String> zip,
  Value<String> city,
  Value<String> phone,
  Value<String> email,
  Value<double?> lat,
  Value<double?> lon,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$ClientsTableReferences
    extends BaseReferences<_$AppDatabase, $ClientsTable, Client> {
  $$ClientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.invoices,
    aliasName: 'clients__id__invoices__client_id',
  );

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrdersTable, List<Order>> _ordersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.orders,
    aliasName: 'clients__id__orders__client_id',
  );

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zip => $composableBuilder(
    column: $table.zip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> invoicesRefs(
    Expression<bool> Function($$InvoicesTableFilterComposer f) f,
  ) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ordersRefs(
    Expression<bool> Function($$OrdersTableFilterComposer f) f,
  ) {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zip => $composableBuilder(
    column: $table.zip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

  GeneratedColumn<String> get zip =>
      $composableBuilder(column: $table.zip, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> invoicesRefs<T extends Object>(
    Expression<T> Function($$InvoicesTableAnnotationComposer a) f,
  ) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ordersRefs<T extends Object>(
    Expression<T> Function($$OrdersTableAnnotationComposer a) f,
  ) {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientsTable,
          Client,
          $$ClientsTableFilterComposer,
          $$ClientsTableOrderingComposer,
          $$ClientsTableAnnotationComposer,
          $$ClientsTableCreateCompanionBuilder,
          $$ClientsTableUpdateCompanionBuilder,
          (Client, $$ClientsTableReferences),
          Client,
          PrefetchHooks Function({bool invoicesRefs, bool ordersRefs})
        > {
  $$ClientsTableTableManager(_$AppDatabase db, $ClientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> street = const Value.absent(),
                Value<String> zip = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion(
                id: id,
                name: name,
                street: street,
                zip: zip,
                city: city,
                phone: phone,
                email: email,
                lat: lat,
                lon: lon,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> street = const Value.absent(),
                Value<String> zip = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion.insert(
                id: id,
                name: name,
                street: street,
                zip: zip,
                city: city,
                phone: phone,
                email: email,
                lat: lat,
                lon: lon,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClientsTable, Client>(table),
                  $$ClientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({invoicesRefs = false, ordersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (invoicesRefs) db.invoices,
                if (ordersRefs) db.orders,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoicesRefs)
                    await $_getPrefetchedDataByColumns<
                      Client,
                      $ClientsTable,
                      Invoice,
                      $InvoicesTable
                    >(
                      currentTable: table,
                      referencedTable: $$ClientsTableReferences
                          ._invoicesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ClientsTableReferences(db, table, p0).invoicesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'client_id',
                      typedResults: items,
                    ),
                  if (ordersRefs)
                    await $_getPrefetchedDataByColumns<
                      Client,
                      $ClientsTable,
                      Order,
                      $OrdersTable
                    >(
                      currentTable: table,
                      referencedTable: $$ClientsTableReferences
                          ._ordersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ClientsTableReferences(db, table, p0).ordersRefs,
                      currentColumn: 'id',
                      referencedColumn: 'client_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ClientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientsTable,
      Client,
      $$ClientsTableFilterComposer,
      $$ClientsTableOrderingComposer,
      $$ClientsTableAnnotationComposer,
      $$ClientsTableCreateCompanionBuilder,
      $$ClientsTableUpdateCompanionBuilder,
      (Client, $$ClientsTableReferences),
      Client,
      PrefetchHooks Function({bool invoicesRefs, bool ordersRefs})
    >;
typedef $$InvoicesTableCreateCompanionBuilder = InvoicesCompanion Function({
  required String id,
  Value<String?> number,
  Value<String> type,
  required String clientId,
  Value<String?> orderId,
  Value<String> status,
  Value<DateTime?> issuedDate,
  Value<int> netCents,
  Value<int> vatRateBp,
  Value<int> vatCents,
  Value<int> grossCents,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$InvoicesTableUpdateCompanionBuilder = InvoicesCompanion Function({
  Value<String> id,
  Value<String?> number,
  Value<String> type,
  Value<String> clientId,
  Value<String?> orderId,
  Value<String> status,
  Value<DateTime?> issuedDate,
  Value<int> netCents,
  Value<int> vatRateBp,
  Value<int> vatCents,
  Value<int> grossCents,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$InvoicesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoicesTable, Invoice> {
  $$InvoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$AppDatabase db) =>
      db.clients.createAlias('invoices__client_id__clients__id');

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InvoiceItemsTable, List<InvoiceItem>>
  _invoiceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.invoiceItems,
    aliasName: 'invoices__id__invoice_items__invoice_id',
  );

  $$InvoiceItemsTableProcessedTableManager get invoiceItemsRefs {
    final manager = $$InvoiceItemsTableTableManager(
      $_db,
      $_db.invoiceItems,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
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

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get issuedDate =>
      $composableBuilder(
        column: $table.issuedDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get netCents => $composableBuilder(
    column: $table.netCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vatRateBp => $composableBuilder(
    column: $table.vatRateBp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vatCents => $composableBuilder(
    column: $table.vatCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> invoiceItemsRefs(
    Expression<bool> Function($$InvoiceItemsTableFilterComposer f) f,
  ) {
    final $$InvoiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
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

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuedDate => $composableBuilder(
    column: $table.issuedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netCents => $composableBuilder(
    column: $table.netCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vatRateBp => $composableBuilder(
    column: $table.vatRateBp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vatCents => $composableBuilder(
    column: $table.vatCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get issuedDate =>
      $composableBuilder(
        column: $table.issuedDate,
        builder: (column) => column,
      );

  GeneratedColumn<int> get netCents =>
      $composableBuilder(column: $table.netCents, builder: (column) => column);

  GeneratedColumn<int> get vatRateBp =>
      $composableBuilder(column: $table.vatRateBp, builder: (column) => column);

  GeneratedColumn<int> get vatCents =>
      $composableBuilder(column: $table.vatCents, builder: (column) => column);

  GeneratedColumn<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> invoiceItemsRefs<T extends Object>(
    Expression<T> Function($$InvoiceItemsTableAnnotationComposer a) f,
  ) {
    final $$InvoiceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoicesTable,
          Invoice,
          $$InvoicesTableFilterComposer,
          $$InvoicesTableOrderingComposer,
          $$InvoicesTableAnnotationComposer,
          $$InvoicesTableCreateCompanionBuilder,
          $$InvoicesTableUpdateCompanionBuilder,
          (Invoice, $$InvoicesTableReferences),
          Invoice,
          PrefetchHooks Function({bool clientId, bool invoiceItemsRefs})
        > {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> number = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String?> orderId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> issuedDate = const Value.absent(),
                Value<int> netCents = const Value.absent(),
                Value<int> vatRateBp = const Value.absent(),
                Value<int> vatCents = const Value.absent(),
                Value<int> grossCents = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion(
                id: id,
                number: number,
                type: type,
                clientId: clientId,
                orderId: orderId,
                status: status,
                issuedDate: issuedDate,
                netCents: netCents,
                vatRateBp: vatRateBp,
                vatCents: vatCents,
                grossCents: grossCents,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> number = const Value.absent(),
                Value<String> type = const Value.absent(),
                required String clientId,
                Value<String?> orderId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> issuedDate = const Value.absent(),
                Value<int> netCents = const Value.absent(),
                Value<int> vatRateBp = const Value.absent(),
                Value<int> vatCents = const Value.absent(),
                Value<int> grossCents = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion.insert(
                id: id,
                number: number,
                type: type,
                clientId: clientId,
                orderId: orderId,
                status: status,
                issuedDate: issuedDate,
                netCents: netCents,
                vatRateBp: vatRateBp,
                vatCents: vatCents,
                grossCents: grossCents,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InvoicesTable, Invoice>(table),
                  $$InvoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({clientId = false, invoiceItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (invoiceItemsRefs) db.invoiceItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (clientId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.clientId,
                            referencedTable: $$InvoicesTableReferences
                                ._clientIdTable(db),
                            referencedColumn: $$InvoicesTableReferences
                                ._clientIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (invoiceItemsRefs)
                        await $_getPrefetchedDataByColumns<
                          Invoice,
                          $InvoicesTable,
                          InvoiceItem,
                          $InvoiceItemsTable
                        >(
                          currentTable: table,
                          referencedTable: $$InvoicesTableReferences
                              ._invoiceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).invoiceItemsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'invoice_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoicesTable,
      Invoice,
      $$InvoicesTableFilterComposer,
      $$InvoicesTableOrderingComposer,
      $$InvoicesTableAnnotationComposer,
      $$InvoicesTableCreateCompanionBuilder,
      $$InvoicesTableUpdateCompanionBuilder,
      (Invoice, $$InvoicesTableReferences),
      Invoice,
      PrefetchHooks Function({bool clientId, bool invoiceItemsRefs})
    >;
typedef $$InvoiceItemsTableCreateCompanionBuilder =
    InvoiceItemsCompanion Function({
      required String id,
      required String invoiceId,
      required int position,
      required String description,
      required int quantityMilli,
      Value<String> unit,
      required int unitPriceCents,
      required int totalCents,
      Value<int> rowid,
    });
typedef $$InvoiceItemsTableUpdateCompanionBuilder =
    InvoiceItemsCompanion Function({
      Value<String> id,
      Value<String> invoiceId,
      Value<int> position,
      Value<String> description,
      Value<int> quantityMilli,
      Value<String> unit,
      Value<int> unitPriceCents,
      Value<int> totalCents,
      Value<int> rowid,
    });

final class $$InvoiceItemsTableReferences
    extends BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem> {
  $$InvoiceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias('invoice_items__invoice_id__invoices__id');

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityMilli => $composableBuilder(
    column: $table.quantityMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityMilli => $composableBuilder(
    column: $table.quantityMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityMilli => $composableBuilder(
    column: $table.quantityMilli,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get unitPriceCents => $composableBuilder(
    column: $table.unitPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoiceItemsTable,
          InvoiceItem,
          $$InvoiceItemsTableFilterComposer,
          $$InvoiceItemsTableOrderingComposer,
          $$InvoiceItemsTableAnnotationComposer,
          $$InvoiceItemsTableCreateCompanionBuilder,
          $$InvoiceItemsTableUpdateCompanionBuilder,
          (InvoiceItem, $$InvoiceItemsTableReferences),
          InvoiceItem,
          PrefetchHooks Function({bool invoiceId})
        > {
  $$InvoiceItemsTableTableManager(_$AppDatabase db, $InvoiceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> quantityMilli = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> unitPriceCents = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceItemsCompanion(
                id: id,
                invoiceId: invoiceId,
                position: position,
                description: description,
                quantityMilli: quantityMilli,
                unit: unit,
                unitPriceCents: unitPriceCents,
                totalCents: totalCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String invoiceId,
                required int position,
                required String description,
                required int quantityMilli,
                Value<String> unit = const Value.absent(),
                required int unitPriceCents,
                required int totalCents,
                Value<int> rowid = const Value.absent(),
              }) => InvoiceItemsCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                position: position,
                description: description,
                quantityMilli: quantityMilli,
                unit: unit,
                unitPriceCents: unitPriceCents,
                totalCents: totalCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InvoiceItemsTable, InvoiceItem>(table),
                  $$InvoiceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({invoiceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (invoiceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.invoiceId,
                        referencedTable: $$InvoiceItemsTableReferences
                            ._invoiceIdTable(db),
                        referencedColumn: $$InvoiceItemsTableReferences
                            ._invoiceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InvoiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoiceItemsTable,
      InvoiceItem,
      $$InvoiceItemsTableFilterComposer,
      $$InvoiceItemsTableOrderingComposer,
      $$InvoiceItemsTableAnnotationComposer,
      $$InvoiceItemsTableCreateCompanionBuilder,
      $$InvoiceItemsTableUpdateCompanionBuilder,
      (InvoiceItem, $$InvoiceItemsTableReferences),
      InvoiceItem,
      PrefetchHooks Function({bool invoiceId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
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

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
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

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$InvoiceSequencesTableCreateCompanionBuilder =
    InvoiceSequencesCompanion Function({
      required int year,
      required String type,
      Value<int> lastNumber,
      Value<int> rowid,
    });
typedef $$InvoiceSequencesTableUpdateCompanionBuilder =
    InvoiceSequencesCompanion Function({
      Value<int> year,
      Value<String> type,
      Value<int> lastNumber,
      Value<int> rowid,
    });

class $$InvoiceSequencesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceSequencesTable> {
  $$InvoiceSequencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastNumber => $composableBuilder(
    column: $table.lastNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvoiceSequencesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceSequencesTable> {
  $$InvoiceSequencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastNumber => $composableBuilder(
    column: $table.lastNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvoiceSequencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceSequencesTable> {
  $$InvoiceSequencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get lastNumber => $composableBuilder(
    column: $table.lastNumber,
    builder: (column) => column,
  );
}

class $$InvoiceSequencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoiceSequencesTable,
          InvoiceSequence,
          $$InvoiceSequencesTableFilterComposer,
          $$InvoiceSequencesTableOrderingComposer,
          $$InvoiceSequencesTableAnnotationComposer,
          $$InvoiceSequencesTableCreateCompanionBuilder,
          $$InvoiceSequencesTableUpdateCompanionBuilder,
          (
            InvoiceSequence,
            BaseReferences<
              _$AppDatabase,
              $InvoiceSequencesTable,
              InvoiceSequence
            >,
          ),
          InvoiceSequence,
          PrefetchHooks Function()
        > {
  $$InvoiceSequencesTableTableManager(
    _$AppDatabase db,
    $InvoiceSequencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceSequencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceSequencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceSequencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> year = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> lastNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceSequencesCompanion(
                year: year,
                type: type,
                lastNumber: lastNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int year,
                required String type,
                Value<int> lastNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceSequencesCompanion.insert(
                year: year,
                type: type,
                lastNumber: lastNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InvoiceSequencesTable, InvoiceSequence>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $InvoiceSequencesTable,
                    InvoiceSequence
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvoiceSequencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoiceSequencesTable,
      InvoiceSequence,
      $$InvoiceSequencesTableFilterComposer,
      $$InvoiceSequencesTableOrderingComposer,
      $$InvoiceSequencesTableAnnotationComposer,
      $$InvoiceSequencesTableCreateCompanionBuilder,
      $$InvoiceSequencesTableUpdateCompanionBuilder,
      (
        InvoiceSequence,
        BaseReferences<_$AppDatabase, $InvoiceSequencesTable, InvoiceSequence>,
      ),
      InvoiceSequence,
      PrefetchHooks Function()
    >;
typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  required String id,
  required String clientId,
  required String title,
  Value<String> description,
  required DateTime createdAt,
  Value<DateTime?> dueDateStart,
  Value<DateTime?> dueDateEnd,
  Value<OrderStatus> status,
  Value<bool> recurring,
  Value<String> notes,
  Value<int> rowid,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<String> id,
  Value<String> clientId,
  Value<String> title,
  Value<String> description,
  Value<DateTime> createdAt,
  Value<DateTime?> dueDateStart,
  Value<DateTime?> dueDateEnd,
  Value<OrderStatus> status,
  Value<bool> recurring,
  Value<String> notes,
  Value<int> rowid,
});

final class $$OrdersTableReferences
    extends BaseReferences<_$AppDatabase, $OrdersTable, Order> {
  $$OrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$AppDatabase db) =>
      db.clients.createAlias('orders__client_id__clients__id');

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String>
  get dueDateStart => $composableBuilder(
    column: $table.dueDateStart,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get dueDateEnd =>
      $composableBuilder(
        column: $table.dueDateEnd,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<OrderStatus, OrderStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get recurring => $composableBuilder(
    column: $table.recurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDateStart => $composableBuilder(
    column: $table.dueDateStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDateEnd => $composableBuilder(
    column: $table.dueDateEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recurring => $composableBuilder(
    column: $table.recurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get dueDateStart =>
      $composableBuilder(
        column: $table.dueDateStart,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, String> get dueDateEnd =>
      $composableBuilder(
        column: $table.dueDateEnd,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<OrderStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get recurring =>
      $composableBuilder(column: $table.recurring, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdersTable,
          Order,
          $$OrdersTableFilterComposer,
          $$OrdersTableOrderingComposer,
          $$OrdersTableAnnotationComposer,
          $$OrdersTableCreateCompanionBuilder,
          $$OrdersTableUpdateCompanionBuilder,
          (Order, $$OrdersTableReferences),
          Order,
          PrefetchHooks Function({bool clientId})
        > {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> dueDateStart = const Value.absent(),
                Value<DateTime?> dueDateEnd = const Value.absent(),
                Value<OrderStatus> status = const Value.absent(),
                Value<bool> recurring = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion(
                id: id,
                clientId: clientId,
                title: title,
                description: description,
                createdAt: createdAt,
                dueDateStart: dueDateStart,
                dueDateEnd: dueDateEnd,
                status: status,
                recurring: recurring,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clientId,
                required String title,
                Value<String> description = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> dueDateStart = const Value.absent(),
                Value<DateTime?> dueDateEnd = const Value.absent(),
                Value<OrderStatus> status = const Value.absent(),
                Value<bool> recurring = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion.insert(
                id: id,
                clientId: clientId,
                title: title,
                description: description,
                createdAt: createdAt,
                dueDateStart: dueDateStart,
                dueDateEnd: dueDateEnd,
                status: status,
                recurring: recurring,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OrdersTable, Order>(table),
                  $$OrdersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (clientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.clientId,
                        referencedTable: $$OrdersTableReferences._clientIdTable(
                          db,
                        ),
                        referencedColumn: $$OrdersTableReferences
                            ._clientIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdersTable,
      Order,
      $$OrdersTableFilterComposer,
      $$OrdersTableOrderingComposer,
      $$OrdersTableAnnotationComposer,
      $$OrdersTableCreateCompanionBuilder,
      $$OrdersTableUpdateCompanionBuilder,
      (Order, $$OrdersTableReferences),
      Order,
      PrefetchHooks Function({bool clientId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$InvoiceSequencesTableTableManager get invoiceSequences =>
      $$InvoiceSequencesTableTableManager(_db, _db.invoiceSequences);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
}
