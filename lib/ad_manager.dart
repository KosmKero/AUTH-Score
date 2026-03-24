import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'globals.dart';

class SmartBanner extends StatefulWidget {

  static final String bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-1918416043234880/2473426532' //ca-app-pub-1918416043234880/2473426532  == ΤΟ ΔΙΚΟ ΜΑΣ   ca-app-pub-3940256099942544/6300978111 == ΤΟ ΤΕΣΤΙΝΚ
      : 'ca-app-pub-1918416043234880/9422859440';

  final bool hasSponsor;
  final String? sponsorImageUrl;
  final String? sponsorLink;

  const SmartBanner({
    super.key,
    required this.hasSponsor,
    this.sponsorImageUrl,
    this.sponsorLink,
  });

  @override
  State<SmartBanner> createState() => _SmartBannerState();
}

class _SmartBannerState extends State<SmartBanner> {
  BannerAd? _adMobBanner;
  bool _isAdMobLoaded = false;

  @override
  void initState() {
    super.initState();
    // Αν δεν έχουμε χορηγό, ξεκίνα την AdMob
    if (!widget.hasSponsor) {
      _initAdMob();
    }
  }

  void _initAdMob() {
    _adMobBanner = BannerAd(
      adUnitId: SmartBanner.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isAdMobLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          //print('AdMob failed: $error');
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    // 1. ΠΕΡΙΠΤΩΣΗ ΧΟΡΗΓΟΥ
    if (widget.hasSponsor && widget.sponsorImageUrl != null && widget.sponsorImageUrl!.isNotEmpty) {
      return GestureDetector(
        onTap: () async {
          if (widget.sponsorLink != null) {
            final url = Uri.parse(widget.sponsorLink!);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          }
        },
        child: CachedNetworkImage(
          imageUrl: widget.sponsorImageUrl!,
          placeholder: (context, url) => Container(height: 60, color: Colors.grey[200]),
          imageBuilder: (context, imageProvider) => Container(
            width: double.infinity,
            height: 60, // 320x100
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
        ),
      );
    }




    // 2. ΠΕΡΙΠΤΩΣΗ ADMOB
    if (_isAdMobLoaded && _adMobBanner != null) {
      return Container(
       color: darkModeNotifier.value ? Color(0xFF121212) : lightModeBackGround,
        alignment: Alignment.center,
        width: double.infinity.toDouble(),
        height: _adMobBanner!.size.height.toDouble(),
        child: AdWidget(ad: _adMobBanner!),
      );
    }

    // 3. ΤΙΠΟΤΑ
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _adMobBanner?.dispose();
    super.dispose();
  }
}

class AdManager {

// === Ad Unit IDs ===

  static final String bannerAdUnitId = Platform.isAndroid

      ?'ca-app-pub-1918416043234880/2473426532' //ca-app-pub-1918416043234880/2473426532 == ΤΟ ΔΙΚΟ ΜΑΣ ca-app-pub-3940256099942544/6300978111 == ΤΟ ΤΕΣΤΙΝΚ

      : 'ca-app-pub-1918416043234880/9422859440';



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