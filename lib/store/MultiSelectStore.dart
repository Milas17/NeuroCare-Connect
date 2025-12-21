import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/model/static_data_model.dart';
import 'package:kivicare_flutter/model/tax_model.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

part 'MultiSelectStore.g.dart';

class MultiSelectStore = MultiSelectStoreBase with _$MultiSelectStore;

abstract class MultiSelectStoreBase with Store {
  @observable
  ObservableList<int> selectedServiceIds = ObservableList<int>();
  ObservableList<ServiceData> selectedService = ObservableList<ServiceData>();
  ObservableList<StaticData?> selectedStaticData = ObservableList<StaticData?>();

  @observable
  bool isSpecialized = false;

  @observable
  TaxModel? taxData;

  @action
  void setTaxData(TaxModel? data) {
    taxData = data;
  }

  @action
  void addList(List<ServiceData> data, {bool isClear = true}) {
    if (isClear) {
      selectedService.clear();
    }
    selectedService.addAll(data);
  }

  @action
  void addSingleItem(ServiceData data, {bool isClear = true}) {
    if (isClear) {
      selectedService.clear();
      selectedServiceIds.clear();
    }
    selectedService.add(data);
    selectedServiceIds.add(data.serviceId.toInt());
  }

  @action
  void removeItem(ServiceData data) {
    selectedService.remove(data);
    selectedServiceIds.remove(data.serviceId.toInt());
  }

  @action
  void clearList() {
    selectedService.clear();
    selectedServiceIds.clear();
  }

  @action
  void addStaticData(List<StaticData> data, {bool isClear = true}) {
    if (isClear) {
      selectedStaticData.clear();
    }
    selectedStaticData.addAll(data);
  }

  @action
  void addSingleStaticItem(StaticData? data, {bool isClear = true}) {
    if (isClear) {
      selectedStaticData.clear();
    }
    selectedStaticData.add(data);
  }

  @action
  void removeStaticItem(StaticData data) {
    selectedStaticData.remove(data);
  }

  @action
  void clearStaticList() {
    selectedStaticData.clear();
  }
}
