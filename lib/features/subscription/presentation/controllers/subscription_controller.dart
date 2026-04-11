import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:me_and_you/features/subscription/domain/entities/benefit_entity.dart';
import 'package:me_and_you/features/subscription/domain/entities/subscription_plan_entity.dart';
import 'package:me_and_you/features/subscription/domain/entities/user_subscription_entity.dart';
import 'package:me_and_you/features/subscription/domain/usecases/get_benefits_usecase.dart';
import 'package:me_and_you/features/subscription/domain/usecases/get_plans_usecase.dart';
import 'package:me_and_you/features/subscription/domain/usecases/get_user_subscription_usecase.dart';
import 'package:me_and_you/features/subscription/domain/usecases/manage_benefit_usecase.dart';
import 'package:me_and_you/features/subscription/domain/usecases/manage_plan_usecase.dart';
import 'package:me_and_you/features/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:me_and_you/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:me_and_you/features/subscription/domain/usecases/purchase_subscription_usecase.dart';
import 'package:me_and_you/features/subscription/domain/usecases/get_subscription_history_usecase.dart';
import 'package:uuid/uuid.dart';

class SubscriptionController extends ChangeNotifier {
  final GetBenefitsUseCase _getBenefitsUseCase;
  final ManageBenefitUseCase _manageBenefitUseCase;
  final GetPlansUseCase _getPlansUseCase;
  final ManagePlanUseCase _managePlanUseCase;
  final GetUserSubscriptionUseCase _getUserSubscriptionUseCase;
  final PurchaseSubscriptionUseCase _purchaseSubscriptionUseCase;
  final GetSubscriptionHistoryUseCase _getSubscriptionHistoryUseCase;

  SubscriptionController() : 
    _getBenefitsUseCase = GetBenefitsUseCase(SubscriptionRepositoryImpl(SubscriptionRemoteDataSource())),
    _manageBenefitUseCase = ManageBenefitUseCase(SubscriptionRepositoryImpl(SubscriptionRemoteDataSource())),
    _getPlansUseCase = GetPlansUseCase(SubscriptionRepositoryImpl(SubscriptionRemoteDataSource())),
    _managePlanUseCase = ManagePlanUseCase(SubscriptionRepositoryImpl(SubscriptionRemoteDataSource())),
    _getUserSubscriptionUseCase = GetUserSubscriptionUseCase(SubscriptionRepositoryImpl(SubscriptionRemoteDataSource())),
    _purchaseSubscriptionUseCase = PurchaseSubscriptionUseCase(SubscriptionRepositoryImpl(SubscriptionRemoteDataSource())),
    _getSubscriptionHistoryUseCase = GetSubscriptionHistoryUseCase(SubscriptionRepositoryImpl(SubscriptionRemoteDataSource())) {
    // Auto-reset when the user signs out so the next user gets clean streams
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) reset();
    });
  }

  List<BenefitEntity> _benefits = [];
  List<SubscriptionPlanEntity> _activePlans = [];
  List<SubscriptionPlanEntity> _allPlans = [];
  UserSubscriptionEntity? _userSubscription;
  List<UserSubscriptionEntity> _subscriptionHistory = [];
  bool _isLoading = false;

  // Guards to prevent re-attaching streams on every rebuild
  bool _isAdminInitialized = false;
  String? _activeUserId;

  List<BenefitEntity> get benefits => _benefits;
  List<SubscriptionPlanEntity> get activePlans => _activePlans;
  List<SubscriptionPlanEntity> get allPlans => _allPlans;
  UserSubscriptionEntity? get userSubscription => _userSubscription;
  List<UserSubscriptionEntity> get subscriptionHistory => _subscriptionHistory;
  bool get isLoading => _isLoading;
  bool get isPremium => _userSubscription?.isPremium ?? false;

  StreamSubscription? _benefitsSub;
  StreamSubscription? _activePlansSub;
  StreamSubscription? _allPlansSub;
  StreamSubscription? _userSub;
  StreamSubscription? _historySub;
  StreamSubscription<User?>? _authSubscription;

  void initAdmin() {
    if (_isAdminInitialized) return;
    _isAdminInitialized = true;
    _listenToBenefits();
    _listenToAllPlans();
  }

  void initUser(String userId) {
    // If already listening for this exact user, don't re-attach
    if (_activeUserId == userId) return;
    _activeUserId = userId;
    _listenToBenefits();
    _listenToActivePlans();
    _listenToUserSubscription(userId);
    _listenToSubscriptionHistory(userId);
  }

  /// Call on logout so the next user gets a fresh initialization
  void reset() {
    _benefitsSub?.cancel();
    _activePlansSub?.cancel();
    _allPlansSub?.cancel();
    _userSub?.cancel();
    _historySub?.cancel();
    _benefitsSub = null;
    _activePlansSub = null;
    _allPlansSub = null;
    _userSub = null;
    _historySub = null;
    _isAdminInitialized = false;
    _activeUserId = null;
    _benefits = [];
    _activePlans = [];
    _allPlans = [];
    _userSubscription = null;
    _subscriptionHistory = [];
  }

  @override
  void dispose() {
    _benefitsSub?.cancel();
    _activePlansSub?.cancel();
    _allPlansSub?.cancel();
    _userSub?.cancel();
    _historySub?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _listenToBenefits() {
    _benefitsSub?.cancel();
    _benefitsSub = _getBenefitsUseCase.execute().listen((data) {
      _benefits = List<BenefitEntity>.from(data);
      notifyListeners();
    });
  }

  void _listenToActivePlans() {
    _activePlansSub?.cancel();
    _activePlansSub = _getPlansUseCase.execute(activeOnly: true).listen((data) {
      _activePlans = List<SubscriptionPlanEntity>.from(data);
      notifyListeners();
    });
  }

  void _listenToAllPlans() {
    _allPlansSub?.cancel();
    _allPlansSub = _getPlansUseCase.execute(activeOnly: false).listen((data) {
      _allPlans = List<SubscriptionPlanEntity>.from(data);
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

  void _listenToSubscriptionHistory(String userId) {
    _historySub?.cancel();
    _historySub = _getSubscriptionHistoryUseCase.execute(userId).listen((data) {
      _subscriptionHistory = data;
      notifyListeners();
    });
  }

  /// Logical check if the user has a specific benefit
  bool hasBenefit(String benefitCode) {
    if (!isPremium || _userSubscription == null) return false;

    // 1. Find the current plan details
    final currentPlan = _activePlans.cast<SubscriptionPlanEntity>().firstWhere(
      (p) => p.id == _userSubscription!.planId,
      orElse: () => _allPlans.cast<SubscriptionPlanEntity>().firstWhere(
        (p) => p.id == _userSubscription!.planId,
        orElse: () => SubscriptionPlanEntity(
          id: '', name: '', productId: '', 
          durationType: DurationType.monthly, durationInDays: 0, 
          price: 0, currency: '', benefitIds: []
        ),
      ),
    );

    if (currentPlan.id.isEmpty) return false;

    // 2. Map benefit IDs to their codes and check for a match
    final userBenefitCodes = _benefits
        .where((b) => currentPlan.benefitIds.contains(b.id))
        .map((b) => b.code)
        .toList();

    return userBenefitCodes.contains(benefitCode);
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

  Future<bool> processPurchase(String userId, SubscriptionPlanEntity plan) async {
    _setLoading(true);
    try {
      // Simulate backend payment verification
      await Future.delayed(const Duration(seconds: 2));

      final now = DateTime.now();
      final expiry = now.add(Duration(days: plan.durationInDays));

      final subscription = UserSubscriptionEntity(
        userId: userId,
        planId: plan.id,
        startDate: now,
        expiryDate: expiry,
        paymentId: 'SIMULATED_${const Uuid().v4()}',
        status: SubscriptionStatus.active,
      );

      await _purchaseSubscriptionUseCase.execute(subscription);
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
