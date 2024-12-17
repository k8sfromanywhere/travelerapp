import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseFirestore firestore;

  ProfileBloc({required this.firestore}) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
      LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final doc = await firestore.collection('users').doc(event.userId).get();
      if (doc.exists) {
        emit(ProfileLoaded(userData: doc.data()!));
      } else {
        emit(ProfileError(message: "User not found"));
      }
    } catch (error) {
      emit(ProfileError(message: error.toString()));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await firestore
          .collection('users')
          .doc(event.userId)
          .update(event.updatedData);
      emit(ProfileUpdated());
      add(LoadProfileEvent(userId: event.userId));
    } catch (error) {
      emit(ProfileError(message: error.toString()));
    }
  }
}
