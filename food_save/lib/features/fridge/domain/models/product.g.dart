// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  emoji: json['emoji'] as String,
  purchaseDate: DateTime.parse(json['purchaseDate'] as String),
  expiryDate: DateTime.parse(json['expiryDate'] as String),
  isEaten: json['isEaten'] as bool? ?? false,
  isSpoiled: json['isSpoiled'] as bool? ?? false,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'emoji': instance.emoji,
  'purchaseDate': instance.purchaseDate.toIso8601String(),
  'expiryDate': instance.expiryDate.toIso8601String(),
  'isEaten': instance.isEaten,
  'isSpoiled': instance.isSpoiled,
};
