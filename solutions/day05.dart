import 'dart:io';

import 'package:meta/meta.dart';

import '../utils/index.dart';

class Day05 extends GenericDay {
  Day05() : super(5);

  @override
  Almanac parseInput() {
    // return Almanac.fromInputUtil(InputUtil.fromMultiLineString(mockInput));
    return Almanac.fromInputUtil(input);
  }

  @override
  int solvePart1() {
    return parseInput().getLowestLocationId();
  }

  @override
  int solvePart2() {
    // I GIVE UP
    return 0;
  }
}

class Almanac {
  Almanac.fromInputUtil(InputUtil input) {
    final [
      seedPart,
      seedToSoilPart,
      soilToFertilizerPart,
      fertilizerToWaterPart,
      waterToLightPart,
      lightToTemperaturePart,
      temperatureToHumidityPart,
      humidityToLocationPart
    ] = input.getPerWhitespace();
    final seedNumbers = seedPart.extractNumbers();
    seeds = seedNumbers.map((id) => Seed(id, 1)).toList();

    seedsWithRange =
        partition(seedNumbers, 2).map((e) => Seed(e.first, e.last)).toList();

    seedToSoil = AlmanacRelationsMap.fromInputPart(
      seedToSoilPart,
      fromTypeCreator: Seed.new,
      toTypeCreator: Soil.new,
    );

    soilToFertilizer = AlmanacRelationsMap.fromInputPart(
      soilToFertilizerPart,
      fromTypeCreator: Soil.new,
      toTypeCreator: Fertilizer.new,
    );
    fertilizerToWater = AlmanacRelationsMap.fromInputPart(
      fertilizerToWaterPart,
      fromTypeCreator: Fertilizer.new,
      toTypeCreator: Water.new,
    );
    waterToLight = AlmanacRelationsMap.fromInputPart(
      waterToLightPart,
      fromTypeCreator: Water.new,
      toTypeCreator: Light.new,
    );
    lightToTemperature = AlmanacRelationsMap.fromInputPart(
      lightToTemperaturePart,
      fromTypeCreator: Light.new,
      toTypeCreator: Temperature.new,
    );
    temperatureToHumidity = AlmanacRelationsMap.fromInputPart(
      temperatureToHumidityPart,
      fromTypeCreator: Temperature.new,
      toTypeCreator: Humidity.new,
    );
    humidityToLocation = AlmanacRelationsMap.fromInputPart(
      humidityToLocationPart,
      fromTypeCreator: Humidity.new,
      toTypeCreator: Location.new,
    );
  }

  late final List<Seed> seeds;
  late final List<Seed> seedsWithRange;
  late final AlmanacRelationsMap<Seed, Soil> seedToSoil;
  late final AlmanacRelationsMap<Soil, Fertilizer> soilToFertilizer;
  late final AlmanacRelationsMap<Fertilizer, Water> fertilizerToWater;
  late final AlmanacRelationsMap<Water, Light> waterToLight;
  late final AlmanacRelationsMap<Light, Temperature> lightToTemperature;
  late final AlmanacRelationsMap<Temperature, Humidity> temperatureToHumidity;
  late final AlmanacRelationsMap<Humidity, Location> humidityToLocation;

  Location getLocation(Seed seed) {
    final soil = seedToSoil.get(seed);
    final fertilizer = soilToFertilizer.get(soil);
    final water = fertilizerToWater.get(fertilizer);
    final light = waterToLight.get(water);
    final temperature = lightToTemperature.get(light);
    final humidity = temperatureToHumidity.get(temperature);
    final location = humidityToLocation.get(humidity);

    return location;
  }

  Seed getSeed(Location location) {
    final humidity = humidityToLocation.getBackwards(location);
    final temperature = temperatureToHumidity.getBackwards(humidity);
    final light = lightToTemperature.getBackwards(temperature);
    final water = waterToLight.getBackwards(light);
    final fertilizer = fertilizerToWater.getBackwards(water);
    final soil = soilToFertilizer.getBackwards(fertilizer);
    final seed = seedToSoil.getBackwards(soil);

    return seed;
  }

  int getLowestLocationId({
    bool useSeedsWithRange = false,
    int startLocationId = 106000000,
  }) {
    if (useSeedsWithRange) {
      var found = false;
      var locationId = startLocationId;

      final stopwatch = Stopwatch()..start();

      while (!found) {
        stdout
            .write('\rTrying location $locationId, took ${stopwatch.elapsed}');
        final possibleSeed = getSeed(Location(locationId, 1));

        final closestSeed = seedsWithRange
            .where(possibleSeed.fallsWithinRange)
            .sorted((a, b) => b.id - a.id)
            .firstOrNull;

        if (closestSeed != null || locationId == 0) {
          found = true;
        } else {
          locationId--;
        }
      }
      stopwatch.stop();
      if (locationId == 0) {
        print('\n ⚠️ Found no location');
      }
      return locationId;
    } else {
      final locations = <Location>[];

      for (final seed in seeds) {
        final location = getLocation(seed);
        locations.add(location);
      }

      return locations.sorted((a, b) => a.id - b.id).first.id;
    }
  }
}

typedef AlmanacItemCreator<T extends AlmanacItem> = T Function(int, int);

class AlmanacRelationsMap<FromType extends AlmanacItem,
    ToType extends AlmanacItem> {
  AlmanacRelationsMap(
    this._explicitRelations, {
    required AlmanacItemCreator<FromType> this.fromTypeCreator,
    required AlmanacItemCreator<ToType> this.toTypeCreator,
  });

  final Map<FromType, ToType> _explicitRelations;
  final AlmanacItemCreator<FromType> fromTypeCreator;
  final AlmanacItemCreator<ToType> toTypeCreator;

  factory AlmanacRelationsMap.fromInputPart(
    String input, {
    required AlmanacItemCreator<FromType> fromTypeCreator,
    required AlmanacItemCreator<ToType> toTypeCreator,
  }) {
    final relationsMap = InputUtil.fromMultiLineString(input)
        .getPerLine()
        .sublist(1)
        .map((e) => e.extractNumbers())
        .toList();

    final explicitRelations = <FromType, ToType>{};

    for (final [toId, fromId, range] in relationsMap) {
      explicitRelations[fromTypeCreator(fromId, range)] =
          toTypeCreator(toId, range);
    }

    return AlmanacRelationsMap(
      explicitRelations,
      fromTypeCreator: fromTypeCreator,
      toTypeCreator: toTypeCreator,
    );
  }

  FromType getBackwards(ToType to) {
    FromType getEffectiveFrom() {
      // same as getEffectiveTo but backwards
      if (_explicitRelations.containsValue(to)) {
        return _explicitRelations.entries
            .where((entry) => entry.value == to)
            .first
            .key;
      }

      final closestExplicitRelation = _explicitRelations.entries
          .where((entry) => entry.value.id < to.id)
          .sorted((a, b) => b.value.id - a.value.id)
          .firstOrNull;

      if (closestExplicitRelation != null) {
        final offsetToClosest = to.id - closestExplicitRelation.value.id;
        final fallsWithinRange =
            offsetToClosest <= closestExplicitRelation.value.range;

        if (fallsWithinRange) {
          return fromTypeCreator(
            closestExplicitRelation.key.id + offsetToClosest,
            closestExplicitRelation.key.range,
          );
        }
      }

      return fromTypeCreator(to.id, to.range);
    }

    final result = getEffectiveFrom();

    return result;
  }

  ToType get(FromType from) {
    ToType getEffectiveTo() {
      // Return the explicit relation if it exists
      if (_explicitRelations.containsKey(from)) {
        return _explicitRelations[from]!;
      }

      // Get the closest explicit relation which has a lower ID than from
      final closestExplicitRelation = _explicitRelations.entries
          .where((entry) => entry.key.id < from.id)
          .sorted((a, b) => b.key.id - a.key.id)
          .firstOrNull;

      if (closestExplicitRelation != null) {
        // Check if the closest explicit relation is within range of from
        final offsetToClosest = from.id - closestExplicitRelation.key.id;
        final fallsWithinRange =
            offsetToClosest <= closestExplicitRelation.key.range;

        if (fallsWithinRange) {
          // If it is, return a new ToType with the offset ID
          return toTypeCreator(
            closestExplicitRelation.value.id + offsetToClosest,
            closestExplicitRelation.value.range,
          );
        }
      }

      // If no explicit relation is found, return a new ToType with the same ID
      return toTypeCreator(from.id, from.range);
    }

    final result = getEffectiveTo();

    return result;
  }
}

@immutable
class AlmanacItem {
  const AlmanacItem(this.id, [this.range = 1]);
  final int id;
  final int range;

  bool fallsWithinRange(AlmanacItem other) {
    return id <= other.id + other.range && id >= other.id;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlmanacItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    // ignore: no_runtimetype_tostring
    return '$runtimeType($id, $range)';
  }
}

class Seed extends AlmanacItem {
  const Seed(super.id, super.range);
}

class Soil extends AlmanacItem {
  const Soil(super.id, super.range);
}

class Fertilizer extends AlmanacItem {
  const Fertilizer(super.id, super.range);
}

class Water extends AlmanacItem {
  const Water(super.id, super.range);
}

class Light extends AlmanacItem {
  const Light(super.id, super.range);
}

class Temperature extends AlmanacItem {
  const Temperature(super.id, super.range);
}

class Humidity extends AlmanacItem {
  const Humidity(super.id, super.range);
}

class Location extends AlmanacItem {
  const Location(super.id, super.range);
}
