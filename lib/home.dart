import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  FlutterTts flutterTts = FlutterTts();
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
  late final Animation<double> _animation = CurvedAnimation(
      parent: _controller, curve: Curves.fastLinearToSlowEaseIn);
  int _dice = 1;
  @override
  Widget build(BuildContext context) {
    flutterTts.speak(_dice.toString());
    _controller.forward();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaking Dice'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _animation,
              child: Image.asset(
                'assets/faces/$_dice.png',
                width: 200,
              ),
            ),
            const SizedBox(height: 25),
            CupertinoButton.filled(
                child: const Text('Roll'),
                onPressed: () {
                  _controller.reset();

                  int newDice = Random().nextInt(6) + 1;
                  setState(() {
                    _dice = newDice;
                  });
                })
          ],
        ),
      ),
    );
  }
}
