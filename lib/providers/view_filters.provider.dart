import 'package:hooks_riverpod/legacy.dart';

// Gardens View Filters
final gardenBusinessFilterProvider = StateProvider<Set<String>>((ref) => {});

// Channels View Filters
final channelBusinessFilterProvider = StateProvider<Set<String>>((ref) => {});

// Machine Candidates View Filters
final candidateBusinessFilterProvider = StateProvider<Set<String>>((ref) => {});
