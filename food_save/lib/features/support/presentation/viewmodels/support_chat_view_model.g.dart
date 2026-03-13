// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_chat_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supportRepositoryHash() => r'a993505e0e87008beb7366004e0215460782a6d0';

/// See also [supportRepository].
@ProviderFor(supportRepository)
final supportRepositoryProvider =
    AutoDisposeProvider<SupportRepository>.internal(
      supportRepository,
      name: r'supportRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$supportRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupportRepositoryRef = AutoDisposeProviderRef<SupportRepository>;
String _$supportChatViewModelHash() =>
    r'6bd30125727dd8b0d4bd2bf00194791ea91b0f39';

/// See also [SupportChatViewModel].
@ProviderFor(SupportChatViewModel)
final supportChatViewModelProvider =
    AutoDisposeNotifierProvider<
      SupportChatViewModel,
      AsyncValue<List<Map<String, dynamic>>>
    >.internal(
      SupportChatViewModel.new,
      name: r'supportChatViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$supportChatViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SupportChatViewModel =
    AutoDisposeNotifier<AsyncValue<List<Map<String, dynamic>>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
