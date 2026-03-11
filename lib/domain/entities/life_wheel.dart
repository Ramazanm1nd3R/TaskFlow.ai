import 'package:flutter/material.dart';

class LifeWheelCategory {
  const LifeWheelCategory({
    required this.key,
    required this.label,
    required this.color,
    required this.score,
  });

  final String key;
  final String label;
  final Color color;
  final double score;

  LifeWheelCategory copyWith({
    String? key,
    String? label,
    Color? color,
    double? score,
  }) {
    return LifeWheelCategory(
      key: key ?? this.key,
      label: label ?? this.label,
      color: color ?? this.color,
      score: score ?? this.score,
    );
  }
}

class LifeWheelAnalysis {
  const LifeWheelAnalysis({
    required this.summary,
    required this.focusArea,
    required this.encouragement,
    required this.nextStep,
  });

  final String summary;
  final String focusArea;
  final String encouragement;
  final String nextStep;

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'focusArea': focusArea,
      'encouragement': encouragement,
      'nextStep': nextStep,
    };
  }

  factory LifeWheelAnalysis.fromJson(Map<String, dynamic> json) {
    return LifeWheelAnalysis(
      summary: json['summary'] as String? ?? '',
      focusArea: json['focusArea'] as String? ?? '',
      encouragement: json['encouragement'] as String? ?? '',
      nextStep: json['nextStep'] as String? ?? '',
    );
  }
}
