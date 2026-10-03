import 'package:flutter/material.dart';

const String kAppName = 'BRETONNIER CAROLE';
const String kSupportEmail = 'support@bretonniercarole.app';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final store = OperationsStore();
  store.load();
  runApp(BretonnierApp(store: store));
}

class BretonnierApp extends StatelessWidget {
  const BretonnierApp({super.key, required this.store});

  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF05B9C8),
      primary: const Color(0xFF067D94),
      secondary: const Color(0xFF1268A6),
      tertiary: const Color(0xFFE8A90D),
      surface: const Color(0xFFF6FAFB),
    );

    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF4F8FA),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFFF4F8FA),
          foregroundColor: Color(0xFF062033),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE0EBEF)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: OperationsShell(store: store),
    );
  }
}

class OperationsStore extends ChangeNotifier {
  OperationsStore();

  final List<LeadRecord> leads = <LeadRecord>[];
  final List<AppointmentRecord> appointments = <AppointmentRecord>[];
  final List<QualityTask> qualityTasks = <QualityTask>[];
  final List<ShiftRecord> shifts = <ShiftRecord>[];

  bool endOfDayReview = true;
  String operationsOwner = 'Carole';

  void load() {
    _seedRecords();
  }

  int get openLeadCount =>
      leads.where((lead) => lead.stage != LeadStage.won).length;

  int get bookedTodayCount => appointments
      .where((appointment) => appointment.status != AppointmentStatus.closed)
      .length;

  int get completedQualityCount =>
      qualityTasks.where((task) => task.isComplete).length;

  double get qualityProgress {
    if (qualityTasks.isEmpty) {
      return 0;
    }
    return completedQualityCount / qualityTasks.length;
  }

  int get coveredShiftCount =>
      shifts.where((shift) => shift.coverage == ShiftCoverage.covered).length;

  void addLead({
    required String contactName,
    required String company,
    required String need,
    required String nextAction,
    required LeadStage stage,
    required Priority priority,
  }) {
    leads.insert(
      0,
      LeadRecord(
        id: _newId('lead'),
        contactName: contactName.trim(),
        company: company.trim(),
        need: need.trim(),
        nextAction: nextAction.trim(),
        stage: stage,
        priority: priority,
      ),
    );
    _changed();
  }

  void advanceLead(String id) {
    final index = leads.indexWhere((lead) => lead.id == id);
    if (index == -1) {
      return;
    }
    final current = leads[index];
    leads[index] = current.copyWith(stage: current.stage.next);
    _changed();
  }

  void addAppointment({
    required String client,
    required String service,
    required String slot,
    required AppointmentStatus status,
  }) {
    appointments.insert(
      0,
      AppointmentRecord(
        id: _newId('appointment'),
        client: client.trim(),
        service: service.trim(),
        slot: slot.trim(),
        status: status,
      ),
    );
    _changed();
  }

  void updateAppointmentStatus(String id, AppointmentStatus status) {
    final index = appointments.indexWhere(
      (appointment) => appointment.id == id,
    );
    if (index == -1) {
      return;
    }
    appointments[index] = appointments[index].copyWith(status: status);
    _changed();
  }

  void toggleQualityTask(String id, bool isComplete) {
    final index = qualityTasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }
    qualityTasks[index] = qualityTasks[index].copyWith(isComplete: isComplete);
    _changed();
  }

  void addQualityTask({required String title, required String area}) {
    qualityTasks.add(
      QualityTask(
        id: _newId('quality'),
        title: title.trim(),
        area: area.trim(),
        isComplete: false,
      ),
    );
    _changed();
  }

  void addShift({
    required String staffName,
    required String role,
    required String window,
    required ShiftCoverage coverage,
  }) {
    shifts.insert(
      0,
      ShiftRecord(
        id: _newId('shift'),
        staffName: staffName.trim(),
        role: role.trim(),
        window: window.trim(),
        coverage: coverage,
      ),
    );
    _changed();
  }

  void setEndOfDayReview(bool value) {
    endOfDayReview = value;
    _changed();
  }

  void setOperationsOwner(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    operationsOwner = trimmed;
    _changed();
  }

  void _seedRecords() {
    leads
      ..clear()
      ..addAll(<LeadRecord>[
        LeadRecord(
          id: 'lead-1',
          contactName: 'M. Laurent',
          company: 'Atelier Nord',
          need: 'Weekly service contract',
          nextAction: 'Confirm Tuesday walkthrough',
          stage: LeadStage.appointment,
          priority: Priority.high,
        ),
        LeadRecord(
          id: 'lead-2',
          contactName: 'Elise Martin',
          company: 'Studio Rive',
          need: 'Team scheduling support',
          nextAction: 'Send operating checklist',
          stage: LeadStage.newLead,
          priority: Priority.medium,
        ),
        LeadRecord(
          id: 'lead-3',
          contactName: 'Nadia Perez',
          company: 'Commerce Central',
          need: 'Quality audit follow-up',
          nextAction: 'Prepare quote summary',
          stage: LeadStage.quoted,
          priority: Priority.low,
        ),
      ]);

    appointments
      ..clear()
      ..addAll(<AppointmentRecord>[
        AppointmentRecord(
          id: 'appointment-1',
          client: 'Atelier Nord',
          service: 'Operations review',
          slot: 'Today 09:30',
          status: AppointmentStatus.confirmed,
        ),
        AppointmentRecord(
          id: 'appointment-2',
          client: 'Studio Rive',
          service: 'Lead intake call',
          slot: 'Today 14:00',
          status: AppointmentStatus.pending,
        ),
        AppointmentRecord(
          id: 'appointment-3',
          client: 'Commerce Central',
          service: 'Checklist validation',
          slot: 'Tomorrow 10:15',
          status: AppointmentStatus.confirmed,
        ),
      ]);

    qualityTasks
      ..clear()
      ..addAll(<QualityTask>[
        QualityTask(
          id: 'quality-1',
          title: 'BRETONNIER CAROLE',
          area: 'Front desk',
          isComplete: true,
        ),
        QualityTask(
          id: 'quality-2',
          title: 'Client files reviewed',
          area: 'Lead management',
          isComplete: true,
        ),
        QualityTask(
          id: 'quality-3',
          title: 'Service notes completed',
          area: 'Appointments',
          isComplete: false,
        ),
        QualityTask(
          id: 'quality-4',
          title: 'Closing shift handoff ready',
          area: 'Staffing',
          isComplete: false,
        ),
      ]);

    shifts
      ..clear()
      ..addAll(<ShiftRecord>[
        ShiftRecord(
          id: 'shift-1',
          staffName: 'Carole',
          role: 'Lead desk',
          window: '08:30 - 12:30',
          coverage: ShiftCoverage.covered,
        ),
        ShiftRecord(
          id: 'shift-2',
          staffName: 'Mina',
          role: 'Appointments',
          window: '12:30 - 16:30',
          coverage: ShiftCoverage.covered,
        ),
        ShiftRecord(
          id: 'shift-3',
          staffName: 'Open assignment',
          role: 'Quality close',
          window: '16:30 - 19:00',
          coverage: ShiftCoverage.needsCover,
        ),
      ]);
    endOfDayReview = true;
    operationsOwner = 'Carole';
  }

  void _changed() {
    notifyListeners();
  }

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}

enum LeadStage {
  newLead('New', Icons.person_add_alt_1),
  appointment('Booked', Icons.event_available),
  quoted('Quoted', Icons.request_quote),
  won('Won', Icons.verified);

  const LeadStage(this.label, this.icon);

  final String label;
  final IconData icon;

  LeadStage get next {
    return switch (this) {
      LeadStage.newLead => LeadStage.appointment,
      LeadStage.appointment => LeadStage.quoted,
      LeadStage.quoted => LeadStage.won,
      LeadStage.won => LeadStage.won,
    };
  }
}

enum Priority {
  low('Low'),
  medium('Medium'),
  high('High');

  const Priority(this.label);

  final String label;
}

enum AppointmentStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  closed('Closed');

  const AppointmentStatus(this.label);

  final String label;
}

enum ShiftCoverage {
  covered('Covered'),
  needsCover('Needs cover');

  const ShiftCoverage(this.label);

  final String label;
}

class LeadRecord {
  const LeadRecord({
    required this.id,
    required this.contactName,
    required this.company,
    required this.need,
    required this.nextAction,
    required this.stage,
    required this.priority,
  });

  final String id;
  final String contactName;
  final String company;
  final String need;
  final String nextAction;
  final LeadStage stage;
  final Priority priority;

  LeadRecord copyWith({LeadStage? stage}) {
    return LeadRecord(
      id: id,
      contactName: contactName,
      company: company,
      need: need,
      nextAction: nextAction,
      stage: stage ?? this.stage,
      priority: priority,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'contactName': contactName,
    'company': company,
    'need': need,
    'nextAction': nextAction,
    'stage': stage.name,
    'priority': priority.name,
  };

  factory LeadRecord.fromJson(Map<String, dynamic> json) {
    return LeadRecord(
      id: json['id'] as String? ?? '',
      contactName: json['contactName'] as String? ?? '',
      company: json['company'] as String? ?? '',
      need: json['need'] as String? ?? '',
      nextAction: json['nextAction'] as String? ?? '',
      stage: LeadStage.values.byName(
        json['stage'] as String? ?? LeadStage.newLead.name,
      ),
      priority: Priority.values.byName(
        json['priority'] as String? ?? Priority.medium.name,
      ),
    );
  }
}

class AppointmentRecord {
  const AppointmentRecord({
    required this.id,
    required this.client,
    required this.service,
    required this.slot,
    required this.status,
  });

  final String id;
  final String client;
  final String service;
  final String slot;
  final AppointmentStatus status;

  AppointmentRecord copyWith({AppointmentStatus? status}) {
    return AppointmentRecord(
      id: id,
      client: client,
      service: service,
      slot: slot,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'client': client,
    'service': service,
    'slot': slot,
    'status': status.name,
  };

  factory AppointmentRecord.fromJson(Map<String, dynamic> json) {
    return AppointmentRecord(
      id: json['id'] as String? ?? '',
      client: json['client'] as String? ?? '',
      service: json['service'] as String? ?? '',
      slot: json['slot'] as String? ?? '',
      status: AppointmentStatus.values.byName(
        json['status'] as String? ?? AppointmentStatus.pending.name,
      ),
    );
  }
}

class QualityTask {
  const QualityTask({
    required this.id,
    required this.title,
    required this.area,
    required this.isComplete,
  });

  final String id;
  final String title;
  final String area;
  final bool isComplete;

  QualityTask copyWith({bool? isComplete}) {
    return QualityTask(
      id: id,
      title: title,
      area: area,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'area': area,
    'isComplete': isComplete,
  };

  factory QualityTask.fromJson(Map<String, dynamic> json) {
    return QualityTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      area: json['area'] as String? ?? '',
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }
}

class ShiftRecord {
  const ShiftRecord({
    required this.id,
    required this.staffName,
    required this.role,
    required this.window,
    required this.coverage,
  });

  final String id;
  final String staffName;
  final String role;
  final String window;
  final ShiftCoverage coverage;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'staffName': staffName,
    'role': role,
    'window': window,
    'coverage': coverage.name,
  };

  factory ShiftRecord.fromJson(Map<String, dynamic> json) {
    return ShiftRecord(
      id: json['id'] as String? ?? '',
      staffName: json['staffName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      window: json['window'] as String? ?? '',
      coverage: ShiftCoverage.values.byName(
        json['coverage'] as String? ?? ShiftCoverage.needsCover.name,
      ),
    );
  }
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({super.key, required this.store});

  final OperationsStore store;

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  int _selectedIndex = 0;

  OperationsStore get store => widget.store;

  @override
  Widget build(BuildContext context) {
    final titles = <String>[
      'Control room',
      'Lead board',
      'Bookings',
      'Quality',
      'Shifts',
    ];
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              titles[_selectedIndex],
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: <Widget>[
              IconButton(
                tooltip: 'Settings and privacy',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => SettingsScreen(store: store),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: <Widget>[
              DashboardScreen(store: store),
              LeadsScreen(store: store),
              AppointmentsScreen(store: store),
              QualityScreen(store: store),
              ShiftsScreen(store: store),
            ],
          ),
          floatingActionButton: _floatingActionButton(context),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (value) {
              setState(() => _selectedIndex = value);
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_alt_outlined),
                selectedIcon: Icon(Icons.people_alt),
                label: 'Leads',
              ),
              NavigationDestination(
                icon: Icon(Icons.event_note_outlined),
                selectedIcon: Icon(Icons.event_note),
                label: 'Bookings',
              ),
              NavigationDestination(
                icon: Icon(Icons.fact_check_outlined),
                selectedIcon: Icon(Icons.fact_check),
                label: 'Quality',
              ),
              NavigationDestination(
                icon: Icon(Icons.schedule_outlined),
                selectedIcon: Icon(Icons.schedule),
                label: 'Shifts',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget? _floatingActionButton(BuildContext context) {
    return switch (_selectedIndex) {
      1 => FloatingActionButton.extended(
        heroTag: 'add-lead',
        tooltip: 'Add lead',
        onPressed: () => showLeadSheet(context, store),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Lead'),
      ),
      2 => FloatingActionButton.extended(
        heroTag: 'add-appointment',
        tooltip: 'Add appointment',
        onPressed: () => showAppointmentSheet(context, store),
        icon: const Icon(Icons.add_task),
        label: const Text('Booking'),
      ),
      3 => FloatingActionButton.extended(
        heroTag: 'add-quality-task',
        tooltip: 'Add quality task',
        onPressed: () => showQualitySheet(context, store),
        icon: const Icon(Icons.playlist_add_check),
        label: const Text('Check'),
      ),
      4 => FloatingActionButton.extended(
        heroTag: 'add-shift',
        tooltip: 'Add shift',
        onPressed: () => showShiftSheet(context, store),
        icon: const Icon(Icons.person_add),
        label: const Text('Shift'),
      ),
      _ => null,
    };
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.store});

  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qualityPercent = (store.qualityProgress * 100).round();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF05233A), Color(0xFF067D94)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'docs/icon.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            kAppName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Daily operations snapshot',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFD8F5F7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    MetricPill(
                      label: 'Open leads',
                      value: store.openLeadCount.toString(),
                      icon: Icons.people_alt,
                    ),
                    MetricPill(
                      label: 'Bookings',
                      value: store.bookedTodayCount.toString(),
                      icon: Icons.event_available,
                    ),
                    MetricPill(
                      label: 'Quality',
                      value: '$qualityPercent%',
                      icon: Icons.verified,
                    ),
                    MetricPill(
                      label: 'Covered shifts',
                      value:
                          '${store.coveredShiftCount}/${store.shifts.length}',
                      icon: Icons.schedule,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('Focus queue', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        ...store.leads
            .take(2)
            .map(
              (lead) => ActionCard(
                icon: lead.stage.icon,
                title: lead.nextAction,
                subtitle: '${lead.company} - ${lead.stage.label}',
                tone: lead.priority,
              ),
            ),
        ActionCard(
          icon: Icons.fact_check,
          title: '$qualityPercent% of checks complete',
          subtitle: 'Finish the remaining closing tasks before handoff.',
          tone: qualityPercent >= 80 ? Priority.low : Priority.high,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.timeline, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Quality run rate',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: store.qualityProgress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 10),
                Text(
                  '${store.completedQualityCount} of ${store.qualityTasks.length} checks are closed.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LeadsScreen extends StatelessWidget {
  const LeadsScreen({super.key, required this.store});

  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    if (store.leads.isEmpty) {
      return EmptyState(
        icon: Icons.people_alt_outlined,
        title: 'No leads yet',
        message: 'Add a lead to begin tracking next actions.',
        actionLabel: 'Add lead',
        onPressed: () => showLeadSheet(context, store),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: store.leads.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final lead = store.leads[index];
        return LeadCard(
          lead: lead,
          onAdvance: lead.stage == LeadStage.won
              ? null
              : () => store.advanceLead(lead.id),
        );
      },
    );
  }
}

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key, required this.store});

  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    if (store.appointments.isEmpty) {
      return EmptyState(
        icon: Icons.event_note_outlined,
        title: 'No bookings yet',
        message: 'Book appointments and keep every client next step visible.',
        actionLabel: 'Add booking',
        onPressed: () => showAppointmentSheet(context, store),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: store.appointments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final appointment = store.appointments[index];
        return AppointmentCard(
          appointment: appointment,
          onStatusChanged: (status) {
            store.updateAppointmentStatus(appointment.id, status);
          },
        );
      },
    );
  }
}

class QualityScreen extends StatelessWidget {
  const QualityScreen({super.key, required this.store});

  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Checklist status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: store.qualityProgress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 10),
                Text(
                  '${store.completedQualityCount} complete, ${store.qualityTasks.length - store.completedQualityCount} remaining',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...store.qualityTasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: QualityTaskTile(
              task: task,
              onChanged: (value) {
                store.toggleQualityTask(task.id, value ?? false);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ShiftsScreen extends StatelessWidget {
  const ShiftsScreen({super.key, required this.store});

  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    if (store.shifts.isEmpty) {
      return EmptyState(
        icon: Icons.schedule_outlined,
        title: 'No shifts planned',
        message: 'Add shift coverage to keep daily staffing balanced.',
        actionLabel: 'Add shift',
        onPressed: () => showShiftSheet(context, store),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: store.shifts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return ShiftCard(shift: store.shifts[index]);
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});

  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ownerController = TextEditingController(text: store.operationsOwner);
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings and privacy')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Workspace',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: ownerController,
                        decoration: const InputDecoration(
                          labelText: 'Operations owner',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: store.setOperationsOwner,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('End of day review'),
                        subtitle: const Text('Keep closing checks visible.'),
                        value: store.endOfDayReview,
                        onChanged: store.setEndOfDayReview,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.lock_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Local privacy',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Lead notes, bookings, checklist items, shift coverage, and preferences stay on this device. There is no account, cloud sync, analytics, advertising, or external service connection.',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        kSupportEmail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MetricPill extends StatelessWidget {
  const MetricPill({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: const Color(0xFF34DCE6), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD8F5F7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Priority tone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final toneColor = switch (tone) {
      Priority.high => colors.tertiary,
      Priority.medium => colors.primary,
      Priority.low => colors.secondary,
    };
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: toneColor.withValues(alpha: 0.14),
          foregroundColor: toneColor,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class LeadCard extends StatelessWidget {
  const LeadCard({super.key, required this.lead, required this.onAdvance});

  final LeadRecord lead;
  final VoidCallback? onAdvance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Icon(lead.stage.icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        lead.company,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(lead.contactName),
                    ],
                  ),
                ),
                StatusChip(label: lead.stage.label),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              lead.need,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(lead.nextAction),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                PriorityChip(priority: lead.priority),
                const Spacer(),
                TextButton.icon(
                  onPressed: onAdvance,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    lead.stage == LeadStage.won ? 'Closed' : 'Advance',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onStatusChanged,
  });

  final AppointmentRecord appointment;
  final ValueChanged<AppointmentStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: colors.secondaryContainer,
                  foregroundColor: colors.onSecondaryContainer,
                  child: const Icon(Icons.event_available),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        appointment.client,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(appointment.service),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Icon(Icons.access_time, size: 18, color: colors.primary),
                const SizedBox(width: 6),
                Expanded(child: Text(appointment.slot)),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<AppointmentStatus>(
              segments: AppointmentStatus.values
                  .map(
                    (status) => ButtonSegment<AppointmentStatus>(
                      value: status,
                      label: Text(status.label),
                    ),
                  )
                  .toList(),
              selected: <AppointmentStatus>{appointment.status},
              onSelectionChanged: (selection) {
                onStatusChanged(selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class QualityTaskTile extends StatelessWidget {
  const QualityTaskTile({
    super.key,
    required this.task,
    required this.onChanged,
  });

  final QualityTask task;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: CheckboxListTile(
        value: task.isComplete,
        onChanged: onChanged,
        secondary: CircleAvatar(
          backgroundColor: task.isComplete
              ? colors.primary
              : const Color(0xFFEAF1F4),
          foregroundColor: task.isComplete
              ? colors.onPrimary
              : colors.onSurfaceVariant,
          child: Icon(task.isComplete ? Icons.check : Icons.pending_actions),
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(task.area),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}

class ShiftCard extends StatelessWidget {
  const ShiftCard({super.key, required this.shift});

  final ShiftRecord shift;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final covered = shift.coverage == ShiftCoverage.covered;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: covered
              ? colors.primaryContainer
              : colors.tertiary.withValues(alpha: 0.16),
          foregroundColor: covered
              ? colors.onPrimaryContainer
              : colors.tertiary,
          child: Icon(covered ? Icons.verified_user : Icons.person_search),
        ),
        title: Text(
          shift.staffName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${shift.role}\n${shift.window}'),
        isThreeLine: true,
        trailing: StatusChip(label: shift.coverage.label),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: colors.primary.withValues(alpha: 0.10),
      side: BorderSide(color: colors.primary.withValues(alpha: 0.24)),
      labelStyle: TextStyle(color: colors.primary, fontWeight: FontWeight.w800),
    );
  }
}

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (priority) {
      Priority.high => colors.tertiary,
      Priority.medium => colors.primary,
      Priority.low => colors.secondary,
    };
    return Chip(
      avatar: Icon(Icons.flag, color: color, size: 18),
      label: Text('${priority.label} priority'),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withValues(alpha: 0.10),
      side: BorderSide(color: color.withValues(alpha: 0.22)),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 34,
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              child: Icon(icon, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showLeadSheet(BuildContext context, OperationsStore store) async {
  final contactController = TextEditingController();
  final companyController = TextEditingController();
  final needController = TextEditingController();
  final nextActionController = TextEditingController();
  var stage = LeadStage.newLead;
  var priority = Priority.medium;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return FormSheet(
            title: 'Add lead',
            children: <Widget>[
              TextField(
                controller: companyController,
                decoration: const InputDecoration(labelText: 'Company'),
              ),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(labelText: 'Contact name'),
              ),
              TextField(
                controller: needController,
                decoration: const InputDecoration(labelText: 'Need'),
              ),
              TextField(
                controller: nextActionController,
                decoration: const InputDecoration(labelText: 'Next action'),
              ),
              DropdownButtonFormField<LeadStage>(
                initialValue: stage,
                decoration: const InputDecoration(labelText: 'Stage'),
                items: LeadStage.values
                    .map(
                      (item) => DropdownMenuItem<LeadStage>(
                        value: item,
                        child: Text(item.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setSheetState(() => stage = value);
                  }
                },
              ),
              DropdownButtonFormField<Priority>(
                initialValue: priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: Priority.values
                    .map(
                      (item) => DropdownMenuItem<Priority>(
                        value: item,
                        child: Text(item.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setSheetState(() => priority = value);
                  }
                },
              ),
              FilledButton.icon(
                onPressed: () {
                  if (companyController.text.trim().isEmpty ||
                      contactController.text.trim().isEmpty) {
                    return;
                  }
                  store.addLead(
                    contactName: contactController.text,
                    company: companyController.text,
                    need: needController.text.isEmpty
                        ? 'Business operations follow-up'
                        : needController.text,
                    nextAction: nextActionController.text.isEmpty
                        ? 'Plan next step'
                        : nextActionController.text,
                    stage: stage,
                    priority: priority,
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.save),
                label: const Text('Save lead'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> showAppointmentSheet(
  BuildContext context,
  OperationsStore store,
) async {
  final clientController = TextEditingController();
  final serviceController = TextEditingController();
  final slotController = TextEditingController();
  var status = AppointmentStatus.pending;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return FormSheet(
            title: 'Add booking',
            children: <Widget>[
              TextField(
                controller: clientController,
                decoration: const InputDecoration(labelText: 'Client'),
              ),
              TextField(
                controller: serviceController,
                decoration: const InputDecoration(labelText: 'Service'),
              ),
              TextField(
                controller: slotController,
                decoration: const InputDecoration(labelText: 'Time window'),
              ),
              DropdownButtonFormField<AppointmentStatus>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: AppointmentStatus.values
                    .map(
                      (item) => DropdownMenuItem<AppointmentStatus>(
                        value: item,
                        child: Text(item.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setSheetState(() => status = value);
                  }
                },
              ),
              FilledButton.icon(
                onPressed: () {
                  if (clientController.text.trim().isEmpty) {
                    return;
                  }
                  store.addAppointment(
                    client: clientController.text,
                    service: serviceController.text.isEmpty
                        ? 'Operations appointment'
                        : serviceController.text,
                    slot: slotController.text.isEmpty
                        ? 'Today 15:00'
                        : slotController.text,
                    status: status,
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.save),
                label: const Text('Save booking'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> showQualitySheet(
  BuildContext context,
  OperationsStore store,
) async {
  final titleController = TextEditingController();
  final areaController = TextEditingController();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return FormSheet(
        title: 'Add quality check',
        children: <Widget>[
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Check item'),
          ),
          TextField(
            controller: areaController,
            decoration: const InputDecoration(labelText: 'Area'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                return;
              }
              store.addQualityTask(
                title: titleController.text,
                area: areaController.text.isEmpty
                    ? 'Daily operations'
                    : areaController.text,
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.save),
            label: const Text('Save check'),
          ),
        ],
      );
    },
  );
}

Future<void> showShiftSheet(BuildContext context, OperationsStore store) async {
  final staffController = TextEditingController();
  final roleController = TextEditingController();
  final windowController = TextEditingController();
  var coverage = ShiftCoverage.covered;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return FormSheet(
            title: 'Add shift',
            children: <Widget>[
              TextField(
                controller: staffController,
                decoration: const InputDecoration(labelText: 'Staff name'),
              ),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              TextField(
                controller: windowController,
                decoration: const InputDecoration(labelText: 'Shift window'),
              ),
              DropdownButtonFormField<ShiftCoverage>(
                initialValue: coverage,
                decoration: const InputDecoration(labelText: 'Coverage'),
                items: ShiftCoverage.values
                    .map(
                      (item) => DropdownMenuItem<ShiftCoverage>(
                        value: item,
                        child: Text(item.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setSheetState(() => coverage = value);
                  }
                },
              ),
              FilledButton.icon(
                onPressed: () {
                  if (staffController.text.trim().isEmpty) {
                    return;
                  }
                  store.addShift(
                    staffName: staffController.text,
                    role: roleController.text.isEmpty
                        ? 'Operations support'
                        : roleController.text,
                    window: windowController.text.isEmpty
                        ? '09:00 - 13:00'
                        : windowController.text,
                    coverage: coverage,
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.save),
                label: const Text('Save shift'),
              ),
            ],
          );
        },
      );
    },
  );
}

class FormSheet extends StatelessWidget {
  const FormSheet({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children.expand(
            (child) => <Widget>[child, const SizedBox(height: 12)],
          ),
        ],
      ),
    );
  }
}
