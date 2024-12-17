part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  final String userId;

  LoadProfileEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UpdateProfileEvent extends ProfileEvent {
  final String userId;
  final Map<String, dynamic> updatedData;

  UpdateProfileEvent({required this.userId, required this.updatedData});

  @override
  List<Object> get props => [userId, updatedData];
}
