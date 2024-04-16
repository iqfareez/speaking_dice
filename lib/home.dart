import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/locale.dart' as intl;

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speaking_dice/models/country.dart';
import 'package:speaking_dice/models/tts_locale.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  FlutterTts flutterTts = FlutterTts();
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
  late final Animation<double> _animation = CurvedAnimation(
      parent: _controller, curve: Curves.fastLinearToSlowEaseIn);

  TtsLocale selectedLocale = TtsLocale(localeCode: 'en-US');
  bool ttsEnabled = true;
  int _dice = 1;

  Future<String?> tryParseCountryName(String countryCode) async {
    countryCode = countryCode.toLowerCase();

    final countriesJson =
        jsonDecode(await rootBundle.loadString('assets/countries.json'));

    final countries = Country.fromList(countriesJson);

    final name = countries
        .where((element) => element.alpha2 == countryCode)
        .firstOrNull
        ?.name;

    return name;
  }

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
            tooltip: 'Change language',
            onPressed: () async {
              final availableLanguagesInTts = await flutterTts.getLanguages;

              List<TtsLocale> namedLangs = [];
              List<TtsLocale> unNamedLangs = [];

              for (final lang in availableLanguagesInTts) {
                // try getting locale name\
                final parsedLocale = intl.Locale.tryParse(lang);

                if (parsedLocale == null) {
                  unNamedLangs.add(TtsLocale(localeCode: lang));
                  continue;
                }
                final parsedCountryCode = parsedLocale.countryCode;

                if (parsedCountryCode == null) {
                  unNamedLangs
                      .add(TtsLocale(localeCode: parsedLocale.toString()));
                  continue;
                }

                final name = await tryParseCountryName(parsedCountryCode);

                if (name != null) {
                  namedLangs.add(TtsLocale(
                      localeCode: parsedLocale.toString(), countryName: name));
                } else {
                  unNamedLangs
                      .add(TtsLocale(localeCode: parsedLocale.languageCode));
                }
              }

              // to arrange that the locale with country name comes first
              final List<TtsLocale> langOptions = [
                // sort from A-Z
                ...namedLangs..sort((a, b) => a.title.compareTo(b.title)),
                ...unNamedLangs
              ];

              // show dialog
              final TtsLocale? selectedTtsLocale = await showModalBottomSheet(
                context: context,
                builder: (_) {
                  return ListView.builder(
                    itemCount: langOptions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        selected: langOptions[index] == selectedLocale,
                        title: Text(langOptions[index].title),
                        onTap: () {
                          Navigator.pop(
                            context,
                            langOptions[index],
                          );
                        },
                      );
                    },
                  );
                },
              );

              if (selectedTtsLocale == null) return;
              var res =
                  await flutterTts.setLanguage(selectedTtsLocale.localeCode);
              setState(() {
                selectedLocale = selectedTtsLocale;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(res == 1
                      ? 'Language set to ${selectedTtsLocale.title}'
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
            Padding(
              padding: const EdgeInsets.all(64.0),
              child: RotationTransition(
                turns: _animation,
                child: Image.asset(
                  'assets/faces/$_dice.png',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade100
                      : null,
                ),
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
              },
            )
          ],
        ),
      ),
    );
  }
}
