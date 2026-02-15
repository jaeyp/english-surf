import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/tts/domain/enums/tts_speaker.dart';
import '../../../sentences/domain/enums/ai_provider.dart';
import '../../../sentences/data/providers/ai_providers.dart';
import '../../../sentences/data/providers/sentence_providers.dart';
import '../../../sentences/application/providers/sentence_providers.dart'; // Ensure application layer providers included
import '../../../sentences/application/providers/folder_providers.dart';
import '../../../sentences/domain/repositories/settings_repository.dart';
import '../../data/repositories/data_repository_impl.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch settings needed for UI
    final settingsRepo = ref.watch(settingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: FutureBuilder(
        future: Future.wait<dynamic>([
          settingsRepo.getAiProvider(),
          // We need models for both to populate dropdowns or just fetch dynamically
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              _buildAiSection(settingsRepo),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Text-to-Speech',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const _TtsSettingsCard(),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Data Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const _DataManagementCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAiSection(SettingsRepository settingsRepo) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'AI Configuration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _AiSettingsCard(),
      ],
    );
  }
}

class _DataManagementCard extends ConsumerStatefulWidget {
  const _DataManagementCard();

  @override
  ConsumerState<_DataManagementCard> createState() =>
      _DataManagementCardState();
}

class _DataManagementCardState extends ConsumerState<_DataManagementCard> {
  bool _isLoading = false;

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(dataRepositoryProvider).exportData();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Export ready via Share')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Backup'),
              subtitle: const Text(
                'Export each folder as a separate JSON file',
              ),
              onTap: _isLoading
                  ? null
                  : () async {
                      await _exportData();
                    },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Import Backup'),
              subtitle: const Text('Restore data from a backup file'),
              onTap: _isLoading
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Import Data'),
                          content: const Text(
                            'Select one or more backup files (.json).\n\nEach file represents a folder. They will be imported and merged with your current data.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Import'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        if (!mounted) return;
                        setState(() => _isLoading = true);
                        try {
                          await ref.read(dataRepositoryProvider).importData();
                          // Invalidate folder list to reflect changes
                          ref.invalidate(folderListProvider);
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Import successful!'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(content: Text('Import failed: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}

// ... helper Widgets ...

// Existing _AiSettingsCard
class _AiSettingsCard extends ConsumerStatefulWidget {
  const _AiSettingsCard();

  @override
  ConsumerState<_AiSettingsCard> createState() => _AiSettingsCardState();
}

class _AiSettingsCardState extends ConsumerState<_AiSettingsCard> {
  AiProvider? _selectedProvider;
  String? _selectedModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    final provider = await repo.getAiProvider();
    final model = await repo.getAiModel(provider);

    if (mounted) {
      setState(() {
        _selectedProvider = provider;
        _selectedModel = model;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProvider(AiProvider? provider) async {
    if (provider == null) return;

    setState(() => _isLoading = true);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveAiProvider(provider);

    // Fetch stored model for the new provider
    final model = await repo.getAiModel(provider);

    if (mounted) {
      setState(() {
        _selectedProvider = provider;
        _selectedModel = model;
        _isLoading = false;
      });
      // Invalidate AiRepository to force re-creation with new settings
      ref.invalidate(aiRepositoryProvider);
    }
  }

  Future<void> _updateModel(String? model) async {
    if (model == null || _selectedProvider == null) return;

    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveAiModel(_selectedProvider!, model);

    if (mounted) {
      setState(() {
        _selectedModel = model;
      });
      // Invalidate AiRepository to apply new model
      ref.invalidate(aiRepositoryProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Selection
            DropdownButtonFormField<AiProvider>(
              initialValue: _selectedProvider,
              decoration: const InputDecoration(
                labelText: 'AI Provider',
                border: OutlineInputBorder(),
              ),
              items: AiProvider.values.map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(provider.displayName),
                );
              }).toList(),
              onChanged: _updateProvider,
            ),
            const SizedBox(height: 16),

            // Model Selection
            if (_selectedProvider != null)
              DropdownButtonFormField<String>(
                initialValue: _selectedModel,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
                items: _selectedProvider!.availableModels.map((model) {
                  return DropdownMenuItem(
                    value: model,
                    child: Text(_selectedProvider!.getModelDisplayLabel(model)),
                  );
                }).toList(),
                onChanged: _updateModel,
              ),
          ],
        ),
      ),
    );
  }
}

class _TtsSettingsCard extends ConsumerStatefulWidget {
  const _TtsSettingsCard();

  @override
  ConsumerState<_TtsSettingsCard> createState() => _TtsSettingsCardState();
}

class _TtsSettingsCardState extends ConsumerState<_TtsSettingsCard> {
  TtsSpeaker _selectedSpeaker = TtsSpeaker.male;
  double _ttsSpeed = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    final speaker = await repo.getTtsSpeaker();
    final speed = await repo.getTtsSpeed();
    if (mounted) {
      setState(() {
        _selectedSpeaker = speaker;
        _ttsSpeed = speed;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSpeaker(TtsSpeaker speaker) async {
    setState(() => _isLoading = true);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveTtsSpeaker(speaker);
    if (mounted) {
      setState(() {
        _selectedSpeaker = speaker;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSpeed(double speed) async {
    setState(() => _ttsSpeed = speed); // Optimistic update for smooth sliding
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveTtsSpeed(speed);
    // Debouncing could be added here if performant issues arise, but SharedPreferences is fast enough.
    // Invalidate provider so listeners get updated
    ref.invalidate(ttsSpeedProvider);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Voice'),
              subtitle: Text(
                _selectedSpeaker == TtsSpeaker.male ? 'Male' : 'Female',
              ),
              trailing: SegmentedButton<TtsSpeaker>(
                segments: const [
                  ButtonSegment(
                    value: TtsSpeaker.male,
                    label: Text('Male'),
                    icon: Icon(Icons.man),
                  ),
                  ButtonSegment(
                    value: TtsSpeaker.female,
                    label: Text('Female'),
                    icon: Icon(Icons.woman),
                  ),
                ],
                selected: {_selectedSpeaker},
                onSelectionChanged: (Set<TtsSpeaker> newSelection) {
                  _updateSpeaker(newSelection.first);
                },
              ),
            ),
            const Divider(),
            ListTile(
              visualDensity: const VisualDensity(vertical: -2),
              title: const Text('Playback Speed'),
              subtitle: const Text(
                'Audio playback may be unstable at higher speeds.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              trailing: Text(
                '${_ttsSpeed.toStringAsFixed(1)}x',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Slider(
              value: _ttsSpeed,
              min: 1.0,
              max: 2.0,
              divisions: 10,
              label: '${_ttsSpeed.toStringAsFixed(1)}x',
              onChanged: (value) {
                _updateSpeed(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
