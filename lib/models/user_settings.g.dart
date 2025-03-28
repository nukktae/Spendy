// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 3;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      name: fields[0] as String,
      email: fields[1] as String,
      currency: fields[2] as String,
      locale: fields[3] as String,
      isDarkMode: fields[4] as bool,
      notificationsEnabled: fields[5] as bool,
      budgetAlerts: fields[6] as bool,
      weeklyReports: fields[7] as bool,
      lastBackup: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.currency)
      ..writeByte(3)
      ..write(obj.locale)
      ..writeByte(4)
      ..write(obj.isDarkMode)
      ..writeByte(5)
      ..write(obj.notificationsEnabled)
      ..writeByte(6)
      ..write(obj.budgetAlerts)
      ..writeByte(7)
      ..write(obj.weeklyReports)
      ..writeByte(8)
      ..write(obj.lastBackup);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
