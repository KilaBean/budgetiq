// ignore_for_file: prefer_initializing_formals — private DI fields cannot use
// initializing formals with named constructor params.
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

/// [ProfileRepository] backed by Supabase with a Hive read-through cache.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required ProfileLocalDataSource local,
    required bool Function() isOnline,
  }) : _remote = remote,
       _local = local,
       _isOnline = isOnline;

  final ProfileRemoteDataSource _remote;
  final ProfileLocalDataSource _local;
  final bool Function() _isOnline;

  @override
  Future<Profile> getProfile() async {
    if (!_isOnline()) {
      final cached = _local.read();
      if (cached != null) return ProfileModel.fromJson(cached);
      throw const NetworkFailure('Profile unavailable offline.');
    }
    try {
      final row = await _remote.fetch();
      if (row == null) throw const UnexpectedFailure('Profile not found.');
      await _local.write(row);
      return ProfileModel.fromJson(row);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on Failure {
      rethrow;
    } catch (_) {
      final cached = _local.read();
      if (cached != null) return ProfileModel.fromJson(cached);
      throw const NetworkFailure('Could not load profile.');
    }
  }

  @override
  Future<Profile> updateCurrency(String currencyCode) async {
    if (!_isOnline()) {
      throw const NetworkFailure('Connect to change your currency.');
    }
    try {
      final row = await _remote.update({'currency_code': currencyCode});
      await _local.write(row);
      return ProfileModel.fromJson(row);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on PostgrestException catch (e) {
      throw NetworkFailure(e.message);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }
}
