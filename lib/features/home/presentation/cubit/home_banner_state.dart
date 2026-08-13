import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_banner_state.freezed.dart';

@freezed
sealed class HomeBannerState with _$HomeBannerState {
  const factory HomeBannerState({
    required bool isEnabled,
    required bool? overrideValue,
  }) = _HomeBannerState;
}
