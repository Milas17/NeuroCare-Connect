import 'clinic_list_model.dart';

class PatientBillModule {
  String? actualAmount;
  List<BillItem>? billItems;
  Clinic? clinic;
  String? createdAt;
  String? discount;
  String? encounterId;
  String? id;
  Patient? patient;
  PatientEncounter? patientEncounter;
  String? paymentStatus;
  String? status;
  String? title;
  String? totalAmount;
  dynamic totalTax; // Added
  List<TaxModule>? taxes; // Added
  //Extra? extra;

  PatientBillModule({
    this.actualAmount,
    this.billItems,
    this.clinic,
    this.createdAt,
    this.discount,
    this.encounterId,
    this.id,
    this.patient,
    this.patientEncounter,
    this.paymentStatus,
    this.status,
    this.title,
    this.totalAmount,
    this.totalTax, // Added
    this.taxes, // Added
  });

  factory PatientBillModule.fromJson(Map<String, dynamic> json) {
    return PatientBillModule(
      actualAmount: json['actual_amount'],
      billItems: json['billItems'] != null ? (json['billItems'] as List).map((i) => BillItem.fromJson(i)).toList() : null,
      clinic: json['clinic'] != null ? Clinic.fromJson(json['clinic']) : null,
      createdAt: json['created_at'],
      discount: json['discount'],
      encounterId: json['encounter_id'],
      id: json['id'],
      patient: json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      patientEncounter: json['patientEncounter'] != null ? PatientEncounter.fromJson(json['patientEncounter']) : null,
      paymentStatus: json['payment_status'],
      status: json['status'],
      title: json['title'],
      //extra: json['extra'] != null ? Extra.fromJson(json['extra']) : null,
      totalAmount: json['total_amount'],
      totalTax: json['tax_total'],
      taxes: json['taxes'] != null ? (json['taxes'] as List).map((i) => TaxModule.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['actual_amount'] = this.actualAmount;
    data['created_at'] = this.createdAt;
    data['discount'] = this.discount;
    data['encounter_id'] = this.encounterId;
    data['id'] = this.id;
    data['payment_status'] = this.paymentStatus;
    data['status'] = this.status;
    data['title'] = this.title;
    data['total_amount'] = this.totalAmount;
    data['tax_total'] = this.totalTax;
    //data['taxes'] = this.taxes;
    //if (this.extra != null) data['extra'] = this.extra!.toJson();

    if (this.taxes != null) {
      data['taxes'] = this.taxes!.map((v) => v.toJson()).toList();
    }

    if (this.billItems != null) {
      data['billItems'] = this.billItems!.map((v) => v.toJson()).toList();
    }
    if (this.clinic != null) {
      data['clinic'] = this.clinic!.toJson();
    }
    if (this.patient != null) {
      data['patient'] = this.patient!.toJson();
    }
    if (this.patientEncounter != null) {
      data['patientEncounter'] = this.patientEncounter!.toJson();
    }
    return data;
  }
}

class PatientEncounter {
  String? addedBy;
  String? appointmentId;
  String? clinicId;
  String? createdAt;
  String? description;
  String? doctorId;
  String? encounterDate;
  String? id;
  String? patientId;
  String? status;

  PatientEncounter({this.addedBy, this.appointmentId, this.clinicId, this.createdAt, this.description, this.doctorId, this.encounterDate, this.id, this.patientId, this.status});

  factory PatientEncounter.fromJson(Map<String, dynamic> json) {
    return PatientEncounter(
      addedBy: json['added_by'],
      appointmentId: json['appointment_id'],
      clinicId: json['clinic_id'],
      createdAt: json['created_at'],
      description: json['description'],
      doctorId: json['doctor_id'],
      encounterDate: json['encounter_date'],
      id: json['id'],
      patientId: json['patient_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['added_by'] = this.addedBy;
    data['appointment_id'] = this.appointmentId;
    data['clinic_id'] = this.clinicId;
    data['created_at'] = this.createdAt;
    data['description'] = this.description;
    data['doctor_id'] = this.doctorId;
    data['encounter_date'] = this.encounterDate;
    data['id'] = this.id;
    data['patient_id'] = this.patientId;
    data['status'] = this.status;
    return data;
  }
}

class BillItem {
  String? billId;
  String? id;
  String? itemId;

  String? mappingTableId;

  String? label;
  String? price;
  String? qty;

  String? serviceId;

  BillItem({this.billId, this.mappingTableId, this.id, this.serviceId, this.itemId, this.label, this.price, this.qty});

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      id: json['id'],
      billId: json['bill_id'],
      price: json['price'],
      qty: json['qty'],
      itemId: json['item_id'],
      serviceId: json['item_id'],
      label: json['label'],
      mappingTableId: json['mapping_table_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['bill_id'] = this.billId;
    data['price'] = this.price;
    data['qty'] = this.qty;
    data['item_id'] = this.itemId;
    data['label'] = this.label;
    return data;
  }
}

class Patient {
  String? displayName;
  String? dob;
  String? email;
  String? gender;
  String? id;

  Patient({this.displayName, this.dob, this.email, this.gender, this.id});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      displayName: json['display_name'],
      dob: json['dob'],
      email: json['email'],
      gender: json['gender'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['display_name'] = this.displayName;
    data['dob'] = this.dob;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['id'] = this.id;
    return data;
  }
}

class TaxModule {
  String? taxName;
  String? taxRate;
  String? charges;

  TaxModule({this.taxName, this.taxRate, this.charges});

  // Factory constructor for creating a TaxModule from a JSON map
  factory TaxModule.fromJson(Map<String, dynamic> json) {
    return TaxModule(taxName: json['name'], taxRate: json['tax_value'], charges: json['charges']);
  }

  // Method to convert a TaxModule to a JSON map
  Map<String, dynamic> toJson() {
    return {'name': taxName, 'tax_value': taxRate, 'charges': charges};
  }
}
