import 'package:equatable/equatable.dart';

enum EducationLevel { BAC, BAC_PLUS_1, BAC_PLUS_2, BAC_PLUS_3, BAC_PLUS_4, BAC_PLUS_5_PLUS }

enum StudentStatus { SEARCHING, ASSIGNED, COMPLETED }

class Student extends Equatable {
  final String id;
  final String userId;
  final EducationLevel educationLevel;
  final String availability;
  final String desiredTrade; // Sub-category ID
  final String countryId;
  final StudentStatus status;
  final String? assignedArtisanId;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.userId,
    required this.educationLevel,
    required this.availability,
    required this.desiredTrade,
    required this.countryId,
    required this.status,
    this.assignedArtisanId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    educationLevel,
    availability,
    desiredTrade,
    countryId,
    status,
    assignedArtisanId,
    createdAt,
  ];
}

class ApprenticeshipOffer extends Equatable {
  final String id;
  final String artisanId;
  final String title;
  final String description;
  final String requiredLevel;
  final String skillsFocus;
  final int duration; // in months
  final String countryId;
  final bool isPublic;
  final DateTime createdAt;

  ApprenticeshipOffer({
    required this.id,
    required this.artisanId,
    required this.title,
    required this.description,
    required this.requiredLevel,
    required this.skillsFocus,
    required this.duration,
    required this.countryId,
    required this.isPublic,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    artisanId,
    title,
    description,
    requiredLevel,
    skillsFocus,
    duration,
    countryId,
    isPublic,
    createdAt,
  ];
}
