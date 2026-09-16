import 'package:flutter/material.dart';

/// A service tile on the home screen (Order Food, Take Away, etc.).
@immutable
class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.badgeCount = 0,
    this.route,
  });

  final String id;
  final String title;
  final String imageUrl;

  /// A red notification badge count (0 hides it). Used by "Food Planner".
  final int badgeCount;

  /// Optional named route this tile navigates to when tapped.
  final String? route;
}
