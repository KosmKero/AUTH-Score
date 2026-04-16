import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

class SmartBanner extends StatelessWidget {
  final bool hasSponsor;
  final String? sponsorImageUrl;
  final String? sponsorLink;
  final String sponsorName;
  final double height;
  final VoidCallback? onCustomTap;

  final Color? customBgColor;

  const SmartBanner({
    super.key,
    required this.hasSponsor,
    this.sponsorName = "General_Sponsor",
    this.sponsorImageUrl,
    this.sponsorLink,
    this.height = 60.0,
    this.onCustomTap,
    required this.customBgColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasSponsor || sponsorImageUrl == null || sponsorImageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    // ΚΑΤΑΓΡΑΦΗ IMPRESSION
    FirebaseAnalytics.instance.logEvent(
      name: 'sponsor_impression',
      parameters: {'sponsor_id': sponsorName},
    );

    return GestureDetector(
      onTap: () async {
        // ΚΑΤΑΓΡΑΦΗ CLICK
        await FirebaseAnalytics.instance.logEvent(
          name: 'sponsor_click',
          parameters: {'sponsor_id': sponsorName},
        );

        // Αν έχω εσωτερική πλοήγηση (π.χ. για το Top 20)
        if (onCustomTap != null) {
          onCustomTap!();
        }
        // 2.Για εξωτερικό link, το ανοίγουμε στον browser
        else if (sponsorLink != null && sponsorLink!.isNotEmpty) {
          final url = Uri.parse(sponsorLink!);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: height,
        // Χρησιμοποιείς το darkModeNotifier όπως και στην HomePage!
        color: customBgColor,
        child: CachedNetworkImage(
          imageUrl: sponsorImageUrl!,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        ),
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