import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../sentences/application/providers/sentence_providers.dart';
import '../../../sentences/domain/enums/ai_provider.dart';
import '../../../sentences/data/providers/ai_providers.dart';
import '../../../sentences/data/providers/sentence_providers.dart';
import '../../../sentences/domain/repositories/settings_repository.dart';

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

          return ListView(children: [_buildAiSection(settingsRepo)]);
        },
      ),
    );
  }

  Widget _buildAiSection(SettingsRepository settingsRepo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'AI Configuration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const _AiSettingsCard(),
      ],
    );
  }
}

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
                  return DropdownMenuItem(value: model, child: Text(model));
                }).toList(),
                onChanged: _updateModel,
              ),
          ],
        ),
      ),
    );
  }
}
