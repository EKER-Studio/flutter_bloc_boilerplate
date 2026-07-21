// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserPreferencesModelCollection on Isar {
  IsarCollection<UserPreferencesModel> get userPreferencesModels =>
      this.collection();
}

const UserPreferencesModelSchema = CollectionSchema(
  name: r'UserPreferencesModel',
  id: 3603656307210587948,
  properties: {
    r'isNotificationsEnabled': PropertySchema(
      id: 0,
      name: r'isNotificationsEnabled',
      type: IsarType.bool,
    ),
    r'themeMode': PropertySchema(
      id: 1,
      name: r'themeMode',
      type: IsarType.string,
    ),
  },

  estimateSize: _userPreferencesModelEstimateSize,
  serialize: _userPreferencesModelSerialize,
  deserialize: _userPreferencesModelDeserialize,
  deserializeProp: _userPreferencesModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _userPreferencesModelGetId,
  getLinks: _userPreferencesModelGetLinks,
  attach: _userPreferencesModelAttach,
  version: '3.3.2',
);

int _userPreferencesModelEstimateSize(
  UserPreferencesModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.themeMode.length * 3;
  return bytesCount;
}

void _userPreferencesModelSerialize(
  UserPreferencesModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isNotificationsEnabled);
  writer.writeString(offsets[1], object.themeMode);
}

UserPreferencesModel _userPreferencesModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserPreferencesModel();
  object.id = id;
  object.isNotificationsEnabled = reader.readBool(offsets[0]);
  object.themeMode = reader.readString(offsets[1]);
  return object;
}

P _userPreferencesModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userPreferencesModelGetId(UserPreferencesModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userPreferencesModelGetLinks(
  UserPreferencesModel object,
) {
  return [];
}

void _userPreferencesModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserPreferencesModel object,
) {
  object.id = id;
}

extension UserPreferencesModelQueryWhereSort
    on QueryBuilder<UserPreferencesModel, UserPreferencesModel, QWhere> {
  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserPreferencesModelQueryWhere
    on QueryBuilder<UserPreferencesModel, UserPreferencesModel, QWhereClause> {
  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserPreferencesModelQueryFilter
    on
        QueryBuilder<
          UserPreferencesModel,
          UserPreferencesModel,
          QFilterCondition
        > {
  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  isNotificationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isNotificationsEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  themeModeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  themeModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  themeModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  themeModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'themeMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  themeModeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  themeModeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  themeModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'themeMode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  themeModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'themeMode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  themeModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'themeMode', value: ''),
      );
    });
  }

  QueryBuilder<
    UserPreferencesModel,
    UserPreferencesModel,
    QAfterFilterCondition
  >
  themeModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'themeMode', value: ''),
      );
    });
  }
}

extension UserPreferencesModelQueryObject
    on
        QueryBuilder<
          UserPreferencesModel,
          UserPreferencesModel,
          QFilterCondition
        > {}

extension UserPreferencesModelQueryLinks
    on
        QueryBuilder<
          UserPreferencesModel,
          UserPreferencesModel,
          QFilterCondition
        > {}

extension UserPreferencesModelQuerySortBy
    on QueryBuilder<UserPreferencesModel, UserPreferencesModel, QSortBy> {
  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
  sortByIsNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
  sortByIsNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
  sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
  sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension UserPreferencesModelQuerySortThenBy
    on QueryBuilder<UserPreferencesModel, UserPreferencesModel, QSortThenBy> {
  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
  thenByIsNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
  thenByIsNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
  thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QAfterSortBy>
  thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension UserPreferencesModelQueryWhereDistinct
    on QueryBuilder<UserPreferencesModel, UserPreferencesModel, QDistinct> {
  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QDistinct>
  distinctByIsNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNotificationsEnabled');
    });
  }

  QueryBuilder<UserPreferencesModel, UserPreferencesModel, QDistinct>
  distinctByThemeMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode', caseSensitive: caseSensitive);
    });
  }
}

extension UserPreferencesModelQueryProperty
    on
        QueryBuilder<
          UserPreferencesModel,
          UserPreferencesModel,
          QQueryProperty
        > {
  QueryBuilder<UserPreferencesModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserPreferencesModel, bool, QQueryOperations>
  isNotificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNotificationsEnabled');
    });
  }

  QueryBuilder<UserPreferencesModel, String, QQueryOperations>
  themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }
}
