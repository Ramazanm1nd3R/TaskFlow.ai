import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:taskflow_ai/core/constants/app_constants.dart';
import 'package:taskflow_ai/core/errors/error_mapper.dart';
import 'package:taskflow_ai/core/errors/failures.dart';
import 'package:taskflow_ai/data/datasources/local/auth_local_datasource.dart';
import 'package:taskflow_ai/data/datasources/remote/auth_remote_datasource.dart';
import 'package:taskflow_ai/data/models/auth/session_model.dart';
import 'package:taskflow_ai/domain/entities/session.dart';
import 'package:taskflow_ai/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Either<Failure, Session?>> restoreSession() async {
    try {
      final session = await _local.readSession();
      if (session == null || session.isExpired) {
        await _local.clearSession();
        return const Right(null);
      }
      return Right(session);
    } catch (error) {
      return Left(mapToFailure(error));
    }
  }

  @override
  Future<Either<Failure, void>> startLogin({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remote.login(email: email, password: password);
      final verification = _buildVerificationPayload(
        email: email,
        type: 'login',
      );
      await _remote.sendVerificationCode(
        email: email,
        code: verification['code'] as String,
        type: 'login',
      );
      await _local.savePendingVerification(verification);
      await _local.savePendingAuthPayload({'type': 'login', 'userId': user.id});
      return const Right(null);
    } catch (error) {
      return Left(mapToFailure(error));
    }
  }

  @override
  Future<Either<Failure, void>> startRegister({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final verification = _buildVerificationPayload(
        email: email,
        type: 'register',
      );
      await _remote.sendVerificationCode(
        email: email,
        code: verification['code'] as String,
        type: 'register',
      );
      await _local.savePendingVerification(verification);
      await _local.savePendingAuthPayload({
        'type': 'register',
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      });
      return const Right(null);
    } catch (error) {
      return Left(mapToFailure(error));
    }
  }

  @override
  Future<Either<Failure, Session>> verifyCode(String code) async {
    try {
      final verification = await _local.readPendingVerification();
      final pending = await _local.readPendingAuthPayload();
      if (verification == null || pending == null) {
        return const Left(ValidationFailure('No active verification flow'));
      }

      final expiresAt = DateTime.parse(verification['expiresAt'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        await _local.clearPendingAuthFlow();
        return const Left(ValidationFailure('Verification code expired'));
      }

      if (verification['code'] != code) {
        final attempts = (verification['attempts'] as int? ?? 0) + 1;
        if (attempts >= AppConstants.maxVerificationAttempts) {
          await _local.clearPendingAuthFlow();
          return const Left(ValidationFailure('Maximum attempts exceeded'));
        }
        await _local.savePendingVerification({...verification, 'attempts': attempts});
        return Left(
          ValidationFailure(
            'Invalid code. Attempts left: ${AppConstants.maxVerificationAttempts - attempts}',
          ),
        );
      }

      final session = await _completeAuthFlow(pending.cast<String, dynamic>());
      await _local.saveSession(session);
      await _local.clearPendingAuthFlow();
      return Right(session);
    } catch (error) {
      return Left(mapToFailure(error));
    }
  }

  @override
  Future<Either<Failure, void>> resendCode() async {
    try {
      final verification = await _local.readPendingVerification();
      if (verification == null) {
        return const Left(ValidationFailure('No active verification flow'));
      }
      final refreshed = _buildVerificationPayload(
        email: verification['email'] as String,
        type: verification['type'] as String,
      );
      await _remote.sendVerificationCode(
        email: refreshed['email'] as String,
        code: refreshed['code'] as String,
        type: refreshed['type'] as String,
      );
      await _local.savePendingVerification(refreshed);
      return const Right(null);
    } catch (error) {
      return Left(mapToFailure(error));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _local.clearSession();
      await _local.clearPendingAuthFlow();
      return const Right(null);
    } catch (error) {
      return Left(mapToFailure(error));
    }
  }

  Map<String, dynamic> _buildVerificationPayload({
    required String email,
    required String type,
  }) {
    final random = Random();
    final code = (100000 + random.nextInt(900000)).toString();
    final expiresAt = DateTime.now()
        .add(const Duration(seconds: AppConstants.verificationTtlSeconds))
        .toIso8601String();
    return {
      'email': email,
      'code': code,
      'type': type,
      'expiresAt': expiresAt,
      'attempts': 0,
    };
  }

  Future<SessionModel> _completeAuthFlow(Map<String, dynamic> pending) async {
    final type = pending['type'] as String;
    if (type == 'register') {
      final userId = await _remote.register(
        firstName: pending['firstName'] as String,
        lastName: pending['lastName'] as String,
        email: pending['email'] as String,
        password: pending['password'] as String,
      );
      final user = await _remote.getUser(userId);
      return SessionModel(
        user: user,
        expiresAt: DateTime.now().add(
          const Duration(hours: AppConstants.sessionTtlHours),
        ),
      );
    }

    final user = await _remote.getUser(pending['userId'] as String);
    return SessionModel(
      user: user,
      expiresAt: DateTime.now().add(
        const Duration(hours: AppConstants.sessionTtlHours),
      ),
    );
  }
}
