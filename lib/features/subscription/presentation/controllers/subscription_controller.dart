import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/benefit_entity.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import '../../domain/entities/user_subscription_entity.dart';
import '../../domain/usecases/get_benefits_usecase.dart';
import '../../domain/usecases/get_plans_usecase.dart';
import '../../domain/usecases/get_user_subscription_usecase.dart';
import '../../domain/usecases/manage_benefit_usecase.dart';
import '../../domain/usecases/manage_plan_usecase.dart';
import '../../data/datasources/subscription_remote_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';

class SubscriptionController extends ChangeNotifier {
  final GetBenefitsUseCase _getBenefitsUseCase;
  final ManageBenefitUseCase _manageBenefitUseCase;
  final GetPlansUseCase _getPlansUseCase;
  final ManagePlanUseCase _managePlanUseCase;
  final GetUserSubscriptionUseCase _getUserSubscriptionUseCase;

  SubscriptionController() : 
    _getBenefitsUseCase = GetBenefitsUseCase(SubscriptionRepositoryImpl(SubscriptionRemoteDataSource())),
    _manageBenefitUseCase = ManageBenefitUseCase(SubscriptionRepositoryImpl(SubscriptionRemoteDataSource())),
    _getPlansUseCase = GetPlansUseCase(SubscriptionRepositoryImpl(SubscriptionRemoteDataSource())),
    _managePlanUseCase = ManagePlanUseCase(SubscriptionRepositoryImpl(SubscriptionRemoteDataSource())),
    _getUserSubscriptionUseCase = GetUserSubscriptionUseCase(SubscriptionRepositoryImpl(SubscriptionRemoteDataSource()));

  List<BenefitEntity> _benefits = [];
  List<SubscriptionPlanEntity> _activePlans = [];
  List<SubscriptionPlanEntity> _allPlans = [];
  UserSubscriptionEntity? _userSubscription;
  bool _isLoading = false;

  List<BenefitEntity> get benefits => _benefits;
  List<SubscriptionPlanEntity> get activePlans => _activePlans;
  List<SubscriptionPlanEntity> get allPlans => _allPlans;
  UserSubscriptionEntity? get userSubscription => _userSubscription;
  bool get isLoading => _isLoading;
  bool get isPremium => _userSubscription?.isPremium ?? false;

  StreamSubscription? _benefitsSub;
  StreamSubscription? _activePlansSub;
  StreamSubscription? _allPlansSub;
  StreamSubscription? _userSub;

  void initAdmin() {
    _listenToBenefits();
    _listenToAllPlans();
  }

  void initUser(String userId) {
    _listenToBenefits();
    _listenToActivePlans();
    _listenToUserSubscription(userId);
  }

  @override
  void dispose() {
    _benefitsSub?.cancel();
    _activePlansSub?.cancel();
    _allPlansSub?.cancel();
    _userSub?.cancel();
    super.dispose();
  }

  void _listenToBenefits() {
    _benefitsSub?.cancel();
    _benefitsSub = _getBenefitsUseCase.execute().listen((data) {
      _benefits = data;
      notifyListeners();
    });
  }

  void _listenToActivePlans() {
    _activePlansSub?.cancel();
    _activePlansSub = _getPlansUseCase.execute(activeOnly: true).listen((data) {
      _activePlans = data;
      notifyListeners();
    });
  }

  void _listenToAllPlans() {
    _allPlansSub?.cancel();
    _allPlansSub = _getPlansUseCase.execute(activeOnly: false).listen((data) {
      _allPlans = data;
      notifyListeners();
    });
  }

  void _listenToUserSubscription(String userId) {
    _userSub?.cancel();
    _userSub = _getUserSubscriptionUseCase.execute(userId).listen((data) {
      _userSubscription = data;
      notifyListeners();
    });
  }

  // Admin Actions
  Future<void> createBenefit(String title, String description) async {
    _setLoading(true);
    try {
      // Automatic code generation: "Unlimited Likes" -> "UNLIMITED_LIKES"
      final String code = title.trim().toUpperCase().replaceAll(' ', '_');

      await _manageBenefitUseCase.create(BenefitEntity(
        id: '',
        title: title.trim(),
        code: code,
        description: description,
      ));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBenefit(BenefitEntity benefit) async {
    _setLoading(true);
    try {
      await _manageBenefitUseCase.update(benefit);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createPlan(SubscriptionPlanEntity plan) async {
    _setLoading(true);
    try {
      await _managePlanUseCase.create(plan);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePlan(SubscriptionPlanEntity plan) async {
    _setLoading(true);
    try {
      await _managePlanUseCase.update(plan);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> processPurchase(String planId) async {
    _setLoading(true);
    try {
      // Simulate backend API call
      await Future.delayed(const Duration(seconds: 2));
      // In a real app, the backend would update Firestore.
      // Our stream listener in initUser will automatically pick it up.
      return true;
    } catch (e) {
      debugPrint("Purchase error: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
