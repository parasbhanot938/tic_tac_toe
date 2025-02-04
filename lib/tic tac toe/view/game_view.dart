import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:zero_kanti/constants/colors.dart';
import 'package:zero_kanti/tic%20tac%20toe/controller/game_controller.dart';

class GameView extends StatelessWidget {
  GameView({super.key});

  var controller = Get.put(GameController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      bottomNavigationBar: GetBuilder(
        init: GameController(),
        builder: (controller) {
          return controller.interstitialAd != null
              ? Container(
                  height: 50,
                  width: Get.width,
                  child: AdWidget(ad: controller.bannerAd!))
              : SizedBox();
        },
      ),
      appBar: _appBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [_boxView(), _confetti()],
          )
        ],
      ),
    );
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  _appBar() {
    return AppBar(
      centerTitle: true,
      leadingWidth: 90,
      leading: Row(
        children: [
          SizedBox(
            width: 20,
          ),
          Image.asset(
            'assets/delete-cross.png',
            height: 25,
            color: AppColors.crossColor,
          ),
          Image.asset(
            'assets/letter-o.png',
            height: 40,
            color: AppColors.OColor,
          ),
        ],
      ),
      title: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: AppColors.boxColor),
        child: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              controller.currentUser.value == controller.player_A
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
                "Turn",
                style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.bgColor,
      actions: [
        GestureDetector(
          onTap: () {
            // NotificationService.showSimpleNotification();

            controller.restartGame();
          },
          child: Container(
            margin: EdgeInsets.only(right: 20),
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: AppColors.textColor),
            child: Icon(
              Icons.refresh,
              color: Colors.black,
              size: 22,
            ),
          ),
        )
      ],
    );
  }

  _boxView() {
    return Column(
      children: [
        Obx(
          () => controller.points.value != 0
              ? Text(
                  "Points earned from ad: ${controller.points}",
                  style: TextStyle(color: AppColors.textColor),
                )
              : SizedBox(),
        ),
        SizedBox(
          height: 20,
        ),
        Obx(
          () => GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            itemCount: controller.occupied.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              // mainAxisExtent: 0.0,
            ),
            itemBuilder: (context, index) {
              return Center(
                  child: GestureDetector(
                onTap: () {
                  controller.startGame(index: index);
                },
                child: Container(
                  height: 200,
                  width: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.bgColor,
                          blurRadius: 2.0,
                          spreadRadius: 2.0,
                          offset: Offset(1, 2))
                    ],
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.boxColor,
                  ),
                  child: controller.occupied[index] == controller.player_A
                      ? Image.asset(
                          'assets/delete-cross.png',
                          height: Get.height * 0.1,
                          color: AppColors.crossColor,
                        )
                      : controller.occupied[index] == controller.player_B
                          ? Image.asset(
                              'assets/letter-o.png',
                              height: Get.height * 0.15,
                              color: AppColors.OColor,
                            )
                          : SizedBox(),
                ),
              ));
            },
          ),
        ),
      ],
    );
  }

  _confetti() {
    return Align(
      alignment: Alignment.center,
      child: ConfettiWidget(
        confettiController: controller.controllerCenter,
        blastDirectionality: BlastDirectionality.explosive,
        // don't specify a direction, blast randomly
        shouldLoop: true,
        // start again as soon as the animation is finished
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple
        ],
        // manually specify the colors to be used
        // createParticlePath: drawStar, // define a custom shape/path.
      ),
    );
  }
}
