import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/async_notifier_provider/model.dart';

import "package:riverpod/riverpod.dart";

final fruitsProvider =
    AsyncNotifierProvider<FruitsNotifier, List<Fruit>>(
  FruitsNotifier.new,
);

class FruitsNotifier extends AsyncNotifier<List<Fruit>> {
  @override
  Future<List<Fruit>> build() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    return const [
      Fruit(id: 1, name: 'Apple', emoji: '🍎'),
      Fruit(id: 2, name: 'Banana', emoji: '🍌'),
      Fruit(id: 3, name: 'Mango', emoji: '🥭'),
      Fruit(id: 4, name: 'Orange', emoji: '🍊'),
    ];
  }

  // ============================================================
  // CREATE
  // ============================================================

  Future<void> addFruit({required String name, required String emoji}) async {
    // Prevent multiple simultaneous operations.
    if (state.isLoading) return;

    final currentFruits = state.value ?? [];

    try {
      // Keep existing data visible while operation runs.
      state = const AsyncLoading<List<Fruit>>();
      // Simulate API request.
      await Future.delayed(const Duration(seconds: 1));

      final newFruit = Fruit(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        emoji: emoji,
      );

      state = AsyncValue.data([...currentFruits, newFruit]);
    } catch (error, stackTrace) {
      state = AsyncError<List<Fruit>>(error, stackTrace);
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<void> updateFruit({
    required int id,
    required String name,
    required String emoji,
  }) async {
    if (state.isLoading) return;

    final currentFruits = state.value ?? [];

    try {
      state = const AsyncLoading<List<Fruit>>();

      // Simulate API request.
      await Future.delayed(const Duration(seconds: 1));

      final updatedFruits = currentFruits.map((fruit) {
        if (fruit.id == id) {
          return fruit.copyWith(name: name, emoji: emoji);
        }

        return fruit;
      }).toList();

      state = AsyncValue.data(updatedFruits);
    } catch (error, stackTrace) {
      state = AsyncError<List<Fruit>>(error, stackTrace);
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteFruit(int id) async {
    if (state.isLoading) return;

    final currentFruits = state.value ?? [];

    try {
      state = const AsyncLoading<List<Fruit>>();

      // Simulate API request.
      await Future.delayed(const Duration(seconds: 1));

      final updatedFruits = currentFruits
          .where((fruit) => fruit.id != id)
          .toList();

      state = AsyncValue.data(updatedFruits);
    } catch (error, stackTrace) {
      state = AsyncError<List<Fruit>>(error, stackTrace);
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshFruits() async {
    ref.invalidateSelf();

    await future;
  }
}
