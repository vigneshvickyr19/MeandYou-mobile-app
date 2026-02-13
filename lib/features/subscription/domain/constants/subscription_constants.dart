import 'package:flutter/material.dart';

class SubscriptionTier {
  final String id;
  final String name;
  final Color? color;

  const SubscriptionTier({
    required this.id,
    required this.name,
    this.color,
  });
}

class SubscriptionConstants {
  static const List<SubscriptionTier> tiers = [
    SubscriptionTier(id: 'plus', name: 'Plus'),
    SubscriptionTier(id: 'premium', name: 'Premium'),
    SubscriptionTier(id: 'ultra', name: 'Ultra'),
  ];

  static String getTierName(String id) {
    return tiers.firstWhere((t) => t.id == id, orElse: () => SubscriptionTier(id: id, name: id.toUpperCase())).name;
  }

  static List<String> get tierIds => tiers.map((t) => t.id).toList();
}
