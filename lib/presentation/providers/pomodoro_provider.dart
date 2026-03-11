import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PomodoroMode { focus, shortBreak, longBreak }

class PomodoroUiState {
  const PomodoroUiState({
    required this.mode,
    required this.isRunning,
    required this.remainingSeconds,
    required this.completedFocusSessions,
    required this.modeDurations,
  });

  factory PomodoroUiState.initial() => const PomodoroUiState(
        mode: PomodoroMode.focus,
        isRunning: false,
        remainingSeconds: 25 * 60,
        completedFocusSessions: 0,
        modeDurations: {
          PomodoroMode.focus: 25 * 60,
          PomodoroMode.shortBreak: 5 * 60,
          PomodoroMode.longBreak: 15 * 60,
        },
      );

  final PomodoroMode mode;
  final bool isRunning;
  final int remainingSeconds;
  final int completedFocusSessions;
  final Map<PomodoroMode, int> modeDurations;

  int get totalSeconds => modeDurations[mode] ?? 1;

  double get progress {
    final total = totalSeconds;
    if (total == 0) return 0;
    return (total - remainingSeconds) / total;
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  PomodoroUiState copyWith({
    PomodoroMode? mode,
    bool? isRunning,
    int? remainingSeconds,
    int? completedFocusSessions,
    Map<PomodoroMode, int>? modeDurations,
  }) {
    return PomodoroUiState(
      mode: mode ?? this.mode,
      isRunning: isRunning ?? this.isRunning,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      completedFocusSessions:
          completedFocusSessions ?? this.completedFocusSessions,
      modeDurations: modeDurations ?? this.modeDurations,
    );
  }
}

class PomodoroController extends StateNotifier<PomodoroUiState> {
  PomodoroController() : super(PomodoroUiState.initial());

  Timer? _timer;

  void toggle() {
    if (state.isRunning) {
      _timer?.cancel();
      state = state.copyWith(isRunning: false);
      return;
    }

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 1) {
        timer.cancel();
        final completedFocus = state.mode == PomodoroMode.focus
            ? state.completedFocusSessions + 1
            : state.completedFocusSessions;
        state = state.copyWith(
          isRunning: false,
          remainingSeconds: 0,
          completedFocusSessions: completedFocus,
        );
        return;
      }

      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    });
  }

  void switchMode(PomodoroMode mode) {
    _timer?.cancel();
    state = state.copyWith(
      mode: mode,
      isRunning: false,
      remainingSeconds: state.modeDurations[mode],
    );
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      remainingSeconds: state.modeDurations[state.mode],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final pomodoroProvider =
    StateNotifierProvider<PomodoroController, PomodoroUiState>(
  (ref) => PomodoroController(),
);
