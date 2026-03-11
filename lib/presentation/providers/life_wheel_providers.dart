import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/domain/entities/life_wheel.dart';
import 'package:taskflow_ai/presentation/providers/ai_providers.dart';

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
}

final lifeWheelProvider =
    StateNotifierProvider<LifeWheelController, List<LifeWheelCategory>>(
  (ref) => LifeWheelController(),
);

final lifeWheelAnalysisProvider = FutureProvider((ref) async {
  final categories = ref.watch(lifeWheelProvider);
  return ref.watch(generateLifeWheelAnalysisUseCaseProvider).call(categories);
});
