class AppStrings {
  final String locale;
  AppStrings(this.locale);

  static AppStrings of(String code) => AppStrings(code.startsWith('fr') ? 'fr' : 'en');

  String get appName => _t('NeuroCare Connect', 'NeuroCare Connect');
  String get roles => _t('Sélection du rôle', 'Select role');
  String get patient => _t('Patient', 'Patient');
  String get doctor => _t('Médecin', 'Doctor');
  String get regulator => _t('Régulateur', 'Dispatcher');
  String get driver => _t('Conducteur', 'Driver');
  String get dashboard => _t('Tableau de bord', 'Dashboard');
  String get telemed => _t('Téléconsultation', 'Telemed');
  String get homecare => _t('Soins à domicile', 'HomeCare');
  String get transport => _t('Transport (VSL)', 'Transport (VSL)');
  String get eeg => _t('EEG/ENMG', 'EEG/ENMG');
  String get academy => _t('Académie', 'Academy');
  String get shop => _t('Boutique', 'Shop');
  String get settings => _t('Réglages', 'Settings');

  String get book => _t('Prendre RDV', 'Book');
  String get myAppointments => _t('Mes RDV', 'My Appointments');
  String get requestRide => _t('Demander un transport', 'Request Ride');
  String get uploadEEG => _t('Téléverser un fichier', 'Upload file');
  String get webinars => _t('Webinaires', 'Webinars');
  String get products => _t('Produits', 'Products');
  String get cart => _t('Panier', 'Cart');
  String get confirm => _t('Confirmer', 'Confirm');
  String get cancel => _t('Annuler', 'Cancel');

  String _t(String fr, String en) => locale == 'fr' ? fr : en;
}
