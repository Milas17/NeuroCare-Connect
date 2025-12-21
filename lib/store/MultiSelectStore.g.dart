// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MultiSelectStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MultiSelectStore on MultiSelectStoreBase, Store {
  late final _$selectedServiceIdsAtom =
      Atom(name: 'MultiSelectStoreBase.selectedServiceIds', context: context);

  @override
  ObservableList<int> get selectedServiceIds {
    _$selectedServiceIdsAtom.reportRead();
    return super.selectedServiceIds;
  }

  @override
  set selectedServiceIds(ObservableList<int> value) {
    _$selectedServiceIdsAtom.reportWrite(value, super.selectedServiceIds, () {
      super.selectedServiceIds = value;
    });
  }

  late final _$isSpecializedAtom =
      Atom(name: 'MultiSelectStoreBase.isSpecialized', context: context);

  @override
  bool get isSpecialized {
    _$isSpecializedAtom.reportRead();
    return super.isSpecialized;
  }

  @override
  set isSpecialized(bool value) {
    _$isSpecializedAtom.reportWrite(value, super.isSpecialized, () {
      super.isSpecialized = value;
    });
  }

  late final _$taxDataAtom =
      Atom(name: 'MultiSelectStoreBase.taxData', context: context);

  @override
  TaxModel? get taxData {
    _$taxDataAtom.reportRead();
    return super.taxData;
  }

  @override
  set taxData(TaxModel? value) {
    _$taxDataAtom.reportWrite(value, super.taxData, () {
      super.taxData = value;
    });
  }

  late final _$MultiSelectStoreBaseActionController =
      ActionController(name: 'MultiSelectStoreBase', context: context);

  @override
  void setTaxData(TaxModel? data) {
    final _$actionInfo = _$MultiSelectStoreBaseActionController.startAction(
        name: 'MultiSelectStoreBase.setTaxData');
    try {
      return super.setTaxData(data);
    } finally {
      _$MultiSelectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addList(List<ServiceData> data, {bool isClear = true}) {
    final _$actionInfo = _$MultiSelectStoreBaseActionController.startAction(
        name: 'MultiSelectStoreBase.addList');
    try {
      return super.addList(data, isClear: isClear);
    } finally {
      _$MultiSelectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addSingleItem(ServiceData data, {bool isClear = true}) {
    final _$actionInfo = _$MultiSelectStoreBaseActionController.startAction(
        name: 'MultiSelectStoreBase.addSingleItem');
    try {
      return super.addSingleItem(data, isClear: isClear);
    } finally {
      _$MultiSelectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeItem(ServiceData data) {
    final _$actionInfo = _$MultiSelectStoreBaseActionController.startAction(
        name: 'MultiSelectStoreBase.removeItem');
    try {
      return super.removeItem(data);
    } finally {
      _$MultiSelectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearList() {
    final _$actionInfo = _$MultiSelectStoreBaseActionController.startAction(
        name: 'MultiSelectStoreBase.clearList');
    try {
      return super.clearList();
    } finally {
      _$MultiSelectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addStaticData(List<StaticData> data, {bool isClear = true}) {
    final _$actionInfo = _$MultiSelectStoreBaseActionController.startAction(
        name: 'MultiSelectStoreBase.addStaticData');
    try {
      return super.addStaticData(data, isClear: isClear);
    } finally {
      _$MultiSelectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addSingleStaticItem(StaticData? data, {bool isClear = true}) {
    final _$actionInfo = _$MultiSelectStoreBaseActionController.startAction(
        name: 'MultiSelectStoreBase.addSingleStaticItem');
    try {
      return super.addSingleStaticItem(data, isClear: isClear);
    } finally {
      _$MultiSelectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeStaticItem(StaticData data) {
    final _$actionInfo = _$MultiSelectStoreBaseActionController.startAction(
        name: 'MultiSelectStoreBase.removeStaticItem');
    try {
      return super.removeStaticItem(data);
    } finally {
      _$MultiSelectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearStaticList() {
    final _$actionInfo = _$MultiSelectStoreBaseActionController.startAction(
        name: 'MultiSelectStoreBase.clearStaticList');
    try {
      return super.clearStaticList();
    } finally {
      _$MultiSelectStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedServiceIds: ${selectedServiceIds},
isSpecialized: ${isSpecialized},
taxData: ${taxData}
    ''';
  }
}
