import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_analytics/firebase_analytics.dart'; // Βεβαιώσου ότι το έχεις κάνει import

class SmartBanner extends StatelessWidget {
  final bool hasSponsor;
  final String? sponsorImageUrl;
  final String? sponsorLink;
  final String sponsorName; // Πρόσθεσε όνομα για να ξέρεις ποιος είναι ο χορηγός

  const SmartBanner({
    super.key,
    required this.hasSponsor,
    this.sponsorName = "General_Sponsor", // Default όνομα
    this.sponsorImageUrl,
    this.sponsorLink,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasSponsor || sponsorImageUrl == null || sponsorImageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    // ΚΑΤΑΓΡΑΦΗ IMPRESSION (Μόλις χτιστεί το widget)
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

        if (sponsorLink != null && sponsorLink!.isNotEmpty) {
          final url = Uri.parse(sponsorLink!);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        }
      },
          child: CachedNetworkImage(
            imageUrl: sponsorImageUrl!,
            height: 60,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 60,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) => const SizedBox.shrink(),
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