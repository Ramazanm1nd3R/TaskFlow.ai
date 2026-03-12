import 'package:flutter/material.dart';

class LifeWheelCategory {
  const LifeWheelCategory({
    required this.key,
    required this.label,
    required this.color,
    required this.score,
    required this.isCustom,
  });

  final String key;
  final String label;
  final Color color;
  final double score;
  final bool isCustom;

  LifeWheelCategory copyWith({
    String? key,
    String? label,
    Color? color,
    double? score,
    bool? isCustom,
  }) {
    return LifeWheelCategory(
      key: key ?? this.key,
      label: label ?? this.label,
      color: color ?? this.color,
      score: score ?? this.score,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'color': color.toARGB32(),
      'score': score,
      'isCustom': isCustom,
    };
  }

  factory LifeWheelCategory.fromJson(Map<String, dynamic> json) {
    return LifeWheelCategory(
      key: json['key'] as String,
      label: json['label'] as String,
      color: Color(json['color'] as int),
      score: (json['score'] as num).toDouble(),
      isCustom: json['isCustom'] as bool? ?? false,
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
