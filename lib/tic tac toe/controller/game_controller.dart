import 'dart:ffi';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zero_kanti/constants/colors.dart';
import 'package:zero_kanti/utils/notification_service.dart';

class GameController extends GetxController {
  var player_A = "X";
  var player_B = "O";
  RxString currentUser = "".obs;
  var points = 0.obs;

  BannerAd? bannerAd;
  RewardedAd? rewardedAd;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  InterstitialAd? interstitialAd;

  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String rewardedAdId = 'ca-app-pub-3940256099942544/5224354917';

  var isGameEnd = false.obs;

  var occupied = List.filled(9, "").obs;

  ConfettiController controllerCenter =
      ConfettiController(duration: const Duration(seconds: 10));

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    NotificationService.showPeriodicNotification();

    // NotificationService.
    // simpleNotification("Tic Tac Toe","hi");
    bluetoothPerm();
    currentUser.value = player_A;
    currentUser.refresh();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    bannerAd?.dispose();
  }

  void createRewardedAd() {
    RewardedAd.load(
        adUnitId: rewardedAdId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint("onAdLoaded--> ${ad}");

            rewardedAd = ad;
            update();
            _showRewardedAd();
          },
          onAdFailedToLoad: (error) {
            debugPrint("error--> ${error}");
          },
        ));
  }

  void _showRewardedAd() {
    if (rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _showRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _showRewardedAd();
      },
    );

    rewardedAd!.setImmersiveMode(true);
    rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
      points = points + int.parse(reward.amount.toString());
      points.refresh();
    });
    rewardedAd = null;
  }

  startGame({index}) {
    if (isGameEnd.value || occupied[index].isNotEmpty) return;
    occupied.value[index] = currentUser.value;
    occupied.refresh();
    changeUser(index: index);
    checkWinnner(index: index);
    drawMatch();
  }

  void changeUser({index}) {
    if (occupied[index] == player_A) {
      currentUser(player_B);
    } else {
      currentUser(player_A);
    }
  }

  Future<void> checkWinnner({index}) async {
    List<List<int>> winningCombos = [
      [0, 1, 2],
      [0, 3, 6],
      [0, 4, 8],
      [1, 4, 7],
      [2, 5, 8],
      [2, 4, 6],
      [6, 7, 8],
      [2, 5, 8],
      [3, 4, 5],
    ];

    for (var winningPos in winningCombos) {
      var pos0 = occupied[winningPos[0]];
      var pos1 = occupied[winningPos[1]];
      var pos2 = occupied[winningPos[2]];
      if (pos0.isNotEmpty) {
        if (pos0 == pos1 && pos0 == pos2) {
          isGameEnd(true);

          Get.dialog(Dialog(
            backgroundColor: AppColors.bgColor,
            child: Container(
              height: Get.height * 0.2,
              width: Get.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      pos0 == player_A
                          ? Image.asset(
                              'assets/delete-cross.png',
                              height: 18,
                              color: AppColors.textColor,
                            )
                          : Image.asset(
                              'assets/letter-o.png',
                              height: 20,
                              color: AppColors.textColor,
                            ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "wins !",
                        style: TextStyle(
                            fontSize: 18.0,
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Get.height * 0.02,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      restartGame();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.boxColor),
                      child: Text(
                        "Restart",
                        style: TextStyle(
                            fontSize: 16.0,
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              // Text("${pos0} wins !")
              );
          // showWinnerSnackbar(name: pos0);
          controllerCenter.play();
          await Future.delayed(Duration(seconds: 2));
          controllerCenter.stop();
          return;
        }
      }
    }
  }

  restartGame() {
    currentUser(player_A);
    isGameEnd(false);
    occupied.value = List.filled(9, "");
    occupied.refresh();
    createRewardedAd();
    _showRewardedAd();
  }

  void drawMatch() {
    if (isGameEnd.value == true) return;

    bool draw = true;

    for (var occupiedPos in occupied) {
      if (occupiedPos.isEmpty) {
        draw = false;
      }
    }

    if (draw == true) {
      Get.dialog(Dialog(
        backgroundColor: AppColors.bgColor,
        child: Container(
          height: Get.height * 0.2,
          width: Get.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Match Draw",
                style: TextStyle(
                    fontSize: 18.0,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: Get.height * 0.02,
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                  restartGame();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.boxColor),
                  child: Text(
                    "Restart",
                    style: TextStyle(
                        fontSize: 16.0,
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
      isGameEnd(true);

      // Get.snackbar(
      //   backgroundColor: AppColors.boxColor,
      //   colorText: AppColors.textColor,
      //   snackPosition: SnackPosition.BOTTOM,
      //   "Tic Tac Toe",
      //   "Draw",
      // );
    }
  }

  void showWinnerSnackbar({name}) {
    Get.snackbar(
      backgroundColor: AppColors.boxColor,
      colorText: AppColors.textColor,
      snackPosition: SnackPosition.BOTTOM,
      "Tic Tac Toe",
      "${name} wins ! ",
    );
  }

  void bluetoothPerm() async {
    await Permission.bluetooth.request();
    var status = await Permission.bluetooth.status;

    if (status.isGranted) {
      createRewardedAd();
      createBannerAd();
    }
  }

  void createBannerAd() {
    bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.fullBanner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('BannerAd loaded.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('BannerAd failed to load: $error');
        },
      ),
    );
    update();
    bannerAd?.load();
  }
}
