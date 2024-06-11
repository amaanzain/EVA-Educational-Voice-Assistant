import 'package:first_app/components/db.dart';
import 'package:first_app/controllers/controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helpers/colors.dart';
import '../pages/answer_page.dart';
import './rec.dart';

class ShapeScreen extends StatefulWidget {
  ShapeScreen({Key? key, required this.context}) : super(key: key);
  final DbModule dbModule = DbModule();
  final BuildContext context;

  @override
  State<ShapeScreen> createState() => _ShapeScreenState();
}

class _ShapeScreenState extends State<ShapeScreen>
    with TickerProviderStateMixin {
  /// when playing, animation will be played
  final HomeController homeController = Get.find();
  bool playing = false;
  late final Rec rec;

  /// animation controller for the play pause button
  late AnimationController _playPauseAnimationController;

  /// animation & animation controller for the top-left and bottom-right bubbles
  late Animation<double> _topBottomAnimation;
  late AnimationController _topBottomAnimationController;

  /// animation & animation controller for the top-right and bottom-left bubbles
  late Animation<double> _leftRightAnimation;
  late AnimationController _leftRightAnimationController;

  @override
  void initState() {
    super.initState();
    rec = Rec(context: widget.context);
    // rec.initRecorder();
    _playPauseAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _topBottomAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _leftRightAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _topBottomAnimation = CurvedAnimation(
            parent: _topBottomAnimationController, curve: Curves.decelerate)
        .drive(Tween<double>(begin: 5, end: -5));
    _leftRightAnimation = CurvedAnimation(
            parent: _leftRightAnimationController, curve: Curves.easeInOut)
        .drive(Tween<double>(begin: 5, end: -5));

    _leftRightAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _leftRightAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _leftRightAnimationController.forward();
      }
    });

    _topBottomAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _topBottomAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _topBottomAnimationController.forward();
      }
    });
    if (homeController.micTurnedOn.value) {
      micButtonLogic();
    }
  }

  @override
  void dispose() {
    _playPauseAnimationController.dispose();
    _topBottomAnimationController.dispose();
    _leftRightAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = 200;
    double height = 200;

    return Padding(
      padding: const EdgeInsets.only(top: 100, left: 50),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // bottom right dark pink
            AnimatedBuilder(
              animation: _topBottomAnimation,
              builder: (context, _) {
                return Positioned(
                  bottom: _topBottomAnimation.value,
                  right: _topBottomAnimation.value,
                  child: Container(
                    width: width * 0.9,
                    height: height * 0.9,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [pink, blue],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: pink.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // top left pink
            AnimatedBuilder(
                animation: _topBottomAnimation,
                builder: (context, _) {
                  return Positioned(
                    top: _topBottomAnimation.value,
                    left: _topBottomAnimation.value,
                    child: Container(
                      width: width * 0.9,
                      height: height * 0.9,
                      decoration: BoxDecoration(
                        color: pink.withOpacity(0.5),
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [pink, blue],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: playing
                            ? [
                                BoxShadow(
                                  color: pink.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  );
                }), // light pink
            // bottom left blue
            AnimatedBuilder(
                animation: _leftRightAnimation,
                builder: (context, _) {
                  return Positioned(
                    bottom: _leftRightAnimation.value,
                    left: _leftRightAnimation.value,
                    child: Container(
                      width: width * 0.9,
                      height: height * 0.9,
                      decoration: BoxDecoration(
                        color: blue,
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [pink, blue],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: blue.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            // top right dark blue
            AnimatedBuilder(
              animation: _leftRightAnimation,
              builder: (context, _) {
                return Positioned(
                  top: _leftRightAnimation.value,
                  right: _leftRightAnimation.value,
                  child: Container(
                    width: width * 0.9,
                    height: height * 0.9,
                    decoration: BoxDecoration(
                      color: blue,
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [pink, blue],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: playing
                          ? [
                              BoxShadow(
                                color: blue.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ]
                          : [],
                    ),
                  ),
                );
              },
            ),
            // play button
            GestureDetector(
              onTap: () {
                micButtonLogic();
                // homeController.updateMicTurnedOn(false);
              },
              child: Container(
                width: width,
                height: height,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Image(image: AssetImage("assets/mic_icon.png")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void micButtonLogic() {
    playing = !playing;
    //mic working
    homeController.updateRecordingStatus(playing);
    homeController.updateIsQueryReady(true);
    //ends here
    startReording();
    if (playing) {
      _playPauseAnimationController.forward();
      _topBottomAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
        _leftRightAnimationController.forward();
      });
    } else {
      _playPauseAnimationController.reverse();
      _topBottomAnimationController.reset();
      _leftRightAnimationController.reset();
      _topBottomAnimationController.stop();
      _leftRightAnimationController.stop();
    }
  }

  void startReording() async {
    print("here");
    await rec.recordMic();
    homeController.updateIsQueryReady(false);
    // if (widget.homeController.isQueryReady.value == true) {
    //   widget.dbModule.testDB();
    // }
    print(homeController.isAnswerReady.value);
    if (homeController.isAnswerReady.value == true) {
      print("Answer is ready");

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AnswerPage()));
    }
  }
}
