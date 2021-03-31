import 'package:flutter/material.dart';
import 'package:footy/ads/ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdScreen extends StatefulWidget {
  static final String id = '/ad_screen';
  @override
  _AdScreenState createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  RewardedAd _rewardedAd;
  bool isBannerReady = false;
  bool _interstitialReady = false;
  bool _rewardedReady = false;

  int rewardEarned = 0;

  void createInterstitialAd() {
    _interstitialAd ??= InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      request: AdRequest(),
      listener: AdListener(
        onAdLoaded: (Ad ad) {
          print('${ad.runtimeType} loaded.');
          _interstitialReady = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('${ad.runtimeType} failed to load: $error.');
          ad.dispose();
          _interstitialAd = null;
          createInterstitialAd();
        },
        onAdOpened: (Ad ad) => print('${ad.runtimeType} onAdOpened.'),
        onAdClosed: (Ad ad) {
          print('${ad.runtimeType} closed.');
          ad.dispose();
          createInterstitialAd();
        },
        onApplicationExit: (Ad ad) =>
            print('${ad.runtimeType} onApplicationExit.'),
      ),
    )..load();
  }

  void createRewardedAd() {
    _rewardedAd ??= RewardedAd(
        adUnitId: RewardedAd.testAdUnitId,
        request: AdRequest(),
        listener: AdListener(
          onAdLoaded: (Ad ad) {
            print('${ad.runtimeType} loaded.');
            _rewardedReady = true;
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('${ad.runtimeType} failed to load: $error.');
            ad.dispose();
            _rewardedAd = null;
            createRewardedAd();
          },
          onAdOpened: (Ad ad) => print('${ad.runtimeType} onAdOpened.'),
          onAdClosed: (Ad ad) {
            print('${ad.runtimeType} closed.');
            ad.dispose();
            createRewardedAd();
          },
          onRewardedAdUserEarnedReward: (RewardedAd ad, RewardItem reward) {
            setState(() {
              rewardEarned += 1;
            });
            print(reward.type);
            print(reward.amount);
            print(rewardEarned);
          },
          onApplicationExit: (Ad ad) =>
              print('${ad.runtimeType} onApplicationExit.'),
        ))
      ..load();
  }

  final AdWidget adWidget = AdWidget(
      ad: BannerAd(
    adUnitId: 'ca-app-pub-3940256099942544/6300978111',
    size: AdSize.banner,
    request: AdRequest(),
    listener: AdListener(),
  ));

  @override
  void initState() {
    createInterstitialAd();
    createRewardedAd();
    super.initState();
  }

  @override
  void dispose() {
    myBanner.dispose();

    _rewardedAd.dispose();
    _interstitialAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ad'),
      ),
      bottomNavigationBar: Container(
        // height: adSize,
        color: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          child: adWidget,
          width: myBanner.size.width.toDouble(),
          height: myBanner.size.height.toDouble(),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                if (!_interstitialReady) return;
                _interstitialAd.show();
                _interstitialReady = false;
                _interstitialAd = null;
              },
              child: Text('Show InterstitialAd'),
            ),
            Text("Reward: $rewardEarned"),
            ElevatedButton(
              onPressed: () async {
                if (!_rewardedReady) return;
                _rewardedAd.show();
                _rewardedReady = false;
                _rewardedAd = null;
              },
              child: Text('Show RewardedAd'),
            ),
          ],
        ),
      ),
    );
  }
}
