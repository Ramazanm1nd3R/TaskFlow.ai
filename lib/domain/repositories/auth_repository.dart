import 'package:dartz/dartz.dart';
import 'package:taskflow_ai/core/errors/failures.dart';
import 'package:taskflow_ai/domain/entities/session.dart';

abstract class AuthRepository {
  Future<Either<Failure, Session?>> restoreSession();
  Future<Either<Failure, void>> startLogin({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> startRegister({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<Either<Failure, Session>> verifyCode(String code);
  Future<Either<Failure, void>> resendCode();
  Future<Either<Failure, void>> logout();
}
