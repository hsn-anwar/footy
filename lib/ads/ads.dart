import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final BannerAd myBanner = BannerAd(
  adUnitId: 'ca-app-pub-3940256099942544/6300978111',
  size: AdSize.banner,
  request: AdRequest(),
  listener: AdListener(),
);

final InterstitialAd myInterstitial = InterstitialAd(
  adUnitId: InterstitialAd.testAdUnitId,
  request: AdRequest(),
  listener: AdListener(),
);
