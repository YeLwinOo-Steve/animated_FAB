import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show radians;

import '../resource/const.dart';

class RadialMenu extends StatefulWidget {
  // will take in list of buttons
  final List<RadialButton> children;

  // used for positioning the widget
  final AlignmentGeometry centerButtonAlignment;

  // set main button size
  final double centerButtonSize;

  /// Track state of clover button
  final bool isOpen;

  /// Tap clover button
  final VoidCallback onTap;
  RadialMenu(
      {Key? key,
      required this.children,
      this.centerButtonSize = 0.2,
      required this.isOpen,
      required this.onTap,
      this.centerButtonAlignment = Alignment.center})
      : super(key: key);

  createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu>
    with SingleTickerProviderStateMixin {
  // used to control animations
  AnimationController? controller;

  // controller gets initialized here
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.centerButtonAlignment,
      child: SizedBox(
        width: 400,
        height: 400,
        child: RadialAnimation(
          onTap: widget.onTap,
          isOpen: widget.isOpen,
          controller: controller!,
          radialButtons: widget.children,
          centerSizeOfButton: widget.centerButtonSize,
        ),
      ),
    );
  }

  // controller gets disposed here
  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}

// Here all the animation will take place
class RadialAnimation extends StatelessWidget {
  /// if clover is open, close it or else open it
  final VoidCallback onTap;
  final bool isOpen;
  RadialAnimation(
      {Key? key,
      required this.onTap,
      required this.isOpen,
      required this.controller,
      required this.radialButtons,
      this.centerSizeOfButton = 0.5})
      :
        // translation animation
        translation = Tween<double>(
          begin: 0.0,

          /// TODO: Change this value if you want to set more distance of radial buttons
          end: 140.0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
        ),

        // scaling animation
        scale = Tween<double>(
          begin: centerSizeOfButton * 2,
          end: 0.0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
        ),

        // rotation animation
        rotation = Tween<double>(
          begin: -270.0,
          end: -180.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.0,
              0.5,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        super(key: key);

  final AnimationController controller;
  final Animation<double> rotation;
  final Animation<double> translation;
  final Animation<double> scale;
  final List<RadialButton> radialButtons;
  final double centerSizeOfButton;

  @override
  Widget build(BuildContext context) {
    // will provide angle for further calculation
    ///For 6 buttons, this is perfectly working
    double generatedAngle = 360 / (radialButtons.length);
    double iconAngle;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, widget) {
        return Transform.rotate(
          angle: radians(rotation.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // generates list of buttons
              ...radialButtons.map(
                (index) {
                  ///TODO: Change this icon angle if Number of buttons are more than or less than 6
                  /// assert( numOfButtons == 6 );
                  iconAngle = radialButtons.indexOf(index) * generatedAngle;
                  return _buildButton(
                    iconAngle,
                    color: index.buttonColor,
                    text: index.text,
                    onPress: index.onPress,
                  );
                },
              ),
              Transform.rotate(
                angle: radians(rotation.value),
                child: GestureDetector(
                  onTap: () {
                    isOpen ? close() : open();
                    onTap();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Image.asset(
                      clover,
                      scale: 4,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // will show child buttons
  void open() {
    controller.forward();
  }

  // will hide child buttons
  void close() {
    controller.reverse();
  }

  // build custom child buttons
  Widget _buildButton(double angle,
      {Function? onPress, Color? color, String? text}) {
    final double rad = radians(angle);
    return Transform(
      transform: Matrix4.identity()
        ..translate(
            (translation.value) * cos(rad), (translation.value) * sin(rad)),
      child: AnimatedOpacity(
        opacity: checkOpacity(translation.value),
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: () {
            onPress!();
            close();
          },
          child: Container(

              ///TODO: Change this value to set size of radial buttons
              width: 100,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 5.0),
              child: Transform.rotate(
                /// Value of Pi is 180 degrees
                angle: pi,
                child: Text(
                  text!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              )),
        ),
      ),
    );
  }

  /// If Clover is closed, radial buttons are invisible
  double checkOpacity(double value) {
    if (value < 10) {
      return 0.0;
    } else if (value < 30) {
      return 0.2;
    } else if (value < 40) {
      return 0.5;
    } else if (value < 50) {
      return 0.8;
    } else {
      return 1;
    }
  }
}

class RadialButton {
  // background colour of the button surrounding the icon
  final Color buttonColor;

  // sets icon of the child buttons
  final String text;

  // onPress function of the child buttons
  final Function onPress;

  // constructor for child buttons
  RadialButton(
      {this.buttonColor = Colors.green,
      required this.text,
      required this.onPress});
}
