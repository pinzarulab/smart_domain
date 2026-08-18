import 'package:flutter/material.dart';
import 'package:smart_domain/smart_domain.dart';
import 'package:smart_domain_example/data/in_memory_user_repository.dart';
import 'package:smart_domain_example/domain/user.dart';
import 'package:smart_domain_example/domain/user_use_cases.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final _idController = TextEditingController(text: '1');
  final _repository = InMemoryUserRepository();
  late final GetUserUseCase _getUser = GetUserUseCase(_repository);
  late final GetUserNameUseCase _getUserName = GetUserNameUseCase(_repository);
  late final SaveUserUseCase _saveUser = SaveUserUseCase(_repository);
  late final LoadUsersUseCase _loadUsers = LoadUsersUseCase(_repository);

  final _events = <String>[];
  String _summary = 'Choose a scenario below.';
  bool _busy = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _run(String label, Future<void> Function() scenario) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _events.insert(0, '▶ $label');
    });
    try {
      await scenario();
    } catch (error) {
      _summary = 'Exception boundary caught: $error';
      _events.insert(0, '✕ $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  int? get _enteredId => int.tryParse(_idController.text.trim());

  Future<void> _lookup() => _run('Look up user', () async {
    final id = _enteredId;
    if (id == null) {
      _summary = 'Enter a valid integer.';
      return;
    }

    final result = await _getUser(id);
    result
        .tap((user) => _events.insert(0, '✓ Loaded ${user.name}'))
        .tapError((failure) => _events.insert(0, '✕ ${failure.message}'));
    _summary = result.fold(
      onSuccess: (user) => 'Success: $user',
      onFailure: (failure) => '${failure.runtimeType}: ${failure.message}',
    );
  });

  Future<void> _mapFuture() => _run('Map future result', () async {
    final id = _enteredId ?? 1;
    _summary = await _getUserName(id).foldResult(
      onSuccess: (name) => 'mapResult → $name',
      onFailure: (failure) => 'mapResult failed → ${failure.message}',
    );
  });

  Future<void> _recover() => _run('Recover missing user', () async {
    final failed = await _getUser(999);
    final recovered = await failed.recoverAsync((failure) async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      _events.insert(0, '↺ Recovered ${failure.runtimeType}');
      return const User.guest();
    });
    _summary = 'recoverAsync → ${recovered.getOrThrow()}';
  });

  Future<void> _save() => _run('Save unit result', () async {
    const user = User(
      id: 4,
      name: 'Barbara Liskov',
      email: 'barbara@example.com',
    );
    final result = await _saveUser(user);
    _summary = result.fold(
      onSuccess: (_) => 'Result.unit → saved ${user.name}',
      onFailure: (failure) => 'Save failed → ${failure.message}',
    );
  });

  Future<void> _sequence() => _run('Sequence users', () async {
    final result = await Result.sequence<User, Failure>([
      _getUser(1),
      _getUser(2),
      _getUser(3),
    ]);
    _summary = result.fold(
      onSuccess: (users) =>
          'sequence → ${users.map((user) => user.name).join(', ')}',
      onFailure: (failure) => 'sequence failed → ${failure.message}',
    );
  });

  Future<void> _traverse() => _run('Traverse IDs', () async {
    final result = await _loadUsers([1, 2, 99, 3]);
    _summary = result.fold(
      onSuccess: (users) => 'traverse → ${users.length} users',
      onFailure: (failure) => 'traverse stopped early → ${failure.message}',
    );
  });

  Future<void> _partition() => _run('Partition results', () async {
    final results = await Future.wait([_getUser(1), _getUser(99), _getUser(2)]);
    final partition = Result.partition(results);
    _summary =
        'partition → ${partition.successes.length} successes, '
        '${partition.failures.length} failure';
  });

  Future<void> _throwBoundary() => _run('Throw at boundary', () async {
    final result = await _getUser(99);
    result.getOrThrow();
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('smart_domain'), centerTitle: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Typed outcomes for real Flutter flows',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Run each scenario and inspect how values and failures move '
              'from repository through use case into presentation.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'User ID',
                helperText: 'Try 1, 0, 13, or 99',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  [
                        _ActionButton(
                          label: 'Look up user',
                          onPressed: _lookup,
                        ),
                        _ActionButton(
                          label: 'Map future',
                          onPressed: _mapFuture,
                        ),
                        _ActionButton(label: 'Recover', onPressed: _recover),
                        _ActionButton(label: 'Save unit', onPressed: _save),
                        _ActionButton(label: 'Sequence', onPressed: _sequence),
                        _ActionButton(label: 'Traverse', onPressed: _traverse),
                        _ActionButton(
                          label: 'Partition',
                          onPressed: _partition,
                        ),
                        _ActionButton(
                          label: 'Throw boundary',
                          onPressed: _throwBoundary,
                        ),
                      ]
                      .map(
                        (button) =>
                            IgnorePointer(ignoring: _busy, child: button),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_busy)
                      const Padding(
                        padding: EdgeInsets.only(right: 14, top: 2),
                        child: SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.account_tree_outlined),
                      ),
                    Expanded(child: Text(_summary, key: const Key('summary'))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Event log', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_events.isEmpty)
              const Text('No events yet.')
            else
              ..._events
                  .take(8)
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(event),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(onPressed: onPressed, child: Text(label));
  }
}
