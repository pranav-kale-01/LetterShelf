// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribed_newsletter_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscribedNewsletterHiveAdapter
    extends TypeAdapter<SubscribedNewsletterHive> {
  @override
  final int typeId = 0;

  @override
  SubscribedNewsletterHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscribedNewsletterHive(
      name: fields[0] as String,
      email: fields[1] as String,
      enabled: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SubscribedNewsletterHive obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.enabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscribedNewsletterHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
