import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String userId;
  
  // Step 1: Basic Identity
  final String? fullName;
  final DateTime? dob;
  final String? gender;

  // Step 2: Photos
  final List<String>? photos;

  // Step 3: Address
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? pinCode;

  // Step 4: Bio
  final String? bio;

  // Step 5: Quick Stats
  final int? height;
  final String? jobTitle;
  final String? education;
  final String? hometown;

  // Step 6: Lifestyle
  final String? drinking;
  final String? smoking;
  final String? exercise;
  final String? diet;
  final String? pets;
  final String? religion;
  final String? language;

  // Step 7: Preferences & Interests
  final String? lookingFor;
  final int? minAge;
  final int? maxAge;
  final int? distance;
  final List<String>? interests;

  // Step 8: Social Links
  final String? instagram;
  final String? linkedin;
  final String? facebook;
  final String? x;

  ProfileModel({
    required this.userId,
    this.fullName,
    this.dob,
    this.gender,
    this.photos,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pinCode,
    this.bio,
    this.height,
    this.jobTitle,
    this.education,
    this.hometown,
    this.drinking,
    this.smoking,
    this.exercise,
    this.diet,
    this.pets,
    this.religion,
    this.language,
    this.lookingFor,
    this.minAge,
    this.maxAge,
    this.distance,
    this.interests,
    this.instagram,
    this.linkedin,
    this.facebook,
    this.x,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> data, String userId) {
    return ProfileModel(
      userId: userId,
      fullName: data['fullName'],
      dob: (data['dob'] as Timestamp?)?.toDate(),
      gender: data['gender'],
      photos: data['photos'] != null ? List<String>.from(data['photos']) : null,
      addressLine1: data['addressLine1'],
      addressLine2: data['addressLine2'],
      city: data['city'],
      state: data['state'],
      country: data['country'],
      pinCode: data['pinCode'],
      bio: data['bio'],
      height: data['height'],
      jobTitle: data['jobTitle'],
      education: data['education'],
      hometown: data['hometown'],
      drinking: data['drinking'],
      smoking: data['smoking'],
      exercise: data['exercise'],
      diet: data['diet'],
      pets: data['pets'],
      religion: data['religion'],
      language: data['language'],
      lookingFor: data['lookingFor'],
      minAge: data['minAge'],
      maxAge: data['maxAge'],
      distance: data['distance'],
      interests: data['interests'] != null ? List<String>.from(data['interests']) : null,
      instagram: data['instagram'],
      linkedin: data['linkedin'],
      facebook: data['facebook'],
      x: data['x'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'gender': gender,
      'photos': photos,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'pinCode': pinCode,
      'bio': bio,
      'height': height,
      'jobTitle': jobTitle,
      'education': education,
      'hometown': hometown,
      'drinking': drinking,
      'smoking': smoking,
      'exercise': exercise,
      'diet': diet,
      'pets': pets,
      'religion': religion,
      'language': language,
      'lookingFor': lookingFor,
      'minAge': minAge,
      'maxAge': maxAge,
      'distance': distance,
      'interests': interests,
      'instagram': instagram,
      'linkedin': linkedin,
      'facebook': facebook,
      'x': x,
    };
  }

  ProfileModel copyWith({
    String? fullName,
    DateTime? dob,
    String? gender,
    List<String>? photos,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? pinCode,
    String? bio,
    int? height,
    String? jobTitle,
    String? education,
    String? hometown,
    String? drinking,
    String? smoking,
    String? exercise,
    String? diet,
    String? pets,
    String? religion,
    String? language,
    String? lookingFor,
    int? minAge,
    int? maxAge,
    int? distance,
    List<String>? interests,
    String? instagram,
    String? linkedin,
    String? facebook,
    String? x,
  }) {
    return ProfileModel(
      userId: userId,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      photos: photos ?? this.photos,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pinCode: pinCode ?? this.pinCode,
      bio: bio ?? this.bio,
      height: height ?? this.height,
      jobTitle: jobTitle ?? this.jobTitle,
      education: education ?? this.education,
      hometown: hometown ?? this.hometown,
      drinking: drinking ?? this.drinking,
      smoking: smoking ?? this.smoking,
      exercise: exercise ?? this.exercise,
      diet: diet ?? this.diet,
      pets: pets ?? this.pets,
      religion: religion ?? this.religion,
      language: language ?? this.language,
      lookingFor: lookingFor ?? this.lookingFor,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      distance: distance ?? this.distance,
      interests: interests ?? this.interests,
      instagram: instagram ?? this.instagram,
      linkedin: linkedin ?? this.linkedin,
      facebook: facebook ?? this.facebook,
      x: x ?? this.x,
    );
  }
}
