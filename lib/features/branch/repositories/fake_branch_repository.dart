import 'package:flutter/material.dart';
import 'package:core/features/branch/models/branch.dart';
import 'package:core/features/branch/repositories/branch_repository.dart';

/// Fake implementation of BranchRepository for development
class FakeBranchRepository implements BranchRepository {
  static final List<Branch> _fakeBranches = [
    const Branch(
      id: 'branch-001',
      name: 'Буундуу Карго - Улаанбаатар',
      address: 'Хан-Уул дүүрэг, 15-р хороо, Ажилчны гудамж 45',
      chinaAddress: '广州市白云区石井镇红星村石沙路168号档口B区108号',
      latitude: 47.9184,
      longitude: 106.9177,
      phone: '+976 7711-1234',
      workingHours: 'Даваа-Баасан 09:00-18:00',
      iconColor: Color(0xFFF08A1A),
      description: 'Төв салбар - Бүх төрлийн ачаа хүлээн авна',
    ),
    const Branch(
      id: 'branch-002',
      name: 'Буундуу Карго - Дархан',
      address: 'Дархан-Уул аймаг, 4-р баг, Төмөр замын гудамж',
      chinaAddress: '深圳市罗湖区笋岗东路3002号万通大厦A座5楼501室',
      latitude: 49.4685,
      longitude: 105.9747,
      phone: '+976 7722-5678',
      workingHours: 'Даваа-Бямба 10:00-17:00',
      iconColor: Color(0xFF2563EB),
      description: 'Хойд бүсийн салбар',
    ),
    const Branch(
      id: 'branch-003',
      name: 'Буундуу Карго - Эрдэнэт',
      address: 'Орхон аймаг, Баян-Өндөр сум, 1-р баг',
      chinaAddress: '义乌市福田街道荷叶塘工业区A栋3楼',
      latitude: 49.0275,
      longitude: 104.0450,
      phone: '+976 7733-9012',
      workingHours: 'Даваа-Баасан 09:00-17:00',
      iconColor: Color(0xFF10B981),
      description: 'Баруун бүсийн салбар',
    ),
    const Branch(
      id: 'branch-004',
      name: 'Буундуу Карго - Чойр',
      address: 'Говьсүмбэр аймаг, Сүмбэр сум, 2-р баг',
      chinaAddress: '二连浩特市前进路88号',
      latitude: 46.3568,
      longitude: 108.3627,
      phone: '+976 7744-3456',
      workingHours: 'Даваа-Баасан 10:00-16:00',
      iconColor: Color(0xFFEC4899),
      description: 'Хилийн боомт салбар',
    ),
    const Branch(
      id: 'branch-005',
      name: 'Буундуу Карго - Замын-Үүд',
      address: 'Дорноговь аймаг, Замын-Үүд сум',
      chinaAddress: '二连浩特市国门大道66号',
      latitude: 43.7157,
      longitude: 111.9035,
      phone: '+976 7755-7890',
      workingHours: '24 цаг',
      iconColor: Color(0xFF8B5CF6),
      description: 'Хилийн гаалийн салбар - Хятад руу шууд хүргэлт',
    ),
  ];

  @override
  Future<List<Branch>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _fakeBranches;
  }

  @override
  Future<Branch?> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _fakeBranches.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
