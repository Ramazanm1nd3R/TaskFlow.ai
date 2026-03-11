import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/domain/entities/life_wheel.dart';
import 'package:taskflow_ai/presentation/providers/ai_providers.dart';

const _lifeWheelPalette = <Color>[
  Color(0xFF0F6CBD),
  Color(0xFF22C55E),
  Color(0xFFF59E0B),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
  Color(0xFF14B8A6),
  Color(0xFFEF4444),
  Color(0xFF06B6D4),
  Color(0xFF84CC16),
  Color(0xFFF97316),
];

class LifeWheelController extends StateNotifier<List<LifeWheelCategory>> {
  LifeWheelController()
      : super(const [
          LifeWheelCategory(
            key: 'career',
            label: 'Career',
            color: Color(0xFF0F6CBD),
            score: 7,
          ),
          LifeWheelCategory(
            key: 'health',
            label: 'Health',
            color: Color(0xFF22C55E),
            score: 6,
          ),
          LifeWheelCategory(
            key: 'relationships',
            label: 'Relationships',
            color: Color(0xFFF59E0B),
            score: 8,
          ),
          LifeWheelCategory(
            key: 'finance',
            label: 'Finance',
            color: Color(0xFF8B5CF6),
            score: 5,
          ),
          LifeWheelCategory(
            key: 'growth',
            label: 'Growth',
            color: Color(0xFFEC4899),
            score: 7,
          ),
          LifeWheelCategory(
            key: 'fun',
            label: 'Fun',
            color: Color(0xFF14B8A6),
            score: 4,
          ),
        ]);

  void updateScore(String key, double score) {
    state = [
      for (final category in state)
        if (category.key == key) category.copyWith(score: score) else category,
    ];
  }

  bool addCategory(String label) {
    if (state.length >= 10) return false;
    final normalized = label.trim();
    if (normalized.isEmpty) return false;
    final key = normalized.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    if (state.any((category) => category.key == key || category.label.toLowerCase() == normalized.toLowerCase())) {
      return false;
    }

    final color = _lifeWheelPalette[state.length % _lifeWheelPalette.length];
    state = [
      ...state,
      LifeWheelCategory(
        key: key,
        label: normalized,
        color: color,
        score: 5,
      ),
    ];
    return true;
  }
}

final lifeWheelProvider =
    StateNotifierProvider<LifeWheelController, List<LifeWheelCategory>>(
  (ref) => LifeWheelController(),
);

final lifeWheelAnalysisTriggerProvider = StateProvider<int>((ref) => 0);

final lifeWheelAnalysisProvider = FutureProvider((ref) async {
  ref.watch(lifeWheelAnalysisTriggerProvider);
  final categories = ref.read(lifeWheelProvider);
  return ref.watch(generateLifeWheelAnalysisUseCaseProvider).call(categories);
});
