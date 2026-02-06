import 'package:flutter/material.dart';

class InterestItem {
  final String label;
  final IconData icon;

  const InterestItem({required this.label, required this.icon});
}

class AppDataConstants {
  // Interests Data
  static const List<InterestItem> interests = [
    InterestItem(label: 'Game', icon: Icons.sports_esports),
    InterestItem(label: 'Singing', icon: Icons.mic),
    InterestItem(label: 'Yoga', icon: Icons.self_improvement),
    InterestItem(label: 'Anime', icon: Icons.favorite),
    InterestItem(label: 'Movie', icon: Icons.movie),
    InterestItem(label: 'Coffee', icon: Icons.coffee),
    InterestItem(label: 'Music', icon: Icons.music_note),
    InterestItem(label: 'Travel', icon: Icons.flight),
    InterestItem(label: 'Fitness', icon: Icons.fitness_center),
    InterestItem(label: 'Reading', icon: Icons.menu_book),
    InterestItem(label: 'Art', icon: Icons.palette),
    InterestItem(label: 'Cooking', icon: Icons.restaurant),
    InterestItem(label: 'Photography', icon: Icons.camera_alt),
    InterestItem(label: 'Networking', icon: Icons.people),
    InterestItem(label: 'Writing', icon: Icons.edit),
  ];

  // Lifestyle Options
  static const List<String> smokingOptions = [
    'Non-smoker',
    'Smoker',
    'Social smoker',
  ];

  static const List<String> drinkingOptions = [
    'Non-drinker',
    'Social drinker',
    'Frequent drinker',
  ];

  static const List<String> exerciseOptions = [
    'Active',
    'Sometimes',
    'Never',
  ];

  static const List<String> dietOptions = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
  ];

  static const List<String> petOptions = [
    'Dog lover',
    'Cat lover',
    'No pets',
  ];

  static const List<String> religionOptions = [
    'Christian',
    'Muslim',
    'Hindu',
    'Buddhist',
    'Sikh',
    'Jewish',
    'Other',
    'None',
  ];

  static const List<String> languageOptions = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Hindi',
  ];

  // Dating Preferences
  static const List<String> lookingForOptions = [
    'Relationship',
    'Friendship',
    'Casual',
    'Marriage',
  ];

  static const List<int> distanceOptions = [10, 20, 50, 100, 500];
}
