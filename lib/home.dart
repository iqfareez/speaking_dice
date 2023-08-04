import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
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
  String language = 'en-US';
  bool ttsEnabled = true;
  int _dice = 1;

  @override
  Widget build(BuildContext context) {
    _controller.forward();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaking Dice'),
        actions: [
          const Text('TTS'),
          Switch(
              value: ttsEnabled,
              onChanged: (newValue) {
                setState(() {
                  ttsEnabled = newValue;
                });
              }),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () async {
              final availableLanguages = await flutterTts.getLanguages;

              final langOptions = availableLanguages
                  .map((e) => LocaleNames.of(context)?.nameOf(e) ?? e)
                  .toList();

              // show dialog
              var selectedLang = await showDialog(
                context: context,
                builder: (_) => SimpleDialog(
                  children: [
                    for (var lang in langOptions)
                      SimpleDialogOption(
                        child: Text(lang),
                        onPressed: () => Navigator.pop(context, lang),
                      )
                  ],
                ),
              );

              if (selectedLang == null) return;
              var res = await flutterTts.setLanguage(selectedLang);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(res == 1
                      ? 'Language set to $selectedLang'
                      : 'Error setting up language'),
                ),
              );
            },
          )
        ],
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
                  setState(() => _dice = newDice);
                  if (ttsEnabled) flutterTts.speak(_dice.toString());
                })
          ],
        ),
      ),
    );
  }
}
