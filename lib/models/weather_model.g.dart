// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeatherModelAdapter extends TypeAdapter<WeatherModel> {
  @override
  final int typeId = 0;

  @override
  WeatherModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeatherModel(
      location: fields[0] as String,
      country: fields[1] as String,
      lastUpdated: fields[2] as DateTime,
      iconUrl: fields[3] as String,
      temperature: fields[4] as double,
      maxTemperature: fields[5] as double,
      minTemperature: fields[6] as double,
      condition: fields[7] as String,
      humidity: fields[8] as double,
      windSpeed: fields[9] as double,
      pressure: fields[10] as double,
      uvIndex: fields[11] as double,
      visibility: fields[12] as double,
      windDirection: fields[13] as String,
      cacheTime: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeatherModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.location)
      ..writeByte(1)
      ..write(obj.country)
      ..writeByte(2)
      ..write(obj.lastUpdated)
      ..writeByte(3)
      ..write(obj.iconUrl)
      ..writeByte(4)
      ..write(obj.temperature)
      ..writeByte(5)
      ..write(obj.maxTemperature)
      ..writeByte(6)
      ..write(obj.minTemperature)
      ..writeByte(7)
      ..write(obj.condition)
      ..writeByte(8)
      ..write(obj.humidity)
      ..writeByte(9)
      ..write(obj.windSpeed)
      ..writeByte(10)
      ..write(obj.pressure)
      ..writeByte(11)
      ..write(obj.uvIndex)
      ..writeByte(12)
      ..write(obj.visibility)
      ..writeByte(13)
      ..write(obj.windDirection)
      ..writeByte(14)
      ..write(obj.cacheTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
