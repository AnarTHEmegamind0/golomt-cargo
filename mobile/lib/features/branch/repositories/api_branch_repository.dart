import 'package:core/core/networking/app_api_operations.dart';
import 'package:core/core/networking/api_parsing.dart';
import 'package:core/core/networking/openapi_client.dart';
import 'package:core/features/branch/models/branch.dart';
import 'package:core/features/branch/repositories/branch_repository.dart';
import 'package:flutter/material.dart';

class ApiBranchRepository implements BranchRepository {
  ApiBranchRepository({required OpenApiClient openApiClient})
    : _openApiClient = openApiClient;

  final OpenApiClient _openApiClient;

  static const _palette = [
    Color(0xFFF08A1A),
    Color(0xFF2563EB),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];

  @override
  Future<List<Branch>> fetchAll() async {
    try {
      final response = await _openApiClient.call(AppApiOperations.listBranches);
      final body = asJsonMap(response.data, context: 'branches response');
      final items = asJsonMapList(body['data'], context: 'branches data');

      return items.map(_mapBranch).toList();
    } catch (error) {
      throw Exception(extractApiErrorMessage(error));
    }
  }

  @override
  Future<Branch?> fetchById(String id) async {
    final branches = await fetchAll();
    try {
      return branches.firstWhere((branch) => branch.id == id);
    } catch (_) {
      return null;
    }
  }

  Branch _mapBranch(Map<String, dynamic> json) {
    final id = ((json['id'] as String?) ?? '').trim();
    final code = ((json['code'] as String?) ?? '').trim();
    final name = ((json['name'] as String?) ?? '').trim();
    final address = ((json['address'] as String?) ?? '').trim();
    final phone = ((json['phone'] as String?) ?? '').trim();
    final isActive = json['isActive'] == true;

    final color = _palette[(id.hashCode.abs()) % _palette.length];

    return Branch(
      id: id.isEmpty ? code : id,
      name: name.isEmpty ? 'Салбар' : name,
      address: address.isEmpty ? 'Хаяг оруулаагүй' : address,
      chinaAddress: 'Хятад дахь агуулахын хаяг мэдээлэл алга',
      latitude: 47.9184,
      longitude: 106.9177,
      phone: phone.isEmpty ? 'Мэдээлэл алга' : phone,
      workingHours: isActive ? 'Өдөр бүр 09:00-18:00' : 'Хаалттай',
      iconColor: color,
      description: code.isEmpty ? null : 'Код: $code',
      isActive: isActive,
    );
  }
}
