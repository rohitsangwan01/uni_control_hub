import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:uni_control_hub/app/data/app_data.dart';

// https://app.lottiefiles.com/animation/16f4c897-ab88-4ca1-8d1b-d77e9a9cac09?channel=web&source=public-animation&panel=download
class MouseAnim extends StatelessWidget {
  const MouseAnim({super.key});

  @override
  Widget build(BuildContext context) {
    // Layers:  Click, Mouse, Wire
    return LottieBuilder.asset(
      AppAssets.mouseAnim,
      height: 200,
    );
  }
}
