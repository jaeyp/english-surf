import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selection_providers.g.dart';

@Riverpod(keepAlive: true)
class Selection extends _$Selection {
  @override
  Set<int> build() => {};

  void toggle(int id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void selectAll(List<int> ids) {
    state = ids.toSet();
  }

  void clear() {
    state = {};
  }

  bool isSelected(int id) => state.contains(id);
  int get count => state.length;
  bool get isEmpty => state.isEmpty;
}

@Riverpod(keepAlive: true)
class SelectionMode extends _$SelectionMode {
  @override
  bool build() => false;

  void setMode(bool enabled) {
    state = enabled;
    if (!enabled) {
      ref.read(selectionProvider.notifier).clear();
    }
  }

  void toggle() {
    setMode(!state);
  }
}
