import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AdManager {
  // === Ad Unit IDs ===
  static final String bannerAdUnitId = Platform.isAndroid
      ?'ca-app-pub-1918416043234880/2473426532' //ca-app-pub-1918416043234880/2473426532  == ΤΟ ΔΙΚΟ ΜΑΣ   ca-app-pub-3940256099942544/6300978111 == ΤΟ ΤΕΣΤΙΝΚ
      : 'ca-app-pub-1918416043234880/8698889690';

  static final String nativeAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-1918416043234880/7386007711'
      : 'ca-app-pub-1918416043234880/8698889690';

  // === Banner Ad ===
  static BannerAd createBannerAd({Function(bool)? onStatusChanged}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('Banner loaded');
          if (onStatusChanged != null) {
            onStatusChanged(true);
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Banner failed to load: $error');
          if (onStatusChanged != null) {
            onStatusChanged(false);
          }
          ad.dispose();
        },
      ),
    );
  }

  // === Native Ad ===
  static NativeAd loadNativeAd(VoidCallback onLoaded, Function(LoadAdError) onFailed) {
    return NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: 'listTile', // το id που θα ορίσεις στην native πλευρά
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('Native ad loaded');
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          print('Native ad failed to load: $error');
          ad.dispose();
          onFailed(error);
        },
      ),
    );
  }
}
Future<void> initTracking() async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await Future.delayed(const Duration(milliseconds: 200));
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}
