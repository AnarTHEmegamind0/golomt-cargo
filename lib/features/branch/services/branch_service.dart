import 'package:core/features/branch/models/branch.dart';
import 'package:core/features/branch/repositories/branch_repository.dart';

/// Branch service handles business logic
class BranchService {
  BranchService({required BranchRepository repository})
    : _repository = repository;

  final BranchRepository _repository;

  Future<List<Branch>> fetchAll() => _repository.fetchAll();

  Future<Branch?> fetchById(String id) => _repository.fetchById(id);
}
