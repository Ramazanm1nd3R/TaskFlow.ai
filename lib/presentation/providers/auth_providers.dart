import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/core/constants/demo_data.dart';
import 'package:taskflow_ai/domain/entities/session.dart';

enum AuthFlowStep { login, register, verification, authenticated }

class AuthUiState {
  const AuthUiState({
    required this.session,
    required this.isLoading,
    required this.flowStep,
    this.errorMessage,
    this.pendingEmail,
  });

  factory AuthUiState.initial() => const AuthUiState(
        session: null,
        isLoading: false,
        flowStep: AuthFlowStep.login,
      );

  final Session? session;
  final bool isLoading;
  final AuthFlowStep flowStep;
  final String? errorMessage;
  final String? pendingEmail;

  AuthUiState copyWith({
    Session? session,
    bool? isLoading,
    AuthFlowStep? flowStep,
    String? errorMessage,
    String? pendingEmail,
    bool clearError = false,
  }) {
    return AuthUiState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      flowStep: flowStep ?? this.flowStep,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      pendingEmail: pendingEmail ?? this.pendingEmail,
    );
  }
}

class AuthController extends StateNotifier<AuthUiState> {
  AuthController() : super(AuthUiState.initial()) {
    restoreSession();
  }

  Future<void> restoreSession() async {
    state = state.copyWith(
      isLoading: false,
      session: demoSession,
      flowStep: AuthFlowStep.authenticated,
      pendingEmail: demoUser.email,
      clearError: true,
    );
  }

  Future<void> startLogin(String email, String password) async {
    state = state.copyWith(
      isLoading: false,
      session: demoSession,
      flowStep: AuthFlowStep.authenticated,
      pendingEmail: demoUser.email,
      clearError: true,
    );
  }

  Future<void> startRegister({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: false,
      session: demoSession,
      flowStep: AuthFlowStep.authenticated,
      pendingEmail: demoUser.email,
      clearError: true,
    );
  }

  Future<void> verifyCode(String code) async {
    state = state.copyWith(
      isLoading: false,
      session: demoSession,
      flowStep: AuthFlowStep.authenticated,
      pendingEmail: demoUser.email,
      clearError: true,
    );
  }

  Future<void> resendCode() async {
    state = state.copyWith(isLoading: false, clearError: true);
  }

  Future<void> logout() async {
    state = state.copyWith(
      isLoading: false,
      session: demoSession,
      flowStep: AuthFlowStep.authenticated,
      pendingEmail: demoUser.email,
      clearError: true,
    );
  }

  void showLogin() {
    state = state.copyWith(flowStep: AuthFlowStep.login, clearError: true);
  }

  void showRegister() {
    state = state.copyWith(flowStep: AuthFlowStep.register, clearError: true);
  }

  void backToLogin() {
    state = state.copyWith(
      flowStep: AuthFlowStep.authenticated,
      session: demoSession,
      clearError: true,
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthUiState>(
  (ref) => AuthController(),
);
