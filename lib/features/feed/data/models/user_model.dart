import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  @JsonKey(name: 'address')
  final AddressModel? addressModel;
  
  @JsonKey(name: 'company')
  final CompanyModel? companyModel;

  const UserModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
    super.phone,
    super.website,
    this.addressModel,
    this.companyModel,
  }) : super(
          address: addressModel,
          company: companyModel,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      username: user.username,
      email: user.email,
      phone: user.phone,
      website: user.website,
      addressModel: user.address != null ? AddressModel.fromEntity(user.address!) : null,
      companyModel: user.company != null ? CompanyModel.fromEntity(user.company!) : null,
    );
  }
}

@JsonSerializable()
class AddressModel extends Address {
  @JsonKey(name: 'geo')
  final GeoModel geoModel;

  const AddressModel({
    required super.street,
    required super.suite,
    required super.city,
    required super.zipcode,
    required this.geoModel,
  }) : super(geo: geoModel);

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  factory AddressModel.fromEntity(Address address) {
    return AddressModel(
      street: address.street,
      suite: address.suite,
      city: address.city,
      zipcode: address.zipcode,
      geoModel: GeoModel.fromEntity(address.geo),
    );
  }
}

@JsonSerializable()
class GeoModel extends Geo {
  const GeoModel({
    required super.lat,
    required super.lng,
  });

  factory GeoModel.fromJson(Map<String, dynamic> json) =>
      _$GeoModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeoModelToJson(this);

  factory GeoModel.fromEntity(Geo geo) {
    return GeoModel(
      lat: geo.lat,
      lng: geo.lng,
    );
  }
}

@JsonSerializable()
class CompanyModel extends Company {
  const CompanyModel({
    required super.name,
    required super.catchPhrase,
    required super.bs,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyModelFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyModelToJson(this);

  factory CompanyModel.fromEntity(Company company) {
    return CompanyModel(
      name: company.name,
      catchPhrase: company.catchPhrase,
      bs: company.bs,
    );
  }
}