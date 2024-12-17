import 'package:equatable/equatable.dart';

class AttractionsState extends Equatable {
  final bool isLoading;
  final List attractions;
  final String error;

  const AttractionsState({
    required this.isLoading,
    required this.attractions,
    required this.error,
  });

  factory AttractionsState.initial() {
    return const AttractionsState(
      isLoading: false,
      attractions: [],
      error: '',
    );
  }

  AttractionsState copyWith({
    bool? isLoading,
    List? attractions,
    String? error,
  }) {
    return AttractionsState(
      isLoading: isLoading ?? this.isLoading,
      attractions: attractions ?? this.attractions,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, attractions, error];
}
