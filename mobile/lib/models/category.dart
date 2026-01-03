import 'package:flutter/material.dart';
import '../config/theme.dart';

class Category {
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;

  Category({
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? '',
      icon: _getIconData(json['name'] ?? 'others'),
      color: AppColors.categoryColors[json['name']] ?? AppColors.textSecondary,
    );
  }

  // Map category names to Material Design icons
  static IconData _getIconData(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'clothes':
        return Icons.checkroom;
      case 'drinks':
        return Icons.local_bar;
      case 'education':
        return Icons.school;
      case 'food':
        return Icons.restaurant;
      case 'fuel':
        return Icons.local_gas_station;
      case 'fun':
        return Icons.sports_esports;
      case 'health':
        return Icons.local_hospital;
      case 'hotel':
        return Icons.hotel;
      case 'personal':
        return Icons.person;
      case 'pets':
        return Icons.pets;
      case 'restaurants':
        return Icons.dining;
      case 'tips':
        return Icons.card_giftcard;
      case 'transport':
        return Icons.directions_car;
      default:
        return Icons.inventory_2;
    }
  }

  // Predefined categories list
  static List<Category> get all {
    return [
      Category(name: 'clothes', displayName: 'Clothes', icon: Icons.checkroom, color: AppColors.categoryColors['clothes']!),
      Category(name: 'drinks', displayName: 'Drinks', icon: Icons.local_bar, color: AppColors.categoryColors['drinks']!),
      Category(name: 'education', displayName: 'Education', icon: Icons.school, color: AppColors.categoryColors['education']!),
      Category(name: 'food', displayName: 'Food', icon: Icons.restaurant, color: AppColors.categoryColors['food']!),
      Category(name: 'fuel', displayName: 'Fuel', icon: Icons.local_gas_station, color: AppColors.categoryColors['fuel']!),
      Category(name: 'fun', displayName: 'Fun', icon: Icons.sports_esports, color: AppColors.categoryColors['fun']!),
      Category(name: 'health', displayName: 'Health', icon: Icons.local_hospital, color: AppColors.categoryColors['health']!),
      Category(name: 'hotel', displayName: 'Hotel', icon: Icons.hotel, color: AppColors.categoryColors['hotel']!),
      Category(name: 'personal', displayName: 'Personal', icon: Icons.person, color: AppColors.categoryColors['personal']!),
      Category(name: 'pets', displayName: 'Pets', icon: Icons.pets, color: AppColors.categoryColors['pets']!),
      Category(name: 'restaurants', displayName: 'Restaurants', icon: Icons.dining, color: AppColors.categoryColors['restaurants']!),
      Category(name: 'tips', displayName: 'Tips', icon: Icons.card_giftcard, color: AppColors.categoryColors['tips']!),
      Category(name: 'transport', displayName: 'Transport', icon: Icons.directions_car, color: AppColors.categoryColors['transport']!),
      Category(name: 'others', displayName: 'Others', icon: Icons.inventory_2, color: AppColors.categoryColors['others']!),
    ];
  }

  static Category getByName(String name) {
    return all.firstWhere(
      (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      orElse: () => all.last, // Return 'others' as default
    );
  }
}
