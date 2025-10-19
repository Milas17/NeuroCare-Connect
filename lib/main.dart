import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: MyApp()));
}

class AppState extends ChangeNotifier {
  // Theme & language
  bool darkMode = false;
  String language = 'fr';

  // Télémed
  final List<Appointment> appointments = [];

  // Soins à domicile
  final List<HomeCareRequest> homeCareRequests = [];

  // VSL transports
  final List<VslRequest> vslRequests = [];

  // EEG/ENMG uploads
  final List<UploadedFile> uploadedFiles = [];

  // Boutique
  final List<Product> products = [
    Product(id: 'p1', name: 'Capteur EEG', price: 49.90),
    Product(id: 'p2', name: 'Gel conductif', price: 9.90),
  ];
  final List<CartItem> cart = [];

  // Academy
  List<Webinar> webinars = [];

  // Actions
  void toggleTheme() {
    darkMode = !darkMode;
    notifyListeners();
  }

  void setLanguage(String lang) {
    language = lang;
    notifyListeners();
  }

  void addAppointment(Appointment a) {
    appointments.add(a);
    notifyListeners();
  }

  void addHomeCareRequest(HomeCareRequest r) {
    homeCareRequests.add(r);
    notifyListeners();
  }

  void addVslRequest(VslRequest r) {
    vslRequests.add(r);
    notifyListeners();
  }

  void updateVslStatus(String id, VslStatus status) {
    final idx = vslRequests.indexWhere((r) => r.id == id);
    if (idx != -1) {
      vslRequests[idx].status = status;
      notifyListeners();
    }
    // sinon on ignore silencieusement
  }

  void addUploadedFile(UploadedFile f) {
    uploadedFiles.add(f);
    notifyListeners();
  }

  void addToCart(Product p, int qty) {
    final existing = cart.where((c) => c.product.id == p.id).toList();
    if (existing.isEmpty) {
      cart.add(CartItem(product: p, qty: qty));
    } else {
      existing.first.qty += qty;
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    cart.removeWhere((c) => c.product.id == productId);
    notifyListeners();
  }

  double cartTotal() {
    return cart.fold(0.0, (s, c) => s + c.product.price * c.qty);
  }

  Future<void> loadWebinars() async {
    try {
      final raw = await rootBundle.loadString('assets/data/webinars.json');
      final list = json.decode(raw) as List<dynamic>;
      webinars = list.map((e) => Webinar.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {
      webinars = [];
    }
  }
}

// Models
class Appointment {
  final String id;
  final String doctor;
  final DateTime date;
  Appointment({required this.id, required this.doctor, required this.date});
}

class HomeCareRequest {
  final String id;
  final String patientName;
  final String details;
  final DateTime requestedAt;
  HomeCareRequest({
    required this.id,
    required this.patientName,
    required this.details,
    required this.requestedAt,
  });
}

enum VslStatus { requested, accepted, inTransit, completed }

class VslRequest {
  final String id;
  final String patient;
  VslStatus status;
  VslRequest({required this.id, required this.patient, required this.status});
}

class UploadedFile {
  final String id;
  final String name;
  final String path;
  UploadedFile({required this.id, required this.name, required this.path});
}

class Product {
  final String id;
  final String name;
  final double price;
  Product({required this.id, required this.name, required this.price});
}

class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, required this.qty});
}

class Webinar {
  final String id;
  final String title;
  final String url;
  final String duration;
  final String? description;
  Webinar({
    required this.id,
    required this.title,
    required this.url,
    required this.duration,
    this.description,
  });
  factory Webinar.fromJson(Map<String, dynamic> j) => Webinar(
        id: j['id'],
        title: j['title'],
        url: j['url'],
        duration: j['duration'],
        description: j['description'],
      );
}

// App
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return MaterialApp(
      title: 'NeuroCare Connect',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(),
      routes: {
        '/telemed': (_) => TelemedPage(),
        '/soins': (_) => SoinsDomicilePage(),
        '/vsl': (_) => VslPage(),
        '/eeg': (_) => EegEnmgPage(),
        '/academy': (_) => AcademyPage(),
        '/boutique': (_) => BoutiquePage(),
        '/reglages': (_) => ReglagesPage(),
      },
    );
  }
}

// Dashboard
class DashboardPage extends StatelessWidget {
  final tiles = [
    {'label': 'Télémed', 'route': '/telemed'},
    {'label': 'Soins à domicile', 'route': '/soins'},
    {'label': 'VSL', 'route': '/vsl'},
    {'label': 'EEG/ENMG', 'route': '/eeg'},
    {'label': 'Academy', 'route': '/academy'},
    {'label': 'Boutique', 'route': '/boutique'},
    {'label': 'Réglages', 'route': '/reglages'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: tiles.map((t) {
          return ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, t['route']!),
            child: Text(t['label']!),
          );
        }).toList(),
      ),
    );
  }
}

// Telemed
class TelemedPage extends StatefulWidget {
  @override
  _TelemedPageState createState() => _TelemedPageState();
}

class _TelemedPageState extends State<TelemedPage> {
  final doctors = ['Dr. Dupont', 'Dr. Martin', 'Dr. Bernard'];

  Future<void> _openJitsi(String room) async {
    final url = 'https://meet.jit.si/$room';
    // depuis le conteneur de dev : "$BROWSER" "<url>" pour ouvrir dans le navigateur hôte
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir la visioconférence')),
      );
    }
  }

  void _bookAppointment(String doctor) {
    final appState = context.read<AppState>();
    final newAppt = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      doctor: doctor,
      date: DateTime.now().add(const Duration(days: 3)),
    );
    appState.addAppointment(newAppt);
  }

  @override
  Widget build(BuildContext context) {
    final appointments = context.watch<AppState>().appointments;
    return Scaffold(
      appBar: AppBar(title: const Text('Télémed')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Médecins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...doctors.map((d) => Card(
                child: ListTile(
                  title: Text(d),
                  trailing: Wrap(spacing: 8, children: [
                    IconButton(
                      icon: const Icon(Icons.video_call),
                      onPressed: () => _openJitsi(d.replaceAll(' ', '') + DateTime.now().millisecondsSinceEpoch.toString()),
                      tooltip: 'Visioconférence',
                    ),
                    ElevatedButton(
                      child: const Text('Prendre RDV'),
                      onPressed: () {
                        _bookAppointment(d);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RDV pris (mémoire)')));
                      },
                    ),
                  ]),
                ),
              )),
          const SizedBox(height: 16),
          const Text('Mes RDV', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...appointments.map((a) => ListTile(
                title: Text('${a.doctor}'),
                subtitle: Text(a.date.toLocal().toString()),
              )),
        ],
      ),
    );
  }
}

// Soins à domicile
class SoinsDomicilePage extends StatefulWidget {
  @override
  _SoinsDomicilePageState createState() => _SoinsDomicilePageState();
}

class _SoinsDomicilePageState extends State<SoinsDomicilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final state = context.read<AppState>();
      state.addHomeCareRequest(HomeCareRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientName: _nameCtrl.text,
        details: _detailsCtrl.text,
        requestedAt: DateTime.now(),
      ));
      _nameCtrl.clear();
      _detailsCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande ajoutée (mémoire)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<AppState>().homeCareRequests;
    return Scaffold(
      appBar: AppBar(title: const Text('Soins à domicile')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom du patient'),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              TextFormField(
                controller: _detailsCtrl,
                decoration: const InputDecoration(labelText: 'Details'),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _submit, child: const Text('Envoyer la demande')),
            ]),
          ),
          const SizedBox(height: 12),
          const Text('Liste des demandes', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: ListView(children: requests.map((r) => ListTile(title: Text(r.patientName), subtitle: Text(r.details))).toList())),
        ]),
      ),
    );
  }
}

// VSL
class VslPage extends StatefulWidget {
  @override
  _VslPageState createState() => _VslPageState();
}

class _VslPageState extends State<VslPage> {
  final _patientCtrl = TextEditingController();

  @override
  void dispose() {
    _patientCtrl.dispose();
    super.dispose();
  }

  void _requestTransport() {
    final state = context.read<AppState>();
    final req = VslRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patient: _patientCtrl.text,
      status: VslStatus.requested,
    );
    state.addVslRequest(req);
    _patientCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transport demandé (mémoire)')));
  }

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<AppState>().vslRequests;
    return Scaffold(
      appBar: AppBar(title: const Text('VSL')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(controller: _patientCtrl, decoration: const InputDecoration(labelText: 'Nom du patient')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _requestTransport, child: const Text('Demander un transport')),
          const SizedBox(height: 12),
          const Text('Suivi des demandes', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView(
              children: requests
                  .map((r) => ListTile(
                        title: Text(r.patient),
                        subtitle: Text(r.status.toString().split('.').last),
                        trailing: PopupMenuButton<VslStatus>(
                          onSelected: (s) => context.read<AppState>().updateVslStatus(r.id, s),
                          itemBuilder: (_) => VslStatus.values
                              .map((s) => PopupMenuItem(value: s, child: Text(s.toString().split('.').last)))
                              .toList(),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ]),
      ),
    );
  }
}

// EEG/ENMG
class EegEnmgPage extends StatefulWidget {
  @override
  _EegEnmgPageState createState() => _EegEnmgPageState();
}

class _EegEnmgPageState extends State<EegEnmgPage> {
  Future<void> _pickFiles() async {
    try {
      final res = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (res != null && res.files.isNotEmpty) {
        final state = context.read<AppState>();
        for (var f in res.files) {
          state.addUploadedFile(UploadedFile(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: f.name,
            path: f.path ?? f.name,
          ));
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fichiers ajoutés (mémoire)')));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de l\'upload')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final files = context.watch<AppState>().uploadedFiles;
    return Scaffold(
      appBar: AppBar(title: const Text('EEG / ENMG')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          ElevatedButton(onPressed: _pickFiles, child: const Text('Uploader des fichiers')),
          const SizedBox(height: 12),
          const Text('Fichiers uploadés', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: ListView(children: files.map((f) => ListTile(title: Text(f.name), subtitle: Text(f.path))).toList())),
        ]),
      ),
    );
  }
}

// Academy
class AcademyPage extends StatefulWidget {
  @override
  _AcademyPageState createState() => _AcademyPageState();
}

class _AcademyPageState extends State<AcademyPage> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().loadWebinars();
  }

  Future<void> _openWebinar(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir le webinar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final webinars = context.watch<AppState>().webinars;
    return Scaffold(
      appBar: AppBar(title: const Text('Academy')),
      body: ListView.builder(
        itemCount: webinars.length,
        itemBuilder: (_, i) {
          final w = webinars[i];
          return Card(
            child: ListTile(
              title: Text(w.title),
              subtitle: Text('${w.duration}'),
              onTap: () => _openWebinar(w.url),
            ),
          );
        },
      ),
    );
  }
}

// Boutique
class BoutiquePage extends StatefulWidget {
  @override
  _BoutiquePageState createState() => _BoutiquePageState();
}

class _BoutiquePageState extends State<BoutiquePage> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Boutique')),
      body: Column(children: [
        Expanded(
          child: ListView(
            children: state.products
                .map((p) => ListTile(
                      title: Text(p.name),
                      subtitle: Text('${p.price.toStringAsFixed(2)} €'),
                      trailing: ElevatedButton(onPressed: () => state.addToCart(p, 1), child: const Text('Ajouter')),
                    ))
                .toList(),
          ),
        ),
        const Divider(),
        ListTile(title: const Text('Panier'), subtitle: Text('Total: ${state.cartTotal().toStringAsFixed(2)} €')),
        ElevatedButton(
          onPressed: state.cart.isEmpty
              ? null
              : () {
                  state.cart.clear();
                  state.notifyListeners();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Achat simulé — panier vidé')));
                },
          child: const Text('Payer'),
        ),
      ]),
    );
  }
}

// Réglages
class ReglagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          SwitchListTile(
            title: const Text('Thème sombre'),
            value: state.darkMode,
            onChanged: (_) => context.read<AppState>().toggleTheme(),
          ),
          ListTile(
            title: const Text('Langue'),
            subtitle: Text(state.language),
            onTap: () async {
              final sel = await showDialog<String>(
                context: context,
                builder: (_) => SimpleDialog(
                  title: const Text('Choisir la langue'),
                  children: [
                    SimpleDialogOption(child: const Text('Français'), onPressed: () => Navigator.pop(context, 'fr')),
                    SimpleDialogOption(child: const Text('English'), onPressed: () => Navigator.pop(context, 'en')),
                  ],
                ),
              );
              if (sel != null) context.read<AppState>().setLanguage(sel);
            },
          ),
        ]),
      ),
    );
  }
}