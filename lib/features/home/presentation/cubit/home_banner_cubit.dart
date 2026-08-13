import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/feature_flags/feature_flag.dart';
import 'package:flutter_enterprise_starter_kit/core/feature_flags/feature_flags.dart';
import 'package:flutter_enterprise_starter_kit/features/home/presentation/cubit/home_banner_state.dart';

class HomeBannerCubit extends Cubit<HomeBannerState> {
  HomeBannerCubit(this._featureFlags)
    : super(
        HomeBannerState(
          isEnabled: _featureFlags.isEnabled(FeatureFlag.homeBanner),
          overrideValue: _featureFlags.overrideFor(FeatureFlag.homeBanner),
        ),
      );

  final FeatureFlags _featureFlags;

  /// Pass `null` to clear the override and go back to following the remote
  /// value.
  Future<void> setOverride({required bool? value}) async {
    await _featureFlags.setOverride(FeatureFlag.homeBanner, value: value);
    emit(
      HomeBannerState(
        isEnabled: _featureFlags.isEnabled(FeatureFlag.homeBanner),
        overrideValue: value,
      ),
    );
  }
}
